<?php
// Existing accounts are never reset by the installer.
require __DIR__.'/../../backend-laravel/vendor/autoload.php';
$app = require __DIR__.'/../../backend-laravel/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();
exit(\App\Models\User::where('is_admin', true)->where('admin_role', 'primary_admin')->exists() ? 0 : 2);
