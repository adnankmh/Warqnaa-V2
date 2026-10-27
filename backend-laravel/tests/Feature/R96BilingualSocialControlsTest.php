<?php

namespace Tests\Feature;

use Tests\TestCase;

class R96BilingualSocialControlsTest extends TestCase
{
    public function test_social_world_controls_localize_labels_without_changing_submitted_values(): void
    {
        $source = file_get_contents(resource_path('views/social-world/index.blade.php'));

        $this->assertIsString($source);
        foreach ([
            'مجتمع اللاعبين • الخصوصية أولًا',
            'PLAYER COMMUNITY • PRIVACY FIRST',
            'يبحث عن مباراة',
            'Looking for game',
            'المتابعون',
            'Followers',
            'قادمة',
            'Scheduled',
            'الحالة العامة',
            'Privacy-safe replay',
            'الظهور في البحث',
            'Appear in search',
            'مشاهدة مبارياتي',
            'Spectate my matches',
            'نوع المنشور',
            'Post type',
        ] as $copy) {
            $this->assertStringContainsString($copy, $source);
        }

        foreach ([
            "'status'=>",
            "'looking_for_game'=>",
            "'achievement'=>",
            "'public'=>",
            "'friends'=>",
            "'followers'=>",
            "'private'=>",
            "'everyone'=>",
            "'nobody'=>",
        ] as $stableValue) {
            $this->assertStringContainsString($stableValue, $source);
        }

        $this->assertStringNotContainsString('R11 • BUILD 230', $source);
    }
}
