<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';

/** Joker recovery from a partner's meld is placement, not a full-Hand finish. */
class R64PartnershipJokerHandTest extends TestCase
{
    public function test_replacing_partner_joker_disqualifies_full_hand_bonus(): void
    {
        $engine=new \HandPartnershipEngine();
        $state=$engine->newGame([
            ['id'=>'p0'],['id'=>'p1'],['id'=>'p2'],['id'=>'p3'],
        ],['seed'=>6401,'singleRound'=>true]);
        $state['currentIndex']=2;
        $state['phase']='draw';
        $state['starterDiscardPending']=false;
        $state['deck']=['A_C'];
        $state['hands']['p0']=['4_S'];
        $state['hands']['p1']=['2_H'];
        $state['hands']['p2']=['5_C','Q_C','K_C'];
        $state['hands']['p3']=['3_H'];
        $state['melds']=[
            'p0'=>[['cards'=>['4_C','JOKER_R','6_C'],'value'=>15]],
            'p1'=>[],
            'p2'=>[],
            'p3'=>[],
        ];
        $state['teamOpened']=[true,false];
        $state['teamOpeningThresholds']=[51,51];
        $state['rummyTurnMeta']=[];

        $drawn=$engine->applyAction($state,'p2',['type'=>'draw_deck']);
        $replaced=$engine->applyAction($drawn,'p2',[
            'type'=>'replace_wild',
            'target_player'=>'p0',
            'meld_index'=>0,
            'card'=>'5_C',
        ]);

        $this->assertTrue($replaced['rummyTurnMeta']['p2']['replaced_wild']);
        $this->assertContains('JOKER_R',$replaced['hands']['p2']);

        $finished=$engine->applyAction($replaced,'p2',[
            'type'=>'meld',
            'cards'=>['JOKER_R','Q_C','K_C','A_C'],
        ]);

        $this->assertTrue($finished['gameOver']);
        $this->assertSame(-30,$finished['scores'][0]);

        $scoreEvents=array_values(array_filter(
            $finished['events'],
            fn(array $event): bool => ($event['type'] ?? '')==='rummy.round_scored',
        ));
        $this->assertNotEmpty($scoreEvents);
        $lastScoreEvent=end($scoreEvents);
        $this->assertFalse((bool)$lastScoreEvent['data']['full_hand']);
    }
}
