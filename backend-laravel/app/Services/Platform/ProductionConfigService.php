<?php
namespace App\Services\Platform;

use App\Models\{AppRelease,FeatureFlag};
use Illuminate\Support\Facades\{Cache,Schema};

class ProductionConfigService
{
    /** @return array<string,mixed> */
    public function publicConfig(string $platform = 'web'): array
    {
        $flags = $this->flags();
        $release = $this->release($platform);
        return [
            'app' => config('app.name', 'Warqna'),
            'version' => config('warqna.version', '1.9.0'),
            'build' => (int) config('warqna.build', 700),
            'environment' => app()->environment(),
            'maintenance' => (bool) data_get($flags, 'maintenance_mode.enabled', false),
            'maintenance_message' => (string) data_get($flags, 'maintenance_mode.payload.message', ''),
            'features' => $flags,
            'release' => $release,
            'legal' => [
                'privacy' => url('/legal/privacy'),
                'terms' => url('/legal/terms'),
                'community' => url('/legal/community-guidelines'),
                'account_deletion' => url('/legal/account-deletion'),
                'competition_rules' => url('/legal/competition-rules'),
                'support' => url('/legal/support'),
            ],
            'voice' => [
                'enabled' => (bool) data_get($flags, 'voice_rooms.enabled', true),
                'stun_count' => count((array) config('voice.stun_urls', [])),
                'turn_configured' => count((array) config('voice.turn_urls', [])) > 0,
                'turn_required' => count((array) config('voice.turn_urls', [])) > 0,
                'production_ready' => app()->environment(['local','testing']) || count((array) config('voice.turn_urls', [])) > 0,
            ],
            'multiplayer' => [
                'enabled' => true,
                'server_authoritative' => true,
                'heartbeat' => true,
                'reconnect' => true,
                'parties' => true,
                'public_runtime' => $this->hasPublicRuntimeUrl(),
            ],
            'commerce' => [
                'enabled' => (bool) config('warqna_commerce.enabled', true),
                'sandbox' => (bool) config('warqna_commerce.sandbox', false),
                'google_play_verification_ready' => $this->providerReady('google_play'),
                'apple_verification_ready' => $this->providerReady('apple'),
                'web_verification_ready' => $this->providerReady('web'),
            ],
            'account_cancellation' => [
                'grace_days' => max(30, (int) config('warqna.account_deletion_grace_days', 30)),
                'reactivate_on_login' => true,
                'ordinary_inactivity_deletes_account' => false,
            ],
            'limits' => [
                'token_transfer_fee_percent' => (int) data_get($flags, 'token_transfers.payload.fee_percent', 10),
                'rewarded_ads_daily' => (int) data_get($flags, 'rewarded_ads.payload.daily_limit', 5),
                'competition_max_stages' => (int) data_get($flags, 'competitions.payload.max_stages', 4),
            ],
            'server_time' => now()->toIso8601String(),
        ];
    }

    /** @return array<string,array<string,mixed>> */
    public function flags(): array
    {
        return Cache::remember('warqna:public-feature-flags', 60, function () {
            if (!Schema::hasTable('feature_flags')) return [];
            return FeatureFlag::query()
                ->whereIn('environment', ['all', app()->environment()])
                ->get()
                ->mapWithKeys(fn (FeatureFlag $flag) => [$flag->key => [
                    'enabled' => (bool) $flag->enabled,
                    'payload' => $flag->payload ?: [],
                ]])->all();
        });
    }

    /** @return array<string,mixed>|null */
    public function release(string $platform): ?array
    {
        if (!Schema::hasTable('app_releases')) return null;
        $release = AppRelease::query()->where('platform', $platform)->where('active', true)->latest('build_number')->first();
        if (!$release) return null;
        return [
            'platform' => $release->platform,
            'version' => $release->version,
            'build_number' => (int) $release->build_number,
            'required' => (bool) $release->required,
            'notes' => $release->notes,
            'download_url' => $release->download_url,
        ];
    }

    public function enabled(string $key, bool $default = false): bool
    {
        $flags = $this->flags();
        return array_key_exists($key, $flags) ? (bool) data_get($flags, $key.'.enabled', $default) : $default;
    }

    private function hasPublicRuntimeUrl(): bool
    {
        $host = strtolower((string) parse_url((string) config('app.url', ''), PHP_URL_HOST));
        return $host !== '' && !in_array($host, ['localhost','127.0.0.1','0.0.0.0','::1'], true);
    }

    private function providerReady(string $provider): bool
    {
        if (!(bool) config("warqna_commerce.providers.$provider.enabled", false)) return false;
        if ($provider === 'web' && trim((string) config('warqna_commerce.providers.web.stripe_secret', '')) !== '') return true;
        return trim((string) config("warqna_commerce.providers.$provider.verifier_url", '')) !== ''
            && trim((string) config("warqna_commerce.providers.$provider.verifier_secret", '')) !== '';
    }

    public function forget(): void
    {
        Cache::forget('warqna:public-feature-flags');
    }
}
