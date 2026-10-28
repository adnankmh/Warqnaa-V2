<?php

namespace Tests\Feature;

use Tests\TestCase;

class R106BilingualCompetitiveAdminTest extends TestCase
{
    public function test_competitive_admin_is_bilingual_without_changing_control_contracts(): void
    {
        $view = file_get_contents(resource_path('views/admin/competitive.blade.php'));

        $this->assertIsString($view);

        foreach ([
            'إدارة ساحة المنافسات',
            'Competitive Arena Admin',
            'قائمة مراجعة النزاهة',
            'Integrity review queue',
            'إنشاء بطولة',
            'Create championship',
            'dir="',
            "app()->isLocale('ar')",
        ] as $label) {
            $this->assertStringContainsString($label, $view);
        }

        foreach ([
            'competitive_enabled',
            'ranked_matchmaking_enabled',
            'season_rewards_enabled',
            'club_championships_enabled',
            'country_championships_enabled',
            'ranked_queue_timeout_minutes',
            'ranked_abandon_penalty',
            'rating_soft_reset_factor',
            'placement_games',
            'single_elimination',
            'league_playoffs',
            'group_playoffs',
            'entry_fee',
            'prize_pool',
            'min_rating',
            'approve',
            'void',
            'activate',
            'finalize',
            'cancel',
        ] as $contract) {
            $this->assertStringContainsString($contract, $view);
        }

        foreach ([
            "route('admin.competitive.settings')",
            "route('admin.competitive.season.create')",
            "route('admin.competitive.season.action',\$season)",
            "route('admin.competitive.tournament.create')",
            "route('admin.competitive.match.action',\$match)",
            "route('admin.competitive.tournament.bracket',\$tournament)",
            "url('/admin/competitive/ratings')",
        ] as $endpoint) {
            $this->assertStringContainsString($endpoint, $view);
        }

        $this->assertStringContainsString('Verified support settlement', $view);
        $this->assertStringContainsString('Integrity review completed', $view);
    }
}
