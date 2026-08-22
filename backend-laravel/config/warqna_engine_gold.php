<?php

return [
    'release' => '0.8.0+250',
    'contract' => 'r13_engine_gold_v1',
    'profiles' => [
        'smoke' => ['matches_per_engine' => 25, 'max_transitions' => 160],
        'release' => ['matches_per_engine' => 2000, 'max_transitions' => 320],
        'nightly' => ['matches_per_engine' => 5000, 'max_transitions' => 400],
    ],
    'invariants' => [
        'server_authoritative_actions',
        'advertised_action_validates',
        'legal_action_changes_state',
        'active_turn_belongs_to_player',
        'no_empty_or_null_hand_items',
        'json_serializable_state',
        'no_active_deadlock',
        'replayable_seed_for_seeded_engines',
    ],
    'engines' => [
        'tarneeb', 'tarneeb_41', 'tarneeb_61', 'syrian_tarneeb', 'tarneeb_400',
        'trix', 'trix_partner', 'trix_complex', 'hand', 'hand_partner',
        'saudi_hand', 'banakil', 'pinochle', 'solitaire_multiplayer', 'baloot',
        'basra', 'domino', 'backgammon', 'jackaroo', 'chess',
    ],
];
