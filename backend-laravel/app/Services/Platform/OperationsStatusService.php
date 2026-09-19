<?php

namespace App\Services\Platform;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

final class OperationsStatusService
{
    public const HEARTBEAT_KEY = 'warqnaa:operations:scheduler';

    public function snapshot(): array
    {
        $health = app(PlatformHealthService::class)->snapshot();
        $release = app(GlobalReleaseReadinessService::class)->report(true);
        try {
            $heartbeat = Cache::get(self::HEARTBEAT_KEY);
        } catch (\Throwable) {
            $heartbeat = null;
        }
        $age = is_numeric($heartbeat) ? time() - (int) $heartbeat : null;
        $scheduler = $age !== null && $age >= 0 && $age <= 180;
        $counts = [];
        foreach ([
            'active_rooms' => ['rooms', ['waiting', 'bidding', 'playing']],
            'ranked_waiting' => ['ranked_queue_entries', ['waiting', 'matching']],
            'open_reports' => ['user_reports', ['open', 'reviewing']],
            'economy_reviews' => ['economy_audit_events', ['open', 'reviewing']],
        ] as $key => [$table, $statuses]) {
            try {
                $counts[$key] = DB::table($table)->whereIn('status', $statuses)->count();
            } catch (\Throwable) {
                // Unknown is never rendered as a healthy zero.
                $counts[$key] = null;
            }
        }
        return [
            'release' => config('warqna.version').'+'.config('warqna.build'),
            'generated_at' => now()->toIso8601String(),
            'environment' => app()->environment(),
            'checks' => [
                'database' => (bool) $health['database_connected'],
                'cache' => (bool) $health['cache_connected'],
                'schema' => !in_array(false, $health['database'], true),
                'scheduler' => $scheduler,
                'release_config' => (bool) $release['checks']['release_version'],
                'https' => str_starts_with((string) config('app.url'), 'https://'),
                'debug_disabled' => !(bool) config('app.debug'),
            ],
            'scheduler_age_seconds' => $age,
            'counts' => $counts,
            // A green runtime panel is not certification of store signing/payment setup.
            'deployment_config_ready' => $health['ok'] && $scheduler && $release['ready'],
            'warnings' => $release['warnings'],
        ];
    }
}
