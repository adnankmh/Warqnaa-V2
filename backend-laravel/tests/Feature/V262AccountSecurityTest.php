<?php

namespace Tests\Feature;

use App\Models\User;
use App\Notifications\VerifyEmailMobile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\{Hash, Notification};
use Tests\TestCase;

class V262AccountSecurityTest extends TestCase
{
    use RefreshDatabase;

    public function test_mobile_user_changes_email_with_current_password_and_keeps_only_current_session(): void
    {
        Notification::fake();
        $user = $this->user('secure-player', 'PlayerPass123');
        $currentToken = $user->createToken('mobile-current')->plainTextToken;
        $user->createToken('mobile-other');

        $this->withToken($currentToken)->getJson('/api/mobile/v1/account/security')
            ->assertOk()
            ->assertJsonPath('account.email', 'secure-player@example.test')
            ->assertJsonPath('account.email_verified', true);

        $this->withToken($currentToken)->patchJson('/api/mobile/v1/account/email', [
            'current_password' => 'wrong-password',
            'email' => 'new-secure@example.test',
        ])->assertUnprocessable()->assertJsonValidationErrors(['current_password']);

        $this->withToken($currentToken)->patchJson('/api/mobile/v1/account/email', [
            'current_password' => 'PlayerPass123',
            'email' => 'new-secure@example.test',
        ])->assertOk()->assertJsonPath('account.email', 'new-secure@example.test');

        $fresh = $user->fresh();
        $this->assertSame('new-secure@example.test', $fresh->email);
        $this->assertNull($fresh->email_verified_at);
        $this->assertSame(1, $fresh->tokens()->count());
        Notification::assertSentTo($fresh, VerifyEmailMobile::class);
    }

    public function test_mobile_user_changes_password_and_old_password_stops_working(): void
    {
        $user = $this->user('password-player', 'PlayerPass123');
        $currentToken = $user->createToken('mobile-current')->plainTextToken;
        $user->createToken('tablet-other');

        $this->withToken($currentToken)->patchJson('/api/mobile/v1/account/password', [
            'current_password' => 'PlayerPass123',
            'password' => 'NewPlayer456',
            'password_confirmation' => 'NewPlayer456',
        ])->assertOk()->assertJsonPath('current_session_preserved', true);

        $fresh = $user->fresh();
        $this->assertTrue(Hash::check('NewPlayer456', $fresh->password));
        $this->assertFalse(Hash::check('PlayerPass123', $fresh->password));
        $this->assertSame(1, $fresh->tokens()->count());

        $this->postJson('/api/mobile/v1/login', ['login' => $fresh->username, 'password' => 'PlayerPass123'])->assertUnprocessable();
        $this->postJson('/api/mobile/v1/login', ['login' => $fresh->username, 'password' => 'NewPlayer456'])->assertOk();
    }

    public function test_web_security_center_protects_admin_credentials_and_permissions(): void
    {
        Notification::fake();
        $admin = $this->user('Adnan', 'AdminPass123', true);

        $this->actingAs($admin)->get('/account/security')
            ->assertOk()
            ->assertSee('أمان الحساب وبيانات الدخول');

        $this->actingAs($admin)->post('/account/security/email', [
            'current_password' => 'AdminPass123',
            'email' => 'adnan-secure@example.test',
        ])->assertRedirect();

        $this->actingAs($admin->fresh())->post('/account/security/password', [
            'current_password' => 'AdminPass123',
            'password' => 'SecureAdmin456',
            'password_confirmation' => 'SecureAdmin456',
        ])->assertRedirect();

        $fresh = $admin->fresh();
        $this->assertSame('adnan-secure@example.test', $fresh->email);
        $this->assertTrue(Hash::check('SecureAdmin456', $fresh->password));
        $this->assertTrue($fresh->is_admin);
        $this->assertTrue($fresh->isPrimaryAdmin());
    }

    public function test_legacy_profile_form_cannot_change_credentials_without_security_confirmation(): void
    {
        $user = $this->user('legacy-profile', 'PlayerPass123');
        $this->actingAs($user)->post('/profile/update', [
            'display_name' => 'Safe Profile',
            'email' => 'bypass@example.test',
            'password' => 'BypassPass456',
            'password_confirmation' => 'BypassPass456',
        ])->assertRedirect();

        $fresh = $user->fresh();
        $this->assertSame('legacy-profile@example.test', $fresh->email);
        $this->assertTrue(Hash::check('PlayerPass123', $fresh->password));
    }

    private function user(string $username, string $password, bool $admin = false): User
    {
        return User::create([
            'username' => $username,
            'email' => strtolower($username).'@example.test',
            'password' => Hash::make($password),
            'email_verified_at' => now(),
            'is_admin' => $admin,
            'admin_role' => $admin ? 'primary_admin' : 'player',
            'admin_permissions' => $admin ? ['all' => true] : null,
        ]);
    }
}
