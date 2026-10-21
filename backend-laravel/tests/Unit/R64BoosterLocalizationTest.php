<?php

namespace Tests\Unit;

use App\Services\WarqnaPro\StoreCatalogService;
use PHPUnit\Framework\TestCase;

class R64BoosterLocalizationTest extends TestCase
{
    public function test_all_seven_server_booster_names_are_renamed_without_changing_identifiers_or_english(): void
    {
        $items = (new StoreCatalogService())->v183Items();
        $boosters = array_values(array_filter($items, fn (array $item): bool => $item['category'] === 'xp_booster'));
        $this->assertCount(7, $boosters);
        $expected = [
            'booster_yellow_v183' => 'Yellow Booster ×1.25',
            'booster_green_v183' => 'Green Booster ×1.5',
            'booster_red_v183' => 'Red Booster ×2',
            'booster_blue_v183' => 'Blue Booster ×2.5',
            'booster_black_v183' => 'Black Booster ×3',
            'booster_silver_v183' => 'Silver Booster ×4',
            'booster_gold_v183' => 'Gold Booster ×5',
        ];
        foreach ($boosters as $item) {
            $this->assertSame($expected[$item['key']], $item['en']);
            $this->assertStringStartsWith('معزز النقاط ', $item['ar']);
            $this->assertGreaterThan(0, (int) $item['price']);
            $this->assertGreaterThan(1, (float) $item['payload']['multiplier']);
        }
    }

    public function test_web_store_localizations_keep_english_category_unchanged(): void
    {
        $view = file_get_contents(__DIR__.'/../../resources/views/store/index.blade.php');
        $this->assertIsString($view);
        $this->assertStringContainsString("'xp_booster'=>'معزز النقاط'", $view);
        $this->assertStringContainsString("'xp_booster'=>'XP Boosters'", $view);
        $this->assertStringNotContainsString("'xp_booster'=>'مسرعات XP'", $view);
    }
}
