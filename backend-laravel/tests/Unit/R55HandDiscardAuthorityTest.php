<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/BanakilEngine.php';

/** The public action executor must enforce the same discard rule as its hints. */
class R55HandDiscardAuthorityTest extends TestCase
{
    private function state(\GlobalCardEngineCore $engine, array $hand, string $top): array
    {
        $state = $engine->newGame([
            ['id'=>'p0'], ['id'=>'p1'], ['id'=>'p2'], ['id'=>'p3'],
        ], ['seed'=>5501]);
        $state['currentIndex'] = 0;
        $state['phase'] = 'draw';
        $state['starterDiscardPending'] = false;
        $state['hands']['p0'] = $hand;
        $state['discard'] = ['2_D', $top];
        $state['melds'] = ['p0'=>[], 'p1'=>[], 'p2'=>[], 'p3'=>[]];
        $state['teamOpened'] = [false, false];
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

    public function test_unadvertised_hand_discard_is_rejected_by_direct_executor_without_mutation(): void
    {
        foreach ([new \SaudiHandEngine(), new \HandPartnershipEngine()] as $engine) {
            foreach ([
                [['4_C','5_C','Q_D'], '9_S'], // no meld containing the top
                [['4_C','5_C','Q_D'], '6_C'], // legal run, below unopened 51
                [['K_C','K_D','K_H','4_C'], '9_S'], // unrelated meld is insufficient
            ] as [$hand, $top]) {
                $state = $this->state($engine, $hand, $top);
                $before = $state;
                $this->assertNotContains('draw_discard', array_column($engine->availableActions($state,'p0'),'type'));
                try {
                    $engine->applyAction($state,'p0',['type'=>'draw_discard']);
                    $this->fail('A forged draw_discard bypassed the authoritative Hand rule.');
                } catch (\GameEngineException $error) {
                    $this->assertStringContainsString('مسار تنزيل قانوني', $error->getMessage());
                }
                $this->assertSame($before, $state);
                $this->assertSame($this->physicalCards($before), $this->physicalCards($state));
                $this->assertContains('draw_deck', array_column($engine->availableActions($state,'p0'),'type'));
                $stock = $engine->applyAction($state,'p0',['type'=>'draw_deck']);
                $this->assertSame('discard', $stock['phase']);
                $this->assertSame($state['discard'], $stock['discard']);
                $this->assertSame($this->physicalCards($state), $this->physicalCards($stock));
            }
        }
    }

    public function test_legal_multi_group_opening_still_takes_fire_and_preserves_cards(): void
    {
        foreach ([new \SaudiHandEngine(), new \HandPartnershipEngine()] as $engine) {
            $state = $this->state($engine, ['K_D','K_H','Q_C','Q_D','Q_H','4_S'], 'K_C');
            $before = $this->physicalCards($state);
            $this->assertContains('draw_discard', array_column($engine->availableActions($state,'p0'),'type'));
            $drawn = $engine->applyAction($state,'p0',['type'=>'draw_discard']);
            $this->assertTrue($drawn['rummyTurnMeta']['p0']['must_meld']);
            $this->assertSame(['2_D'], $drawn['discard']);
            $this->assertSame($before, $this->physicalCards($drawn));
            $opened = $engine->applyAction($drawn,'p0',[
                'type'=>'meld_many',
                'groups'=>[['K_C','K_D','K_H'], ['Q_C','Q_D','Q_H']],
            ]);
            $this->assertSame(['4_S'], $opened['hands']['p0']);
            $this->assertFalse($opened['rummyTurnMeta']['p0']['must_meld']);
            $this->assertSame($before, $this->physicalCards($opened));
        }
    }

    public function test_opened_hand_can_take_a_low_value_meld_from_fire(): void
    {
        foreach ([new \SaudiHandEngine(), new \HandPartnershipEngine()] as $engine) {
            $state = $this->state($engine, ['4_C','5_C','Q_D'], '6_C');
            $state['melds']['p0'] = [['cards'=>['J_H','Q_H','K_H'], 'value'=>30]];
            $state['teamOpened'][0] = true;
            $this->assertContains('draw_discard', array_column($engine->availableActions($state,'p0'),'type'));
            $before = $this->physicalCards($state);
            $drawn = $engine->applyAction($state,'p0',['type'=>'draw_discard']);
            $melded = $engine->applyAction($drawn,'p0',['type'=>'meld','cards'=>['4_C','5_C','6_C']]);
            $this->assertFalse($melded['rummyTurnMeta']['p0']['must_meld']);
            $this->assertSame(['Q_D'], $melded['hands']['p0']);
            $this->assertSame($before, $this->physicalCards($melded));
        }
    }

    public function test_banakil_keeps_unrestricted_single_and_multi_fire_draws(): void
    {
        $engine = new \BanakilEngine();
        $state = $this->state($engine, ['4_C','5_C','Q_D'], '9_S');
        $before = $this->physicalCards($state);
        $this->assertContains('draw_discard', array_column($engine->availableActions($state,'p0'),'type'));
        $drawn = $engine->applyAction($state,'p0',['type'=>'draw_discard']);
        $this->assertFalse($drawn['rummyTurnMeta']['p0']['must_meld']);
        $this->assertSame($before, $this->physicalCards($drawn));
        $stack = $engine->applyAction($state,'p0',['type'=>'draw_discard_stack','count'=>2]);
        $this->assertSame([], $stack['discard']);
        $this->assertCount(5, $stack['hands']['p0']);
        $this->assertFalse($stack['rummyTurnMeta']['p0']['must_meld']);
        $this->assertSame($before, $this->physicalCards($stack));
    }
}
