<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/BanakilEngine.php';

class R62SaudiHandRotationProbe extends \SaudiHandEngine
{
    public function nextRound(array $state): array { return $this->newRoundFromState($state); }
}

class R62BanakilRotationProbe extends \BanakilEngine
{
    public function nextRound(array $state): array { return $this->newRoundFromState($state); }
}

/** The dealer's next seat must receive the extra card and own the first turn. */
class R62RummyDealerRotationTest extends TestCase
{
    private function players(int $count): array
    {
        return array_map(fn(int $seat): array => ['id'=>'p'.$seat], range(0,$count-1));
    }

    private function assertStarter(array $state,int $dealer,int $starter,int $cardsEach): void
    {
        $this->assertSame($dealer,$state['dealerIndex']);
        $this->assertSame($starter,$state['currentIndex']);
        $this->assertTrue($state['starterDiscardPending']);
        foreach($state['players'] as $seat=>$player){
            $expected=$seat===$starter ? $cardsEach+1 : $cardsEach;
            $this->assertCount($expected,$state['hands'][$player['id']],"seat {$seat}");
        }
    }

    public function test_custom_dealer_controls_saudi_hand_starter_and_extra_card(): void
    {
        $engine=new R62SaudiHandRotationProbe();
        $state=$engine->newGame($this->players(4),['seed'=>6201,'dealerIndex'=>1]);

        $this->assertStarter($state,1,2,14);
        $this->assertContains('discard',array_column($engine->availableActions($state,'p2'),'type'));
        $this->assertSame(['wait'],array_column($engine->availableActions($state,'p0'),'type'));
        try{
            $engine->applyAction($state,'p0',['type'=>'discard','card'=>$state['hands']['p0'][0]]);
            $this->fail('A non-starter discarded during the dealer-right opening turn.');
        }catch(\GameEngineException $error){
            $this->assertStringContainsString('ليست دورك',$error->getMessage());
        }
    }

    public function test_dealer_and_starter_rotate_together_between_hand_rounds(): void
    {
        $engine=new R62SaudiHandRotationProbe();
        $first=$engine->newGame($this->players(3),['seed'=>6202,'dealerIndex'=>2]);
        $this->assertStarter($first,2,0,14);

        $second=$engine->nextRound($first);
        $this->assertSame(2,$second['round']);
        $this->assertStarter($second,0,1,14);
        $this->assertSame($first['scores'],$second['scores']);
    }

    public function test_banakil_uses_the_same_authoritative_rotation(): void
    {
        $engine=new R62BanakilRotationProbe();
        $first=$engine->newGame($this->players(4),['seed'=>6203,'dealerIndex'=>0]);
        $this->assertStarter($first,0,1,18);

        $second=$engine->nextRound($first);
        $this->assertStarter($second,1,2,18);
        $this->assertSame($first['scores'],$second['scores']);
    }
}
