<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/BanakilEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';

/** R44 preserves stock/fire order, card conservation and team-owned meld rights. */
class R44BanakilHandOwnershipTest extends TestCase
{
    private function state(\GlobalCardEngineCore $engine): array
    {
        $state = $engine->newGame([
            ['id'=>'p0'], ['id'=>'p1'], ['id'=>'p2'], ['id'=>'p3'],
        ], ['seed'=>440044]);
        $state['currentIndex'] = 0;
        $state['phase'] = 'draw';
        $state['starterDiscardPending'] = false;
        $state['hands']['p0'] = ['10_C', 'Q_D'];
        $state['discard'] = ['4_H', '5_H', '6_H', '7_H'];
        $state['melds'] = [
            'p0'=>[],
            'p1'=>[['cards'=>['7_C','8_C','9_C'], 'value'=>24]],
            'p2'=>[['cards'=>['7_C','8_C','9_C'], 'value'=>24]],
            'p3'=>[],
        ];
        $state['teamOpened'] = [true, true];
        $state['rummyTurnMeta'] = [];
        $state['deck'] = ['K_S', 'A_D'];
        return $state;
    }

    public function test_banakil_buried_selection_takes_selected_card_and_every_card_above_it(): void
    {
        $engine = new \BanakilEngine();
        $state = $this->state($engine);
        $this->assertContains('draw_discard_stack', array_column($engine->availableActions($state,'p0'),'type'));

        $taken = $engine->applyAction($state,'p0',['type'=>'draw_discard_stack','count'=>3]);
        $this->assertSame(['4_H'], $taken['discard']);
        $this->assertSame(['10_C','Q_D','5_H','6_H','7_H'], $taken['hands']['p0']);
        $this->assertSame('discard', $taken['phase']);
        $this->assertSame(['4_H','5_H','6_H','7_H'], $state['discard']);
        $this->expectException(\GameEngineException::class);
        $engine->applyAction($taken,'p0',['type'=>'draw_discard_stack','count'=>2]);
    }

    public function test_only_team_can_lay_off_on_partners_meld_in_both_modes(): void
    {
        foreach ([new \BanakilEngine(), new \HandPartnershipEngine()] as $engine) {
            $state = $this->state($engine);
            $drawn = $engine->applyAction($state,'p0',['type'=>'draw_deck']);
            try {
                $engine->applyAction($drawn,'p0',[
                    'type'=>'layoff','target_player'=>'p1','meld_index'=>0,'cards'=>['10_C'],
                ]);
                $this->fail('Cross-team layoff was allowed.');
            } catch (\GameEngineException $error) {
                $this->assertStringContainsString('شريكك فقط', $error->getMessage());
            }
            $allowed = $engine->applyAction($drawn,'p0',[
                'type'=>'layoff','target_player'=>'p2','meld_index'=>0,'cards'=>['10_C'],
            ]);
            $this->assertSame(['7_C','8_C','9_C','10_C'], $allowed['melds']['p2'][0]['cards']);
            $this->assertSame(['Q_D','A_D'], $allowed['hands']['p0']);
            $this->assertSame(['7_C','8_C','9_C'], $allowed['melds']['p1'][0]['cards']);
        }
    }
}
