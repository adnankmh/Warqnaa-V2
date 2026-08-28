<?php
namespace App\Console\Commands;

use App\Models\{Profile,User,Wallet};
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SetupLocalAdmins extends Command
{
    protected $signature = 'warqnaa:local-admin-setup {--force : Apply even when APP_ENV is not local/testing}';
    protected $description = 'Provision local Warqnaa primary/deputy admin credentials from private environment variables.';

    public function handle(): int
    {
        if (!$this->option('force') && !app()->environment(['local','testing'])) {
            $this->error('Refusing to provision local credentials outside local/testing. Use --force only in a controlled private environment.');
            return self::FAILURE;
        }
        $primaryPassword=(string)env('WARQNAA_LOCAL_ADMIN_PASSWORD','');
        $deputyPassword=(string)env('WARQNAA_LOCAL_DEPUTY_PASSWORD','');
        if (strlen($primaryPassword)<8 || strlen($deputyPassword)<8) {
            $this->error('Set WARQNAA_LOCAL_ADMIN_PASSWORD and WARQNAA_LOCAL_DEPUTY_PASSWORD (8+ chars) in a private, untracked environment file.');
            return self::FAILURE;
        }
        $primary=$this->upsertAdmin(
            (string)env('WARQNAA_LOCAL_ADMIN_USERNAME','PrimaryAdmin'),
            (string)env('WARQNAA_LOCAL_ADMIN_EMAIL','admin@warqnaa.local'),
            $primaryPassword,'primary_admin',99,36500,9000000000000000000,100000000
        );
        $this->upsertAdmin(
            (string)env('WARQNAA_LOCAL_DEPUTY_USERNAME','Abd'),
            (string)env('WARQNAA_LOCAL_DEPUTY_EMAIL','abd@warqna.local'),
            $deputyPassword,'delegated_admin',90,365,10000000000000000,100000
        );
        // Re-sync after role provisioning so the durable primary administrator receives every
        // current collectible even when the username was changed previously.
        try { app(\App\Services\WarqnaPro\StoreCatalogService::class)->sync(); } catch (\Throwable $e) {
            $this->warn('Store catalog sync was deferred: '.$e->getMessage());
        }
        if (\Illuminate\Support\Facades\Schema::hasTable('competition_tickets')) {
            foreach ([50,100,200,500,1000,2000,4000,5000,8000,10000,20000,30000,50000,100000] as $denomination) {
                \App\Models\CompetitionTicket::updateOrCreate(
                    ['user_id'=>$primary->id,'denomination'=>$denomination],
                    ['quantity'=>999999,'total_used'=>0]
                );
            }
        }
        $this->info('Local admins provisioned. Primary user id: '.$primary->id.'. No plaintext password was written to the repository.');
        return self::SUCCESS;
    }

    private function upsertAdmin(string $username,string $email,string $password,string $role,int $level,int $pasha,int $tokens,int $gems): User
    {
        $user=User::query()->where('admin_role',$role)->first() ?: User::query()->where('username',$username)->first();
        $user ??= new User(['username'=>$username]);
        $user->forceFill([
            'username'=>$username,'email'=>$email,'password'=>Hash::make($password),'is_admin'=>true,'is_banned'=>false,
            'admin_role'=>$role,'admin_permissions'=>['all'=>true,'users'=>true,'store'=>true,'rooms'=>true,'clubs'=>true,'tournaments'=>true,'economy'=>true,'security'=>true,'social_world'=>true,'designer'=>true,'moderation'=>true,'analytics'=>true,'settings'=>true,'releases'=>true,'support'=>true],
        ])->save();
        Profile::updateOrCreate(['user_id'=>$user->id],[
            'display_name'=>$username,'avatar'=>$role==='primary_admin'?'🦁':'🛡️','country_code'=>'PS','country_name'=>'Palestine','level'=>$level,
            'xp'=>$level===99?193947651:7800000,'games_played'=>$level===99?20000:12000,'wins'=>$level===99?15000:8000,
            'name_color'=>$role==='primary_admin'?'#facc15':'#38bdf8','chat_color'=>$role==='primary_admin'?'#facc15':'#38bdf8','pasha_days'=>$pasha,'badge'=>$role==='primary_admin'?'king':'admin'
        ]);
        Wallet::updateOrCreate(['user_id'=>$user->id],['tokens'=>$tokens,'gems'=>$gems]);
        return $user->fresh();
    }
}
