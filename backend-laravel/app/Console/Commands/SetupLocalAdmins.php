<?php
namespace App\Console\Commands;

use App\Models\{CompetitionTicket,Profile,StoreItem,User,Wallet};
use App\Services\WarqnaPro\StoreCatalogService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\{Hash,Schema};

class SetupLocalAdmins extends Command
{
    protected $signature = 'warqnaa:local-admin-setup {--force : Apply even when APP_ENV is not local/testing}';
    protected $description = 'Provision private primary/deputy administrator accounts exclusively from untracked environment variables.';

    private const TOKEN_RESERVE = 9000000000000000000;
    private const GEM_RESERVE = 100000000;
    private const LEVEL = 99;
    private const PASHA_DAYS = 36500;

    public function handle(): int
    {
        if (!$this->option('force') && !app()->environment(['local','testing'])) {
            $this->error('Refusing to provision private administrator credentials outside local/testing. Use --force only in a controlled environment.');
            return self::FAILURE;
        }

        $primaryPassword=(string)env('WARQNAA_LOCAL_ADMIN_PASSWORD','');
        $deputyPassword=(string)env('WARQNAA_LOCAL_DEPUTY_PASSWORD','');
        if (strlen($primaryPassword)<8 || strlen($deputyPassword)<8) {
            $this->error('Set both private administrator passwords (8+ chars) in an untracked .env file.');
            return self::FAILURE;
        }

        $primaryUsername=trim((string)env('WARQNAA_LOCAL_ADMIN_USERNAME','PrimaryAdmin'));
        $primaryEmail=trim((string)env('WARQNAA_LOCAL_ADMIN_EMAIL','admin@warqnaa.local'));
        $deputyUsername=trim((string)env('WARQNAA_LOCAL_DEPUTY_USERNAME','DeputyAdmin'));
        $deputyEmail=trim((string)env('WARQNAA_LOCAL_DEPUTY_EMAIL','deputy@warqnaa.local'));
        $deputyRole=trim((string)env('WARQNAA_LOCAL_DEPUTY_ROLE','delegated_admin'));

        if ($primaryUsername==='' || $primaryEmail==='' || $deputyUsername==='' || $deputyEmail==='') {
            $this->error('Administrator usernames/emails must not be empty.');
            return self::FAILURE;
        }
        if (strcasecmp($primaryUsername,$deputyUsername)===0 || strcasecmp($primaryEmail,$deputyEmail)===0) {
            $this->error('Primary and deputy administrator identities must be different.');
            return self::FAILURE;
        }
        if (!in_array($deputyRole,['primary_admin','delegated_admin'],true)) {
            $this->error('WARQNAA_LOCAL_DEPUTY_ROLE must be primary_admin or delegated_admin.');
            return self::FAILURE;
        }

        $primary=$this->upsertAdmin(
            $primaryUsername,$primaryEmail,$primaryPassword,'primary_admin',
            self::LEVEL,self::PASHA_DAYS,self::TOKEN_RESERVE,self::GEM_RESERVE
        );
        $deputy=$this->upsertAdmin(
            $deputyUsername,$deputyEmail,$deputyPassword,$deputyRole,
            self::LEVEL,self::PASHA_DAYS,self::TOKEN_RESERVE,self::GEM_RESERVE
        );

        try {
            $catalog=app(StoreCatalogService::class);
            $catalog->sync();
            $this->grantCurrentCollectibles($catalog,$primary);
            $this->grantCurrentCollectibles($catalog,$deputy);
        } catch (\Throwable $e) {
            $this->warn('Store catalog/inventory sync was deferred: '.$e->getMessage());
        }

        if (Schema::hasTable('competition_tickets')) {
            foreach ([$primary,$deputy] as $admin) {
                foreach ([50,100,200,500,1000,2000,4000,5000,8000,10000,20000,30000,50000,100000] as $denomination) {
                    CompetitionTicket::updateOrCreate(
                        ['user_id'=>$admin->id,'denomination'=>$denomination],
                        ['quantity'=>999999,'total_used'=>0]
                    );
                }
            }
        }

        $this->info(
            'Private administrator accounts provisioned. '.
            'Primary ID: '.$primary->id.'; deputy ID: '.$deputy->id.'. '.
            'No plaintext identity or password is stored in tracked source.'
        );
        return self::SUCCESS;
    }

    private function upsertAdmin(
        string $username,string $email,string $password,string $role,
        int $level,int $pasha,int $tokens,int $gems
    ): User {
        $byEmail=User::query()->whereRaw('LOWER(email) = ?',[strtolower($email)])->first();
        $byUsername=User::query()->whereRaw('LOWER(username) = ?',[strtolower($username)])->first();

        if ($byEmail && $byUsername && (int)$byEmail->id !== (int)$byUsername->id) {
            throw new \RuntimeException('Requested username and email belong to different existing users.');
        }

        $user=$byEmail ?: $byUsername ?: new User(['username'=>$username]);
        $user->forceFill([
            'username'=>$username,
            'email'=>$email,
            'password'=>Hash::make($password),
            'is_admin'=>true,
            'is_banned'=>false,
            'admin_role'=>$role,
            'admin_permissions'=>[
                'all'=>true,'users'=>true,'store'=>true,'rooms'=>true,'clubs'=>true,
                'tournaments'=>true,'economy'=>true,'security'=>true,'social_world'=>true,
                'designer'=>true,'moderation'=>true,'analytics'=>true,'settings'=>true,
                'releases'=>true,'support'=>true
            ],
        ])->save();

        Profile::updateOrCreate(['user_id'=>$user->id],[
            'display_name'=>$username,
            'avatar'=>$role==='primary_admin'?'🦁':'🛡️',
            'country_code'=>'PS',
            'country_name'=>'Palestine',
            'level'=>$level,
            'xp'=>193947651,
            'games_played'=>20000,
            'wins'=>15000,
            'name_color'=>'#facc15',
            'chat_color'=>'#facc15',
            'pasha_days'=>$pasha,
            'badge'=>$role==='primary_admin'?'king':'admin'
        ]);

        Wallet::updateOrCreate(
            ['user_id'=>$user->id],
            ['tokens'=>$tokens,'gems'=>$gems]
        );

        return $user->fresh();
    }

    private function grantCurrentCollectibles(StoreCatalogService $catalog, User $admin): void
    {
        if (!Schema::hasTable('store_items') || !Schema::hasTable('inventory_items')) return;

        StoreItem::query()
            ->where('active',true)
            ->whereNotIn('category',['pasha','competition_ticket'])
            ->orderBy('id')
            ->chunkById(100,function($items) use($catalog,$admin){
                foreach($items as $item) {
                    $catalog->grantPrimaryAdminItem((int)$item->id,$admin);
                }
            });
    }
}
