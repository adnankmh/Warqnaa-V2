<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';

/** Fire pickup must be consumed before unrelated meld, layoff or joker exchange. */
class R59HandFireFirstUseTest extends TestCase
{
    private function state(\GlobalCardEngineCore $engine): array
    {
        $state = $engine->newGame([
            ['id'=>'p0'], ['id'=>'p1'], ['id'=>'p2'], ['id'=>'p3'],
        ], ['seed'=>5901]);
        $state['currentIndex'] = 0;
        $state['phase'] = 'draw';
        $state['starterDiscardPending'] = false;
        $state['hands']['p0'] = ['4_C','4_D','4_H','5_C','5_S','10_H','Q_D'];
        $state['discard'] = ['2_D','6_C'];
        $state['melds'] = [
            'p0'=>[
                ['cards'=>['J_H','Q_H','K_H'], 'value'=>30],
                ['cards'=>['4_S','JOKER_R','6_S'], 'value'=>15],
            ],
            'p1'=>[], 'p2'=>[], 'p3'=>[],
        ];
        $state['teamOpened'] = [true, false];
        $state['teamOpeningThresholds'] = [51, 51];
        $state['rummyTurnMeta'] = [];
        return $state;
    }

    private function physicalCards(array $state): array
    {
        $cards = array_merge($state['deck'], $state['discard'], ...array_values($state['hands']));
        foreach ($state['melds'] as $groups) {
            foreach ($groups as $group) $cards = array_merge($cards, $group['cards']);
        }
        sort($cards);
        return $cards;
    }

    public function test_fire_card_is_the_first_authorized_table_mutation(): void
    {
        foreach ([new \SaudiHandEngine(), new \HandPartnershipEngine()] as $engine) {
            $state = $this->state($engine);
            $before = $this->physicalCards($state);
            $drawn = $engine->applyAction($state,'p0',['type'=>'draw_discard']);
            $afterDraw = $drawn;
            $actions = $engine->availableActions($drawn,'p0');

            $this->assertNotContains('layoff', array_column($actions,'type'));
            $this->assertNotContains('replace_wild', array_column($actions,'type'));
            foreach ($actions as $action) {
                if (in_array($action['type'] ?? '', ['meld','meld_many'], true)) {
                    $cards = isset($action['groups'])
                        ? array_merge(...array_values($action['groups']))
                        : (array)($action['cards'] ?? []);
                    $this->assertContains('6_C', $cards);
                }
            }

            foreach ([
                ['type'=>'meld','cards'=>['4_C','4_D','4_H']],
                ['type'=>'meld_many','groups'=>[['4_C','4_D','4_H']]],
                ['type'=>'layoff','target_player'=>'p0','meld_index'=>0,'cards'=>['10_H']],
                ['type'=>'replace_wild','target_player'=>'p0','meld_index'=>1,'card'=>'5_S','cards'=>['5_S']],
            ] as $forged) {
                try {
                    $engine->applyAction($drawn,'p0',$forged);
                    $this->fail('A side action bypassed the mandatory fire-card meld.');
                } catch (\GameEngineException $error) {
                    $this->assertStringContainsString('ورقة النار', $error->getMessage());
                }
                $this->assertSame($afterDraw, $drawn);
            }

            $consumed = $engine->applyAction($drawn,'p0',[
                'type'=>'meld', 'cards'=>['4_C','5_C','6_C'],
            ]);
            $this->assertFalse($consumed['rummyTurnMeta']['p0']['must_meld']);
            $this->assertSame($before, $this->physicalCards($consumed));
        }
    }
}
