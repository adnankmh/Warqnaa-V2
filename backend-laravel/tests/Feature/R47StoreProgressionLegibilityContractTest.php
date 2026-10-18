<?php

namespace Tests\Feature;

use Tests\TestCase;

class R47StoreProgressionLegibilityContractTest extends TestCase
{
    public function test_store_progression_uses_readable_bilingual_live_values(): void
    {
        $source = file_get_contents(base_path('../flutter_app/lib/main.dart'));

        $this->assertStringContainsString('class R47StoreProgressPanel extends StatelessWidget', $source);
        $this->assertStringContainsString("controller.localeCode == 'ar'", $source);
        $this->assertStringContainsString('controller.pointsToNextLevel', $source);
        $this->assertStringContainsString('controller.activeXpMultiplier', $source);
        $this->assertStringContainsString("ValueKey('r47-store-progress-panel')", $source);
        $this->assertStringContainsString("fontSize: 11.5, height: 1.3", $source);
        $this->assertStringContainsString("fontSize: 11, height: 1.35", $source);
        $this->assertStringContainsString("fontSize: 11, height: 1.15", $source);

        $start = strpos($source, 'class ProfileMetric extends StatelessWidget');
        $end = strpos($source, 'void showNotifications', $start);
        $this->assertNotFalse($start);
        $this->assertNotFalse($end);
        $progressSource = substr($source, $start, $end - $start);
        $this->assertStringNotContainsString('fontSize: 8', $progressSource);
    }
}
