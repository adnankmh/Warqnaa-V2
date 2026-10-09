<?php

namespace Tests\Feature;

use App\Models\{DailyRewardClaim,Profile,StoreItem,StoreOffer,User,Wallet,WalletTransaction};
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
            'category'=>'badge', 'price'=>$price, 'active'=>true,
            'payload'=>['badge'=>$key],
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
