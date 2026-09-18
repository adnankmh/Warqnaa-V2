<?php

namespace Tests\Feature;

use App\Models\StoreItem;
use App\Services\WarqnaPro\StoreCatalogService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class V305SingleTableTest extends TestCase
{
    use RefreshDatabase;

    public function test_r61_store_keeps_free_starter_pair_and_curated_matching_collection(): void
    {
        (new StoreCatalogService())->sync();
        $tables=StoreItem::query()->where('category','table')->where('active',true)->get();
        $backs=StoreItem::query()->where('category','card_back')->where('active',true)->get();
        $this->assertCount(51,$tables);
        $this->assertCount(63,$backs);
        $starterTable=$tables->firstWhere('key','v305_table_emerald_royal');
        $starterBack=$backs->firstWhere('key','v305_cardback_emerald_royal');
        $this->assertNotNull($starterTable);
        $this->assertNotNull($starterBack);
        $this->assertSame(0,(int)$starterTable->price);
        $this->assertSame(0,(int)$starterBack->price);
        $this->assertCount(50,$backs->filter(fn($item)=>str_starts_with($item->key,'r61_cardback_table_v173_')));
        $this->assertSame('table_v173_royal_01',$backs->firstWhere('key','r61_cardback_table_v173_royal_01')->payload['paired_table']);
    }
}
