<?php
// Disposable runtime fixtures, never a production account provisioning command.
require __DIR__.'/../vendor/autoload.php';
$app = require __DIR__.'/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$database = (string) config('database.connections.sqlite.database');
$workspace = realpath((string) getenv('WARQNA_R7_WORKSPACE'));
if (!$app->environment('testing') || config('database.default') !== 'sqlite'
    || !$workspace || realpath(dirname($database)) !== $workspace
    || basename($database) !== 'runtime.sqlite') {
    throw new RuntimeException('R7 fixtures require the isolated testing workspace.');
}

$accounts = [];
foreach (['player' => 37, 'peer' => 41, 'admin' => 99] as $kind => $level) {
    $password = bin2hex(random_bytes(24));
    $username = 'R7Review'.ucfirst($kind);
    $user = App\Models\User::create([
        'username' => $username, 'email' => strtolower($username).'@example.test',
        'password' => Illuminate\Support\Facades\Hash::make($password),
        'is_admin' => $kind === 'admin',
        'admin_role' => $kind === 'admin' ? 'primary_admin' : 'player',
    ]);
    App\Models\Profile::create([
        'user_id' => $user->id, 'display_name' => $username,
        'country_code' => 'PS', 'country_name' => 'Palestine',
        'locale' => 'ar', 'level' => $level, 'xp' => 250000,
    ]);
    App\Models\Wallet::create(['user_id' => $user->id, 'tokens' => 250000, 'gems' => 75]);
    $accounts[$kind] = ['login' => $username, 'password' => $password, 'id' => $user->id, 'level' => $level];
}
app(App\Services\WarqnaPro\StoreCatalogService::class)->sync();
$target = $workspace.'/accounts.json';
file_put_contents($target, json_encode($accounts, JSON_THROW_ON_ERROR));
chmod($target, 0600);
echo "Created isolated synthetic accounts.\n";
