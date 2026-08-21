<?php

return [
    'mode' => env('WARQNA_ASSET_MODE', 'hybrid'), // local|hybrid|remote
    'cdn_url' => rtrim((string) env('WARQNA_ASSET_CDN_URL', ''), '/'),
    'manifest_ttl_seconds' => (int) env('WARQNA_ASSET_MANIFEST_TTL', 21600),
    'data_saver_default' => filter_var(env('WARQNA_DATA_SAVER_DEFAULT', false), FILTER_VALIDATE_BOOL),
    'manifest_file' => resource_path('data/r10_asset_manifest.json'),
];
