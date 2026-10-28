<?php

namespace Tests\Feature;

use App\Notifications\ResetPasswordMobile;
use App\Notifications\VerifyEmailMobile;
use Tests\TestCase;

class R105BilingualRecoveryMailTest extends TestCase
{
    public function test_recovery_and_verification_mail_follow_the_active_locale_without_changing_urls(): void
    {
        $user = (object) ['username' => 'Adnan'];
        $resetUrl = 'https://example.test/password/reset?token=signed-reset';
        $verifyUrl = 'https://example.test/email/verify/1/signed-hash';

        app()->setLocale('ar');
        $resetAr = (new ResetPasswordMobile($resetUrl))->toMail($user);
        $verifyAr = (new VerifyEmailMobile($verifyUrl))->toMail($user);

        $this->assertSame('إعادة تعيين كلمة مرور Warqna', $resetAr->subject);
        $this->assertSame('مرحبًا Adnan', $resetAr->greeting);
        $this->assertSame('إعادة تعيين كلمة المرور', $resetAr->actionText);
        $this->assertSame($resetUrl, $resetAr->actionUrl);
        $this->assertSame('تأكيد بريدك في Warqna', $verifyAr->subject);
        $this->assertSame('تأكيد البريد الإلكتروني', $verifyAr->actionText);
        $this->assertSame($verifyUrl, $verifyAr->actionUrl);

        app()->setLocale('en');
        $resetEn = (new ResetPasswordMobile($resetUrl))->toMail($user);
        $verifyEn = (new VerifyEmailMobile($verifyUrl))->toMail($user);

        $this->assertSame('Reset your Warqna password', $resetEn->subject);
        $this->assertSame('Hello Adnan', $resetEn->greeting);
        $this->assertSame('Reset password', $resetEn->actionText);
        $this->assertSame($resetUrl, $resetEn->actionUrl);
        $this->assertSame('Verify your Warqna email', $verifyEn->subject);
        $this->assertSame('Verify email address', $verifyEn->actionText);
        $this->assertSame($verifyUrl, $verifyEn->actionUrl);
    }

    public function test_legal_page_chrome_is_bilingual_without_changing_trusted_content_or_home_route(): void
    {
        $view = file_get_contents(resource_path('views/legal/page.blade.php'));

        $this->assertIsString($view);
        foreach ([
            'آخر تحديث',
            'Last updated',
            'الإصدار',
            'Version',
            'العودة إلى Warqna',
            'Back to Warqna',
            '{!! $content !!}',
            "url('/')",
            "app()->isLocale('ar')",
        ] as $contract) {
            $this->assertStringContainsString($contract, $view);
        }
    }
}
