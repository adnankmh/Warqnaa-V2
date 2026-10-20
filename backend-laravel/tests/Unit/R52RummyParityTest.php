<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/BanakilEngine.php';

class R52RummyParityTest extends TestCase
{
    public function test_long_wild_runs_can_be_melded_and_extended_without_card_loss(): void
    {
        $engines=[new class extends \SaudiHandEngine {
            public function accepts(array $cards): bool {return $this->isValidMeld($cards);}
        },new class extends \BanakilEngine {
            public function accepts(array $cards): bool {return $this->isValidMeld($cards);}
        }];
        foreach($engines as $engine) {
            $run=['2_C','3_C','4_C','5_C','6_C','7_C','8_C','9_C','10_C','J_C','JOKER_R','K_C','A_C'];
            $this->assertTrue($engine->accepts($run));
            $this->assertFalse($engine->accepts(array_merge($run,['Q_C'])));
            $this->assertFalse($engine->accepts(['5_C','5_C','6_C','JOKER_R']));
            $this->assertFalse($engine->accepts(['K_C','A_C','3_C']));
            $this->assertTrue($engine->accepts(['A_C','3_C','JOKER_R']));
            $state=$engine->newGame([['id'=>'p0'],['id'=>'p1']],['seed'=>5250]);
            $state['hands']['p0']=array_merge($run,['K_D']);
            $state['phase']='discard';$state['currentIndex']=0;$state['starterDiscardPending']=false;
            $before=$this->physicalCards($state);
            $after=$engine->applyAction($state,'p0',['type'=>'meld','cards'=>$run]);
            $this->assertSame(['K_D'],$after['hands']['p0']);
            $this->assertCount(13,$after['melds']['p0'][0]['cards']);
            $this->assertSame($before,$this->physicalCards($after));

            $short=array_values(array_diff($run,['K_C']));
            $state['hands']['p0']=['K_C','K_D'];
            $state['melds']['p0']=[['cards'=>$short,'value'=>100]];
            $before=$this->physicalCards($state);
            $after=$engine->applyAction($state,'p0',['type'=>'layoff','target_player'=>'p0','meld_index'=>0,'cards'=>['K_C']]);
            $this->assertSame(['K_D'],$after['hands']['p0']);
            $this->assertCount(13,$after['melds']['p0'][0]['cards']);
            $this->assertSame($before,$this->physicalCards($after));
        }
    }

    private function physicalCards(array $state): array
    {
        $cards=array_merge($state['deck'],$state['discard'],...array_values($state['hands']));
        foreach($state['melds'] as $melds) foreach($melds as $meld) $cards=array_merge($cards,$meld['cards']);
        sort($cards);return $cards;
    }

    public function test_two_natural_card_set_requires_both_missing_suits_to_recover_joker(): void
    {
        $engine=new class extends \SaudiHandEngine {
            public function replacement(array $meld,array $cards): ?array {return $this->jokerReplacementMeld($meld,$cards);}
        };
        $this->assertNull($engine->replacement(['7_C','7_D','JOKER_R'],['7_H']));
        $this->assertSame(['7_C','7_D','7_H','7_S'],$engine->replacement(['7_C','7_D','JOKER_R'],['7_H','7_S']));
        $this->assertNull($engine->replacement(['7_C','7_D','JOKER_R'],['7_H','7_H']));
        $this->assertSame(['4_C','5_C','6_C'],$engine->replacement(['4_C','JOKER_R','6_C'],['5_C']));
    }

    public function test_banakil_cannot_recover_a_two_or_exchange_joker_for_another_wild(): void
    {
        $engine=new class extends \BanakilEngine {
            public function replacement(array $meld,array $cards): ?array {return $this->jokerReplacementMeld($meld,$cards);}
        };
        $this->assertNull($engine->replacement(['4_C','2_H','6_C'],['5_C']));
        $this->assertNull($engine->replacement(['4_C','JOKER_R','6_C'],['2_D']));
    }

    public function test_final_discard_preserves_full_hand_bonus(): void
    {
        $engine=new \SaudiHandEngine();
        $state=$engine->newGame([['id'=>'p0'],['id'=>'p1']],['singleRound'=>true]);
        $state['hands']['p0']=['2_C'];$state['hands']['p1']=['A_H','JOKER_B'];
        $state['melds']['p0']=[['cards'=>['J_C','Q_C','K_C'],'value'=>30]];
        $state['melds']['p1']=[];$state['phase']='discard';$state['currentIndex']=0;
        $state['starterDiscardPending']=false;
        $state['rummyTurnMeta']['p0']=['opened_before'=>false,'melded'=>true,'layoff'=>false,'must_meld'=>false];
        $after=$engine->applyAction($state,'p0',['type'=>'discard','card'=>'2_C']);
        $this->assertTrue($after['gameOver']);
        $this->assertSame(-60,$after['scores']['p0']);
        $this->assertSame(252,$after['scores']['p1']);
    }
}
