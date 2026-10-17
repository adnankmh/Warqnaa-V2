<?php

namespace Tests\Feature;

use App\Models\{AdminDesignerEntity, StoreItem, User};
use App\Services\WarqnaPro\StoreCatalogService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R39PremiumAdminSurfaceContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_premium_admin_surfaces_reject_unauthenticated_and_ordinary_players(): void
    {
        $this->getJson('/api/mobile/v1/admin/dashboard')->assertUnauthorized();

        $player = User::factory()->create([
            'is_admin' => false,
            'admin_role' => 'player',
        ]);
        $token = $player->createToken('r39-player')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/mobile/v1/admin/dashboard')
            ->assertForbidden();
        $this->withToken($token)
            ->getJson('/api/mobile/v1/admin/designer')
            ->assertForbidden();
    }

    public function test_primary_admin_reads_catalogue_and_publishes_audited_designer_copy(): void
    {
        $admin = User::factory()->create([
            'is_admin' => true,
            'admin_role' => 'primary_admin',
        ]);
        app(StoreCatalogService::class)->sync();
        $token = $admin->createToken('r39-primary-admin')->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/mobile/v1/admin/dashboard')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonStructure([
                'stats' => ['store_items'],
                'store',
                'audit_logs',
                'designer_entities',
            ]);
        $this->assertGreaterThan(0, StoreItem::where('active', true)->count());

        $this->withToken($token)
            ->patchJson('/api/mobile/v1/admin/designer/store_label/r39-premium-copy', [
                'locale' => 'ar',
                'payload' => [
                    'title' => 'واجهة المتجر الفاخرة',
                    'contrast' => 'high',
                    'minimum_font_size' => 11,
                ],
                'sort_order' => 39,
                'active' => true,
            ])
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('entity.revision', 1)
            ->assertJsonPath('entity.updated_by', $admin->id);

        $entity = AdminDesignerEntity::where('key', 'r39-premium-copy')->firstOrFail();
        $this->assertSame('ar', $entity->locale);
        $this->assertSame(11, $entity->payload['minimum_font_size']);
        $this->assertDatabaseHas('admin_audit_logs', [
            'admin_id' => $admin->id,
            'action' => 'admin.designer.upsert',
        ]);
    }
}
