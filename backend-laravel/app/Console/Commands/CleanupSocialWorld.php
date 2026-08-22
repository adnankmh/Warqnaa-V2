<?php

namespace App\Console\Commands;

use App\Models\{MatchReplay, PresenceSession, RoomSpectator, SocialActivity, SocialEvent};
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class CleanupSocialWorld extends Command
{
    protected $signature = 'warqna:cleanup-social-world {--dry-run : Report due records without changing them}';

    protected $description = 'Expire stale Social World presence, events, activities, spectators, and replay retention records.';

    public function handle(): int
    {
        $required = ['room_spectators', 'match_replays', 'social_activities', 'social_events', 'presence_sessions'];
        foreach ($required as $table) {
            if (!Schema::hasTable($table)) {
                $this->warn("Social World cleanup skipped until {$table} is migrated.");
                return self::SUCCESS;
            }
        }

        $now = now();
        $staleBefore = $now->copy()->subSeconds(max(15, min(180, (int) config('warqna_social_world.spectator_stale_seconds', 30))));
        $counts = [
            'stale_spectators' => RoomSpectator::where('status', 'active')->where('last_seen_at', '<', $staleBefore)->count(),
            'expired_replays' => MatchReplay::whereNotNull('expires_at')->where('expires_at', '<=', $now)->count(),
            'expired_activities' => SocialActivity::whereNotNull('expires_at')->where('expires_at', '<=', $now->copy()->subDays(7))->count(),
            'events_to_live' => SocialEvent::where('status', 'scheduled')->where('starts_at', '<=', $now)
                ->where(fn ($query) => $query->whereNull('ends_at')->orWhere('ends_at', '>', $now))->count(),
            'events_to_finish' => SocialEvent::whereIn('status', ['scheduled', 'live'])->where(function ($query) use ($now) {
                $query->where(fn ($ended) => $ended->whereNotNull('ends_at')->where('ends_at', '<=', $now))
                    ->orWhere(fn ($untimed) => $untimed->whereNull('ends_at')->where('starts_at', '<=', $now->copy()->subDay()));
            })->count(),
            'stale_presence' => PresenceSession::where('scope', 'social_world')->where('last_seen_at', '<', $now->copy()->subMinutes(10))->count(),
        ];

        if ($this->option('dry-run')) {
            $this->line(json_encode($counts, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
            return self::SUCCESS;
        }

        DB::transaction(function () use ($now, $staleBefore): void {
            RoomSpectator::where('status', 'active')->where('last_seen_at', '<', $staleBefore)->update([
                'status' => 'left', 'can_chat' => false, 'voice_enabled' => false,
            ]);
            MatchReplay::whereNotNull('expires_at')->where('expires_at', '<=', $now)->delete();
            SocialActivity::whereNotNull('expires_at')->where('expires_at', '<=', $now->copy()->subDays(7))->delete();
            SocialEvent::whereIn('status', ['scheduled', 'live'])->where(function ($query) use ($now) {
                $query->where(fn ($ended) => $ended->whereNotNull('ends_at')->where('ends_at', '<=', $now))
                    ->orWhere(fn ($untimed) => $untimed->whereNull('ends_at')->where('starts_at', '<=', $now->copy()->subDay()));
            })->update(['status' => 'finished']);
            SocialEvent::where('status', 'scheduled')->where('starts_at', '<=', $now)
                ->where(fn ($query) => $query->whereNull('ends_at')->orWhere('ends_at', '>', $now))
                ->update(['status' => 'live']);
            PresenceSession::where('scope', 'social_world')->where('last_seen_at', '<', $now->copy()->subMinutes(10))->delete();
        });

        $this->info('Social World cleanup complete: '.collect($counts)->map(fn ($value, $key) => "{$key}={$value}")->implode(', '));
        return self::SUCCESS;
    }
}
