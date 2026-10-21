<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';

/** Saudi Hand raises every unopened player's target after a successful opening. */
class R61SaudiHandOpeningEscalationTest extends TestCase
{
    private function state(\SaudiHandEngine $engine): array
    {
        $state=$engine->newGame([
            ['id'=>'p0'],['id'=>'p1'],['id'=>'p2'],['id'=>'p3'],
        ],['seed'=>6101]);
        $state['phase']='discard';
        $state['starterDiscardPending']=false;
        $state['currentIndex']=0;
        $state['melds']=['p0'=>[],'p1'=>[],'p2'=>[],'p3'=>[]];
        $state['rummyTurnMeta']=[];
        $state['hands']['p0']=['Q_C','K_C','A_C','Q_D','K_D','A_D','4_S'];
        return $state;
    }

    private function opening62(): array
    {
        return [
            'type'=>'meld_many',
            'groups'=>[['Q_C','K_C','A_C'],['Q_D','K_D','A_D']],
        ];
    }

    public function test_each_unopened_player_must_beat_the_latest_saudi_opening(): void
    {
        $engine=new \SaudiHandEngine();
        $opened=$engine->applyAction($this->state($engine),'p0',$this->opening62());
        $this->assertSame(63,$opened['individualOpeningThreshold']);

        $opened['currentIndex']=1;
        $opened['phase']='discard';
        $opened['hands']['p1']=['Q_C','K_C','A_C','Q_D','K_D','A_D','5_S'];
        try {
            $engine->applyAction($opened,'p1',$this->opening62());
            $this->fail('A 62-point opening bypassed the authoritative 63-point target.');
        } catch (\GameEngineException $error) {
            $this->assertStringContainsString('أقل من المطلوب',$error->getMessage());
        }

        $opened['hands']['p1']=['A_C','A_D','A_H','K_C','K_D','K_H','5_S'];
        $next=$engine->applyAction($opened,'p1',[
            'type'=>'meld_many',
            'groups'=>[['A_C','A_D','A_H'],['K_C','K_D','K_H']],
        ]);
        $this->assertSame(64,$next['individualOpeningThreshold']);
        $this->assertCount(2,$next['melds']['p1']);
    }

    public function test_regular_hand_override_keeps_the_fixed_51_point_target(): void
    {
        $engine=new \SaudiHandEngine(['openingEscalates'=>false]);
        $opened=$engine->applyAction($this->state($engine),'p0',$this->opening62());
        $this->assertSame(51,$opened['individualOpeningThreshold']);

        $opened['currentIndex']=1;
        $opened['phase']='discard';
        $opened['hands']['p1']=['7_C','8_C','9_C','8_D','9_D','10_D','5_S'];
        $next=$engine->applyAction($opened,'p1',[
            'type'=>'meld_many',
            'groups'=>[['7_C','8_C','9_C'],['8_D','9_D','10_D']],
        ]);
        $this->assertCount(2,$next['melds']['p1']);
        $this->assertSame(51,$next['individualOpeningThreshold']);
    }

    public function test_legacy_saudi_state_without_threshold_falls_back_to_51(): void
    {
        $engine=new \SaudiHandEngine();
        $state=$this->state($engine);
        unset($state['individualOpeningThreshold']);
        $opened=$engine->applyAction($state,'p0',$this->opening62());
        $this->assertSame(63,$opened['individualOpeningThreshold']);
    }
}
