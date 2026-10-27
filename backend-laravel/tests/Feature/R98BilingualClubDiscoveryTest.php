<?php

namespace Tests\Feature;

use Tests\TestCase;

class R98BilingualClubDiscoveryTest extends TestCase
{
    public function test_club_discovery_localizes_copy_without_changing_membership_contracts(): void
    {
        $source = file_get_contents(resource_path('views/clubs/index.blade.php'));

        $this->assertIsString($source);
        foreach ([
            'المجموعات | ورقنا',
            'Clubs | Warqnaa',
            'صفحتها الكاملة',
            'Browse clubs at a glance',
            'اسم المجموعة الجديدة',
            'New club name',
            'إنشاء مجموعة للباشا - 5000 توكنز',
            'Create Pasha club — 5,000 tokens',
            'نقاط أسبوعية:',
            'Weekly points:',
            'فتح المجموعة',
            'Open club',
            'طلب انضمام',
            'Request to join',
        ] as $copy) {
            $this->assertStringContainsString($copy, $source);
        }

        foreach ([
            "route('clubs.store')",
            "route('clubs.show',\$club)",
            "route('clubs.join',\$club)",
            'name="name"',
            '@csrf',
            '$club->weekly_points',
            '$club->total_points',
            '$club->treasury',
        ] as $stableContract) {
            $this->assertStringContainsString($stableContract, $source);
        }

        $this->assertStringNotContainsString('اضغط على أي مجموعة لفتح صفحته الكاملة', $source);
    }
}
