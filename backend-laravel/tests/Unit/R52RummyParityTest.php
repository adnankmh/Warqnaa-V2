<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/BanakilEngine.php';

class R52RummyParityTest extends TestCase
{
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
