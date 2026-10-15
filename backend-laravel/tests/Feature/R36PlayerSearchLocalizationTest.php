<?php

namespace Tests\Feature;

use App\Models\Profile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36PlayerSearchLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function player(string $username, bool $admin=false, string $displayName=''): User
    {
        $user=User::factory()->create([
            'username'=>$username,
            'is_admin'=>$admin,
        ]);
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>$displayName ?: $username,
            'country_code'=>'PS',
            'country_name'=>'Palestine',
            'level'=>6,
            'xp'=>240,
            'wins'=>9,
            'games_played'=>12,
        ]);

        return $user;
    }

    public function test_english_search_page_localizes_initial_and_empty_states(): void
    {
        app()->setLocale('en');
        $admin=$this->player('search_admin_en',true);

        $this->actingAs($admin)->get('/players/search')
            ->assertOk()
            ->assertSee('dir="ltr"',false)
            ->assertSee('Player Search')
            ->assertSee('Player name')
            ->assertSee('Enter a player name in the search field above.')
            ->assertDontSee('البحث عن لاعب');

        $this->actingAs($admin)->get('/players/search?q=missing-player-r36')
            ->assertOk()
            ->assertSee('Search results')
            ->assertSee('No players match this search.');
    }

    public function test_english_search_results_localize_stats_and_social_actions(): void
    {
        app()->setLocale('en');
        $admin=$this->player('search_admin_actions',true);
        $this->player('target_player_r36',false,'Target Player');

        $this->actingAs($admin)->get('/players/search?q=target_player_r36')
            ->assertOk()
            ->assertSee('Target Player')
            ->assertSee('Level 6')
            ->assertSee('Wins 9')
            ->assertSee('Games 12')
            ->assertSee('View profile')
            ->assertSee('Add friend')
            ->assertSee('Block')
            ->assertDontSee('إضافة صديق');
    }

    public function test_arabic_search_results_keep_rtl_labels_and_actions(): void
    {
        app()->setLocale('ar');
        $admin=$this->player('search_admin_ar',true);
        $this->player('arabic_target_r36',false,'لاعب تجريبي');

        $this->actingAs($admin)->get('/players/search?q=arabic_target_r36')
            ->assertOk()
            ->assertSee('dir="rtl"',false)
            ->assertSee('البحث عن لاعب')
            ->assertSee('نتائج البحث')
            ->assertSee('لاعب تجريبي')
            ->assertSee('المستوى 6')
            ->assertSee('فوز 9')
            ->assertSee('ألعاب 12')
            ->assertSee('عرض الملف الشخصي')
            ->assertSee('إضافة صديق')
            ->assertSee('حظر');
    }

    public function test_player_search_remains_admin_only(): void
    {
        app()->setLocale('en');
        $player=$this->player('regular_search_player');

        $this->actingAs($player)->get('/players/search?q=admin')
            ->assertRedirect(route('friends'))
            ->assertSessionHas('ok','Player search is available inside friends chat.');
    }
}
