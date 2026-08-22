<?php

namespace Tests\Feature;

use App\Models\{
    Club, ClubJoinRequest, ClubMember, Friendship, Game, MatchReplay, PresenceSession,
    Room, RoomPlayer, RoomSpectator, SocialActivity, SocialEvent, SocialGift,
    SocialPreference, User, Wallet
};
use App\Services\Social\{MatchReplayService, SocialWorldPolicy};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

class V230SocialWorldTest extends TestCase
{
    use RefreshDatabase;

    public function test_r11_schema_and_default_gift_contract_are_available(): void
    {
        foreach ([
            'social_preferences', 'social_follows', 'social_activities', 'social_events',
            'social_event_attendees', 'room_spectators', 'match_replays', 'social_gifts',
        ] as $table) {
            $this->assertTrue(Schema::hasTable($table), "Missing R11 table: {$table}");
        }

        $this->assertSame('0.6.0+230', config('warqna_social_world.release'));
        $this->assertCount(6, config('warqna_social_world.gifts'));
        $this->assertSame(50, config('warqna_social_world.gifts.rose.cost'));
        $this->assertSame(3500, config('warqna_social_world.gifts.aurora.cost'));
    }

    public function test_spectator_payload_recursively_removes_private_engine_state(): void
    {
        $safe = app(MatchReplayService::class)->spectatorState([
            'phase' => 'playing',
            'turn' => 7,
            'hands' => ['1' => ['AS', 'KH'], '2' => ['2C']],
            'deck' => ['QD', 'JS'],
            'stock' => ['9H'],
            'boneyard' => ['6S', '7S', '8S'],
            'legal_cards' => ['AS'],
            'nested' => [
                'visible' => 'scoreboard',
                'opponent_hand_cache' => ['10S'],
                'private_state' => ['bid' => 7],
                'auth_token' => 'never-leak',
                'credential' => 'never-leak',
                'email' => 'private@example.test',
                'rng' => ['seed' => 12345],
            ],
        ]);

        $this->assertTrue($safe['spectator_safe']);
        $this->assertFalse($safe['hands_visible']);
        $this->assertSame(['1' => 2, '2' => 1], $safe['hand_counts']);
        $this->assertSame(2, $safe['deck_count']);
        $this->assertSame(1, $safe['stock_count']);
        $this->assertSame(3, $safe['boneyard_count']);
        $this->assertSame('scoreboard', $safe['nested']['visible']);
        $this->assertArrayNotHasKey('hands', $safe);
        $this->assertArrayNotHasKey('deck', $safe);
        $this->assertArrayNotHasKey('legal_cards', $safe);
        $this->assertArrayNotHasKey('private_state', $safe['nested']);
        $this->assertArrayNotHasKey('opponent_hand_cache', $safe['nested']);
        $this->assertArrayNotHasKey('auth_token', $safe['nested']);
        $this->assertArrayNotHasKey('credential', $safe['nested']);
        $this->assertArrayNotHasKey('email', $safe['nested']);
        $this->assertArrayNotHasKey('rng', $safe['nested']);
    }

    public function test_realtime_room_chat_is_player_only_and_rejects_spectators(): void
    {
        [$owner, $viewer, $room] = $this->publicRoom(['phase' => 'playing', 'allow_spectators' => true]);

        RoomSpectator::create([
            'room_id' => $room->id, 'user_id' => $viewer->id, 'status' => 'active',
            'joined_at' => now(), 'last_seen_at' => now(), 'can_chat' => false, 'voice_enabled' => false,
        ]);

        $this->actingAs($viewer)->getJson("/realtime/room/{$room->code}")->assertForbidden();
        $this->actingAs($owner)->getJson("/realtime/room/{$room->code}")
            ->assertOk()->assertJsonPath('ok', true);
    }

    public function test_social_world_cleanup_enforces_retention_and_lifecycle(): void
    {
        [$owner, $viewer, $room] = $this->publicRoom(['phase' => 'playing']);
        $spectator = RoomSpectator::create([
            'room_id' => $room->id, 'user_id' => $viewer->id, 'status' => 'active',
            'joined_at' => now()->subHour(), 'last_seen_at' => now()->subHour(),
            'can_chat' => false, 'voice_enabled' => false,
        ]);
        $replay = MatchReplay::create([
            'room_id' => $room->id, 'owner_id' => $owner->id, 'game_id' => $room->game_id,
            'visibility' => 'private', 'status' => 'ready', 'event_log' => [],
            'frames_count' => 1, 'sha256' => str_repeat('a', 64), 'expires_at' => now()->subMinute(),
        ]);
        $activity = SocialActivity::create([
            'actor_id' => $owner->id, 'type' => 'looking_for_game', 'audience' => 'public',
            'payload' => ['text' => 'expired'], 'published_at' => now()->subDays(9), 'expires_at' => now()->subDays(8),
        ]);
        $event = SocialEvent::create([
            'created_by' => $owner->id, 'title' => ['ar' => 'اختبار', 'en' => 'Test'],
            'visibility' => 'public', 'status' => 'live', 'starts_at' => now()->subHours(2), 'ends_at' => now()->subHour(),
        ]);
        $presence = PresenceSession::create([
            'user_id' => $viewer->id, 'scope' => 'social_world', 'last_seen_at' => now()->subHour(), 'meta' => [],
        ]);

        $this->artisan('warqna:cleanup-social-world')->assertSuccessful();

        $this->assertSame('left', $spectator->fresh()->status);
        $this->assertNull($replay->fresh());
        $this->assertNull($activity->fresh());
        $this->assertSame('finished', $event->fresh()->status);
        $this->assertNull($presence->fresh());
    }

    public function test_live_spectator_endpoint_is_read_only_safe_and_rejects_players(): void
    {
        [$owner, $viewer, $room] = $this->publicRoom([
            'phase' => 'playing',
            'score' => ['teamA' => 30, 'teamB' => 20],
            'hands' => ['1' => ['AS', 'KH'], '2' => ['2C']],
            'deck' => ['QD'],
            'seed' => 'server-secret',
            'allow_spectators' => true,
        ]);
        $token = $viewer->createToken('r11-spectator')->plainTextToken;

        $response = $this->withToken($token)
            ->postJson("/api/mobile/v1/spectator/rooms/{$room->code}/join")
            ->assertCreated()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('spectator.restrictions.read_only', true)
            ->assertJsonPath('spectator.restrictions.hands_visible', false)
            ->assertJsonPath('spectator.restrictions.voice_enabled', false)
            ->assertJsonPath('spectator.state.spectator_safe', true)
            ->assertJsonPath('spectator.state.deck_count', 1);

        $state = $response->json('spectator.state');
        $this->assertArrayNotHasKey('hands', $state);
        $this->assertArrayNotHasKey('deck', $state);
        $this->assertArrayNotHasKey('seed', $state);

        RoomPlayer::create([
            'room_id' => $room->id, 'user_id' => $viewer->id, 'seat' => '3',
            'is_bot' => false, 'connected' => true,
        ]);
        $this->withToken($token)
            ->postJson("/api/mobile/v1/spectator/rooms/{$room->code}/join")
            ->assertForbidden();
    }

    public function test_finished_match_creates_a_signed_privacy_safe_replay(): void
    {
        [$owner, , $room] = $this->publicRoom(['phase' => 'playing', 'hands' => ['1' => ['AS']]]);
        $after = [
            'phase' => 'finished', 'winner' => 'teamA', 'score' => ['teamA' => 100, 'teamB' => 80],
            'hands' => ['1' => ['AS']], 'deck' => ['2C'], 'available_actions' => ['deal_again'],
        ];

        app(MatchReplayService::class)->capture($room, $owner, 'round_finished', $room->state ?: [], $after);
        $replay = MatchReplay::where('room_id', $room->id)->firstOrFail();
        $frame = $replay->event_log[0];

        $this->assertSame('ready', $replay->status);
        $this->assertSame(1, $replay->frames_count);
        $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', (string) $replay->sha256);
        $this->assertSame('round_finished', $frame['action']);
        $this->assertTrue($frame['state']['spectator_safe']);
        $this->assertTrue(app(MatchReplayService::class)->verify($replay));
        $this->assertArrayNotHasKey('hands', $frame['state']);
        $this->assertArrayNotHasKey('deck', $frame['state']);
        $this->assertArrayNotHasKey('available_actions', $frame['state']);

        $replay->update(['event_log' => [['action' => 'tampered']]]);
        $this->assertFalse(app(MatchReplayService::class)->verify($replay->fresh()));
    }

    public function test_replay_visibility_and_social_discovery_follow_privacy_and_blocks(): void
    {
        [$owner, $viewer, $room] = $this->publicRoom(['phase' => 'finished']);
        SocialPreference::updateOrCreate(['user_id' => $owner->id], [
            'profile_visibility' => 'friends', 'presence_visibility' => 'friends',
            'activity_visibility' => 'friends', 'message_policy' => 'friends',
            'invite_policy' => 'friends', 'discoverable' => true, 'allow_friend_requests' => true,
            'allow_follows' => true, 'allow_spectators' => true, 'allow_replay_share' => true,
            'allow_voice' => true, 'show_online_status' => true, 'show_current_room' => false,
        ]);
        $replay = MatchReplay::create([
            'room_id' => $room->id, 'owner_id' => $owner->id, 'game_id' => $room->game_id,
            'visibility' => 'friends', 'status' => 'ready', 'event_log' => [], 'frames_count' => 0,
        ]);
        $policy = app(SocialWorldPolicy::class);

        $this->assertFalse($policy->canDiscover($viewer, $owner));
        $this->assertFalse($policy->canViewReplay($viewer, $replay));
        Friendship::create(['requester_id' => $viewer->id, 'addressee_id' => $owner->id, 'status' => 'accepted']);
        $this->assertTrue($policy->canDiscover($viewer, $owner));
        $this->assertTrue($policy->canViewReplay($viewer, $replay));

        Friendship::where('requester_id', $viewer->id)->where('addressee_id', $owner->id)->update(['status' => 'blocked']);
        $this->assertFalse($policy->canDiscover($viewer, $owner));
        $this->assertFalse($policy->canViewReplay($viewer, $replay));
    }

    public function test_every_human_participant_controls_spectator_and_replay_consent(): void
    {
        [$owner, $viewer, $room] = $this->publicRoom(['phase' => 'playing', 'allow_spectators' => true]);
        $participant = User::factory()->create();
        RoomPlayer::create([
            'room_id' => $room->id, 'user_id' => $participant->id, 'seat' => '2',
            'is_bot' => false, 'connected' => true,
        ]);
        $policy = app(SocialWorldPolicy::class);
        $policy->preferences($participant)->update(['allow_spectators' => false, 'allow_replay_share' => false]);
        $replay = MatchReplay::create([
            'room_id' => $room->id, 'owner_id' => $owner->id, 'game_id' => $room->game_id,
            'visibility' => 'public', 'status' => 'ready', 'event_log' => [], 'frames_count' => 0,
        ]);

        $this->assertFalse($policy->canSpectate($viewer, $room));
        $this->assertFalse($policy->canViewReplay($viewer, $replay));

        $policy->preferences($participant)->update(['allow_spectators' => true, 'allow_replay_share' => true]);
        $this->assertTrue($policy->canSpectate($viewer, $room->fresh()));
        $this->assertTrue($policy->canViewReplay($viewer, $replay->fresh()));
    }

    public function test_social_gift_is_atomic_and_credits_primary_admin_revenue(): void
    {
        $admin = User::factory()->create(['username' => 'Adnan', 'is_admin' => true]);
        $sender = User::factory()->create(['username' => 'r11_sender']);
        $recipient = User::factory()->create(['username' => 'r11_recipient']);
        Wallet::create(['user_id' => $admin->id, 'tokens' => 0, 'gems' => 0]);
        Wallet::create(['user_id' => $sender->id, 'tokens' => 500, 'gems' => 0]);
        $token = $sender->createToken('r11-gift')->plainTextToken;

        $this->withToken($token)->postJson('/api/mobile/v1/social-world/gifts', [
            'recipient_id' => $recipient->id,
            'gift_key' => 'rose',
            'message' => '<b>مبروك</b>',
        ])->assertCreated()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('gift.gift_key', 'rose')
            ->assertJsonPath('gift.token_cost', 50);

        $this->assertSame(450, (int) $sender->wallet()->firstOrFail()->tokens);
        $this->assertSame(50, (int) $admin->wallet()->firstOrFail()->tokens);
        $gift = SocialGift::firstOrFail();
        $this->assertSame('مبروك', $gift->message);
        $this->assertSame('petal_burst', $gift->animation_key);
    }

    public function test_clubs_world_request_moderation_and_one_club_rule(): void
    {
        $owner = User::factory()->create(['is_admin' => true]);
        $applicant = User::factory()->create();
        Wallet::create(['user_id' => $owner->id, 'tokens' => 6000, 'gems' => 0]);
        $ownerToken = $owner->createToken('r11-club-owner')->plainTextToken;
        $applicantToken = $applicant->createToken('r11-club-applicant')->plainTextToken;

        $created = $this->withToken($ownerToken)->postJson('/api/mobile/v1/clubs-world', [
            'name' => 'R11 Contract Club', 'description' => 'Privacy-first club', 'visibility' => 'request',
        ])->assertCreated()->json('club');
        $clubId = (int) $created['id'];

        $this->withToken($applicantToken)->postJson("/api/mobile/v1/clubs-world/{$clubId}/join")
            ->assertStatus(202)->assertJsonPath('status', 'pending');
        $joinRequest = ClubJoinRequest::where('club_id', $clubId)->where('user_id', $applicant->id)->firstOrFail();

        $this->withToken($ownerToken)->patchJson("/api/mobile/v1/clubs-world/join-requests/{$joinRequest->id}", [
            'status' => 'accepted',
        ])->assertOk();
        $this->assertTrue(ClubMember::where('club_id', $clubId)->where('user_id', $applicant->id)->exists());

        $otherOwner = User::factory()->create();
        $otherClub = Club::create([
            'owner_id' => $otherOwner->id, 'name' => 'R11 Other Club', 'visibility' => 'public',
            'level' => 1, 'weekly_points' => 0, 'treasury' => 0, 'capacity' => 20, 'league_tier' => 'bronze',
        ]);
        ClubMember::create(['club_id' => $otherClub->id, 'user_id' => $otherOwner->id, 'role' => 'owner', 'permissions' => ['all' => true]]);

        $this->withToken($applicantToken)->postJson("/api/mobile/v1/clubs-world/{$otherClub->id}/join")
            ->assertStatus(409);
    }

    public function test_admin_social_world_requires_explicit_permission(): void
    {
        $admin = User::factory()->create([
            'username' => 'r11_moderator', 'is_admin' => true, 'admin_permissions' => [],
        ]);
        $token = $admin->createToken('r11-admin')->plainTextToken;

        $this->withToken($token)->getJson('/api/mobile/v1/admin/social-world')->assertForbidden();

        $admin->update(['admin_permissions' => ['social_world' => true]]);
        $this->withToken($token)->getJson('/api/mobile/v1/admin/social-world')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('release.build', 230);
    }

    /** @return array{0:User,1:User,2:Room} */
    private function publicRoom(array $state): array
    {
        $owner = User::factory()->create();
        $viewer = User::factory()->create();
        $game = Game::create([
            'key' => 'r11_contract_game_'.strtolower(Str::random(6)),
            'name' => ['ar' => 'لعبة الاختبار', 'en' => 'Contract Game'],
            'min_players' => 2, 'max_players' => 4, 'partnership' => false,
            'rules' => [], 'active' => true,
        ]);
        $room = Room::create([
            'code' => strtoupper(Str::random(8)), 'game_id' => $game->id, 'owner_id' => $owner->id,
            'visibility' => 'public', 'status' => ($state['phase'] ?? null) === 'finished' ? 'finished' : 'playing',
            'max_players' => 4, 'state' => $state,
        ]);
        RoomPlayer::create([
            'room_id' => $room->id, 'user_id' => $owner->id, 'seat' => '1',
            'is_bot' => false, 'connected' => true,
        ]);

        return [$owner, $viewer, $room];
    }
}
