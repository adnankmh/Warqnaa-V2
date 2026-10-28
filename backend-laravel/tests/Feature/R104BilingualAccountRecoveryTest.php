<?php

namespace Tests\Feature;

use Tests\TestCase;

class R104BilingualAccountRecoveryTest extends TestCase
{
    public function test_account_recovery_is_bilingual_without_changing_reset_or_verification_security_contracts(): void
    {
        $view = file_get_contents(resource_path('views/auth/mobile-reset-password.blade.php'));
        $controller = file_get_contents(app_path('Http/Controllers/MobileAuthRecoveryController.php'));

        $this->assertIsString($view);
        $this->assertIsString($controller);

        foreach ([
            'إعادة تعيين كلمة المرور',
            'Reset password',
            'البريد الإلكتروني',
            'Email address',
            'كلمة المرور الجديدة',
            'New password',
            'تأكيد كلمة المرور',
            'Confirm new password',
            'العودة إلى تسجيل الدخول',
            'Back to sign in',
        ] as $localizedViewCopy) {
            $this->assertStringContainsString($localizedViewCopy, $view);
        }

        foreach ([
            'إذا كان البريد مسجلاً فستصل رسالة إعادة التعيين.',
            'If the email is registered, a password reset message will be sent.',
            'تم تغيير كلمة المرور. سجل الدخول من جديد.',
            'Your password has been changed. Sign in again.',
            'البريد مؤكد مسبقًا.',
            'This email address is already verified.',
            'رابط التأكيد غير صالح أو منتهي.',
            'The verification link is invalid or expired.',
            'تم تأكيد البريد',
            'Email verified',
        ] as $localizedControllerCopy) {
            $this->assertStringContainsString($localizedControllerCopy, $controller);
        }

        foreach ([
            '@csrf',
            "route('password.reset.web')",
            'name="token"',
            'name="email"',
            'name="password"',
            'name="password_confirmation"',
            'minlength="8"',
            'maxlength="120"',
            "route('login')",
        ] as $stableViewContract) {
            $this->assertStringContainsString($stableViewContract, $view);
        }

        foreach ([
            "\$request->validate(['email'=>'required|email|max:190'])",
            "Password::broker()->createToken(\$user)",
            "'email'=>'required|email|max:190'",
            "'token'=>'required|string'",
            "'password'=>'required|string|min:8|max:120|confirmed'",
            "Password::broker()->reset(\$data",
            "Hash::make(\$password)",
            "setRememberToken(Str::random(60))",
            "\$user->tokens()->delete()",
            "event(new PasswordReset(\$user))",
            "now()->addMinutes(60)",
            "\$request->hasValidSignature()",
            "hash_equals(sha1(\$user->email), \$hash)",
            "['email_verified_at'=>now()]",
        ] as $stableSecurityContract) {
            $this->assertStringContainsString($stableSecurityContract, $controller);
        }
    }
}
