<?php

namespace Tests\Feature;

use Tests\TestCase;

class R99BilingualClubDetailTest extends TestCase
{
    public function test_club_detail_localizes_controls_without_changing_authority_contracts(): void
    {
        $source = file_get_contents(resource_path('views/clubs/show.blade.php'));

        $this->assertIsString($source);
        foreach ([
            'Club identity and settings',
            'Players online now',
            'Club members',
            'Join requests',
            'Club announcements',
            'Create a club tournament',
            'Club activity log',
            'Back to clubs',
            'هوية وإعدادات النادي',
            'اللاعبون الموجودون الآن',
            'أعضاء المجموعة',
            'طلبات الانضمام',
            'إعلانات النادي',
            'إنشاء مسابقة للنادي',
            'سجل النادي',
            'العودة للمجموعات',
        ] as $localizedCopy) {
            $this->assertStringContainsString($localizedCopy, $source);
        }

        foreach ([
            "route('clubs.settings.update',\$club)",
            "route('clubs.memberAction',[\$club,\$m])",
            "route('clubs.respond',\$req)",
            "route('clubs.announcements.store',\$club)",
            "route('clubs.tournaments.store',\$club)",
            'value="public"',
            'value="request"',
            'value="private"',
            'value="moderator"',
            'value="kick"',
            'value="accepted"',
            'value="rejected"',
            'name="entry_fee"',
            'name="prize_pool"',
            'value="10000"',
            '@csrf',
        ] as $stableContract) {
            $this->assertStringContainsString($stableContract, $source);
        }
    }
}
