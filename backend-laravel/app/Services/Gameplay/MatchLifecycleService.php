<?php

namespace App\Services\Gameplay;

use App\Models\{GameSessionEvent,Room,RoomPlayer,User};
use Illuminate\Support\Facades\DB;

class MatchLifecycleService
{
    public const HEARTBEAT_STALE_SECONDS = 35;
    public const RECONNECT_GRACE_SECONDS = 90;
    public const ABANDONED_SECONDS = 600;

    public function heartbeat(Room $room, User $user): RoomPlayer
    {
        $player = $room->players()->where('user_id', $user->id)->firstOrFail();
        $state = (array)($room->state ?? []);
        abort_if(in_array((int)$user->id, array_map('intval',(array)($state['expired_user_ids'] ?? [])), true), 410, 'This game seat expired after extended inactivity.');
        $wasDisconnected = !$player->connected;
        $player->forceFill([
            'connected' => true,
            'missed_turns' => 0,
            'last_heartbeat_at' => now(),
            'disconnected_at' => null,
            'afk_since' => null,
            'bot_difficulty' => null,
        ])->save();
        if ($wasDisconnected) $this->event($room, $user, 'player.reconnected', 0, ['seat'=>$player->seat]);
        return $player;
    }

    public function disconnect(Room $room, User $user, string $reason = 'network'): RoomPlayer
    {
        $player = $room->players()->where('user_id', $user->id)->firstOrFail();
        $player->forceFill([
            'connected' => false,
            'disconnected_at' => now(),
            'afk_since' => $player->afk_since ?: now(),
        ])->save();
        $this->event($room, $user, 'player.disconnected', 1, ['seat'=>$player->seat,'reason'=>$reason]);
        return $player;
    }

    public function sweep(Room $room): array
    {
        $now = now();
        $events = [];
        DB::transaction(function () use ($room, $now, &$events) {
            $room->loadMissing('players.user');
            foreach ($room->players->where('is_bot', false) as $player) {
                $heartbeat = $player->last_heartbeat_at ?: $player->updated_at;
                if ($player->connected && $heartbeat && $heartbeat->lt($now->copy()->subSeconds(self::HEARTBEAT_STALE_SECONDS))) {
                    $player->forceFill(['connected'=>false,'disconnected_at'=>$now,'afk_since'=>$player->afk_since ?: $now])->save();
                    $events[] = ['type'=>'afk','user_id'=>$player->user_id,'seat'=>$player->seat];
                    $this->event($room, $player->user, 'player.afk', 1, ['seat'=>$player->seat]);
                }
                if (!$player->connected && $player->disconnected_at && $player->disconnected_at->lt($now->copy()->subSeconds(self::ABANDONED_SECONDS))) {
                    $state=(array)($room->state ?? []);
                    $expired=array_values(array_unique(array_merge(array_map('intval',(array)($state['expired_user_ids'] ?? [])),[(int)$player->user_id])));
                    $state['expired_user_ids']=$expired;
                    $state['last_abandoned_at']=$now->toIso8601String();
                    $room->state=$state;$room->save();
                    if ($player->bot_difficulty === null) { $player->bot_difficulty='master'; $player->save(); }
                    $events[]=['type'=>'abandoned','user_id'=>$player->user_id,'seat'=>$player->seat];
                    $this->event($room,$player->user,'player.abandoned',2,['seat'=>$player->seat,'after_seconds'=>self::ABANDONED_SECONDS]);
                    continue;
                }
                if (!$player->connected && $player->bot_difficulty === null && $player->disconnected_at && $player->disconnected_at->lt($now->copy()->subSeconds(self::RECONNECT_GRACE_SECONDS))) {
                    $state = $room->state ?: [];
                    $competitive = (bool)($state['competitive'] ?? false);
                    // Competitive games retain the official user identity and use server auto-play.
                    // Casual games mark the seat as temporarily controlled by a bot without changing ownership.
                    $player->bot_difficulty = $competitive ? 'pro' : $this->difficultyFor($room, $player);
                    $player->save();
                    $events[] = ['type'=>'server_control','user_id'=>$player->user_id,'seat'=>$player->seat,'difficulty'=>$player->bot_difficulty];
                    $this->event($room, $player->user, 'player.server_control', $competitive ? 2 : 1, ['seat'=>$player->seat,'difficulty'=>$player->bot_difficulty,'competitive'=>$competitive]);
                }
            }
        });
        return $events;
    }

    public function snapshot(Room $room, ?User $viewer = null): array
    {
        $room->loadMissing('players.user.profile');
        return [
            'room' => $room->code,
            'grace_seconds' => self::RECONNECT_GRACE_SECONDS,
            'heartbeat_stale_seconds' => self::HEARTBEAT_STALE_SECONDS,
            'abandoned_seconds' => self::ABANDONED_SECONDS,
            'players' => $room->players->map(fn(RoomPlayer $p) => [
                'user_id'=>$p->user_id,'seat'=>$p->seat,'is_bot'=>(bool)$p->is_bot,'connected'=>(bool)$p->connected,
                'missed_turns'=>(int)$p->missed_turns,'last_heartbeat_at'=>$p->last_heartbeat_at?->toIso8601String(),
                'disconnected_at'=>$p->disconnected_at?->toIso8601String(),'afk_since'=>$p->afk_since?->toIso8601String(),
                'server_control'=>$p->bot_difficulty,
            ])->values(),
            'viewer_seat' => $viewer ? $room->players->firstWhere('user_id', $viewer->id)?->seat : null,
        ];
    }

    private function difficultyFor(Room $room, RoomPlayer $player): string
    {
        $state = $room->state ?: [];
        $level = (int)($player->user?->profile?->level ?? 1);
        return (string)($state['bot_difficulty'] ?? ($level >= 50 ? 'master' : ($level >= 20 ? 'pro' : 'normal')));
    }

    private function event(Room $room, ?User $user, string $type, int $severity, array $payload): void
    {
        GameSessionEvent::create(['room_id'=>$room->id,'user_id'=>$user?->id,'type'=>$type,'severity'=>$severity,'payload'=>$payload]);
    }
}
