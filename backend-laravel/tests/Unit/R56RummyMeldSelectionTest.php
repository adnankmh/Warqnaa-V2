<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';

/** Multi-group openings must not depend on greedy suggestion order. */
class R56RummyMeldSelectionTest extends TestCase
{
    private function state(\GlobalCardEngineCore $engine): array
    {
        $state = $engine->newGame([
            ['id'=>'p0'], ['id'=>'p1'], ['id'=>'p2'], ['id'=>'p3'],
        ], ['seed'=>5601]);
        $state['currentIndex'] = 0;
        $state['phase'] = 'draw';
        $state['starterDiscardPending'] = false;
        $state['hands']['p0'] = ['A_C','A_D','A_H','K_C','K_D','Q_D','4_S'];
        $state['discard'] = ['2_H', 'Q_C'];
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

    public function test_overlapping_high_value_set_does_not_hide_legal_fire_opening(): void
    {
        foreach ([new \SaudiHandEngine(), new \HandPartnershipEngine()] as $engine) {
            $state = $this->state($engine);
            $before = $this->physicalCards($state);

            // A-A-A (33) sorts ahead of both Q-K-A runs (31 each), but taking
            // that set greedily blocks the two-run 62-point legal opening.
            $this->assertContains('draw_discard', array_column($engine->availableActions($state, 'p0'), 'type'));
            $drawn = $engine->applyAction($state, 'p0', ['type'=>'draw_discard']);
            $many = collect($engine->availableActions($drawn, 'p0'))->firstWhere('type', 'meld_many');
            $this->assertNotNull($many);
            $normalized = array_map(function (array $cards): array {
                sort($cards);
                return $cards;
            }, $many['groups']);
            $this->assertSame([
                ['A_C','K_C','Q_C'],
                ['A_D','K_D','Q_D'],
            ], $normalized);

            $opened = $engine->applyAction($drawn, 'p0', $many);
            $this->assertFalse($opened['rummyTurnMeta']['p0']['must_meld']);
            $remaining = $opened['hands']['p0'];
            sort($remaining);
            $this->assertSame(['4_S','A_H'], $remaining);
            $this->assertSame(62, array_sum(array_column($opened['melds']['p0'], 'value')));
            $this->assertSame($before, $this->physicalCards($opened));
        }
    }
}
