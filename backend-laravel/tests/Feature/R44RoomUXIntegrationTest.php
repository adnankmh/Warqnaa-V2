<?php

namespace Tests\Feature;

use Tests\TestCase;

class R44RoomUXIntegrationTest extends TestCase
{
    public function test_room_ui_mounts_two_real_piles_and_per_owner_melds_in_rummy_games(): void
    {
        $blade = file_get_contents(resource_path('views/room/show.blade.php'));
        $script = file_get_contents(public_path('assets/js/r44-room-rummy.js'));
        $styles = file_get_contents(public_path('assets/css/r43-reference-screens.css'));

        $this->assertStringContainsString('id="r44RoomPiles"', $blade);
        $this->assertStringContainsString('id="r44OwnerMelds"', $blade);
        $this->assertStringContainsString("asset('assets/js/r44-room-rummy.js')", $blade);
        $this->assertStringContainsString("window.roomAction('draw_discard_stack',{count:amount})", $script);
        $this->assertStringContainsString("enginePhase === 'draw'", $script);
        $this->assertStringContainsString('state.melds', $script);
        $this->assertStringContainsString('r44-pick-card', $styles);
        $this->assertStringContainsString('theme-emerald', $styles);
        $this->assertStringContainsString('theme-galaxy', $styles);
        $this->assertStringNotContainsString('Warqnaa_Screens_Overview', $blade);
    }
}
