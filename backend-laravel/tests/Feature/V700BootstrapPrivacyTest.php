<?php

namespace Tests\Feature;

use App\Models\{Game, Room, RoomPlayer, User};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class V700BootstrapPrivacyTest extends TestCase
{
    use RefreshDatabase;

    public function test_bootstrap_filters_room_visibility_and_never_serializes_private_game_state(): void
    {
        $owner = User::factory()->create();
        $visitor = User::factory()->create();
        $member = User::factory()->create();
        $game = Game::firstOrCreate(['key'=>'tarneeb'], ['name'=>['ar'=>'طرنيب','en'=>'Tarneeb'], 'active'=>true, 'min_players'=>4, 'max_players'=>4]);
        foreach (['public', 'private', 'friends'] as $visibility) {
            $room = Room::create([
                'code'=>'R7'.strtoupper($visibility), 'game_id'=>$game->id,
                'owner_id'=>$owner->id, 'visibility'=>$visibility, 'status'=>'playing',
                'max_players'=>4, 'target_score'=>41, 'password'=>bcrypt(bin2hex(random_bytes(16))),
                'state'=>['hands'=>['user:'.$owner->id=>['AS','KS']], 'deck'=>['QS']],
            ]);
            if ($visibility === 'private') {
                RoomPlayer::create(['room_id'=>$room->id, 'user_id'=>$member->id, 'seat'=>'1', 'is_bot'=>false, 'connected'=>true]);
            }
        }
        // Return to the outsider after privileged views to catch stale actors
        // in both directions, not just missing owner/member rooms.
        foreach ([[$visitor, ['R7PUBLIC']], [$owner, ['R7PUBLIC','R7PRIVATE','R7FRIENDS']], [$member, ['R7PUBLIC','R7PRIVATE']], [$visitor, ['R7PUBLIC']]] as [$user, $expected]) {
            $response = $this->withToken($user->createToken('r7')->plainTextToken)->getJson('/api/mobile/v1/bootstrap')->assertOk();
            $this->assertSame($user->id, $response->json('user.id'));
            $rooms = $response->json('rooms');
            $this->assertEqualsCanonicalizing($expected, array_column($rooms, 'code'));
            foreach ($rooms as $room) {
                $this->assertArrayNotHasKey('state', $room);
                $this->assertArrayNotHasKey('password', $room);
                $this->assertArrayHasKey('game', $room);
            }
        }
    }
}
