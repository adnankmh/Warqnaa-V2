<?php

namespace Tests\Feature;

use App\Models\Profile;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36ProfileModalLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function player(string $username): User
    {
        $user=User::factory()->create(['username'=>$username]);
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>$username,
            'country_code'=>'PS',
            'country_name'=>'Palestine',
            'xp'=>40,
            'level'=>2,
            'wins'=>3,
            'losses'=>1,
            'games_played'=>4,
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>1000,'gems'=>0]);

        return $user;
    }

    private function modal(User $viewer, User $profile)
    {
        return $this->actingAs($viewer)->get(
            route('profile.show',$profile),
            ['X-Requested-With'=>'XMLHttpRequest'],
        );
    }

    public function test_english_own_profile_modal_localizes_account_summary_and_actions(): void
    {
        app()->setLocale('en');
        $user=$this->player('english_profile_r36');

        $this->modal($user,$user)
            ->assertOk()
            ->assertSee('dir="ltr"',false)
            ->assertSee('Your profile')
            ->assertSee('Favorite game')
            ->assertSee('Level')
            ->assertSee('Wins')
            ->assertSee('Games')
            ->assertSee('Player needs')
            ->assertSee('Round points')
            ->assertSee('Tournament points')
            ->assertSee('Club points')
            ->assertSee('Current XP')
            ->assertSee('Active items')
            ->assertSee('No active items.')
            ->assertSee('Edit profile')
            ->assertSee('My purchases')
            ->assertDontSee('بروفايلك الشخصي');
    }

    public function test_arabic_own_profile_modal_keeps_rtl_labels_and_actions(): void
    {
        app()->setLocale('ar');
        $user=$this->player('arabic_profile_r36');

        $this->modal($user,$user)
            ->assertOk()
            ->assertSee('dir="rtl"',false)
            ->assertSee('بروفايلك الشخصي')
            ->assertSee('اللعبة المفضلة')
            ->assertSee('المستوى')
            ->assertSee('نقاط الجولات')
            ->assertSee('XP الحالي')
            ->assertSee('المقتنيات المفعلة')
            ->assertSee('لا توجد مقتنيات مفعلة.')
            ->assertSee('تعديل البروفايل')
            ->assertSee('مشترياتي');
    }

    public function test_english_other_player_modal_localizes_social_and_transfer_controls(): void
    {
        app()->setLocale('en');
        $viewer=$this->player('viewer_profile_r36');
        $other=$this->player('other_profile_r36');

        $this->modal($viewer,$other)
            ->assertOk()
            ->assertSee('Player on Warqna')
            ->assertSee('Add friend')
            ->assertSee('Block')
            ->assertSee('Block this player?')
            ->assertSee('Send tokens')
            ->assertSee('A 10% fee will be deducted.')
            ->assertDontSee('طلب صداقة');
    }
}
