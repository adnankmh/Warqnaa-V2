<?php

return [
    'release' => '0.6.0+230',
    'max_replay_frames' => (int) env('WARQNAA_REPLAY_MAX_FRAMES', 600),
    'spectator_stale_seconds' => (int) env('WARQNAA_SPECTATOR_STALE_SECONDS', 30),
    'gifts' => [
        'rose' => ['ar' => 'وردة ملكية', 'en' => 'Royal Rose', 'icon' => '🌹', 'cost' => 50, 'animation' => 'petal_burst'],
        'coffee' => ['ar' => 'قهوة المجلس', 'en' => 'Majlis Coffee', 'icon' => '☕', 'cost' => 100, 'animation' => 'coffee_glow'],
        'applause' => ['ar' => 'تصفيق الأبطال', 'en' => 'Champion Applause', 'icon' => '👏', 'cost' => 250, 'animation' => 'gold_confetti'],
        'falcon' => ['ar' => 'الصقر الذهبي', 'en' => 'Golden Falcon', 'icon' => '🦅', 'cost' => 600, 'animation' => 'falcon_flight'],
        'crown' => ['ar' => 'تاج الباشا', 'en' => 'Pasha Crown', 'icon' => '👑', 'cost' => 1500, 'animation' => 'crown_orbit'],
        'aurora' => ['ar' => 'شفق ورقنا', 'en' => 'Warqnaa Aurora', 'icon' => '✨', 'cost' => 3500, 'animation' => 'aurora_stage'],
    ],
];
