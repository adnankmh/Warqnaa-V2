<?php

namespace Tests\Feature;

use App\Models\Notification;
use App\Models\Profile;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36SupportPagesLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function player(string $username, bool $admin=false): User
    {
        $user=User::factory()->create([
            'username'=>$username,
            'is_admin'=>$admin,
        ]);
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>$username,
            'country_code'=>'PS',
            'country_name'=>'Palestine',
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>1000,'gems'=>0]);

        return $user;
    }

    public function test_english_about_and_contact_pages_use_ltr_content(): void
    {
        app()->setLocale('en');
        $user=$this->player('support_pages_en');

        $this->actingAs($user)->get('/about')
            ->assertOk()
            ->assertSee('dir="ltr"',false)
            ->assertSee('About Warqna')
            ->assertSee('Browse games')
            ->assertSee('Contact support')
            ->assertDontSee('حول ورقنا');

        $this->actingAs($user)->get('/contact')
            ->assertOk()
            ->assertSee('dir="ltr"',false)
            ->assertSee('Contact &amp; Support',false)
            ->assertSee('Subject')
            ->assertSee('Message details')
            ->assertSee('Never include your password or any secret codes.')
            ->assertSee('Send to support');
    }

    public function test_arabic_about_and_contact_pages_keep_rtl_content(): void
    {
        app()->setLocale('ar');
        $user=$this->player('support_pages_ar');

        $this->actingAs($user)->get('/about')
            ->assertOk()
            ->assertSee('dir="rtl"',false)
            ->assertSee('حول ورقنا')
            ->assertSee('استعراض الألعاب')
            ->assertSee('التواصل مع الدعم');

        $this->actingAs($user)->get('/contact')
            ->assertOk()
            ->assertSee('dir="rtl"',false)
            ->assertSee('التواصل والدعم')
            ->assertSee('عنوان الرسالة')
            ->assertSee('تفاصيل الرسالة')
            ->assertSee('لا ترسل كلمة المرور أو أي رموز سرية.')
            ->assertSee('إرسال للدعم');
    }

    public function test_english_ajax_support_submission_creates_bilingual_admin_notification(): void
    {
        app()->setLocale('en');
        $admin=$this->player('support_admin_r36',true);
        $user=$this->player('support_sender_r36');

        $this->actingAs($user)
            ->withHeader('X-Requested-With','XMLHttpRequest')
            ->post('/contact',[
                'subject'=>'Room reconnect issue',
                'message'=>'The table did not reconnect after the network returned.',
            ])
            ->assertOk()
            ->assertJson([
                'ok'=>true,
                'message'=>'Your message was sent to support.',
            ]);

        $notification=Notification::where('user_id',$admin->id)->where('type','support')->sole();
        $this->assertSame('رسالة دعم جديدة',$notification->title['ar']);
        $this->assertSame('New support message',$notification->title['en']);
        $this->assertStringContainsString('Room reconnect issue',$notification->body['ar']);
        $this->assertStringContainsString('Room reconnect issue',$notification->body['en']);
        $this->assertSame(1000,(int)$user->wallet->fresh()->tokens);
        $this->assertFalse((bool)$user->fresh()->is_admin);
    }

    public function test_arabic_support_submission_returns_localized_confirmation(): void
    {
        app()->setLocale('ar');
        $this->player('support_admin_ar_r36',true);
        $user=$this->player('support_sender_ar_r36');

        $this->actingAs($user)->post('/contact',[
            'subject'=>'مشكلة في الحساب',
            'message'=>'أحتاج إلى مساعدة في إعدادات الحساب.',
        ])->assertRedirect()->assertSessionHas('ok','تم إرسال الرسالة للدعم');
    }
}
