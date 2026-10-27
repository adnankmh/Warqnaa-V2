<?php

namespace Tests\Feature;

use Tests\TestCase;

class R102BilingualEconomySurfaceTest extends TestCase
{
    public function test_economy_surface_localizes_copy_without_changing_catalog_or_economy_queries(): void
    {
        $view = file_get_contents(resource_path('views/economy/index.blade.php'));
        $controller = file_get_contents(app_path('Http/Controllers/EconomyController.php'));

        $this->assertIsString($view);
        $this->assertIsString($controller);

        foreach ([
            'المواسم والعروض النادرة',
            'Seasons and rare offers',
            'الموسم الحالي',
            'Current season',
            'العروض النشطة',
            'Active offers',
            'مقتنيات نادرة',
            'Rare collectibles',
            'عناصر مميزة',
            'Featured items',
            'معاينة',
            'Preview',
        ] as $localizedCopy) {
            $this->assertStringContainsString($localizedCopy, $view);
        }

        foreach ([
            "route('store')",
            '$season->rewards',
            '$offer->discount_percent',
            'rarity-{{ $rare->rarity }}',
            '$rare->claimed',
            '$rare->supply',
            'data-category="{{ $item->category }}"',
            'data-item-key="{{ $item->key }}"',
            '$item->price',
            'previewStoreItem(this)',
        ] as $stableViewContract) {
            $this->assertStringContainsString($stableViewContract, $view);
        }

        foreach ([
            "EconomySeason::where('active',true)->latest()->first()",
            "StoreOffer::where('active',true)->latest()->get()",
            "RareCollectible::where('active',true)->latest()->get()",
            "StoreItem::where('active',true)",
            "whereIn('category',['table','card_back','effect','xp_booster','emoji_pack'])",
            "latest()->limit(16)->get()",
            "compact('season','offers','rares','featured')",
        ] as $stableControllerContract) {
            $this->assertStringContainsString($stableControllerContract, $controller);
        }
    }
}
