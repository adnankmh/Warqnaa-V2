<?php

namespace Tests\Feature;

use App\Models\{StoreItem, User};
use App\Services\Admin\PrimaryAdminStateService;
use App\Services\GameEngine\{GameFactory, GlobalCardEngineRules};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36RequestedGameplayFixesTest extends TestCase
{
    use RefreshDatabase;

    public function test_real_banakil_factory_advertises_and_applies_fire_stack_without_losing_cards(): void
    {
        $engine = GameFactory::make('banakil');
        $this->assertInstanceOf(GlobalCardEngineRules::class, $engine);
        $state = $engine->initialState(['user:1','user:2','user:3','user:4'], ['seed'=>3701]);
        $g = $state['_global_engine'];
        $g['currentIndex'] = 0;
        $g['phase'] = 'draw';
        $g['starterDiscardPending'] = false;
        $g['discard'] = array_merge($g['discard'], array_splice($g['deck'], 0, 4));
        $state['_global_engine'] = $g;
        $state['turn'] = 'user:1';
        $pile = $g['discard'];
        $before = $this->cards($g);
        $this->assertSame(count($pile), collect($engine->availableActions($state, 'user:1'))->firstWhere('type','draw_discard_stack')['max_count']);
        $this->assertFalse($engine->validate($state, 'user:2', 'draw_discard_stack', ['count'=>2]));
        foreach ([0,1,count($pile)+1] as $count) {
            $this->assertFalse($engine->validate($state, 'user:1', 'draw_discard_stack', ['count'=>$count]));
        }
        $this->assertTrue($engine->validate($state, 'user:1', 'draw_discard_stack', ['count'=>3]));
        $next = $engine->apply($state, 'user:1', 'draw_discard_stack', ['count'=>3]);
        $after = $next['_global_engine'];
        $this->assertArrayNotHasKey('last_error', $next);
        $this->assertSame(array_slice($pile,0,-3), $after['discard']);
        $this->assertSame(array_merge($g['hands']['user:1'],array_slice($pile,-3)), $after['hands']['user:1']);
        $this->assertSame($before, $this->cards($after));
        $this->assertFalse($engine->validate($next, 'user:1', 'draw_discard_stack', ['count'=>2]));
    }

    public function test_hand_does_not_inherit_banakil_stack_pickup(): void
    {
        $engine = GameFactory::make('hand');
        $state = $engine->initialState(['user:1','user:2'], ['seed'=>3702]);
        $state['_global_engine']['phase'] = 'draw';
        $state['_global_engine']['currentIndex'] = 0;
        $state['turn'] = 'user:1';
        $this->assertFalse($engine->validate($state, 'user:1','draw_discard_stack',['count'=>2]));
    }

    public function test_live_banakil_bot_keeps_a_connected_card_and_takes_a_useful_discard(): void
    {
        GameFactory::make('banakil'); // Load the production engine classes.
        $engine = new class extends \BanakilEngine {
            public function choose(array $state,array $actions): array {
                return $this->chooseBotAction($state,'user:1',$actions);
            }
        };
        $state=$engine->newGame([
            ['id'=>'user:1'],['id'=>'user:2'],['id'=>'user:3'],['id'=>'user:4'],
        ],['seed'=>3703]);
        $state['currentIndex']=0;
        $state['hands']['user:1']=['5_C','6_C','JOKER_R','K_D'];
        $state['phase']='discard';
        $choice=$engine->choose($state,[
            ['type'=>'discard','card'=>'5_C'],['type'=>'discard','card'=>'6_C'],
            ['type'=>'discard','card'=>'JOKER_R'],['type'=>'discard','card'=>'K_D'],
        ]);
        $this->assertSame('K_D',$choice['card']);
        $state['hands']['user:1']=['5_C','6_C','K_D'];
        $state['phase']='draw';
        $state['discard']=['7_C'];
        $actions=[['type'=>'draw_deck'],['type'=>'draw_discard']];
        $this->assertSame('draw_discard',$engine->choose($state,$actions)['type']);
        $state['discard']=['3_H'];
        $this->assertSame('draw_deck',$engine->choose($state,$actions)['type']);
        // No opponent hand or face-down stock is inspected by the policy.
        $state['hands']['user:2']=['3_H','3_H','JOKER_B'];
        $state['deck']=array_reverse($state['deck']);
        $this->assertSame('draw_deck',$engine->choose($state,$actions)['type']);
    }

    public function test_bootstrap_exposes_exact_tokens_full_permissions_and_more_than_200_owned_items(): void
    {
        $admin = User::factory()->create(['is_admin'=>true,'admin_role'=>'primary_admin']);
        for ($i=0;$i<205;$i++) {
            StoreItem::create(['key'=>'r36_owned_'.$i,'category'=>'card_back','name'=>['ar'=>'ورق','en'=>'Cards'], 'price'=>1,'active'=>true,'payload'=>[]]);
        }
        $admin = app(PrimaryAdminStateService::class)->enforce($admin);
        $this->withToken($admin->createToken('r36')->plainTextToken)
            ->getJson('/api/mobile/v1/bootstrap')
            ->assertOk()
            ->assertJsonPath('wallet.tokens','9999999999999999999')
            ->assertJsonPath('wallet.tokens_formatted','9,999,999,999,999,999,999')
            ->assertJsonPath('user.admin_permissions.all',true)
            ->assertJson(fn($json) => $json->where('inventory',fn($rows)=>count($rows)>200)->etc());
        $this->assertSame('9,999,999,999,999,999,999',token_display($admin));
        $this->assertSame('9999999999999999999',$admin->displayTokenBalance());
    }

    private function cards(array $g): array
    {
        $cards = array_merge($g['deck'], $g['discard'], ...array_values($g['hands']));
        sort($cards);
        return $cards;
    }

    public function test_bootstrap_restores_the_active_booster_and_rejects_an_expired_multiplier(): void
    {
        $user=User::factory()->create();
        $profile=$user->profile()->firstOrCreate(['user_id'=>$user->id],['display_name'=>$user->username]);
        $expiry=now()->addHour();
        $profile->update(['xp_boost_multiplier'=>3.25,'xp_boost_expires_at'=>$expiry]);
        $token=$user->createToken('r36-boost')->plainTextToken;
        $this->withToken($token)->getJson('/api/mobile/v1/bootstrap')->assertOk()
            ->assertJsonPath('user.xp_boost_multiplier',3.25)
            ->assertJsonPath('user.xp_boost_expires_at',$expiry->toIso8601String());
        $profile->update(['xp_boost_expires_at'=>now()->subSecond()]);
        $this->withToken($token)->getJson('/api/mobile/v1/bootstrap')->assertOk()
            ->assertJsonPath('user.xp_boost_multiplier',1);
    }

    public function test_individual_hand_allows_laying_off_on_other_players_but_banakil_keeps_partnership_scope(): void
    {
        foreach(['hand'=>true,'saudi_hand'=>true,'banakil'=>false] as $game=>$allowed) {
            $engine=GameFactory::make($game);
            $state=$engine->initialState(['user:1','user:2','user:3','user:4'],['seed'=>3704]);
            $g=$state['_global_engine'];$g['phase']='discard';$g['currentIndex']=0;$g['starterDiscardPending']=false;
            $g['hands']['user:1']=['8_C','K_H'];
            $g['melds']['user:1']=[['cards'=>['9_D','10_D','J_D'],'value'=>29]];
            $g['melds']['user:2']=[['cards'=>['5_C','6_C','7_C'],'value'=>18]];
            $state['_global_engine']=$g;$state['turn']='user:1';
            $state['hands']['user:1']=['8_clubs','K_hearts'];
            $payload=['target_player'=>'user:2','meld_index'=>0,'cards'=>['8_clubs']];
            $this->assertSame($allowed,$engine->validate($state,'user:1','layoff',$payload),$game);
        }
    }
}
