<?php

namespace Tests\Feature;

use App\Models\{ClubJoinRequest, ClubMember, User, Wallet};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class V303RuntimeStabilityTest extends TestCase
{
    use RefreshDatabase;

    public function test_club_join_uses_the_current_bearer_actor_after_another_authenticated_request(): void
    {
        $owner = User::factory()->create(['is_admin' => true]);
        $applicant = User::factory()->create();
        Wallet::create(['user_id' => $owner->id, 'tokens' => 6000, 'gems' => 0]);
        $ownerToken = $owner->createToken('v303-owner')->plainTextToken;
        $applicantToken = $applicant->createToken('v303-applicant')->plainTextToken;

        $club = $this->withToken($ownerToken)->postJson('/api/mobile/v1/clubs-world', [
            'name' => 'B303 Runtime Club', 'visibility' => 'request',
        ])->assertCreated()->json('club');

        $this->withToken($applicantToken)->postJson('/api/mobile/v1/clubs-world/'.$club['id'].'/join')
            ->assertStatus(202)
            ->assertJsonPath('status', 'pending');

        $this->assertTrue(ClubJoinRequest::where('club_id', $club['id'])->where('user_id', $applicant->id)->where('status', 'pending')->exists());
        $this->assertFalse(ClubMember::where('club_id', $club['id'])->where('user_id', $applicant->id)->exists());
    }

    public function test_new_social_world_permission_is_visible_on_the_next_token_request(): void
    {
        $admin = User::factory()->create(['is_admin' => true, 'admin_permissions' => []]);
        $token = $admin->createToken('v303-admin')->plainTextToken;

        $this->withToken($token)->getJson('/api/mobile/v1/admin/social-world')->assertForbidden();
        $admin->update(['admin_permissions' => ['social_world' => true]]);

        $this->withToken($token)->getJson('/api/mobile/v1/admin/social-world')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('release.build', 230);
    }
}
