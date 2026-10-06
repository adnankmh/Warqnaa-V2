<?php

namespace Tests\Feature;

use App\Models\{CompetitiveMatch, CompetitiveSeason, Game, User};
use App\Services\GameEngine\{HandRules, PinochleRules};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class R28HandBanakilCompetitionAppealTest extends TestCase
{
    use RefreshDatabase;

    public function test_hand_manual_order_survives_a_later_stock_draw(): void
    {
        $engine = new HandRules();
        $player = 'user:1';
        $state = $engine->initialState([$player, 'user:2']);
        $original = array_values($state['hands'][$player]);
        $reordered = array_reverse($original);

        $this->assertTrue($engine->validate($state, $player, 'organize', ['cards' => $reordered]));
        $state = $engine->apply($state, $player, 'organize', ['cards' => $reordered]);
        $this->assertSame($reordered, $state['hands'][$player]);
        $this->assertSame($player, $state['turn']);

        $this->assertTrue($engine->validate($state, $player, 'draw_deck', []));
        $afterDraw = $engine->apply($state, $player, 'draw_deck', []);
        $this->assertSame($reordered, array_slice($afterDraw['hands'][$player], 0, count($reordered)));
        $this->assertCount(count($reordered) + 1, $afterDraw['hands'][$player]);
    }

    public function test_banakil_can_take_multiple_consecutive_cards_from_the_fire(): void
    {
        $engine = new PinochleRules();
        $player = 'user:2';
        $state = $engine->initialState(['user:1', $player]);
        $state['turn'] = $player;
        $state['drew_this_turn'] = [];
        $state['discard'] = ['3_clubs', '4_diamonds', '5_spades', '6_hearts'];
        $before = count($state['hands'][$player]);

        $actions = $engine->availableActions($state, $player);
        $stack = collect($actions)->firstWhere('type', 'draw_discard_stack');
        $this->assertSame(4, (int) ($stack['max_count'] ?? 0));
        $this->assertTrue($engine->validate($state, $player, 'draw_discard_stack', ['count' => 3]));

        $next = $engine->apply($state, $player, 'draw_discard_stack', ['count' => 3]);
        $this->assertSame(['3_clubs'], $next['discard']);
        $this->assertCount($before + 3, $next['hands'][$player]);
        $this->assertTrue((bool) ($next['drew_this_turn'][$player] ?? false));
        $this->assertFalse($engine->validate($next, $player, 'draw_discard_stack', ['count' => 2]));
    }

    public function test_player_can_appeal_and_primary_admin_can_delegate_a_reviewer(): void
    {
        $player = $this->user('r28_player');
        $outsider = $this->user('r28_outsider');
        $primary = $this->user('Adnan', true, 'primary_admin');
        $reviewer = $this->user('r28_reviewer');
        $game = Game::firstOrCreate(
            ['key' => 'basra'],
            ['name' => ['ar' => 'باصرة', 'en' => 'Basra'], 'min_players' => 2, 'max_players' => 2, 'partnership' => false, 'rules' => [], 'active' => true]
        );
        $season = CompetitiveSeason::where('status', 'active')->firstOrFail();
        $match = CompetitiveMatch::create([
            'match_key' => (string) Str::uuid(),
            'season_id' => $season->id,
            'game_id' => $game->id,
            'mode' => 'tournament',
            'status' => 'completed',
            'region' => 'global',
            'team_size' => 1,
            'participant_ids' => [$player->id, $outsider->id],
            'team_map' => [(string) $player->id => 'player:'.$player->id, (string) $outsider->id => 'player:'.$outsider->id],
            'rating_snapshot' => [],
            'result' => ['winner_user_ids' => [$player->id]],
            'rating_processed' => true,
            'reward_processed' => true,
            'anti_cheat_status' => 'clean',
            'started_at' => now()->subMinutes(15),
            'finished_at' => now()->subMinutes(2),
            'processed_at' => now()->subMinute(),
        ]);

        $playerToken = $player->createToken('r28-player')->plainTextToken;
        $this->withToken($playerToken)->postJson("/api/mobile/v1/competitive/matches/{$match->id}/appeals", [
            'category' => 'result',
            'reason' => 'أعترض على النتيجة وأطلب مراجعة سجل المباراة الكامل.',
            'evidence' => ['راجع سجل الحركات وإعادة المباراة.'],
        ])->assertCreated()->assertJsonPath('appeal.status', 'pending');

        $primaryToken = $primary->createToken('r28-primary')->plainTextToken;
        $this->withToken($primaryToken)->patchJson("/api/mobile/v1/admin/competitive/reviewers/{$reviewer->id}", [
            'enabled' => true,
        ])->assertOk()->assertJsonPath('user.competition_review', true);

        $reviewer->refresh();
        $this->assertTrue((bool) $reviewer->is_admin);
        $this->assertTrue($reviewer->hasAdminPermission('competition_review'));

        $reviewerToken = $reviewer->createToken('r28-reviewer')->plainTextToken;
        $appealId = (int) $player->competitionAppeals()->value('id');
        $this->withToken($reviewerToken)->getJson('/api/mobile/v1/admin/competitive/appeals')
            ->assertOk()->assertJsonPath('appeals.0.id', $appealId);

        $this->withToken($reviewerToken)->patchJson("/api/mobile/v1/admin/competitive/appeals/{$appealId}", [
            'decision' => 'uphold',
            'note' => 'تمت مراجعة السجل الكامل وتبين أن النتيجة المسجلة صحيحة.',
        ])->assertOk()->assertJsonPath('appeal.status', 'upheld');

        $this->withToken($playerToken)->getJson('/api/mobile/v1/competitive/appeals')
            ->assertOk()->assertJsonPath('appeals.0.status', 'upheld');
    }

    private function user(string $username, bool $admin = false, string $role = 'player'): User
    {
        $user = User::factory()->create([
            'username' => $username,
            'is_admin' => $admin,
            'admin_role' => $role,
            'admin_permissions' => [],
        ]);
        $user->profile()->create([
            'display_name' => $username,
            'country_code' => 'PS',
            'country_name' => 'فلسطين',
            'level' => 20,
            'xp' => 0,
        ]);
        return $user->fresh('profile');
    }
}
