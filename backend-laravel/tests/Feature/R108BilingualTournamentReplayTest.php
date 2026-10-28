<?php

namespace Tests\Feature;

use Tests\TestCase;

class R108BilingualTournamentReplayTest extends TestCase
{
    public function test_tournament_replay_is_bilingual_without_changing_replay_contracts(): void
    {
        $view = file_get_contents(resource_path('views/tournaments/replay.blade.php'));
        $controller = file_get_contents(app_path('Http/Controllers/TournamentController.php'));

        $this->assertIsString($view);
        $this->assertIsString($controller);

        foreach ([
            'تسجيل المسابقة',
            'Tournament replay',
            'العودة للمسابقات',
            'Back to tournaments',
            'توليد فيديو التسجيل',
            'Generate replay video',
            'سجل الحركات',
            'Action log',
            "app()->getLocale()",
            'dir="{{ $ar ? \'rtl\' : \'ltr\' }}"',
        ] as $label) {
            $this->assertStringContainsString($label, $view);
        }

        foreach ([
            'window.TOURNAMENT_REPLAY_FRAMES',
            'window.TOURNAMENT_FINAL_HANDS',
            'window.TOURNAMENT_REPLAY_TITLE',
            '@json($frames, JSON_UNESCAPED_UNICODE)',
            '@json($finalHands, JSON_UNESCAPED_UNICODE)',
            "route('tournaments')",
            'route(\'rooms.show\',$room->code)',
            'playTournamentReplay(false)',
            'playTournamentReplay(true)',
            'tournamentReplayCanvas',
            'tournamentReplayVideo',
        ] as $contract) {
            $this->assertStringContainsString($contract, $view);
        }

        $this->assertStringContainsString(
            "(\$state['phase'] ?? '') === 'finished'",
            $controller
        );
        $this->assertStringContainsString(
            "return view('tournaments.replay', compact('tournament','room','state','frames','finalHands'))",
            $controller
        );
    }
}
