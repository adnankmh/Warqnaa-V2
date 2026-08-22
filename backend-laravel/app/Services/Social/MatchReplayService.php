<?php

namespace App\Services\Social;

use App\Models\{MatchReplay, Room, User};
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class MatchReplayService
{
    public function begin(Room $room): ?MatchReplay
    {
        if (!Schema::hasTable('match_replays')) return null;
        $retention = max(1, min(365, (int) \App\Models\SiteSetting::getValue('replay_retention_days', 30)));
        return MatchReplay::firstOrCreate(
            ['room_id' => $room->id],
            [
                'owner_id' => $room->owner_id,
                'game_id' => $room->game_id,
                'visibility' => in_array($room->visibility, ['public', 'friends'], true) ? $room->visibility : 'private',
                'status' => 'recording',
                'event_log' => [],
                'final_state' => null,
                'expires_at' => now()->addDays($retention),
            ]
        );
    }

    public function capture(Room $room, ?User $actor, string $action, array $before, array $after): void
    {
        if (!Schema::hasTable('match_replays') || !filter_var(\App\Models\SiteSetting::getValue('replay_system_enabled', true), FILTER_VALIDATE_BOOLEAN)) return;
        try {
            $this->begin($room);
            $maxFrames = max(50, min(2000, (int) config('warqna_social_world.max_replay_frames', 600)));

            DB::transaction(function () use ($room, $actor, $action, $before, $after, $maxFrames) {
                $replay = MatchReplay::where('room_id', $room->id)->lockForUpdate()->first();
                if (!$replay || $replay->status === 'hidden') return;
                $frames = array_values((array) ($replay->event_log ?: []));
                $publicAfter = $this->spectatorState($after);
                $frames[] = [
                    'index' => count($frames),
                    'at' => now()->toIso8601String(),
                    'actor_id' => $actor?->id,
                    'actor_name' => $actor?->profile?->display_name ?: $actor?->username,
                    'action' => mb_substr($action, 0, 80),
                    'phase_before' => (string) ($before['phase'] ?? ''),
                    'phase_after' => (string) ($after['phase'] ?? ''),
                    'turn' => $publicAfter['turn'] ?? null,
                    'score' => $publicAfter['score'] ?? $publicAfter['scores'] ?? null,
                    'state' => $publicAfter,
                ];
                if (count($frames) > $maxFrames) $frames = array_slice($frames, -$maxFrames);
                $finished = in_array((string) ($after['phase'] ?? ''), ['finished', 'game_over'], true) || $room->status === 'finished';
                $encoded = json_encode($frames, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
                $startedAt = $room->started_at ?: $room->created_at ?: now();
                $replay->update([
                    'event_log' => $frames,
                    'frames_count' => count($frames),
                    'duration_seconds' => (int) max(0, $startedAt->diffInSeconds(now())),
                    'final_state' => $finished ? $publicAfter : null,
                    'status' => $finished ? 'ready' : 'recording',
                    'published_at' => $finished ? ($replay->published_at ?: now()) : null,
                    'sha256' => hash('sha256', (string) $encoded),
                ]);
            });
        } catch (\Throwable $exception) {
            // A social recording failure must never roll back or interrupt an
            // authoritative game action. CI and monitoring still receive a
            // structured warning so the replay path can be repaired safely.
            Log::warning('R11 replay capture skipped without affecting gameplay.', [
                'room_id' => $room->id,
                'action' => mb_substr($action, 0, 80),
                'error' => $exception->getMessage(),
            ]);
        }
    }

    /**
     * Spectator/replay payloads never contain a player's hand, the deck, legal
     * actions, private engine metadata or undisclosed draw piles.
     *
     * @return array<string,mixed>
     */
    public function spectatorState(array $state): array
    {
        $copy = $this->sanitizeNode($state);
        $hands = is_array($state['hands'] ?? null) ? $state['hands'] : [];
        $copy['hand_counts'] = [];
        foreach ($hands as $key => $cards) {
            $copy['hand_counts'][(string) $key] = is_array($cards) ? count($cards) : 0;
        }
        if (isset($state['deck']) && is_array($state['deck'])) $copy['deck_count'] = count($state['deck']);
        if (isset($state['stock']) && is_array($state['stock'])) $copy['stock_count'] = count($state['stock']);
        if (isset($state['boneyard']) && is_array($state['boneyard'])) $copy['boneyard_count'] = count($state['boneyard']);
        $copy['spectator_safe'] = true;
        $copy['hands_visible'] = false;
        return $copy;
    }

    /**
     * Recursively strips secret material so a future engine cannot leak a
     * nested hand, RNG seed, room password or action hint by changing shape.
     *
     * @return array<string|int,mixed>
     */
    private function sanitizeNode(array $node): array
    {
        $blocked = [
            'hands', 'hand', 'cards', 'cards_in_hand', 'deck', 'stock', 'draw_pile', 'boneyard',
            'legal_cards', 'available_actions', 'private_state', 'private_metadata',
            'secret', 'secrets', 'seed', 'rng', 'deal_nonce', 'plain_room_password',
            'room_password', 'password', 'invite_token', 'auth_token', 'session_token',
            'api_key', 'access_key', 'private_key', 'credential', 'credentials',
            'authorization', 'cookie', 'cookies', 'csrf', 'csrf_token', 'remember_token',
            'email', 'phone', 'phone_number', 'ip', 'ip_address', 'user_agent', 'device_token', 'push_token',
            'kicked_user_ids', 'banned_user_ids', 'disconnected_replacements', 'video_frames',
        ];
        $safe = [];
        foreach ($node as $key => $value) {
            $normalized = strtolower((string) $key);
            if (str_starts_with($normalized, '_') || in_array($normalized, $blocked, true)
                || str_contains($normalized, 'hand') || str_contains($normalized, 'private')
                || str_contains($normalized, 'legal_') || str_contains($normalized, 'available_action')
                || str_contains($normalized, 'valid_action') || str_contains($normalized, 'rng')
                || str_starts_with($normalized, 'deck_') || str_starts_with($normalized, 'stock_')
                || str_contains($normalized, 'password') || str_contains($normalized, 'secret')
                || str_contains($normalized, 'credential') || str_contains($normalized, 'authorization')
                || str_ends_with($normalized, '_token') || str_ends_with($normalized, '_cookie')) {
                continue;
            }
            $safe[$key] = is_array($value) ? $this->sanitizeNode($value) : $value;
        }
        return $safe;
    }

    /** @return array<string,mixed> */
    public function payload(MatchReplay $replay, bool $includeFrames = false): array
    {
        $replay->loadMissing(['room.players.user.profile', 'owner.profile', 'game']);
        return [
            'id' => $replay->id,
            'room_code' => $replay->room?->code,
            'game' => $replay->game?->key,
            'game_name' => $replay->game?->name,
            'owner' => $replay->owner ? [
                'id' => $replay->owner->id,
                'name' => $replay->owner->profile?->display_name ?: $replay->owner->username,
                'avatar' => $replay->owner->profile?->avatar,
            ] : null,
            'players' => $replay->room?->players?->where('is_bot', false)->map(fn ($player) => [
                'id' => $player->user_id,
                'name' => $player->user?->profile?->display_name ?: $player->user?->username,
                'avatar' => $player->user?->profile?->avatar,
                'seat' => (int) $player->seat,
            ])->values()->all() ?? [],
            'visibility' => $replay->visibility,
            'status' => $replay->status,
            'duration_seconds' => (int) $replay->duration_seconds,
            'frames_count' => (int) $replay->frames_count,
            'views' => (int) $replay->views,
            'featured' => (bool) $replay->featured,
            'sha256' => $replay->sha256,
            'integrity_verified' => $this->verify($replay),
            'published_at' => $replay->published_at?->toIso8601String(),
            'final_state' => $includeFrames ? $replay->final_state : null,
            'frames' => $includeFrames ? array_values((array) ($replay->event_log ?: [])) : null,
            'privacy' => ['hands_visible' => false, 'voice_included' => false, 'private_chat_included' => false],
        ];
    }

    public function verify(MatchReplay $replay): bool
    {
        if (!$replay->sha256 || !preg_match('/^[a-f0-9]{64}$/', (string) $replay->sha256)) return false;
        $frames = array_values((array) ($replay->event_log ?: []));
        $encoded = json_encode($frames, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        return is_string($encoded) && hash_equals((string) $replay->sha256, hash('sha256', $encoded));
    }
}
