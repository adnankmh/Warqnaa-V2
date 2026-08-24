<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class V263AccountSecurityTest extends TestCase
{
    use RefreshDatabase;

    public function test_web_account_security_requires_the_current_password(): void
    {
        $user = User::factory()->create([
            'email' => 'before@example.test',
            'password' => Hash::make('CurrentPass123'),
        ]);

        $this->actingAs($user)->patch('/account/security', [
            'current_password' => 'WrongPass123',
            'email' => 'after@example.test',
        ])->assertUnprocessable();

        $this->assertSame('before@example.test', $user->fresh()->email);
        $this->assertTrue(Hash::check('CurrentPass123', $user->fresh()->password));
    }

    public function test_web_account_security_changes_email_and_password_safely(): void
    {
        $user = User::factory()->create([
            'email' => 'before@example.test',
            'email_verified_at' => now(),
            'password' => Hash::make('CurrentPass123'),
        ]);

        $this->actingAs($user)->patch('/account/security', [
            'current_password' => 'CurrentPass123',
            'email' => 'AFTER@example.test',
            'password' => 'NewSecurePass456',
            'password_confirmation' => 'NewSecurePass456',
        ])->assertRedirect();

        $updated = $user->fresh();
        $this->assertSame('after@example.test', $updated->email);
        $this->assertNull($updated->email_verified_at);
        $this->assertTrue(Hash::check('NewSecurePass456', $updated->password));
        $this->assertFalse(Hash::check('CurrentPass123', $updated->password));
    }

    public function test_legacy_profile_route_cannot_change_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'safe@example.test',
            'password' => Hash::make('CurrentPass123'),
        ]);

        $this->actingAs($user)->post('/profile/update', [
            'email' => 'attacker@example.test',
            'password' => 'UnsafePass456',
        ])->assertRedirect();

        $updated = $user->fresh();
        $this->assertSame('safe@example.test', $updated->email);
        $this->assertTrue(Hash::check('CurrentPass123', $updated->password));
    }
}
