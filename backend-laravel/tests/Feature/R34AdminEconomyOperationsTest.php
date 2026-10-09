<?php

namespace Tests\Feature;

use App\Models\{EconomySeason, RareCollectible, StoreItem, StoreOffer, User};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class R34AdminEconomyOperationsTest extends TestCase
{
    use RefreshDatabase;

    private function actor(bool $admin): User
    {
        return User::create([
            'username' => $admin ? 'r34_admin' : 'r34_guest',
            'email' => $admin ? 'r34-admin@example.test' : 'r34-guest@example.test',
            'password' => Hash::make('random-local-test-only'),
            'is_admin' => $admin,
            'admin_role' => $admin ? 'primary_admin' : null,
        ]);
    }

    public function test_non_admin_cannot_operate_economy(): void
    {
        $this->actingAs($this->actor(false))->post(route('admin.economy.season'), [
            'key' => 'r34_unauthorized', 'name_ar' => 'موسم',
            'starts_at' => '2026-10-10', 'ends_at' => '2026-10-12',
        ])->assertForbidden();
        $this->assertDatabaseMissing('economy_seasons', ['key' => 'r34_unauthorized']);
    }

    public function test_season_save_is_real_and_repeated_updates_are_idempotent(): void
    {
        $this->actingAs($this->actor(true));
        $request = [
            'key' => 'r34_real_season', 'name_ar' => 'موسم أول',
            'starts_at' => '2026-10-10', 'ends_at' => '2026-10-17', 'active' => 1,
        ];
        $this->post(route('admin.economy.season'), $request)->assertRedirect();
        $this->post(route('admin.economy.season'), array_merge($request, ['name_ar'=>'موسم معدل']))->assertRedirect();
        $this->assertSame(1, EconomySeason::where('key', $request['key'])->count());
        $this->assertSame('موسم معدل', EconomySeason::where('key', $request['key'])->firstOrFail()->name['ar']);
    }

    public function test_offer_requires_existing_products_and_dates(): void
    {
        $this->actingAs($this->actor(true));
        $data = [
            'key' => 'r34_safe_offer', 'title_ar' => 'عرض الموسم',
            'discount_percent' => 25, 'starts_at' => '2026-10-10',
            'ends_at' => '2026-10-17', 'item_keys' => 'r34_nonexistent',
            'active' => 1,
        ];
        $this->post(route('admin.economy.offer'), $data)->assertSessionHasErrors('item_keys');
        $this->assertDatabaseMissing('store_offers', ['key' => $data['key']]);
        StoreItem::create([
            'key'=>'r34_test_table','category'=>'table','name'=>['ar'=>'طاولة','en'=>'Table'],
            'price'=>1000,'active'=>true,
        ]);
        $this->post(route('admin.economy.offer'), array_merge($data, ['item_keys'=>'r34_test_table']))
            ->assertRedirect();
        $this->assertSame(['r34_test_table'], StoreOffer::where('key', $data['key'])->firstOrFail()->item_keys);
    }

    public function test_rare_item_cannot_reduce_supply_below_claims(): void
    {
        $this->actingAs($this->actor(true));
        $item = RareCollectible::create([
            'key'=>'r34_test_relic','name'=>['ar'=>'إطار','en'=>'Frame'],
            'rarity'=>'rare','supply'=>100,'claimed'=>25,'active'=>true,
        ]);
        $input = [
            'key'=>$item->key,'name_ar'=>'إطار محدود','rarity'=>'epic',
            'supply'=>10,'active'=>1,
        ];
        $this->post(route('admin.economy.rare'), $input)->assertSessionHasErrors('supply');
        $this->assertSame(100, (int)$item->fresh()->supply);
        $this->post(route('admin.economy.rare'), array_merge($input, ['supply'=>150]))->assertRedirect();
        $this->assertSame(25, (int)$item->fresh()->claimed);
        $this->assertSame(150, (int)$item->fresh()->supply);
    }
}
