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


    public function test_catalog_sync_fills_every_primary_admin_item_including_boosters_and_pasha(): void
    {
        $admin=User::factory()->create([
            'is_admin'=>true,'admin_role'=>'primary_admin',
        ]);
        $ordinary=User::factory()->create(['is_admin'=>false,'admin_role'=>'player']);
        app(StoreCatalogService::class)->sync();
        $items=StoreItem::query()->where('active',true)
            ->where('category','!=','competition_ticket')->get();
        $this->assertNotEmpty($items);
        $boosterIds=$items->where('category','xp_booster')->pluck('id');
        $this->assertNotEmpty($boosterIds);
        $this->assertNotEmpty($items->where('category','pasha'));
        $rows=InventoryItem::where('user_id',$admin->id)
            ->whereIn('store_item_id',$items->pluck('id'))->get();
        $this->assertCount($items->count(),$rows);
        $this->assertTrue($rows->every(fn(InventoryItem $row)=>
            $row->quantity>=PrimaryAdminStateService::INVENTORY_QUANTITY
            && $row->expires_at===null));
        $this->assertSame(0,InventoryItem::where('user_id',$ordinary->id)->count());

        // A second sync must replenish the exact deficit without writing
        // duplicate inventory or shortening any existing privileges.
        $owned=$rows->firstWhere('store_item_id',$boosterIds->first());
        $owned->update(['quantity'=>2,'expires_at'=>now()->subDay()]);
        app(StoreCatalogService::class)->sync();
        $this->assertGreaterThanOrEqual(100,(int)$owned->fresh()->quantity);
        $this->assertNull($owned->fresh()->expires_at);
        $this->assertSame(1,InventoryItem::where('user_id',$admin->id)
            ->where('store_item_id',$owned->store_item_id)->count());
    }

    public function test_primary_admin_color_equipment_maintains_a_year_and_all_ticket_denominations(): void
    {
        \Carbon\Carbon::setTestNow('2026-10-12 10:00:00');
        try {
            $admin=User::factory()->create(['is_admin'=>true,'admin_role'=>'primary_admin']);
            Profile::create([
                'user_id'=>$admin->id,'display_name'=>'Primary',
                'country_code'=>'PS','country_name'=>'Palestine',
                'name_color'=>'#1188ff','text_color'=>'#eedd33',
                'active_profile_color'=>'#123456|#abcdef',
            ]);
            Wallet::create(['user_id'=>$admin->id,'tokens'=>1,'gems'=>1]);
            app(StoreCatalogService::class)->sync();
            $admin=app(PrimaryAdminStateService::class)->enforce($admin);
            foreach(['name_color_expires_at','chat_color_expires_at','profile_color_expires_at'] as $field) {
                $this->assertGreaterThanOrEqual(
                    now()->addDays(PrimaryAdminStateService::COLOR_VALIDITY_DAYS)->timestamp,
                    $admin->profile->{$field}->timestamp,
                    $field
                );
            }
            $tickets=CompetitionTicket::where('user_id',$admin->id)->get();
            foreach([50,100,500,1000,5000,10000,50000,100000] as $value) {
                $ticket=$tickets->firstWhere('denomination',$value);
                $this->assertNotNull($ticket);
                $this->assertGreaterThanOrEqual(100,$ticket->quantity);
            }
            $admin->profile->name_color_expires_at=now()->addDays(500);
            $admin->profile->save();
            app(PrimaryAdminStateService::class)->enforce($admin->fresh());
            $this->assertGreaterThanOrEqual(now()->addDays(500)->timestamp,
                $admin->profile()->firstOrFail()->name_color_expires_at->timestamp);
        } finally {
            \Carbon\Carbon::setTestNow();
        }
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
