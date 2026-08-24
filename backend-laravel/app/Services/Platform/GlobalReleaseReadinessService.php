<?php

namespace App\Services\Platform;

final class GlobalReleaseReadinessService
{
    public function report(bool $strict = false): array
    {
        $checks = [
            'release_version' => config('warqna.version') === '1.0.3' && (int)config('warqna.build') === 263,
            'bilingual_contract' => config('warqna_global_release.locales') === ['ar', 'en'],
            'four_channels' => count((array)config('warqna_global_release.channels')) === 4,
            'engine_gold' => (int)config('warqna_global_release.engine_gold.engines') === 20
                && (int)config('warqna_global_release.engine_gold.matches_per_engine') >= 2000,
            'production_definition' => is_file(base_path('docker-compose.production.yml')),
            'android_store_icon' => is_file(base_path('../assets/play-store/icon-512.png')),
            'android_feature_graphic' => is_file(base_path('../assets/play-store/feature-graphic-1024x500.png')),
            'web_manifest' => is_file(base_path('../flutter_app/web/manifest.json')) || is_file(base_path('../flutter_app/web/manifest.webmanifest')),
        ];
        $warnings = [];
        if (config('app.env') !== 'production') $warnings[] = 'APP_ENV must be production at deployment time.';
        if ((bool)config('app.debug')) $warnings[] = 'APP_DEBUG must be false at deployment time.';
        if (!str_starts_with((string)config('app.url'), 'https://')) $warnings[] = 'APP_URL must use HTTPS at deployment time.';
        $ready = !in_array(false, $checks, true) && (!$strict || !$warnings);
        return [
            'release' => '1.0.3+263', 'contract' => 'r14_3_ci_engine_security_v1',
            'ready' => $ready, 'strict' => $strict, 'checks' => $checks,
            'warnings' => $warnings, 'channels' => config('warqna_global_release.channels'),
        ];
    }
}
