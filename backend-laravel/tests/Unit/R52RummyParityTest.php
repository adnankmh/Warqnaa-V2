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
        $this->assertNull($engine->replacement(['7C','7D','JOKER1'],['7H']));
        $this->assertSame(['7C','7D','7H','7S'],$engine->replacement(['7C','7D','JOKER1'],['7H','7S']));
        $this->assertNull($engine->replacement(['7C','7D','JOKER1'],['7H','7H']));
        $this->assertSame(['4C','6C','5C'],$engine->replacement(['4C','JOKER1','6C'],['5C']));
    }

    public function test_banakil_cannot_recover_a_two_or_exchange_joker_for_another_wild(): void
    {
        $engine=new class extends \BanakilEngine {
            public function replacement(array $meld,array $cards): ?array {return $this->jokerReplacementMeld($meld,$cards);}
        };
        $this->assertNull($engine->replacement(['4C','2H','6C'],['5C']));
        $this->assertNull($engine->replacement(['4C','JOKER1','6C'],['2D']));
    }

    public function test_final_discard_preserves_full_hand_bonus(): void
    {
        $engine=new \SaudiHandEngine();
        $state=$engine->newGame([['id'=>'p0'],['id'=>'p1']],['singleRound'=>true]);
        $state['hands']['p0']=['2C'];$state['hands']['p1']=['AH','JOKER2'];
        $state['melds']['p0']=[['cards'=>['JC','QC','KC'],'value'=>30]];
        $state['melds']['p1']=[];$state['phase']='discard';$state['currentIndex']=0;
        $state['starterDiscardPending']=false;
        $state['rummyTurnMeta']['p0']=['opened_before'=>false,'melded'=>true,'layoff'=>false,'must_meld'=>false];
        $after=$engine->applyAction($state,'p0',['type'=>'discard','card'=>'2C']);
        $this->assertTrue($after['gameOver']);
        $this->assertSame(-60,$after['scores']['p0']);
        $this->assertSame(252,$after['scores']['p1']);
    }
}
