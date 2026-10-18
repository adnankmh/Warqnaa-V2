<?php

namespace Tests\Feature;

use Tests\TestCase;

class R42HomeLobbyLegibilityContractTest extends TestCase
{
    public function test_live_home_lobby_keeps_readable_copy_and_real_navigation(): void
    {
        $source = file_get_contents(base_path('../flutter_app/lib/r8_play_experience.dart'));

        $this->assertStringContainsString('class R8HomeLobby extends StatelessWidget', $source);
        $this->assertStringContainsString('showGameLobby(context, controller, game)', $source);
        $this->assertStringContainsString('R64RoomBrowserPage(controller: controller)', $source);
        $this->assertStringContainsString('R65PartyPage(controller: controller)', $source);
        $this->assertDoesNotMatchRegularExpression(
            '/fontSize:\\s*(?:[0-9](?:\\.[0-9]+)?|10(?:\\.[0-9]+)?)(?![0-9])/',
            $source
        );
    }
}
