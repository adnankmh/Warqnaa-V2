<?php

namespace Tests\Feature;

use App\Models\{CompetitionTicket,InventoryItem,Profile,User,Wallet};
use App\Services\WarqnaPro\PrizeBoxService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class R53PrizePresentationBoundaryTest extends TestCase
{
    use RefreshDatabase;

    public function test_animation_metadata_cannot_choose_a_reward_or_open_it_twice(): void
    {
        $user=User::create(['username'=>'R53Player','email'=>'r53@example.test',
            'password'=>Hash::make(bin2hex(random_bytes(16))),'is_admin'=>false]);
        Profile::create(['user_id'=>$user->id,'display_name'=>'R53Player','level'=>1,'xp'=>0]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>1000,'gems'=>0]);
        $box=app(PrizeBoxService::class)->awardForCompletedGame($user,'r53-presentation','hand','normal',true);
        $this->withToken($user->createToken('r53')->plainTextToken);
        $endpoint='/api/mobile/v1/prize-boxes/'.$box->id.'/open';
        $payload=['animation_skipped'=>true,'animation_completed'=>true,
            'reward'=>['type'=>'untrusted_client_reward','value'=>999999999]];
        $response=$this->postJson($endpoint,$payload)->assertOk()->assertJsonPath('ok',true);
        $this->assertNotSame('untrusted_client_reward',$response->json('reward.type'));
        $this->assertNotNull($box->fresh()->opened_at);
        $reward=$box->fresh()->payload['reward'];
        $wallet=$user->wallet()->first()->only(['tokens','gems']);
        $profile=$user->profile()->first()->only(['xp','level','pasha_days']);
        $inventory=InventoryItem::where('user_id',$user->id)->pluck('id')->all();
        $tickets=CompetitionTicket::where('user_id',$user->id)->pluck('quantity','denomination')->all();
        foreach([true,false] as $skipped) {
            $this->postJson($endpoint,array_merge($payload,['animation_skipped'=>$skipped]))->assertStatus(409);
            $this->assertSame($reward,$box->fresh()->payload['reward']);
            $this->assertSame($wallet,$user->wallet()->first()->only(['tokens','gems']));
            $this->assertSame($profile,$user->profile()->first()->only(['xp','level','pasha_days']));
            $this->assertSame($inventory,InventoryItem::where('user_id',$user->id)->pluck('id')->all());
            $this->assertSame($tickets,CompetitionTicket::where('user_id',$user->id)->pluck('quantity','denomination')->all());
        }
    }
}
