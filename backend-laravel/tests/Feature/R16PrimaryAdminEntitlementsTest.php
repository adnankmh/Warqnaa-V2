<?php

namespace Tests\Feature;

use App\Models\{CompetitionTicket,InventoryItem,Profile,StoreItem,User,Wallet};
use App\Services\Admin\PrimaryAdminStateService;
use App\Services\Wallet\WalletService;
use App\Services\WarqnaPro\StoreCatalogService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R16PrimaryAdminEntitlementsTest extends TestCase
{
    use RefreshDatabase;

    public function test_primary_admin_is_repaired_to_full_permissions_and_economy_floor(): void
    {
        $admin = User::factory()->create([
            'is_admin'=>false,
            'admin_role'=>'primary_admin',
            'admin_permissions'=>[],
            'is_banned'=>true,
        ]);
        Profile::create([
            'user_id'=>$admin->id,
            'display_name'=>'Primary',
            'country_code'=>'PS',
            'country_name'=>'Palestine',
            'level'=>1,
            'xp'=>0,
            'pasha_days'=>0,
        ]);
        Wallet::create(['user_id'=>$admin->id,'tokens'=>1,'gems'=>0]);

        app(StoreCatalogService::class)->sync();
        $admin = app(PrimaryAdminStateService::class)->enforce($admin);

        $this->assertTrue($admin->is_admin);
        $this->assertFalse($admin->is_banned);
        $this->assertSame('primary_admin', $admin->admin_role);
        foreach (PrimaryAdminStateService::FULL_PERMISSIONS as $permission=>$enabled) {
            $this->assertTrue($enabled);
            $this->assertTrue($admin->hasAdminPermission($permission), $permission);
            $this->assertTrue((bool)data_get($admin->admin_permissions, $permission), $permission);
        }
        $this->assertGreaterThanOrEqual(99, (int)$admin->profile->level);
        $this->assertGreaterThanOrEqual(36500, (int)$admin->profile->pasha_days);
        $this->assertGreaterThanOrEqual(99999999999999999, (int)$admin->wallet->tokens);
        $this->assertGreaterThanOrEqual(100000000, (int)$admin->wallet->gems);

        $activeCollectibleIds = StoreItem::query()
            ->where('active', true)
            ->whereNotIn('category', ['pasha','competition_ticket'])
            ->pluck('id');
        $owned = InventoryItem::query()
            ->where('user_id', $admin->id)
            ->whereIn('store_item_id', $activeCollectibleIds)
            ->get();
        $this->assertCount($activeCollectibleIds->count(), $owned);
        $this->assertTrue($owned->every(fn (InventoryItem $item) => (int)$item->quantity >= 100));
        $this->assertTrue($owned->every(fn (InventoryItem $item) => $item->expires_at === null));

        $tickets = CompetitionTicket::query()->where('user_id', $admin->id)->get();
        $this->assertNotEmpty($tickets);
        $this->assertTrue($tickets->every(fn (CompetitionTicket $ticket) => (int)$ticket->quantity >= 100));
    }

    public function test_primary_admin_wallet_never_spends_down(): void
    {
        $admin = User::factory()->create([
            'is_admin'=>true,
            'admin_role'=>'primary_admin',
            'admin_permissions'=>PrimaryAdminStateService::FULL_PERMISSIONS,
        ]);
        Profile::create(['user_id'=>$admin->id,'display_name'=>'Primary','country_code'=>'PS','country_name'=>'Palestine']);
        Wallet::create(['user_id'=>$admin->id,'tokens'=>PrimaryAdminStateService::TOKEN_RESERVE,'gems'=>PrimaryAdminStateService::GEMS]);

        $before = (int)$admin->wallet->tokens;
        app(WalletService::class)->debit($admin, 1000000, 'r16_admin_unlimited_test');
        $this->assertSame($before, (int)$admin->wallet()->value('tokens'));

        $admin->wallet()->update(['tokens'=>1]);
        $repaired = app(PrimaryAdminStateService::class)->enforce($admin->fresh());
        $this->assertGreaterThanOrEqual(PrimaryAdminStateService::TOKEN_RESERVE, (int)$repaired->wallet->tokens);
    }
}
