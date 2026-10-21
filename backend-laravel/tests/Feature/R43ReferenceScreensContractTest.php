<?php

namespace Tests\Feature;

use Tests\TestCase;

class R43ReferenceScreensContractTest extends TestCase
{
    public function test_approved_reference_theme_is_loaded_after_legacy_styles(): void
    {
        $layout = file_get_contents(resource_path('views/layouts/app.blade.php'));
        $legacy = strpos($layout, 'assets/css/r48-approved-art.css');
        $reference = strpos($layout, 'assets/css/r43-reference-screens.css');

        $this->assertNotFalse($legacy);
        $this->assertNotFalse($reference);
        $this->assertGreaterThan($legacy, $reference);
    }

    public function test_reference_is_css_and_live_templates_not_a_screenshot_overlay(): void
    {
        $css = file_get_contents(public_path('assets/css/r43-reference-screens.css'));
        $this->assertStringContainsString('.w36-games-wall', $css);
        $this->assertStringContainsString('.w36-grand-hero', $css);
        $this->assertStringContainsString('.w36-profile-scene', $css);
        $this->assertStringContainsString('.w36-emoji-preview', $css);
        $this->assertStringContainsString('.game-table', $css);
        $this->assertStringContainsString('grid-template-columns:repeat(3', $css);
        $this->assertStringContainsString('prefers-reduced-motion', $css);
        $this->assertStringNotContainsString('Warqnaa_Screens_Overview', $css);

        $games = file_get_contents(resource_path('views/games/index.blade.php'));
        $this->assertStringContainsString("route('rooms.index',$game->key)", $games);
        $this->assertStringContainsString("id=\"gameSearchV130\"", $games);
        $this->assertStringContainsString("id=\"compactGamesV130\"", $games);
    }
}
