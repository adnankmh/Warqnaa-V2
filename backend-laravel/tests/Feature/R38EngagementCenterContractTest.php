<?php

namespace Tests\Feature;

use App\Models\{Profile, User, Wallet};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class R38EngagementCenterContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_engagement_center_requires_authentication(): void
    {
        $this->getJson('/api/mobile/v1/engagement/center')->assertUnauthorized();
    }

    public function test_authenticated_center_keeps_server_authoritative_reward_metadata(): void
    {
        $user = User::create([
            'username' => 'r38-player',
            'email' => 'r38-player@example.test',
            'password' => Hash::make('password123'),
        ]);
        Profile::create([
            'user_id' => $user->id,
            'display_name' => 'R38 Player',
            'country_code' => 'PS',
            'country_name' => 'Palestine',
        ]);
        Wallet::create(['user_id' => $user->id, 'tokens' => 500, 'gems' => 0]);

        $this->withToken($user->createToken('r38-contract')->plainTextToken)
            ->getJson('/api/mobile/v1/engagement/center')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonStructure([
                'daily_pack' => ['available', 'next_available_at', 'cooldown_hours'],
                'inventory',
                'challenges',
                'challenge_road' => ['game_key', 'stage', 'total_stages', 'attempts', 'completed'],
            ]);
    }
}
