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
        $this->assertStringContainsString("asset('assets/js/r44-room-rummy.js') }}?v=85", $blade);
        $this->assertStringContainsString("window.roomAction('draw_discard_stack',{count:amount})", $script);
        $this->assertStringContainsString("enginePhase === 'draw'", $script);
        $this->assertStringContainsString('state.melds', $script);
        $this->assertStringContainsString("text('الرزمة','Stock')", $script);
        $this->assertStringContainsString("text('الرمي','Discard')", $script);
        $this->assertStringContainsString("text('إلغاء','Cancel')", $script);
        $this->assertStringContainsString("text('أنت','You')", $script);
        $this->assertStringContainsString("modal.dir=english?'ltr':'rtl'", $script);
        $this->assertStringContainsString("'Draw selected cards'", $script);
        $this->assertStringContainsString('const playerName=owner=>', $script);
        $this->assertStringContainsString("player?.name||player?.username||player?.display_name", $script);
        $this->assertStringContainsString("buckets.set(bucketKey,{team,owners:[]})", $script);
        $this->assertStringContainsString("tile.dataset.owners", $script);
        $this->assertStringContainsString("ownerSection.dataset.owner=item.owner", $script);
        $this->assertStringContainsString('r84-meld-owner-section', $styles);
        $this->assertStringContainsString('$phaseLabel = match($phase)', $blade);
        $this->assertStringContainsString('Waiting for players', $blade);
        $this->assertStringContainsString('Draw stock', $blade);
        $this->assertStringContainsString('Groups ready to meld', $blade);
        $this->assertStringContainsString('Stock and discard piles', $blade);
        $this->assertStringContainsString('Write a game message', $blade);
        $seatBlade = file_get_contents(resource_path('views/room/seat.blade.php'));
        $this->assertStringContainsString('Bot ready', $seatBlade);
        $this->assertStringContainsString('Disconnected', $seatBlade);
        $this->assertStringContainsString('Pasha options', $seatBlade);
        $this->assertStringContainsString('Replace player with bot', $seatBlade);
        $this->assertStringContainsString('Mute this player for me only', $seatBlade);
        $this->assertStringContainsString('Empty seat', $seatBlade);
        $this->assertStringContainsString('Sit here', $seatBlade);
        $roomIndex = file_get_contents(resource_path('views/room/index.blade.php'));
        $this->assertStringContainsString("app()->getLocale() === 'en'", $roomIndex);
        $this->assertStringContainsString('Rooms for', $roomIndex);
        $this->assertStringContainsString("'Public'", $roomIndex);
        $this->assertStringContainsString("'Private'", $roomIndex);
        $this->assertStringContainsString('Voice game — deducts 100 tokens from each player', $roomIndex);
        $this->assertStringContainsString('Pasha room-owner kick permission', $roomIndex);
        $this->assertStringContainsString('XP penalty for manual exit', $roomIndex);
        $this->assertStringContainsString('Create room', $roomIndex);
        $this->assertStringContainsString("'Close'", $roomIndex);
        $this->assertStringContainsString('Away mode is active', $blade);
        $this->assertStringContainsString('Leave and return to', $blade);
        $this->assertStringContainsString('Waiting for selection', $blade);
        $this->assertStringContainsString('Roll dice', $blade);
        $this->assertStringContainsString('Voice game', $blade);
        $this->assertStringContainsString('r44-pick-card', $styles);
        $this->assertStringContainsString('theme-emerald', $styles);
        $this->assertStringContainsString('theme-galaxy', $styles);
        $this->assertStringNotContainsString('Warqnaa_Screens_Overview', $blade);
    }
}
