<?php
namespace App\Console\Commands;

use App\Models\{CompetitionTicket,Profile,StoreItem,User,Wallet};
use App\Services\WarqnaPro\StoreCatalogService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\{Hash,Schema};

class SetupLocalAdmins extends Command
{
    protected $signature='warqnaa:local-admin-setup {--force : Apply outside local/testing}';
    protected $description='Provision two private administrator accounts from untracked environment values.';

    private const TOKEN_RESERVE=9000000000000000000;
    private const LEVEL=99;
    private const XP_LEVEL_99=193947651;
    private const PASHA_DAYS=36500;
    private const GEMS=100000000;

    public function handle(): int
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

        foreach($accounts as $a){
            if($a['username']==='' || $a['email']==='' || strlen($a['password'])<8){
                $this->error('Private admin username/email/password values are incomplete.');
                return self::FAILURE;
            }
        }

        $admins=[];
        foreach($accounts as $a){
            $admins[]=$this->upsert($a['username'],$a['email'],$a['password']);
        }

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
            $admin->refresh()->load(['profile','wallet']);
            $this->line($admin->username.' level='.(int)$admin->profile?->level.' xp='.(int)$admin->profile?->xp.' role='.$admin->admin_role);
        }

        return self::SUCCESS;
    }

    private function upsert(string $username,string $email,string $password): User
    {
        $byEmail=User::query()->whereRaw('LOWER(email)=?',[strtolower($email)])->first();
        $byUsername=User::query()->whereRaw('LOWER(username)=?',[strtolower($username)])->first();

        if($byEmail && $byUsername && (int)$byEmail->id!==(int)$byUsername->id){
            throw new \RuntimeException('Username and email belong to different users.');
        }

        $user=$byEmail ?: $byUsername ?: new User(['username'=>$username]);
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
                'designer'=>true,'moderation'=>true,'analytics'=>true,'settings'=>true,
                'releases'=>true,'support'=>true
            ],
        ])->save();

        Profile::updateOrCreate(['user_id'=>$user->id],[
            'display_name'=>$username,
            'avatar'=>'🦁',
            'country_code'=>'PS',
            'country_name'=>'Palestine',
            'level'=>self::LEVEL,
            'xp'=>self::XP_LEVEL_99,
            'games_played'=>20000,
            'wins'=>15000,
            'name_color'=>'#facc15',
            'chat_color'=>'#facc15',
            'pasha_days'=>self::PASHA_DAYS,
            'badge'=>'king',
        ]);

        Wallet::updateOrCreate(['user_id'=>$user->id],[
            'tokens'=>self::TOKEN_RESERVE,
            'gems'=>self::GEMS,
        ]);

        return $user->fresh();
    }
}
