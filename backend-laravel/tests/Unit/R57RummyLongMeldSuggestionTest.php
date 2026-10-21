<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/SaudiHandEngine.php';
require_once __DIR__.'/../../app/Services/GameEngine/GlobalEngines/HandPartnershipEngine.php';

/** Long server-valid runs must be advertised by the same authoritative engine. */
class R57RummyLongMeldSuggestionTest extends TestCase
{
    private function state(\GlobalCardEngineCore $engine): array
    {
        $state = $engine->newGame([
            ['id'=>'p0'], ['id'=>'p1'], ['id'=>'p2'], ['id'=>'p3'],
        ], ['seed'=>5701]);
        $state['currentIndex'] = 0;
        $state['phase'] = 'draw';
        $state['starterDiscardPending'] = false;
        $state['hands']['p0'] = ['9_C','10_C','J_C','Q_C','K_C','4_S'];
        $state['discard'] = ['2_H', 'A_C'];
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

    public function test_long_run_unlocks_fire_draw_and_is_advertised_as_one_opening(): void
    {
        foreach ([new \SaudiHandEngine(), new \HandPartnershipEngine()] as $engine) {
            $state = $this->state($engine);
            $before = $this->physicalCards($state);
            $this->assertContains('draw_discard', array_column($engine->availableActions($state, 'p0'), 'type'));

            $drawn = $engine->applyAction($state, 'p0', ['type'=>'draw_discard']);
            $longMeld = null;
            foreach ($engine->availableActions($drawn, 'p0') as $action) {
                if (($action['type'] ?? '') === 'meld' && count($action['cards'] ?? []) === 6) {
                    $longMeld = $action;
                    break;
                }
            }
            $this->assertNotNull($longMeld);
            $cards = $longMeld['cards'];
            sort($cards);
            $this->assertSame(['10_C','9_C','A_C','J_C','K_C','Q_C'], $cards);

            $opened = $engine->applyAction($drawn, 'p0', $longMeld);
            $this->assertFalse($opened['rummyTurnMeta']['p0']['must_meld']);
            $this->assertSame(['4_S'], $opened['hands']['p0']);
            $this->assertSame(60, $opened['melds']['p0'][0]['value']);
            $this->assertSame($before, $this->physicalCards($opened));
        }
    }
}
