<?php

namespace Tests\Feature;

use Tests\TestCase;

class R97BilingualCompetitiveControlsTest extends TestCase
{
    public function test_competitive_arena_localizes_controls_without_changing_submitted_values(): void
    {
        $source = file_get_contents(resource_path('views/competitive/index.blade.php'));

        $this->assertIsString($source);
        foreach ([
            'منافسات موثقة • لعب عادل',
            'VERIFIED COMPETITION • FAIR PLAY',
            'الخادم هو المرجع',
            'Server authoritative',
            'البحث المصنف',
            'RANKED MATCHMAKING',
            'الشرق الأوسط وشمال أفريقيا',
            'MENA',
            'الدوريات والكؤوس',
            'LEAGUES & CUPS',
            'التصنيف العالمي',
            'GLOBAL LADDER',
            'جوائز الموسم',
            'SEASON REWARDS',
            'استلام',
            'Claim',
        ] as $copy) {
            $this->assertStringContainsString($copy, $source);
        }

        foreach ([
            "'levant'",
            "'mena'",
            "'gcc'",
            "'global'",
            "'waiting'",
            "'matching'",
            "'matched'",
            "name=\"region\"",
            "name=\"preferred_seats\"",
        ] as $stableValue) {
            $this->assertStringContainsString($stableValue, $source);
        }

        $this->assertStringNotContainsString('R12 • BUILD 240 • COMPETITIVE', $source);
    }
}
