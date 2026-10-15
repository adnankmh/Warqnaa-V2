<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class R36AccountSecurityLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function player(): User
    {
        $user=User::factory()->create([
            'username'=>'secure_player',
            'email'=>'before@example.test',
            'password'=>Hash::make('CurrentPass123'),
            'is_admin'=>false,
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>1000,'gems'=>5]);
        return $user;
    }

    public function test_english_security_center_localizes_all_controls_and_direction(): void
    {
        app()->setLocale('en');
        $user=$this->player();

        $this->actingAs($user)->get('/account/security')
            ->assertOk()
            ->assertSee('dir="ltr"',false)
            ->assertSee('Account Security Center')
            ->assertSee('Username')
            ->assertSee('New email address')
            ->assertSee('Current password')
            ->assertSee('New password (optional)')
            ->assertSee('Confirm new password')
            ->assertSee('Save security changes')
            ->assertSee('other sessions');
    }

    public function test_arabic_security_center_keeps_rtl_and_arabic_controls(): void
    {
        app()->setLocale('ar');
        $user=$this->player();

        $this->actingAs($user)->get('/account/security')
            ->assertOk()
            ->assertSee('dir="rtl"',false)
            ->assertSee('مركز أمان الحساب')
            ->assertSee('اسم المستخدم')
            ->assertSee('البريد الإلكتروني الجديد')
            ->assertSee('كلمة المرور الحالية')
            ->assertSee('كلمة المرور الجديدة (اختياري)')
            ->assertSee('تأكيد كلمة المرور الجديدة')
            ->assertSee('حفظ تغييرات الأمان');
    }

    public function test_english_security_update_preserves_wallet_and_privileges(): void
    {
        app()->setLocale('en');
        $user=$this->player();
        $adminBefore=(bool)$user->is_admin;

        $this->actingAs($user)->patch('/account/security',[
            'username'=>'secure_player_2',
            'email'=>'AFTER@example.test',
            'current_password'=>'CurrentPass123',
            'password'=>'NewSecurePass456',
            'password_confirmation'=>'NewSecurePass456',
        ])->assertRedirect()->assertSessionHas(
            'ok',
            'Account security updated and other sessions were signed out safely.'
        );

        $updated=$user->fresh();
        $this->assertSame('secure_player_2',$updated->username);
        $this->assertSame('after@example.test',$updated->email);
        $this->assertTrue(Hash::check('NewSecurePass456',$updated->password));
        $this->assertSame(1000,(int)$user->wallet->fresh()->tokens);
        $this->assertSame($adminBefore,(bool)$updated->is_admin);
    }

    public function test_incorrect_current_password_message_follows_active_language(): void
    {
        app()->setLocale('en');
        $user=$this->player();

        $this->actingAs($user)->patch('/account/security',[
            'username'=>'secure_player',
            'email'=>'after@example.test',
            'current_password'=>'WrongPass123',
        ])->assertUnprocessable()->assertSeeText('The current password is incorrect.');

        $this->assertSame('before@example.test',$user->fresh()->email);
        $this->assertSame(1000,(int)$user->wallet->fresh()->tokens);
    }
}
