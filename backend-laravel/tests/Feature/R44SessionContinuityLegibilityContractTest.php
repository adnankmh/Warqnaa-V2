<?php

namespace Tests\Feature;

use Tests\TestCase;

class R44SessionContinuityLegibilityContractTest extends TestCase
{
    public function test_session_continuity_copy_is_readable_localized_and_actionable(): void
    {
        $main = file_get_contents(base_path('../flutter_app/lib/main.dart'));
        $polish = file_get_contents(base_path('../flutter_app/lib/v166_polish.dart'));
        $studio = file_get_contents(base_path('../flutter_app/lib/r9_local_studio.dart'));

        $this->assertStringContainsString("tooltip:L.t(controller.localeCode,'exitGameTooltip')", $polish);
        $this->assertStringContainsString("content:Text(L.t(controller.localeCode,'leaveGamePrompt'))", $polish);
        $this->assertStringContainsString("content: Text(L.t(controller.localeCode, 'leaveGamePrompt'))", $main);
        $this->assertStringContainsString("L.t(controller.localeCode,'keepPlaying')", $main);
        $this->assertStringContainsString("'exitGameTooltip': 'Exit game'", $polish);
        $this->assertStringContainsString("'leaveGamePrompt': 'You are currently in a game.", $polish);
        $this->assertStringNotContainsString("tooltip:'الخروج من اللعبة'", $polish);
        $this->assertDoesNotMatchRegularExpression(
            '/fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])/',
            $polish.$studio
        );
    }
}
