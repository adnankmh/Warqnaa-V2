<?php

namespace Tests\Feature;

use Tests\TestCase;

class R109BilingualGameRulesTest extends TestCase
{
    public function test_game_rules_are_bilingual_without_changing_catalog_or_room_contracts(): void
    {
        $view = file_get_contents(resource_path('views/games/rules.blade.php'));
        $rules = file_get_contents(config_path('warqna_game_rules.php'));
        $controller = file_get_contents(app_path('Http/Controllers/GameController.php'));

        $this->assertIsString($view);
        $this->assertIsString($rules);
        $this->assertIsString($controller);

        foreach ([
            'قوانين الألعاب',
            'Game rules',
            'اقرأ المزيد عن قوانين',
            'Read more about',
            'الترجمات المتاحة',
            'Available translations',
            'دخول غرف اللعبة',
            'Enter game rooms',
            "app()->getLocale()",
            'dir="{{ $ar ? \'rtl\' : \'ltr\' }}"',
        ] as $label) {
            $this->assertStringContainsString($label, $view);
        }

        foreach ([
            "route('rooms.index',\$game->key)",
            '@foreach($games as $game)',
            "\$game->min_players",
            "\$game->max_players",
            "\$game->partnership",
            "\$game->name[\$locale]",
            "\$ruleGuide[\$game->key]",
            "\$guide['core']",
            "\$guide['core_en']",
        ] as $contract) {
            $this->assertStringContainsString($contract, $view);
        }

        foreach ([
            "'tarneeb'",
            "'hand'",
            "'banakil'",
            "'trix'",
            "'baloot'",
            "'domino'",
            "'backgammon'",
            "'summary_en'",
            "'core_en'",
            'يمكن الإضافة على مجموعات الشريك.',
            'لا يجوز للخصم الإضافة على مجموعات لاعب أو فريق آخر.',
            'عند اختيار ورقة مدفونة من كومة الرمي تُسحب هي وكل الأوراق الأحدث فوقها فقط.',
            'A player may lay off on a partner’s meld.',
            'An opponent may not lay off on another player’s or team’s meld.',
            'Choosing a buried discard takes that card and every newer card above it—nothing below it.',
        ] as $ruleContract) {
            $this->assertStringContainsString($ruleContract, $rules);
        }

        $this->assertStringContainsString('GameCatalog::customerKeys()', $controller);
        $this->assertStringContainsString("where('active',true)", $controller);
        $this->assertStringContainsString("config('warqna_game_rules',[])", $controller);
    }
}
