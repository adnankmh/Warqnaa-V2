<?php

namespace Tests\Feature;

use App\Models\{CompetitionTicket,DailyRewardClaim,InventoryItem,Profile,StoreItem,StoreOffer,User,Wallet,WalletTransaction};
use App\Services\WarqnaPro\StoreCatalogService;
use App\Services\Commerce\StoreOfferPricingService;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class R36OffersAndDailyClaimIntegrityTest extends TestCase
{
    use RefreshDatabase;

    protected function tearDown(): void
    {
        Carbon::setTestNow();
        parent::tearDown();
    }

    private function player(): User
    {
        $user = User::create([
            'username' => 'r36_player', 'email' => 'r36-player@example.test',
            'password' => Hash::make('local-test-only-password'),
            'is_admin' => false, 'admin_role' => 'player',
        ]);
        Wallet::create(['user_id'=>$user->id, 'tokens'=>1000, 'gems'=>0]);
        Profile::create([
            'user_id'=>$user->id, 'display_name'=>'R36 Player',
            'country_code'=>'PS', 'country_name'=>'Palestine',
        ]);
        return $user;
    }

    private function item(string $key, int $price = 1000): StoreItem
    {
        return StoreItem::create([
            'key'=>$key, 'name'=>['ar'=>'عنصر تجريبي','en'=>'Test item'],
            'category'=>'profile_cover', 'price'=>$price, 'active'=>true,
            'payload'=>['cover'=>$key, 'r91_price_normalized'=>true, 'r91_base_price'=>$price],
        ]);
    }

    private function offer(string $key, array $keys, int $percent, array $changes=[]): StoreOffer
    {
        return StoreOffer::create(array_merge([
            'key'=>$key, 'title'=>['ar'=>'عرض','en'=>'Offer'],
            'description'=>['ar'=>'خصم','en'=>'Discount'],
            'discount_percent'=>$percent,
            'item_keys'=>$keys, 'active'=>true,
            'starts_at'=>'2026-10-09 00:00:00',
            'ends_at'=>'2026-10-12 23:59:59',
        ], $changes));
    }

    public function test_offers_do_not_stack_and_only_apply_to_valid_items_and_dates(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $item = $this->item('r36_target');
        $other = $this->item('r36_other');
        $this->offer('r36_small', [$item->key], 10);
        $this->offer('r36_large', [$item->key], 25);
        $this->offer('r36_expired', [$item->key], 80, ['ends_at'=>'2026-10-09 09:00:00']);
        $this->offer('r36_inactive', [$item->key], 90, ['active'=>false]);

        $pricing = app(StoreOfferPricingService::class);
        $quote = $pricing->quote($item);
        $this->assertSame(750, $quote['price']);
        $this->assertSame(1000, $quote['original_price']);
        $this->assertSame(25, $quote['discount_percent']);
        $this->assertSame('r36_large', $quote['offer_key']);
        $this->assertSame(1000, $pricing->quote($other)['price']);
        $this->assertSame(750, $pricing->quotesFor(collect([$item]))[$item->id]['price']);

        Carbon::setTestNow('2026-10-13 00:00:00');
        $this->assertSame(1000, $pricing->quote($item)['price']);
    }

    public function test_mobile_store_charges_the_quote_and_rejects_stale_price(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $item = $this->item('r36_discounted_badge');
        $this->offer('r36_silver', [$item->key], 25);
        $this->withToken($user->createToken('r36-tests')->plainTextToken);

        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key, 'confirmed'=>true, 'expected_price'=>1000,
        ])->assertStatus(409);
        $this->assertSame(1000, (int)$user->wallet()->firstOrFail()->tokens);

        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key, 'confirmed'=>true, 'expected_price'=>750,
        ])->assertOk()
          ->assertJsonPath('pricing.price', 750)
          ->assertJsonPath('pricing.offer_key', 'r36_silver');
        $this->assertSame(250, (int)$user->wallet()->firstOrFail()->tokens);
        $tx = WalletTransaction::where('user_id',$user->id)->where('type','store_purchase')->firstOrFail();
        $this->assertSame('r36_silver', $tx->meta['offer_key']);
        $this->assertSame(25, $tx->meta['discount_percent']);
        $this->assertSame(1, $user->inventoryItems()->where('store_item_id',$item->id)->count());

        // A non-renewable collectible must not charge the player twice.
        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key, 'confirmed'=>true, 'expected_price'=>750,
        ])->assertStatus(409);
        $this->assertSame(250, (int)$user->wallet()->firstOrFail()->tokens);
        $this->assertSame(1, WalletTransaction::where('user_id',$user->id)->where('type','store_purchase')->count());
        $this->assertSame(1, $user->inventoryItems()->where('store_item_id',$item->id)->count());
    }

    public function test_expired_discount_must_not_allow_checkout_using_stale_price(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $item = $this->item('r36_expiring_cover');
        $this->offer('r36_ends', [$item->key], 25);
        $this->withToken($user->createToken('r36-expired')->plainTextToken);

        Carbon::setTestNow('2026-10-13 00:00:00');
        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key, 'confirmed'=>true, 'expected_price'=>750,
        ])->assertStatus(409)->assertJsonPath('pricing.price', 1000);
        $this->assertSame(1000, (int)$user->wallet()->firstOrFail()->tokens);
        $this->assertSame(0, WalletTransaction::where('user_id',$user->id)->where('type','store_purchase')->count());
        $this->assertSame(0, $user->inventoryItems()->where('store_item_id',$item->id)->count());
    }

    public function test_mobile_bootstrap_displays_the_actual_discounted_store_price(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $item = $this->item('r36_bootstrap_badge');
        $this->offer('r36_bootstrap_offer', [$item->key], 25);
        $this->withToken($user->createToken('r36-store-bootstrap')->plainTextToken);
        $response = $this->getJson('/api/mobile/v1/bootstrap')->assertOk();
        $row = collect($response->json('store'))->firstWhere('key', $item->key);
        $this->assertNotNull($row);
        $this->assertSame(750, $row['price']);
        $this->assertSame(1000, $row['original_price']);
        $this->assertSame(25, $row['discount_percent']);
    }

    public function test_web_store_rejects_repeat_permanent_purchase_without_second_debit(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $item = $this->item('r36_web_collectible');
        $this->offer('r36_web_offer', [$item->key], 25);
        $this->actingAs($user);

        $this->postJson(route('store.buy', ['item'=>$item->id]), [
            'expected_price'=>750,
        ])->assertOk()->assertJsonPath('ok', true)
          ->assertJsonPath('pricing.price', 750);

        $this->assertSame(250, (int)$user->wallet()->firstOrFail()->tokens);
        $this->assertSame(1, WalletTransaction::where('user_id',$user->id)->where('type','store_buy')->count());
        $this->assertSame(1, $user->inventoryItems()->where('store_item_id',$item->id)->count());

        $this->postJson(route('store.buy', ['item'=>$item->id]), [
            'expected_price'=>750,
        ])->assertOk()->assertJsonPath('ok', false);

        $this->assertSame(250, (int)$user->wallet()->firstOrFail()->tokens);
        $this->assertSame(1, WalletTransaction::where('user_id',$user->id)->where('type','store_buy')->count());
        $this->assertSame(1, $user->inventoryItems()->where('store_item_id',$item->id)->count());
    }

    public function test_web_checkout_rejects_expired_promotion_price_without_debit(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $item = $this->item('r36_web_offer_expiry');
        $this->offer('r36_web_expired', [$item->key], 25);
        $this->actingAs($user);

        Carbon::setTestNow('2026-10-13 00:00:00');
        $this->postJson(route('store.buy', ['item'=>$item->id]), [
            'expected_price'=>750,
        ])->assertOk()->assertJsonPath('ok', false);

        $this->assertSame(1000, (int)$user->wallet()->firstOrFail()->tokens);
        $this->assertSame(0, WalletTransaction::where('user_id',$user->id)->where('type','store_buy')->count());
        $this->assertSame(0, $user->inventoryItems()->where('store_item_id',$item->id)->count());
    }

    public function test_rewarded_ad_cannot_mint_tokens_from_client_supplied_id(): void
    {
        $user = $this->player();
        $this->withToken($user->createToken('r36-fake-ad')->plainTextToken);
        $this->postJson('/api/mobile/v1/rewards/rewarded-ad', [
            'verification_id'=>'unverified-client-claim-123456',
            'network'=>'admob',
        ])->assertStatus(503)->assertJsonPath('ok', false);
        $this->assertSame(1000, (int)$user->wallet()->firstOrFail()->tokens);
        $this->assertSame(0, WalletTransaction::where('user_id',$user->id)->where('type','rewarded_ad')->count());
    }

    public function test_mobile_paid_booster_activates_once_and_each_new_purchase_is_separate(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $user->wallet()->update(['tokens'=>200000]);
        app(StoreCatalogService::class)->sync();
        $item = StoreItem::where('key','booster_yellow_v183')->firstOrFail();
        $price = app(StoreOfferPricingService::class)->quote($item)['price'];
        $this->withToken($user->createToken('r36-booster')->plainTextToken);

        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key, 'confirmed'=>true, 'expected_price'=>$price,
        ])->assertOk()->assertJsonPath('ok', true);
        $first = $user->inventoryItems()->where('store_item_id',$item->id)->firstOrFail();
        $this->assertNull($first->activated_at);

        $this->postJson('/api/mobile/v1/store/activate', ['key'=>$item->key])
            ->assertOk()->assertJsonPath('ok', true);
        $this->postJson('/api/mobile/v1/store/activate', ['key'=>$item->key])
            ->assertStatus(409);
        $this->assertNotNull($first->fresh()->activated_at);

        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key, 'confirmed'=>true, 'expected_price'=>$price,
        ])->assertOk()->assertJsonPath('ok', true);
        $this->assertSame(2, $user->inventoryItems()->where('store_item_id',$item->id)->count());
        $this->postJson('/api/mobile/v1/store/activate', ['key'=>$item->key])
            ->assertOk()->assertJsonPath('ok', true);
        $this->postJson('/api/mobile/v1/store/activate', ['key'=>$item->key])
            ->assertStatus(409);
        $this->assertSame(2, $user->inventoryItems()->where('store_item_id',$item->id)
            ->whereNotNull('activated_at')->count());
        $this->assertSame(200000-2*$price, (int)$user->wallet()->firstOrFail()->tokens);
    }

    public function test_mobile_booster_honors_delisted_catalog_and_preserves_expired_audit(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $item = StoreItem::create([
            'key'=>'r36_delisted_booster', 'category'=>'xp_booster',
            'name'=>['ar'=>'مسرع','en'=>'Booster'], 'price'=>1000,
            'active'=>false, 'duration_days'=>2,
            'payload'=>['multiplier'=>1.5,'activate_hours'=>24],
        ]);
        $expired = InventoryItem::create([
            'user_id'=>$user->id, 'store_item_id'=>$item->id,
            'active'=>false,'expires_at'=>now()->subMinute(),
        ]);
        $this->withToken($user->createToken('r36-delisted')->plainTextToken);
        $this->postJson('/api/mobile/v1/store/activate', ['key'=>$item->key])
            ->assertStatus(410);
        $this->assertNotNull($expired->fresh());
        $this->assertNull($expired->fresh()->activated_at);

        $expired->update(['expires_at'=>now()->addDay()]);
        $this->postJson('/api/mobile/v1/store/activate', ['key'=>$item->key])
            ->assertOk()->assertJsonPath('ok', true);
        $this->postJson('/api/mobile/v1/store/activate', ['key'=>$item->key])
            ->assertStatus(409);
    }

    public function test_web_cosmetic_activation_keeps_expiry_and_rejects_expired_use(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $item = StoreItem::create([
            'key'=>'r36_timed_profile', 'category'=>'profile_color',
            'name'=>['ar'=>'لون','en'=>'Color'], 'price'=>1000,
            'duration_days'=>2, 'active'=>true,
            'payload'=>['gradient'=>['#123456','#abcdef']],
        ]);
        $expiry = now()->addDay();
        $inventory = InventoryItem::create([
            'user_id'=>$user->id,'store_item_id'=>$item->id,
            'active'=>false,'expires_at'=>$expiry,
        ]);
        $this->actingAs($user);
        $this->postJson(route('inventory.activate',['inventory'=>$inventory->id]))
            ->assertOk()->assertJsonPath('ok',true);
        $this->assertSame($expiry->toDateTimeString(), $inventory->fresh()->expires_at->toDateTimeString());
        $this->assertSame($expiry->toDateTimeString(),
            $user->profile()->firstOrFail()->profile_color_expires_at->toDateTimeString());

        Carbon::setTestNow('2026-10-12 10:00:00');
        $this->postJson(route('inventory.activate',['inventory'=>$inventory->id]))
            ->assertStatus(410)->assertJsonPath('ok',false);
        $this->assertSame($expiry->toDateTimeString(), $inventory->fresh()->expires_at->toDateTimeString());
    }

    public function test_web_booster_cannot_reactivate_without_another_paid_entitlement(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $item = StoreItem::create([
            'key'=>'r36_web_booster', 'category'=>'xp_booster',
            'name'=>['ar'=>'مسرع','en'=>'Booster'], 'price'=>1000,
            'active'=>true, 'duration_days'=>3,
            'payload'=>['multiplier'=>1.5, 'activate_hours'=>24],
        ]);
        $inventory = InventoryItem::create([
            'user_id'=>$user->id,'store_item_id'=>$item->id,
            'active'=>false,'expires_at'=>now()->addDays(3),
        ]);
        $this->actingAs($user);
        $this->postJson(route('inventory.activate',['inventory'=>$inventory->id]))
            ->assertOk()->assertJsonPath('ok',true);
        $this->postJson(route('inventory.activate',['inventory'=>$inventory->id]))
            ->assertStatus(409)->assertJsonPath('ok',false);
        $this->assertSame(1,$user->inventoryItems()->whereNotNull('activated_at')->count());
    }

    public function test_second_booster_purchase_preserves_active_effect_and_has_new_expiry(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $user->wallet()->update(['tokens'=>200000]);
        app(StoreCatalogService::class)->sync();
        $item = StoreItem::where('key','booster_yellow_v183')->firstOrFail();
        $price = app(StoreOfferPricingService::class)->quote($item)['price'];
        $this->withToken($user->createToken('r36-booster-renewal')->plainTextToken);

        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key,'confirmed'=>true,'expected_price'=>$price,
        ])->assertOk();
        $this->postJson('/api/mobile/v1/store/activate',['key'=>$item->key])->assertOk();
        $first = $user->inventoryItems()->where('store_item_id',$item->id)->firstOrFail();
        $this->assertTrue((bool)$first->active);
        $this->assertNotNull($first->activated_at);
        $firstActiveExpiry = $first->expires_at->toDateTimeString();

        // Purchasing the next booster must NOT deactivate the first, nor carry over its expiry.
        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key,'confirmed'=>true,'expected_price'=>$price,
        ])->assertOk();
        $second = $user->inventoryItems()->where('store_item_id',$item->id)
            ->whereNull('activated_at')->firstOrFail();
        $this->assertTrue((bool)$first->fresh()->active);
        $this->assertSame($firstActiveExpiry, $first->fresh()->expires_at->toDateTimeString());
        $this->assertFalse((bool)$second->active);
        $this->assertSame(now()->addDays((int)$item->duration_days)->toDateTimeString(),
            $second->expires_at->toDateTimeString());
    }

    public function test_expired_later_booster_does_not_block_older_valid_purchase(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $item = StoreItem::create([
            'key'=>'r36_booster_mixed_expiry','category'=>'xp_booster',
            'name'=>['ar'=>'مسرع','en'=>'Booster'],'price'=>1000,
            'active'=>false,'duration_days'=>5,
            'payload'=>['multiplier'=>1.5,'activate_hours'=>24],
        ]);
        $valid = InventoryItem::create([
            'user_id'=>$user->id,'store_item_id'=>$item->id,
            'active'=>false,'expires_at'=>now()->addDays(2),
        ]);
        $expired = InventoryItem::create([
            'user_id'=>$user->id,'store_item_id'=>$item->id,
            'active'=>false,'expires_at'=>now()->subMinute(),
        ]);
        $this->withToken($user->createToken('r36-mixed-booster')->plainTextToken);
        $this->postJson('/api/mobile/v1/store/activate',['key'=>$item->key])->assertOk();
        $this->assertNotNull($valid->fresh()->activated_at);
        $this->assertNull($expired->fresh()->activated_at);
        $this->assertNotNull($expired->fresh());
    }

    public function test_paid_profile_color_renewal_keeps_inventory_and_profile_expiration_equal(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $user->wallet()->update(['tokens'=>10000000]);
        app(StoreCatalogService::class)->sync();
        $item = StoreItem::where('category','profile_color')->where('active',true)->firstOrFail();
        $this->assertGreaterThan(0, (int)$item->duration_days);
        $oldExpiry = now()->addDays(20);
        $inventory = InventoryItem::create([
            'user_id'=>$user->id,'store_item_id'=>$item->id,
            'active'=>true,'activated_at'=>now(),'expires_at'=>$oldExpiry,
        ]);
        $price=app(StoreOfferPricingService::class)->quote($item)['price'];
        $this->withToken($user->createToken('r36-profile-renewal')->plainTextToken);
        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key,'confirmed'=>true,'expected_price'=>$price,
        ])->assertOk();
        $expected=$oldExpiry->copy()->addDays((int)$item->duration_days)->toDateTimeString();
        $this->assertSame($expected,$inventory->fresh()->expires_at->toDateTimeString());
        $this->assertSame($expected,$user->profile()->firstOrFail()
            ->profile_color_expires_at->toDateTimeString());
    }

    public function test_ticket_checkout_charges_server_quote_and_credits_once(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user=$this->player();
        $user->wallet()->update(['tokens'=>1000000]);
        app(StoreCatalogService::class)->sync();
        $item=StoreItem::where('category','competition_ticket')->where('active',true)->firstOrFail();
        $denomination=(int) data_get($item->payload,'denomination');
        $this->assertGreaterThan(0,$denomination);
        $price=app(StoreOfferPricingService::class)->quote($item)['price'];
        $this->withToken($user->createToken('r36-ticket-purchase')->plainTextToken);
        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key,'confirmed'=>true,'expected_price'=>$price+1,
        ])->assertStatus(409);
        $this->assertSame(0,CompetitionTicket::where('user_id',$user->id)->count());
        $this->postJson('/api/mobile/v1/store/purchase', [
            'key'=>$item->key,'confirmed'=>true,'expected_price'=>$price,
        ])->assertOk()->assertJsonPath('ok',true);
        $this->assertSame(1,(int)CompetitionTicket::where('user_id',$user->id)
            ->where('denomination',$denomination)->firstOrFail()->quantity);
        $this->assertSame(1000000-$price,(int)$user->wallet()->firstOrFail()->tokens);
        $this->assertSame(1,WalletTransaction::where('user_id',$user->id)
            ->where('type','competition_ticket_purchase')->count());
    }

    public function test_duplicate_daily_claim_does_not_credit_wallet_twice(): void
    {
        Carbon::setTestNow('2026-10-10 10:00:00');
        $user = $this->player();
        $this->withToken($user->createToken('r36-daily')->plainTextToken);
        $this->postJson('/api/mobile/v1/rewards/daily')->assertOk()
            ->assertJsonPath('coins',100)->assertJsonPath('xp',20);
        $this->postJson('/api/mobile/v1/rewards/daily')->assertStatus(409);
        $this->assertSame(1100,(int)$user->wallet()->firstOrFail()->tokens);
        $this->assertSame(1,DailyRewardClaim::where('user_id',$user->id)->count());
        $this->assertSame(1,WalletTransaction::where('user_id',$user->id)->where('type','daily_reward')->count());
        $this->assertSame(20,(int)$user->profile()->firstOrFail()->xp);
    }
}
