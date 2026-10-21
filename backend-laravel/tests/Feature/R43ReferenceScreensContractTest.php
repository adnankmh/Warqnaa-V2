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

    public function test_real_bots_use_existing_assets_and_do_not_forge_prize_or_play_actions(): void
    {
        $template = file_get_contents(resource_path('views/home.blade.php'));
        $catalogue = json_decode(file_get_contents(public_path('assets/bots/royal/catalog.json')), true);

        $this->assertIsArray($catalogue);
        $this->assertCount(10, $catalogue);
        foreach ($catalogue as $bot) {
            $this->assertNotEmpty($bot['name']);
            $this->assertFileExists(public_path(ltrim($bot['avatar'], '/')));
        }
        $this->assertStringContainsString('r43-bot-identity-grid', $template);
        $this->assertStringContainsString('r43BotCatalogPath', $template);
        $this->assertStringContainsString("route('games')", $template);
        $css = file_get_contents(public_path('assets/css/r43-reference-screens.css'));
        $this->assertStringContainsString('.r43-bot-identity', $css);
    }

}
