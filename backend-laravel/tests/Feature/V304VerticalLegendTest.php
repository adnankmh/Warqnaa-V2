<?php

namespace Tests\Feature;

use App\Models\{Profile,User,Wallet};
use App\Services\Games\GameCatalog;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class V304VerticalLegendTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_catalog_hides_removed_games_and_basra_is_two_player(): void
    {
        $keys = GameCatalog::customerKeys();
        foreach (['jackaroo','backgammon','domino','chess'] as $removed) {
            $this->assertNotContains($removed, $keys);
        }
        $this->assertSame(2, GameCatalog::all()['basra']['min']);
        $this->assertSame(2, GameCatalog::all()['basra']['max']);
        $this->assertStringContainsString('7 إلى 13', GameCatalog::rules('tarneeb'));
        $this->assertStringContainsString('Pass', GameCatalog::rules('tarneeb'));
    }

    public function test_primary_admin_role_is_durable_after_username_change(): void
    {
        $admin = User::factory()->create([
            'username' => 'RenamedPrimary',
            'email' => 'renamed-primary@warqna.local',
            'is_admin' => true,
            'admin_role' => 'primary_admin',
        ]);
        Wallet::create(['user_id'=>$admin->id,'tokens'=>100,'gems'=>0]);

        $this->assertTrue($admin->fresh()->isPrimaryAdmin());
        $this->assertSame('1000000000000000000000000000000', $admin->fresh('wallet')->displayTokenBalance());
    }

    public function test_mobile_bootstrap_exposes_only_arabic_english_as_active_locales(): void
    {
        $user = User::factory()->create();
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>$user->username,
            'country_code'=>'PS',
            'country_name'=>'Palestine',
            'locale'=>'ar',
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>50,'gems'=>0]);
        $token = $user->createToken('b304-locales')->plainTextToken;

        $this->withToken($token)->getJson('/api/mobile/v1/bootstrap')
            ->assertOk()
            ->assertJsonPath('features.languages', ['ar','en'])
            ->assertJsonPath('features.future_languages', ['de','tr','fr','es']);
    }

    public function test_inactive_future_locale_cannot_be_selected_as_product_locale(): void
    {
        $user = User::factory()->create();
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>$user->username,
            'country_code'=>'PS',
            'country_name'=>'Palestine',
            'locale'=>'ar',
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>50,'gems'=>0]);
        $token = $user->createToken('b304-locale-guard')->plainTextToken;

        $this->withToken($token)->patchJson('/api/mobile/v1/profile', ['locale'=>'de'])
            ->assertUnprocessable();
        $this->assertSame('ar', $user->fresh()->profile->locale);
    }
}
