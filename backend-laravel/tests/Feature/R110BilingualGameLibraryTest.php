<?php

namespace Tests\Feature;

use Tests\TestCase;

class R110BilingualGameLibraryTest extends TestCase
{
    public function test_professional_game_library_is_bilingual_without_changing_game_contracts(): void
    {
        $view = file_get_contents(resource_path('views/games/library_pro.blade.php'));
        $controller = file_get_contents(app_path('Http/Controllers/GameLibraryController.php'));
        $layout = file_get_contents(resource_path('views/layouts/app.blade.php'));
        $matrix = require config_path('warqna_games_matrix.php');

        $this->assertIsString($view);
        $this->assertIsString($controller);
        $this->assertIsString($layout);

        foreach ([
            'مكتبة ألعاب Warqnaa الاحترافية',
            'Warqnaa professional game library',
            'فتح كل الألعاب',
            'Open all games',
            'المحرك',
            'Engine',
            'عدد اللاعبين',
            'Players',
            'دخول اللعبة',
            'Enter game',
            'مبادئ الحماية',
            'Protection principles',
            "app()->getLocale()",
            'dir="{{ $ar ? \'rtl\' : \'ltr\' }}"',
        ] as $label) {
            $this->assertStringContainsString($label, $view);
        }

        foreach ([
            "@foreach(\$matrix['families'] as \$familyKey=>\$family)",
            "@foreach(\$family['games'] as \$gk)",
            "\$matrix['supported'][\$gk]",
            "\$g['engine']",
            "\$g['players']",
            "\$g['difficulty']",
            "route('rooms.index',\$gk)",
            "route('games')",
        ] as $contract) {
            $this->assertStringContainsString($contract, $view);
        }

        $this->assertSame(
            ['trick_taking', 'melding', 'contracts', 'board'],
            array_keys($matrix['families'])
        );
        $this->assertCount(20, $matrix['supported']);

        $expected = [
            'tarneeb' => [4, 'tarneeb', 'advanced'],
            'hand' => [4, 'hand', 'advanced'],
            'banakil' => [4, 'hand', 'advanced'],
            'trix' => [4, 'contract', 'advanced'],
            'baloot' => [4, 'trick_taking', 'expert'],
            'domino' => [4, 'domino', 'medium'],
            'backgammon' => [2, 'board', 'medium'],
            'chess' => [2, 'board', 'expert'],
        ];

        foreach ($expected as $key => [$players, $engine, $difficulty]) {
            $this->assertSame($players, $matrix['supported'][$key]['players']);
            $this->assertSame($engine, $matrix['supported'][$key]['engine']);
            $this->assertSame($difficulty, $matrix['supported'][$key]['difficulty']);
            $this->assertNotSame('', $matrix['supported'][$key]['ar']);
            $this->assertNotSame('', $matrix['supported'][$key]['en']);
        }

        foreach ($matrix['families'] as $family) {
            $this->assertNotSame('', $family['ar']);
            $this->assertNotSame('', $family['en']);
        }

        $this->assertStringContainsString("config('warqna_games_matrix')", $controller);
        $this->assertStringContainsString("view('games.library_pro',['matrix'=>\$matrix])", $controller);
        $this->assertStringContainsString('data-theme="{{ $siteTheme }}"', $layout);
        $this->assertStringContainsString('theme-{{ $siteTheme }}', $layout);
    }
}
