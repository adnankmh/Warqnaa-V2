<?php

namespace Tests\Feature;

use Tests\TestCase;

class R94BilingualPageTitlesTest extends TestCase
{
    public function test_page_specific_titles_do_not_override_the_active_locale(): void
    {
        $cases = [
            'home.blade.php' => ['العب وتواصل بطريقتك', 'Play and connect your way'],
            'store/offers.blade.php' => ['العروض والشراء', 'Offers & checkout'],
            'social-world/index.blade.php' => ['العالم الاجتماعي', 'Social World'],
            'social-world/spectator.blade.php' => ['المدرجات المباشرة', 'Live Stands'],
            'social-world/replay.blade.php' => ['إعادة المباراة', 'Match Replay'],
            'competitive/index.blade.php' => ['الساحة التنافسية', 'Competitive Arena'],
        ];

        foreach ($cases as $path => [$arabic, $english]) {
            $source = file_get_contents(resource_path('views/'.$path));
            $this->assertIsString($source, $path);
            $this->assertStringContainsString("app()->isLocale('ar')", $source, $path);
            $this->assertStringContainsString($arabic, $source, $path);
            $this->assertStringContainsString($english, $source, $path);
        }
    }
}
