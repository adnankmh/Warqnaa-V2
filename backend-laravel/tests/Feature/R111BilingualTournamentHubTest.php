<?php

namespace Tests\Feature;

use Tests\TestCase;

class R111BilingualTournamentHubTest extends TestCase
{
    public function test_tournament_hub_is_bilingual_without_changing_competition_contracts(): void
    {
        $view = file_get_contents(resource_path('views/tournaments/index.blade.php'));
        $controller = file_get_contents(app_path('Http/Controllers/TournamentController.php'));
        $layout = file_get_contents(resource_path('views/layouts/app.blade.php'));

        $this->assertIsString($view);
        $this->assertIsString($controller);
        $this->assertIsString($layout);

        foreach ([
            'المنافسات',
            'Competitions',
            'نظام المنافسات المعتمد',
            'Competition format',
            'إنشاء منافسة',
            'Create competition',
            'رسوم الدخول',
            'Entry fee',
            'الجائزة الأساسية',
            'Base prize',
            'تسجيل المنافسة وسجل المراحل',
            'Competition recording and stage log',
            'دخول المنافسة',
            'Join competition',
            'تشغيل عند اكتمال العدد',
            'Launch when full',
            "app()->isLocale('ar')",
            'dir="{{$ar?\'rtl\':\'ltr\'}}"',
        ] as $label) {
            $this->assertStringContainsString($label, $view);
        }

        foreach ([
            "route('tournaments.store')",
            "route('tournaments.join', \$t)",
            "route('tournaments.launch', \$t)",
            "route('tournaments.replay', \$t)",
            "route('rooms.show', \$match['room_code'])",
            'name="game_id"',
            'name="stages"',
            'name="seats_per_match"',
            'name="entry_fee"',
            'name="prize_pool"',
            '$t->creator_id === auth()->id() || auth()->user()->is_admin',
            '$t->entries->count()',
            '$t->prize_distribution',
            '$t->leaderboard_points',
            'Math.floor(total*entry*.90)',
            'creationFee=1000',
            'Math.floor(expectedPrize*.55)',
            'Math.floor(expectedPrize*.30)',
            'Math.floor(expectedPrize*.10)',
        ] as $contract) {
            $this->assertStringContainsString($contract, $view);
        }

        foreach ([
            "Tournament::with('creator.profile','game','entries.user.profile')->latest()->get()",
            "Game::where('active',true)->whereIn('key', GameCatalog::customerKeys())->get()",
            "'entry_fee'=>'required|integer|min:0|max:1000000'",
            "'prize_pool'=>'required|integer|min:0|max:100000000'",
            'DB::transaction',
            "tournament_prize_escrow",
            "tournament_entry",
            "lockForUpdate()",
            "replay_mode'=>'event_log_with_final_hands'",
            "(\$state['phase'] ?? '') === 'finished'",
        ] as $controllerContract) {
            $this->assertStringContainsString($controllerContract, $controller);
        }

        $this->assertStringContainsString('data-theme="{{ $siteTheme }}"', $layout);
        $this->assertStringContainsString('theme-{{ $siteTheme }}', $layout);
    }
}
