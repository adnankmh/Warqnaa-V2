<?php

namespace Tests\Feature;

use App\Models\Game;
use App\Models\Profile;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36ProfilePageLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function player(): User
    {
        $user=User::factory()->create();
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>'Profile player',
            'country_code'=>'PS',
            'country_name'=>'Palestine',
            'level'=>4,
            'xp'=>120,
            'round_points'=>15,
            'tournament_points'=>7,
            'club_points'=>3,
            'pasha_days'=>2,
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>1000,'gems'=>5]);
        Game::updateOrCreate(['key'=>'baloot'],[
            'name'=>['ar'=>'بلوت','en'=>'Baloot'],
            'min_players'=>4,
            'max_players'=>4,
            'partnership'=>true,
            'rules'=>[],
            'active'=>true,
        ]);
        return $user;
    }

    public function test_english_profile_page_localizes_controls_countries_and_games(): void
    {
        app()->setLocale('en');
        $user=$this->player();

        $this->actingAs($user)->get('/profile')
            ->assertOk()
            ->assertSee('dir="ltr"',false)
            ->assertSee('Edit profile')
            ->assertSee('Level 4')
            ->assertSee('XP remaining to the next level')
            ->assertSee('Quick themes')
            ->assertSee('Royal')
            ->assertSee('Midnight')
            ->assertSee('Emerald')
            ->assertSee('Display name')
            ->assertSee('Country &amp; flag',false)
            ->assertSee('Palestinian Territories')
            ->assertSee('Favorite game')
            ->assertSee('Baloot')
            ->assertSee('Profile photo')
            ->assertSee('Save changes')
            ->assertSee('Change email and password in the Security Center');
    }

    public function test_arabic_profile_page_keeps_rtl_and_localized_controls(): void
    {
        app()->setLocale('ar');
        $user=$this->player();

        $this->actingAs($user)->get('/profile')
            ->assertOk()
            ->assertSee('dir="rtl"',false)
            ->assertSee('تعديل الملف الشخصي')
            ->assertSee('المستوى 4')
            ->assertSee('الثيمات السريعة')
            ->assertSee('الاسم الظاهر')
            ->assertSee('الدولة والعلم')
            ->assertSee('فلسطين')
            ->assertSee('اللعبة المفضلة')
            ->assertSee('بلوت')
            ->assertSee('الصورة الشخصية')
            ->assertSee('حفظ التعديلات');
    }

    public function test_english_profile_update_persists_without_changing_wallet_or_privileges(): void
    {
        app()->setLocale('en');
        $user=$this->player();
        $adminBefore=(bool) $user->is_admin;

        $this->actingAs($user)->post('/profile/update',[
            'display_name'=>'Updated profile',
            'country_code'=>'JO',
            'favorite_game_key'=>'baloot',
        ])->assertRedirect()->assertSessionHas('ok','Profile updated successfully');

        $profile=$user->profile->fresh();
        $this->assertSame('Updated profile',$profile->display_name);
        $this->assertSame('JO',$profile->country_code);
        $this->assertSame('baloot',$profile->favorite_game_key);
        $this->assertSame(1000,(int) $user->wallet->fresh()->tokens);
        $this->assertSame($adminBefore,(bool) $user->fresh()->is_admin);
    }

    public function test_json_profile_update_uses_active_language(): void
    {
        app()->setLocale('ar');
        $user=$this->player();

        $this->actingAs($user)->postJson('/profile/update',[
            'display_name'=>'لاعب محدث',
            'country_code'=>'PS',
        ])->assertOk()->assertJson([
            'ok'=>true,
            'message'=>'تم تحديث الملف الشخصي بنجاح',
        ]);
    }
}
