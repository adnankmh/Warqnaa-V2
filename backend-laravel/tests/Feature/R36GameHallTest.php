<?php

namespace Tests\Feature;

use App\Models\{Game, Profile, User, Wallet};
use App\Services\Games\GameCatalog;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36GameHallTest extends TestCase
{
    use RefreshDatabase;

    private function signInPlayer(): void
    {
        $user = User::factory()->create(['is_admin'=>false, 'admin_role'=>'player']);
        Profile::create(['user_id'=>$user->id, 'display_name'=>'Hall player',
            'country_code'=>'PS', 'country_name'=>'Palestine']);
        Wallet::create(['user_id'=>$user->id, 'tokens'=>1000, 'gems'=>0]);
        $this->actingAs($user);
    }

    public function test_arabic_hall_renders_all_curated_play_links_and_real_family_filters(): void
    {
        $this->signInPlayer();
        app()->setLocale('ar');
        $response = $this->get(route('games'))->assertOk();
        $response->assertSee('lang="ar" dir="rtl"', false)
            ->assertSee('جميع الألعاب')->assertSee('هاند وبناكل')
            ->assertSee('aria-live="polite"', false);
        foreach (GameCatalog::customerKeys() as $key) {
            $response->assertSee('href="'.route('rooms.index', $key).'"', false);
        }
        foreach (['all', 'tarneeb', 'trix', 'meld', 'gulf', 'basra'] as $family) {
            $response->assertSee('data-family-filter-v130="'.$family.'"', false);
        }
    }

    public function test_english_hall_preserves_arabic_search_metadata_and_ltr_navigation(): void
    {
        $this->signInPlayer();
        app()->setLocale('en');
        $response = $this->get(route('games'))->assertOk();
        $response->assertSee('lang="en" dir="ltr"', false)
            ->assertSee('All games')->assertSee('Hand and Banakil')
            ->assertSee('Search games')->assertSee('Play now')
            ->assertSee('بصرة بصره باصره basrah')
            ->assertSee('<span aria-hidden="true">→</span>', false);
    }

    public function test_opening_hall_preserves_admin_deactivation_and_excludes_uncurated_games(): void
    {
        $this->signInPlayer();
        $this->get(route('games'))->assertOk();
        $game = Game::where('key', 'tarneeb')->firstOrFail();
        $game->update(['active'=>false]);
        Game::create(['key'=>'domino', 'name'=>['ar'=>'دومينو','en'=>'Domino'],
            'min_players'=>2, 'max_players'=>4, 'partnership'=>false,
            'active'=>true, 'rules'=>['family'=>'board']]);
        $response = $this->get(route('games'))->assertOk();
        $html = $response->getContent();
        preg_match_all('/<a\s+class="wz-game-card-v130.*?<\/a>/s', $html, $cards);
        $this->assertCount(11, $cards[0]);
        $tiles = implode('\n', $cards[0]);
        $this->assertStringNotContainsString('href="'.route('rooms.index', 'tarneeb').'"', $tiles);
        $this->assertStringNotContainsString('href="'.route('rooms.index', 'domino').'"', $tiles);
        $this->assertFalse((bool)$game->fresh()->active);
    }
}
