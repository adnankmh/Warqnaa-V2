<?php

namespace Tests\Feature;

use App\Models\{StoreItem,User};
use App\Services\WarqnaPro\StoreCatalogService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36AdminStorePersistenceTest extends TestCase
{
    use RefreshDatabase;

    private function administrator(): User
    {
        return User::factory()->create(['is_admin'=>true,'admin_role'=>'primary_admin']);
    }

    public function test_mobile_admin_edits_survive_repeated_catalogue_sync(): void
    {
        $admin=$this->administrator();
        $catalog=app(StoreCatalogService::class);$catalog->sync();
        $item=StoreItem::where('key','pasha_7_days_v128')->firstOrFail();
        $this->withToken($admin->createToken('r36')->plainTextToken)
            ->patchJson('/api/mobile/v1/admin/store/'.$item->id,[
                'price'=>12345,'active'=>false,'duration_days'=>14,
                'name'=>['ar'=>'خطة المدير','en'=>'Administrator plan'],
                'payload'=>['description_ar'=>'وصف محفوظ','preview_icon'=>'premium'],
            ])->assertOk();
        $catalog->sync();$catalog->sync();$item->refresh();
        $this->assertSame(12345,(int)$item->price);
        $this->assertFalse((bool)$item->active);
        $this->assertSame(14,(int)$item->duration_days);
        $this->assertSame('خطة المدير',$item->name['ar']);
        $this->assertSame('وصف محفوظ',$item->payload['description_ar']);
        $this->assertDatabaseCount('store_catalog_overrides',1);
    }

    public function test_deleted_catalogue_item_does_not_reappear_at_next_login(): void
    {
        $admin=$this->administrator();$catalog=app(StoreCatalogService::class);$catalog->sync();
        $item=StoreItem::where('key','pasha_7_days_v128')->firstOrFail();$key=$item->key;
        $this->withToken($admin->createToken('r36')->plainTextToken)
            ->deleteJson('/api/mobile/v1/admin/store/'.$item->id)->assertOk();
        $catalog->sync();$catalog->sync();
        $this->assertDatabaseMissing('store_items',['key'=>$key]);
        $this->assertDatabaseHas('store_catalog_overrides',['key'=>$key,'operation'=>'delete']);
    }

    public function test_web_admin_can_hide_an_item_durably(): void
    {
        $admin=$this->administrator();$catalog=app(StoreCatalogService::class);$catalog->sync();
        $item=StoreItem::where('key','pasha_7_days_v128')->firstOrFail();
        $this->actingAs($admin)->post(route('admin.store.delete',$item))->assertRedirect();
        $catalog->sync();
        $this->assertFalse((bool)$item->fresh()->active);
    }

    public function test_ordinary_player_cannot_record_catalogue_overrides(): void
    {
        $user=User::factory()->create(['is_admin'=>false,'admin_role'=>'player']);
        app(StoreCatalogService::class)->sync();
        $item=StoreItem::where('active',true)->firstOrFail();
        $this->withToken($user->createToken('r36')->plainTextToken)
            ->patchJson('/api/mobile/v1/admin/store/'.$item->id,['price'=>1])->assertForbidden();
        $this->assertDatabaseCount('store_catalog_overrides',0);
    }
}
