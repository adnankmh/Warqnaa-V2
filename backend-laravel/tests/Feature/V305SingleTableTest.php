<?php

namespace Tests\Feature;

use App\Models\StoreItem;
use App\Services\WarqnaPro\StoreCatalogService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class V305SingleTableTest extends TestCase
{
    use RefreshDatabase;

    public function test_store_has_exactly_one_active_free_table_and_one_active_free_card_back(): void
    {
        (new StoreCatalogService())->sync();
        $tables=StoreItem::query()->where('category','table')->where('active',true)->get();
        $backs=StoreItem::query()->where('category','card_back')->where('active',true)->get();
        $this->assertCount(1,$tables);
        $this->assertCount(1,$backs);
        $this->assertSame('v305_table_emerald_royal',$tables->first()->key);
        $this->assertSame(0,(int)$tables->first()->price);
        $this->assertSame('v305_cardback_emerald_royal',$backs->first()->key);
        $this->assertSame(0,(int)$backs->first()->price);
    }
}
