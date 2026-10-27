<?php

namespace Tests\Feature;

use Tests\TestCase;

class R103BilingualAuthenticationTest extends TestCase
{
    public function test_authentication_surfaces_localize_copy_without_changing_security_or_account_contracts(): void
    {
        $login = file_get_contents(resource_path('views/auth/login.blade.php'));
        $register = file_get_contents(resource_path('views/auth/register.blade.php'));
        $controller = file_get_contents(app_path('Http/Controllers/AuthController.php'));

        $this->assertIsString($login);
        $this->assertIsString($register);
        $this->assertIsString($controller);

        foreach ([
            'تسجيل الدخول',
            'Sign in',
            'اسم المستخدم أو البريد الإلكتروني',
            'Username or email address',
            'كلمة المرور',
            'Password',
            'إنشاء حساب جديد',
            'Create a new account',
        ] as $localizedLoginCopy) {
            $this->assertStringContainsString($localizedLoginCopy, $login);
        }

        foreach ([
            'تسجيل مستخدم جديد',
            'Create a new account',
            'اسم مستخدم فريد',
            'Unique username',
            'البريد الإلكتروني',
            'Email address',
            'الدولة',
            'Country',
            'تأكيد كلمة المرور',
            'Confirm password',
        ] as $localizedRegistrationCopy) {
            $this->assertStringContainsString($localizedRegistrationCopy, $register);
        }

        foreach ([
            '@csrf',
            'name="login"',
            'name="password"',
            "route('register')",
            'autocomplete="current-password"',
        ] as $stableLoginContract) {
            $this->assertStringContainsString($stableLoginContract, $login);
        }

        foreach ([
            '@csrf',
            "unset(\$countries['IL'])",
            "old('country_code','PS')",
            'name="username"',
            'name="email"',
            'name="country_code"',
            'name="password"',
            'name="password_confirmation"',
            'updateCountryPreview(this)',
            'data-flag="{{ flag_url($code) }}"',
        ] as $stableRegistrationContract) {
            $this->assertStringContainsString($stableRegistrationContract, $register);
        }

        foreach ([
            "'username'=>'required|string|min:3|max:30|alpha_dash|unique:users,username'",
            "'email'=>'required|email|max:190|unique:users,email'",
            "'password'=>'required|min:8|confirmed'",
            "'country_code'=>'nullable|string|size:2|not_in:IL,il'",
            "Wallet::create(['user_id'=>\$u->id,'tokens'=>50])",
            "RateLimiter::tooManyAttempts(\$key,5)",
            "Auth::attempt([\$field=>\$cred['login'],'password'=>\$cred['password']],false)",
            "RateLimiter::hit(\$key,60)",
            "\$r->session()->regenerate()",
            "redirect()->route('games')",
            'Too many attempts. Try again in ',
            'This account is suspended by the administration.',
            'The sign-in details are incorrect.',
        ] as $stableControllerContract) {
            $this->assertStringContainsString($stableControllerContract, $controller);
        }
    }
}
