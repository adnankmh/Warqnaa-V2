<?php

namespace Tests\Feature;

use App\Models\Profile;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R37SurfaceLegibilityTest extends TestCase
{
    use RefreshDatabase;

    private function player(): User
    {
        $user=User::factory()->create(['is_admin'=>false,'admin_role'=>'player']);
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>'R37 legibility player',
            'country_code'=>'PS',
            'country_name'=>'Palestine',
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>1000,'gems'=>0]);

        return $user;
    }

    public function test_home_store_and_game_hall_keep_real_navigable_surfaces(): void
    {
        $user=$this->player();

        $this->actingAs($user)->get('/')
            ->assertOk()
            ->assertSee('class="b304-home"',false)
            ->assertSee('w36-grand-hero',false)
            ->assertSee(route('store'),false)
            ->assertSee(route('games'),false);

        $this->actingAs($user)->get('/store')
            ->assertOk()
            ->assertSee('store-category-tabs-v127',false)
            ->assertSee('store-products-grid-v127',false)
            ->assertSee('storeSearchV127',false);

        $this->actingAs($user)->get('/games')
            ->assertOk()
            ->assertSee('w36-game-hall-hero',false)
            ->assertSee('w36-games-wall',false)
            ->assertSee('w36GamesResults',false);
    }

    public function test_shared_r37_css_enforces_readable_type_focus_and_touch_targets(): void
    {
        $css=file_get_contents(public_path('assets/css/b307-cardroom-ui.css'));
        $layout=file_get_contents(resource_path('views/layouts/app.blade.php'));

        $this->assertStringContainsString('R37 SKY SURFACE LEGIBILITY',$css);
        $this->assertStringContainsString('--r37-copy:#f4fcff',$css);
        $this->assertStringContainsString('.b304-head h1',$css);
        $this->assertStringContainsString('.store-section-head-v127 h2',$css);
        $this->assertStringContainsString('.w36-game-tile-info strong',$css);
        $this->assertStringContainsString('min-height:44px!important',$css);
        $this->assertStringContainsString('font-size:16px!important',$css);
        $this->assertStringContainsString('outline:3px solid var(--r37-focus)!important',$css);
        $this->assertStringContainsString('@media(prefers-contrast:more)',$css);
        $this->assertStringContainsString('?v=37-surface-legibility',$layout);
        $this->assertStringNotContainsString('?v=36-sky-world-game-hall-discovery-art',$layout);
    }
}
