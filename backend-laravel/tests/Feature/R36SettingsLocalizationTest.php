<?php

namespace Tests\Feature;

use App\Models\Profile;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36SettingsLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function player(): User
    {
        $user=User::factory()->create();
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>'Settings player',
            'country_code'=>'PS',
            'country_name'=>'Palestine',
            'sound_enabled'=>true,
            'active_site_theme'=>'dark',
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>1000,'gems'=>0]);
        return $user;
    }

    public function test_english_settings_page_localizes_all_account_controls(): void
    {
        app()->setLocale('en');
        $user=$this->player();

        $this->actingAs($user)->get('/settings')
            ->assertOk()
            ->assertSee('dir="ltr"',false)
            ->assertSee('Settings')
            ->assertSee('Profile photo')
            ->assertSee('Display name')
            ->assertSee('Country')
            ->assertSee('Play game, notification and message sounds')
            ->assertSee('Site theme')
            ->assertSee('Royal Gold')
            ->assertSee('Save settings')
            ->assertSee('Typography')
            ->assertSee('Increase text')
            ->assertSee('Audio')
            ->assertSee('Test victory sound');
    }

    public function test_arabic_settings_page_keeps_rtl_and_arabic_controls(): void
    {
        app()->setLocale('ar');
        $user=$this->player();

        $this->actingAs($user)->get('/settings')
            ->assertOk()
            ->assertSee('dir="rtl"',false)
            ->assertSee('الإعدادات')
            ->assertSee('الصورة الشخصية')
            ->assertSee('الاسم المعروض')
            ->assertSee('الدولة')
            ->assertSee('تشغيل أصوات اللعبة والإشعارات والرسائل')
            ->assertSee('ثيم الموقع')
            ->assertSee('ذهبي ملكي')
            ->assertSee('حفظ الإعدادات')
            ->assertSee('حجم الخط')
            ->assertSee('الأصوات')
            ->assertSee('تجربة صوت الفوز');
    }

    public function test_english_settings_save_updates_profile_and_returns_localized_confirmation(): void
    {
        app()->setLocale('en');
        $user=$this->player();

        $this->actingAs($user)->post('/settings',[
            'display_name'=>'Updated player',
            'country_code'=>'JO',
            'sound_enabled'=>'0',
            'active_site_theme'=>'gold',
        ])->assertRedirect()->assertSessionHas('ok','Settings saved');

        $profile=$user->profile->fresh();
        $this->assertSame('Updated player',$profile->display_name);
        $this->assertSame('JO',$profile->country_code);
        $this->assertFalse($profile->sound_enabled);
        $this->assertSame('gold',$profile->active_site_theme);
    }

    public function test_quick_preference_uses_the_requested_language_in_its_response(): void
    {
        app()->setLocale('ar');
        $user=$this->player();

        $this->actingAs($user)->postJson('/preferences/quick',['lang'=>'en','theme'=>'purple'])
            ->assertOk()
            ->assertJson([
                'ok'=>true,
                'message'=>'Preferences saved',
                'theme'=>'purple',
                'lang'=>'en',
            ]);
        $this->assertSame('purple',$user->profile->fresh()->active_site_theme);
    }
}
