<?php

namespace Tests\Unit;

use App\Services\GameEngine\HandRules;
use App\Services\GameEngine\PinochleRules;
use PHPUnit\Framework\TestCase;

class R50RummyDrawIntegrityTest extends TestCase
{
    public function test_empty_stock_cannot_claim_a_draw_when_only_the_public_top_card_remains(): void
    {
        foreach ([new HandRules(), new PinochleRules()] as $engine) {
            $player = 'user:2';
            $state = $engine->initialState(['user:1', $player]);
            $state['turn'] = $player;
            $state['drew_this_turn'] = [];
            $state['deck'] = [];
            $state['discard'] = ['9_hearts'];
            $handBefore = $state['hands'][$player];

            $this->assertFalse($engine->validate($state, $player, 'draw_deck', []));
            $types = array_column($engine->availableActions($state, $player), 'type');
            $this->assertNotContains('draw_deck', $types);
            $this->assertContains('draw_discard', $types);

            $rejected = $engine->apply($state, $player, 'draw_deck', []);
            $this->assertSame('invalid_action', $rejected['last_error']);
            $this->assertSame($handBefore, $rejected['hands'][$player]);
            $this->assertSame(['9_hearts'], $rejected['discard']);
            $this->assertEmpty($rejected['drew_this_turn']);

            $drawn = $engine->apply($state, $player, 'draw_discard', []);
            $this->assertSame([], $drawn['discard']);
            $this->assertCount(count($handBefore) + 1, $drawn['hands'][$player]);
            $this->assertTrue($drawn['drew_this_turn'][$player]);
            $this->assertFalse($engine->validate($drawn, $player, 'draw_deck', []));
        }
    }

    public function test_empty_stock_recycles_only_buried_fire_cards_and_preserves_the_visible_top(): void
    {
        foreach ([new HandRules(), new PinochleRules()] as $engine) {
            $player = 'user:2';
            $state = $engine->initialState(['user:1', $player]);
            $state['turn'] = $player;
            $state['drew_this_turn'] = [];
            $state['deck'] = [];
            $state['discard'] = ['7_clubs', '8_diamonds', '9_hearts'];
            $before = $state['hands'][$player];

            $this->assertTrue($engine->validate($state, $player, 'draw_deck', []));
            $this->assertContains('draw_deck', array_column($engine->availableActions($state, $player), 'type'));
            $drawn = $engine->apply($state, $player, 'draw_deck', []);
            $this->assertSame(['9_hearts'], $drawn['discard']);
            $this->assertCount(1, $drawn['deck']);
            $this->assertCount(count($before) + 1, $drawn['hands'][$player]);
            $newCard = array_values(array_diff_assoc($drawn['hands'][$player], $before));
            // Sort order may change, so assert the invariant on multisets.
            $available = array_count_values($before);
            $after = array_count_values($drawn['hands'][$player]);
            foreach ($available as $card => $count) {
                $this->assertGreaterThanOrEqual($count, $after[$card] ?? 0);
            }
            $this->assertTrue($drawn['drew_this_turn'][$player]);
            $this->assertFalse($engine->validate($drawn, $player, 'draw_deck', []));
            $combined = array_merge($drawn['deck'], $drawn['discard']);
            $difference = array_count_values($drawn['hands'][$player]);
            foreach (array_count_values($before) as $card => $count) {
                $difference[$card] -= $count;
                if ($difference[$card] === 0) unset($difference[$card]);
            }
            foreach ($difference as $card => $count) {
                for ($i = 0; $i < $count; $i++) $combined[] = $card;
            }
            sort($combined);
            $this->assertSame(['7_clubs', '8_diamonds', '9_hearts'], $combined);
        }
    }

    public function test_banakil_stack_draw_rejects_non_integral_inputs_without_mutating_the_hand_or_fire(): void
    {
        $engine = new PinochleRules();
        $player = 'user:2';
        $state = $engine->initialState(['user:1', $player]);
        $state['turn'] = $player;
        $state['drew_this_turn'] = [];
        $state['discard'] = ['3_clubs', '4_diamonds', '5_spades', '6_hearts'];
        $before = $state['hands'][$player];

        foreach ([null, true, false, 2.0, 2.5, '2.5', '2extra', '02', '', ' 2', '2 ', [], ['2'], -2, 0, 1, 5] as $invalid) {
            $payload = ['count' => $invalid];
            $this->assertFalse($engine->validate($state, $player, 'draw_discard_stack', $payload));
            $rejected = $engine->apply($state, $player, 'draw_discard_stack', $payload);
            $this->assertSame('invalid_discard_stack', $rejected['last_error']);
            $this->assertSame($before, $rejected['hands'][$player]);
            $this->assertSame($state['discard'], $rejected['discard']);
            $this->assertEmpty($rejected['drew_this_turn']);
        }

        foreach ([2, '2', 4] as $valid) {
            $this->assertTrue($engine->validate($state, $player, 'draw_discard_stack', ['count' => $valid]));
            $drawn = $engine->apply($state, $player, 'draw_discard_stack', ['count' => $valid]);
            $this->assertCount(count($before) + (int) $valid, $drawn['hands'][$player]);
            $this->assertCount(4 - (int) $valid, $drawn['discard']);
            $this->assertTrue($drawn['drew_this_turn'][$player]);
            $this->assertFalse($engine->validate($drawn, $player, 'draw_discard_stack', ['count' => 2]));
        }
    }
}
