<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Services\Wallet\WalletService;

$options = getopt('', ['user::','all','tokens::','pasha-days::','reason::']);
$tokens = (int)($options['tokens'] ?? 0);
$pashaDays = (int)($options['pasha-days'] ?? 0);
$reason = (string)($options['reason'] ?? 'admin_bulk_grant_v202');

if ($tokens <= 0 && $pashaDays <= 0) {
    fwrite(STDERR, "Usage: php backend-laravel/tools/grant_tokens_pasha.php --user=username_or_email|--all --tokens=5000 --pasha-days=3 --reason=promo\n");
    exit(1);
}

$query = User::query();
if (empty($options['all'])) {
    $needle = trim((string)($options['user'] ?? ''));
    if ($needle === '') {
        fwrite(STDERR, "Provide --user or --all\n");
        exit(1);
    }
    $query->where(function($q) use ($needle){
        $q->where('username', $needle)->orWhere('email', $needle);
    });
}

$users = $query->with('profile')->get();
if ($users->isEmpty()) {
    fwrite(STDERR, "No users matched the target.\n");
    exit(1);
}

$wallet = app(WalletService::class);
foreach ($users as $user) {
    if ($tokens > 0) {
        $wallet->credit($user, $tokens, 'admin_manual_grant', ['reason' => $reason]);
    }
    if ($pashaDays > 0) {
        $profile = $user->profile()->firstOrCreate(
            ['user_id'=>$user->id],
            ['display_name'=>$user->username,'country_code'=>'PS','country_name'=>'Palestine']
        );
        $profile->pasha_days = (int)($profile->pasha_days ?? 0) + $pashaDays;
        $profile->save();
    }
    echo "Granted user={$user->username} tokens={$tokens} pasha_days={$pashaDays}\n";
}

echo "Done. users=".$users->count()."\n";
