<?php
namespace App\Console\Commands;

use App\Models\{CompetitionTicket,InventoryItem,Profile,StoreItem,User,Wallet};
use App\Services\Admin\PrimaryAdminStateService;
use App\Services\WarqnaPro\StoreCatalogService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\{DB,Hash,Schema};

class SetupLocalAdmins extends Command
{
    protected $signature='warqnaa:local-admin-setup {--single : Provision only the primary account} {--force : Apply outside local/testing}';
    protected $description='Provision private primary administrators from untracked environment values.';

    public function handle(PrimaryAdminStateService $state): int
    {
        if(!$this->option('force') && !app()->environment(['local','testing'])){
            $this->error('Use --force only in a controlled environment.');
            return self::FAILURE;
        }

        $accounts=[
            [
                'username'=>trim((string)env('WARQNAA_LOCAL_ADMIN_USERNAME','PrimaryAdmin')),
                'email'=>trim((string)env('WARQNAA_LOCAL_ADMIN_EMAIL','admin@warqnaa.local')),
                'password'=>(string)env('WARQNAA_LOCAL_ADMIN_PASSWORD',''),
            ],
            [
                'username'=>trim((string)env('WARQNAA_LOCAL_DEPUTY_USERNAME','DeputyAdmin')),
                'email'=>trim((string)env('WARQNAA_LOCAL_DEPUTY_EMAIL','deputy@warqnaa.local')),
                'password'=>(string)env('WARQNAA_LOCAL_DEPUTY_PASSWORD',''),
            ],
        ];
        if($this->option('single')) $accounts=array_slice($accounts,0,1);

        foreach($accounts as $a){
            if($a['username']==='' || $a['email']==='' || strlen($a['password'])<8){
                $this->error('Private admin username/email/password values are incomplete.');
                return self::FAILURE;
            }
        }
        if(count($accounts)>1 && (strcasecmp($accounts[0]['username'],$accounts[1]['username'])===0 || strcasecmp($accounts[0]['email'],$accounts[1]['email'])===0)){
            $this->error('Primary and deputy identities must be different.');
            return self::FAILURE;
        }

        $admins=[];
        DB::transaction(function() use($accounts,&$admins,$state){
            foreach($accounts as $a){
                $admins[]=$this->upsert($a['username'],$a['email'],$a['password'],$state);
            }
        });

        try{
            $catalog=app(StoreCatalogService::class);
            $catalog->sync();
            foreach($admins as $admin){
                StoreItem::query()->where('active',true)
                    ->whereNotIn('category',['pasha','competition_ticket'])
                    ->chunkById(100,function($items) use($catalog,$admin){
                        foreach($items as $item) $catalog->grantPrimaryAdminItem((int)$item->id,$admin);
                    });
            }
        }catch(\Throwable $e){
            $this->warn('Catalog sync deferred: '.$e->getMessage());
        }

        if(Schema::hasTable('competition_tickets')){
            foreach($admins as $admin){
                foreach([50,100,200,500,1000,2000,4000,5000,8000,10000,20000,30000,50000,100000] as $d){
                    CompetitionTicket::updateOrCreate(
                        ['user_id'=>$admin->id,'denomination'=>$d],
                        ['quantity'=>999999,'total_used'=>0]
                    );
                }
            }
        }

        foreach($admins as $admin){
            $admin=$state->enforce($admin);
            $inventory=Schema::hasTable('inventory_items') ? InventoryItem::where('user_id',$admin->id)->count() : 0;
            $tickets=Schema::hasTable('competition_tickets') ? CompetitionTicket::where('user_id',$admin->id)->sum('quantity') : 0;
            $this->line(sprintf(
                'ADMIN_OK username=%s id=%d role=%s level=%d xp=%d pasha=%d tokens=%s gems=%s inventory=%d tickets=%d',
                $admin->username,$admin->id,$admin->admin_role,(int)$admin->profile?->level,(int)$admin->profile?->xp,
                (int)$admin->profile?->pasha_days,(string)$admin->wallet?->tokens,(string)$admin->wallet?->gems,$inventory,$tickets
            ));
            if((int)$admin->profile?->level !== 99 || ($admin->admin_role ?? null)!=='primary_admin'){
                $this->error('Administrator verification failed.');
                return self::FAILURE;
            }
        }

        $this->info(count($accounts)>1 ? 'DUAL_PRIMARY_ADMIN_SETUP_OK' : 'PRIMARY_ADMIN_SETUP_OK');
        return self::SUCCESS;
    }

    private function upsert(string $username,string $email,string $password,PrimaryAdminStateService $state): User
    {
        $byUsername=User::query()->whereRaw('LOWER(username)=?',[strtolower($username)])->first();
        $byEmail=User::query()->whereRaw('LOWER(email)=?',[strtolower($email)])->first();
        $user=$byUsername ?: $byEmail ?: new User(['username'=>$username]);

        // A previous broken setup may have split the desired username and email
        // across two rows. Preserve both rows but free the conflicting identity
        // so the intended username account becomes the administrator account.
        if($byEmail && $byUsername && (int)$byEmail->id!==(int)$byUsername->id){
            $byEmail->forceFill(['email'=>'archived-'.$byEmail->id.'-'.time().'@warqna.local'])->save();
            $user=$byUsername;
        }
        $nameOwner=User::query()->whereRaw('LOWER(username)=?',[strtolower($username)])->where('id','!=',$user->id ?? 0)->first();
        if($nameOwner){
            $nameOwner->forceFill(['username'=>'archived_user_'.$nameOwner->id.'_'.time()])->save();
        }
        $mailOwner=User::query()->whereRaw('LOWER(email)=?',[strtolower($email)])->where('id','!=',$user->id ?? 0)->first();
        if($mailOwner){
            $mailOwner->forceFill(['email'=>'archived-'.$mailOwner->id.'-'.time().'@warqna.local'])->save();
        }

        $user->forceFill([
            'username'=>$username,
            'email'=>$email,
            'password'=>Hash::make($password),
            'is_admin'=>true,
            'is_banned'=>false,
            'admin_role'=>'primary_admin',
            'admin_permissions'=>[
                'all'=>true,'users'=>true,'store'=>true,'rooms'=>true,'clubs'=>true,
                'tournaments'=>true,'economy'=>true,'security'=>true,'social_world'=>true,
                'competitive'=>true,'site_settings'=>true,'site_design'=>true,'game_rules'=>true,
                'designer'=>true,'moderation'=>true,'analytics'=>true,'settings'=>true,
                'releases'=>true,'support'=>true
            ],
        ])->save();

        Profile::updateOrCreate(['user_id'=>$user->id],[
            'display_name'=>$username,'avatar'=>'🦁','country_code'=>'PS','country_name'=>'Palestine',
            'level'=>PrimaryAdminStateService::LEVEL,'xp'=>PrimaryAdminStateService::XP_FLOOR,
            'games_played'=>20000,'wins'=>15000,'name_color'=>'#facc15','chat_color'=>'#facc15',
            'pasha_days'=>PrimaryAdminStateService::PASHA_DAYS,'pasha_style'=>'red','badge'=>'king'
        ]);
        Wallet::updateOrCreate(['user_id'=>$user->id],[
            'tokens'=>PrimaryAdminStateService::TOKEN_RESERVE,'gems'=>PrimaryAdminStateService::GEMS
        ]);
        return $state->enforce($user);
    }
}
