<?php

return [
    'release' => '1.3.0+304',
    'contract' => 'r14_3_ci_engine_security_v1',
    'locales' => ['ar', 'en'],
    'future_locales' => ['de', 'tr', 'fr', 'es'],
    'channels' => ['backend', 'web', 'android', 'ios'],
    'required_gates' => [
        'r8_r13_regression', 'engine_gold_release', 'laravel_phpunit',
        'flutter_analyze', 'flutter_test', 'android_aab', 'ios_no_codesign',
        'web_release', 'docker_image', 'secret_scan', 'release_checksums',
    ],
    'engine_gold' => ['engines' => 20, 'matches_per_engine' => 2000],
    'store_assets' => [
        'icon' => 'assets/play-store/icon-512.png',
        'feature_graphic' => 'assets/play-store/feature-graphic-1024x500.png',
    ],
];
