<?php

namespace Tests\Feature;

use Tests\TestCase;

class R95BilingualSpectatorReplayShellTest extends TestCase
{
    public function test_spectator_and_replay_shells_keep_arabic_and_english_copy(): void
    {
        $spectator = file_get_contents(resource_path('views/social-world/spectator.blade.php'));
        $replay = file_get_contents(resource_path('views/social-world/replay.blade.php'));

        $this->assertIsString($spectator);
        $this->assertIsString($replay);

        foreach ([
            'مباشر • للقراءة فقط',
            'LIVE • READ ONLY',
            'درع الخصوصية مفعّل',
            'Privacy Shield active',
            'الدور الحالي',
            'Current turn',
            'الحالة العامة الآمنة',
            'Safe public state',
        ] as $copy) {
            $this->assertStringContainsString($copy, $spectator);
        }

        foreach ([
            'إعادة آمنة تحمي الخصوصية',
            'PRIVACY-SAFE REPLAY',
            'عقد خصوصية الإعادة',
            'Replay Privacy Contract',
            'اللقطة السابقة',
            'Previous frame',
            'موضع الإعادة',
            'Replay position',
        ] as $copy) {
            $this->assertStringContainsString($copy, $replay);
        }

        $this->assertStringContainsString('data-fallback-phase', $spectator);
        $this->assertStringContainsString('data-ready-label', $replay);
        $this->assertStringContainsString("x.action||ready", $replay);
    }
}
