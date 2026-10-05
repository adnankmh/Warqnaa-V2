<?php
namespace App\Services\Platform;

use Illuminate\Support\Facades\{Cache,DB,Schema};
use Illuminate\Support\Str;

class PlatformHealthService
{
    public function snapshot(): array
    {
        $startedAt = microtime(true);
        $correlationId = (string) Str::uuid();
        $tables = ['users','games','rooms','messages','notifications','store_items','inventory_items','friendships','feature_flags','app_releases'];
        $checks = [];
        foreach ($tables as $table) {
            try { $checks[$table] = Schema::hasTable($table); } catch (\Throwable) { $checks[$table] = false; }
        }
        $databaseConnected = false;
        try { DB::connection()->getPdo(); $databaseConnected = true; } catch (\Throwable) {}
        $cacheConnected = false;
        $healthCacheKey = 'warqna-health:'.$correlationId;
        try {
            Cache::put($healthCacheKey, 'ok', 10);
            $cacheConnected = Cache::get($healthCacheKey) === 'ok';
        } catch (\Throwable) {
        } finally {
            try { Cache::forget($healthCacheKey); } catch (\Throwable) {}
        }
        $missingTables = array_keys(array_filter($checks, static fn (bool $ready): bool => !$ready));
        $ok = $databaseConnected && $cacheConnected && $missingTables === [];
        return [
            'ok' => $ok,
            'status' => $ok ? 'ready' : 'degraded',
            'correlation_id' => $correlationId,
            'version' => config('warqna.version', '1.9.0'),
            'build' => (int) config('warqna.build', 700),
            'environment' => app()->environment(),
            'database_connected' => $databaseConnected,
            'cache_connected' => $cacheConnected,
            'database' => $checks,
            'failure_classes' => array_values(array_filter([
                $databaseConnected ? null : 'database_unavailable',
                $cacheConnected ? null : 'cache_unavailable',
                $missingTables === [] ? null : 'schema_incomplete',
            ])),
            'missing_tables' => $missingTables,
            'counts' => config('warqna.health_show_counts') ? $this->counts() : null,
            'voice_turn_configured' => count((array) config('voice.turn_urls', [])) > 0,
            'queue' => config('queue.default'),
            'duration_ms' => (int) round((microtime(true) - $startedAt) * 1000),
            'time' => now()->toIso8601String(),
        ];
    }

    private function counts(): array
    {
        $out = [];
        foreach (['users','games','rooms','messages','notifications','store_items','user_reports'] as $table) {
            try { $out[$table] = Schema::hasTable($table) ? DB::table($table)->count() : 0; } catch (\Throwable) { $out[$table] = 0; }
        }
        return $out;
    }
}
