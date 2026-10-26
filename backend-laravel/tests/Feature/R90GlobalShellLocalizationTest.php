<?php

namespace Tests\Feature;

use Tests\TestCase;

class R90GlobalShellLocalizationTest extends TestCase
{
    public function test_global_navigation_and_personalization_controls_have_server_rendered_english_contracts(): void
    {
        $layout = file_get_contents(resource_path('views/layouts/app.blade.php'));

        $this->assertStringContainsString("app()->getLocale() === 'en'", $layout);
        $this->assertStringContainsString('Warqnaa Zone', $layout);
        $this->assertStringContainsString('Game rules', $layout);
        $this->assertStringContainsString('Notifications', $layout);
        $this->assertStringContainsString('Games menu', $layout);
        $this->assertStringContainsString('Search games...', $layout);
        $this->assertStringContainsString('Partnership', $layout);
        $this->assertStringContainsString('Choose a site theme', $layout);
        $this->assertStringContainsString('Choose a language', $layout);
        $this->assertStringContainsString('Open theme menu', $layout);
        $this->assertStringContainsString('Open language menu', $layout);
        $this->assertStringContainsString('Token ledger', $layout);
        $this->assertStringContainsString('Volume from 0 to 100', $layout);
        $this->assertStringContainsString("\$g->name[\$english ? 'en' : 'ar']", $layout);
    }
}
