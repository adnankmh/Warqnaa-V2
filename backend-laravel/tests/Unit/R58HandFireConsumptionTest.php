<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';

/** A Hand discard pickup remains locked until that exact card value is melded. */
class R58HandFireConsumptionTest extends TestCase
{
    private function state(\GlobalCardEngineCore $engine): array
    {
        $state = $engine->newGame([
            ['id'=>'p0'], ['id'=>'p1'], ['id'=>'p2'], ['id'=>'p3'],
        ], ['seed'=>5801]);
        $state['currentIndex'] = 0;
        $state['phase'] = 'draw';
        $state['starterDiscardPending'] = false;
        $state['hands']['p0'] = ['3_H','4_C','5_C','7_S','8_S','9_S','Q_D'];
        $state['discard'] = ['2_H','6_C'];
        $state['melds'] = [
            'p0'=>[['cards'=>['J_H','Q_H','K_H'], 'value'=>30]],
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

    public function test_unrelated_meld_cannot_release_the_fire_pickup_lock(): void
    {
        foreach ([new \SaudiHandEngine(), new \HandPartnershipEngine()] as $engine) {
            $state = $this->state($engine);
            $before = $this->physicalCards($state);
            $this->assertContains('draw_discard', array_column($engine->availableActions($state,'p0'),'type'));

            $drawn = $engine->applyAction($state,'p0',['type'=>'draw_discard']);
            $this->assertTrue($drawn['rummyTurnMeta']['p0']['must_meld']);
            $this->assertSame('6_C', $drawn['rummyTurnMeta']['p0']['required_meld_card']);

            try {
                $engine->applyAction($drawn,'p0',[
                    'type'=>'meld', 'cards'=>['7_S','8_S','9_S'],
                ]);
                $this->fail('An unrelated meld bypassed the authoritative fire-card lock.');
            } catch (\GameEngineException $error) {
                $this->assertStringContainsString('ورقة النار', $error->getMessage());
            }
            $this->assertTrue($drawn['rummyTurnMeta']['p0']['must_meld']);
            $this->assertSame('6_C', $drawn['rummyTurnMeta']['p0']['required_meld_card']);
            $this->assertNotContains('discard', array_column($engine->availableActions($drawn,'p0'),'type'));

            $consumed = $engine->applyAction($drawn,'p0',[
                'type'=>'meld', 'cards'=>['4_C','5_C','6_C'],
            ]);
            $this->assertFalse($consumed['rummyTurnMeta']['p0']['must_meld']);
            $this->assertArrayNotHasKey('required_meld_card', $consumed['rummyTurnMeta']['p0']);
            $this->assertSame(['3_H','7_S','8_S','9_S','Q_D'], $consumed['hands']['p0']);
            $this->assertSame($before, $this->physicalCards($consumed));

            $finished = $engine->applyAction($consumed,'p0',['type'=>'discard','card'=>'Q_D']);
            $this->assertSame('draw', $finished['phase']);
            $this->assertSame($before, $this->physicalCards($finished));
        }
    }
}
