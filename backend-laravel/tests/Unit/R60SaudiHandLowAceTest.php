<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';

class R60SaudiHandProbe extends \SaudiHandEngine
{
    public function openingValue(array $cards): int { return $this->meldValue($cards); }
}

class R60PartnerHandProbe extends \HandPartnershipEngine
{
    public function openingValue(array $cards): int { return $this->meldValue($cards); }
}

/** Saudi Hand treats an ace in A-2-3 as one point, including joker gaps. */
class R60SaudiHandLowAceTest extends TestCase
{
    private function state(\GlobalCardEngineCore $engine,array $secondRun): array
    {
        $state=$engine->newGame([
            ['id'=>'p0'],['id'=>'p1'],['id'=>'p2'],['id'=>'p3'],
        ],['seed'=>6001]);
        $state['currentIndex']=0;
        $state['phase']='draw';
        $state['starterDiscardPending']=false;
        $state['hands']['p0']=array_merge(['A_C','2_C'],$secondRun,['4_S']);
        $state['discard']=['7_H','3_C'];
        $state['melds']=['p0'=>[],'p1'=>[],'p2'=>[],'p3'=>[]];
        $state['teamOpened']=[false,false];
        $state['teamOpeningThresholds']=[51,51];
        $state['rummyTurnMeta']=[];
        return $state;
    }

    private function physicalCards(array $state): array
    {
        $cards=array_merge($state['deck'],$state['discard'],...array_values($state['hands']));
        foreach($state['melds'] as $groups){
            foreach($groups as $group) $cards=array_merge($cards,$group['cards']);
        }
        sort($cards);
        return $cards;
    }

    public function test_low_ace_and_joker_runs_use_the_authoritative_substitute_value(): void
    {
        foreach([new R60SaudiHandProbe(),new R60PartnerHandProbe()] as $engine){
            $this->assertSame(6,$engine->openingValue(['A_C','2_C','3_C']));
            $this->assertSame(10,$engine->openingValue(['A_C','2_C','3_C','4_C']));
            $this->assertSame(31,$engine->openingValue(['Q_C','K_C','A_C']));
            $this->assertSame(6,$engine->openingValue(['A_C','2_C','JOKER_R']));
            $this->assertSame(6,$engine->openingValue(['A_C','3_C','JOKER_R']));
            $this->assertSame(10,$engine->openingValue(['A_C','2_C','3_C','JOKER_R']));
            $this->assertSame(9,$engine->openingValue(['2_C','3_C','JOKER_R']));
        }
    }

    public function test_inflated_low_ace_value_cannot_authorize_a_fire_draw(): void
    {
        foreach([new R60SaudiHandProbe(),new R60PartnerHandProbe()] as $engine){
            $state=$this->state($engine,['10_D','J_D','Q_D','K_D']);
            $this->assertNotContains('draw_discard',array_column($engine->availableActions($state,'p0'),'type'));
            try{
                $engine->applyAction($state,'p0',['type'=>'draw_discard']);
                $this->fail('A 46-point opening was authorized by an inflated low-ace value.');
            }catch(\GameEngineException $error){
                $this->assertStringContainsString('شرط الافتتاح',$error->getMessage());
            }
            $this->assertSame('draw',$state['phase']);
            $discard=$state['discard'];
            $this->assertSame('3_C',end($discard));
        }
    }

    public function test_true_51_point_low_ace_opening_is_advertised_and_conserves_cards(): void
    {
        foreach([new R60SaudiHandProbe(),new R60PartnerHandProbe()] as $engine){
            $state=$this->state($engine,['5_D','6_D','7_D','8_D','9_D','10_D']);
            $before=$this->physicalCards($state);
            $this->assertContains('draw_discard',array_column($engine->availableActions($state,'p0'),'type'));

            $drawn=$engine->applyAction($state,'p0',['type'=>'draw_discard']);
            $many=collect($engine->availableActions($drawn,'p0'))->firstWhere('type','meld_many');
            $this->assertNotNull($many);
            $opened=$engine->applyAction($drawn,'p0',$many);

            $this->assertFalse($opened['rummyTurnMeta']['p0']['must_meld']);
            $this->assertSame(['4_S'],$opened['hands']['p0']);
            $values=array_column($opened['melds']['p0'],'value'); sort($values);
            $this->assertSame([6,45],$values);
            $this->assertSame($before,$this->physicalCards($opened));
        }
    }
}
