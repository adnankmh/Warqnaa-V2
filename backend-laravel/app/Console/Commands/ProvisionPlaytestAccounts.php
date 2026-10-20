<?php

namespace App\Console\Commands;

use App\Models\{Profile,User,Wallet};
use Illuminate\Console\Command;
use Illuminate\Support\Facades\{DB,Hash};

class ProvisionPlaytestAccounts extends Command
{
    protected $signature='warqna:playtest-accounts';
    protected $description='Create ten unprivileged staging playtest accounts with privately stored random passwords.';

    public function handle(): int
    {
        if (!app()->environment(['local','testing','staging'])) {
            $this->error('Playtest provisioning requires local, testing or staging.');
            return self::FAILURE;
        }
        $directory=storage_path('app/private/playtest');
        if (!is_dir($directory) && !mkdir($directory,0700,true)) return self::FAILURE;
        chmod($directory,0700);
        $path=$directory.'/accounts.json';
        // Exclusive creation prevents overwriting credentials from another run.
        $handle=@fopen($path,'x');
        if (!$handle) {
            $this->error('Private playtest credentials already exist; no accounts were changed.');
            return self::FAILURE;
        }
        chmod($path,0600);
        try {
            DB::transaction(function () use ($handle) {
                $accounts=[];
                for ($number=1;$number<=10;$number++) {
                    $name='QAPlayer'.str_pad((string)$number,2,'0',STR_PAD_LEFT);
                    if (User::where('username',$name)->exists()) throw new \RuntimeException('A playtest username already exists; no accounts were changed.');
                    $password=bin2hex(random_bytes(18));
                    $user=User::create(['username'=>$name,'email'=>strtolower($name).'@example.test',
                        'password'=>Hash::make($password),'is_admin'=>false,'admin_role'=>'player']);
                    Profile::create(['user_id'=>$user->id,'display_name'=>$name,'locale'=>'ar','level'=>1,'xp'=>0]);
                    Wallet::create(['user_id'=>$user->id,'tokens'=>10000,'gems'=>0]);
                    $accounts[]=['username'=>$name,'password'=>$password];
                }
                $json=json_encode($accounts,JSON_PRETTY_PRINT|JSON_THROW_ON_ERROR)."\n";
                if (fwrite($handle,$json)!==strlen($json) || !fflush($handle)) throw new \RuntimeException('Could not save private credentials.');
            });
        } catch (\Throwable $error) {
            fclose($handle);unlink($path);
            $this->error($error->getMessage());
            return self::FAILURE;
        }
        fclose($handle);
        $this->info('Created 10 player accounts. Credentials: storage/app/private/playtest/accounts.json');
        return self::SUCCESS;
    }
}
