<?php

return [
    /*
    |--------------------------------------------------------------------------
    | View Storage Paths
    |--------------------------------------------------------------------------
    */
    'paths' => [
        resource_path('views'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Compiled View Path
    |--------------------------------------------------------------------------
    |
    | Laravel's Blade compiler requires a real writable cache directory.
    | Keep this explicit so GitHub Actions, fresh ZIP extractions and XAMPP
    | all resolve the same valid path instead of receiving null/false.
    */
    'compiled' => env(
        'VIEW_COMPILED_PATH',
        storage_path('framework/views')
    ),
];
