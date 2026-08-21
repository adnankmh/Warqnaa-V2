<?php
return [
    'enabled' => env('WARQNAA_COMMERCE_ENABLED', true),
    'sandbox' => env('WARQNAA_COMMERCE_SANDBOX', false),
    'providers' => [
        'google_play' => ['enabled' => env('WARQNAA_GOOGLE_PLAY_BILLING', true)],
        'apple' => ['enabled' => env('WARQNAA_APPLE_IAP', true)],
        'web' => ['enabled' => env('WARQNAA_WEB_PAYMENTS', true)],
    ],
    'ads' => [
        'rewarded' => true,
        'interstitial' => true,
        'during_match' => false,
        'rewarded_daily_limit' => 5,
        'interstitial_min_minutes' => 12,
    ],
    // Product identifiers are deliberately configuration-only. Store console
    // product IDs can be swapped without changing game rules or client code.
    'packages' => [
        'starter_tokens' => ['product_id'=>'warqnaa.tokens.starter','usd_minor'=>99,'tokens'=>1200,'badge'=>'START','icon'=>'🪙'],
        'value_tokens' => ['product_id'=>'warqnaa.tokens.value','usd_minor'=>399,'tokens'=>6000,'badge'=>'VALUE','icon'=>'💰'],
        'royal_tokens' => ['product_id'=>'warqnaa.tokens.royal','usd_minor'=>999,'tokens'=>18000,'badge'=>'ROYAL','icon'=>'👑'],
        'elite_tokens' => ['product_id'=>'warqnaa.tokens.elite','usd_minor'=>1999,'tokens'=>42000,'badge'=>'ELITE','icon'=>'💎'],
    ],
    'offer_cadences' => ['daily','weekly','monthly','annual'],
];
