<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';

/** A partner's opening must not erase another player's personal Hand bonus. */
class R63PartnershipFullHandTest extends TestCase
{
    private function state(bool $playerMeldedBefore): array
    {
        $engine=new \HandPartnershipEngine();
        $state=$engine->newGame([
            ['id'=>'p0'],['id'=>'p1'],['id'=>'p2'],['id'=>'p3'],
        ],['seed'=>6301,'singleRound'=>true]);
        $state['currentIndex']=2;
        $state['phase']='draw';
        $state['starterDiscardPending']=false;
        $state['deck']=['A_D'];
        $state['hands']['p0']=['4_S'];
        $state['hands']['p1']=['2_H'];
        $state['hands']['p2']=['Q_C','K_C','A_C','Q_D','K_D'];
        $state['hands']['p3']=['3_H'];
        $state['melds']=[
            'p0'=>[['cards'=>['7_C','8_C','9_C'],'value'=>24]],
            'p1'=>[],
            'p2'=>$playerMeldedBefore
                ? [['cards'=>['3_C','3_D','3_H'],'value'=>9]]
                : [],
            'p3'=>[],
        ];
        $state['teamOpened']=[true,false];
        $state['teamOpeningThresholds']=[51,51];
        $state['rummyTurnMeta']=[];
        return $state;
    }

    private function finish(array $state): array
    {
        $engine=new \HandPartnershipEngine();
        $drawn=$engine->applyAction($state,'p2',['type'=>'draw_deck']);
        $this->assertTrue($drawn['rummyTurnMeta']['p2']['opened_before']);

        return $engine->applyAction($drawn,'p2',[
            'type'=>'meld_many',
            'groups'=>[['Q_C','K_C','A_C'],['Q_D','K_D','A_D']],
        ]);
    }

    public function test_first_personal_meld_can_score_full_hand_after_partner_opened(): void
    {
        $finished=$this->finish($this->state(false));
        $this->assertTrue($finished['gameOver']);
        $this->assertSame(-60,$finished['scores'][0]);

        $scoreEvent=array_values(array_filter(
            $finished['events'],
            fn(array $event): bool => ($event['type'] ?? '')==='rummy.round_scored',
        ));
        $this->assertNotEmpty($scoreEvent);
        $lastScoreEvent=end($scoreEvent);
        $this->assertTrue((bool)$lastScoreEvent['data']['full_hand']);
    }

    public function test_player_with_an_earlier_personal_meld_scores_normal_finish(): void
    {
        $finished=$this->finish($this->state(true));
        $this->assertTrue($finished['gameOver']);
        $this->assertSame(-30,$finished['scores'][0]);

        $scoreEvent=array_values(array_filter(
            $finished['events'],
            fn(array $event): bool => ($event['type'] ?? '')==='rummy.round_scored',
        ));
        $this->assertNotEmpty($scoreEvent);
        $lastScoreEvent=end($scoreEvent);
        $this->assertFalse((bool)$lastScoreEvent['data']['full_hand']);
    }
}
