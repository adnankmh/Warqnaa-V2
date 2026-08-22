<?php

return [
    'release' => '0.7.0+240',
    'initial_rating' => (int) env('WARQNAA_RANKED_INITIAL_RATING', 1000),
    'rating_floor' => 100,
    'placement_games' => 10,
    'queue_timeout_minutes' => (int) env('WARQNAA_RANKED_QUEUE_TIMEOUT_MINUTES', 15),
    'search_window_initial' => (int) env('WARQNAA_RANKED_SEARCH_WINDOW_INITIAL', 100),
    'search_window_max' => (int) env('WARQNAA_RANKED_SEARCH_WINDOW_MAX', 500),
    'abandon_penalty' => (int) env('WARQNAA_RANKED_ABANDON_PENALTY', 35),
    'tiers' => [
        ['key' => 'bronze', 'ar' => 'برونزي', 'en' => 'Bronze', 'min' => 0, 'color' => '#B7794B', 'icon' => '◆'],
        ['key' => 'silver', 'ar' => 'فضي', 'en' => 'Silver', 'min' => 900, 'color' => '#C7D2E0', 'icon' => '◇'],
        ['key' => 'gold', 'ar' => 'ذهبي', 'en' => 'Gold', 'min' => 1100, 'color' => '#F4C85A', 'icon' => '✦'],
        ['key' => 'platinum', 'ar' => 'بلاتيني', 'en' => 'Platinum', 'min' => 1300, 'color' => '#67E8F9', 'icon' => '✧'],
        ['key' => 'diamond', 'ar' => 'ماسي', 'en' => 'Diamond', 'min' => 1500, 'color' => '#7DD3FC', 'icon' => '◈'],
        ['key' => 'master', 'ar' => 'ماستر', 'en' => 'Master', 'min' => 1750, 'color' => '#C084FC', 'icon' => '♛'],
        ['key' => 'grandmaster', 'ar' => 'جراند ماستر', 'en' => 'Grandmaster', 'min' => 2000, 'color' => '#FB7185', 'icon' => '♚'],
        ['key' => 'legend', 'ar' => 'أسطورة ورقنا', 'en' => 'Warqnaa Legend', 'min' => 2300, 'color' => '#FDE68A', 'icon' => '★'],
    ],
    'season_rewards' => [
        'bronze' => ['tokens' => 250, 'xp' => 100, 'badge' => null],
        'silver' => ['tokens' => 600, 'xp' => 250, 'badge' => null],
        'gold' => ['tokens' => 1500, 'xp' => 500, 'badge' => 'season_gold'],
        'platinum' => ['tokens' => 3500, 'xp' => 900, 'badge' => 'season_platinum'],
        'diamond' => ['tokens' => 7500, 'xp' => 1600, 'badge' => 'season_diamond'],
        'master' => ['tokens' => 15000, 'xp' => 2600, 'badge' => 'season_master'],
        'grandmaster' => ['tokens' => 30000, 'xp' => 4200, 'badge' => 'season_grandmaster'],
        'legend' => ['tokens' => 60000, 'xp' => 7000, 'badge' => 'season_legend'],
    ],
];
