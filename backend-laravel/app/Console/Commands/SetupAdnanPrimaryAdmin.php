<?php
namespace App\Console\Commands;

use App\Models\{CompetitionTicket,Profile,User,Wallet};
use App\Services\WarqnaPro\StoreCatalogService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\{Hash,Schema};

class SetupAdnanPrimaryAdmin extends Command
{
    protected $signature='warqnaa:setup-adnan-admin {--force} {--keep-password}';
    protected $description='Provision Adnan as the durable primary administrator.';

    public function handle(): int
    {
        if(!$this->option('force') && !app()->environment(['local','testing'])){
            $this->error('Use --force outside local/testing only when intentional.');
            return self::FAILURE;
        }

        $username='Adnan';
        $email='adnanasd63@gmail.com';
        $primary=User::where('admin_role','primary_admin')->first()
            ?: User::where('email',$email)->first()
            ?: User::whereRaw('LOWER(username)=?',[strtolower($username)])->first()
            ?: new User();

        $emailOwner=User::where('email',$email)->first();
        $nameOwner=User::whereRaw('LOWER(username)=?',[strtolower($username)])->first();
        foreach([$emailOwner,$nameOwner] as $owner){
            if($owner && $primary->exists && (int)$owner->id!==(int)$primary->id){
                $this->error('Adnan username/email already belongs to another account.');
                return self::FAILURE;
            }
        }

        $payload=[
            'username'=>$username,
            'email'=>$email,
            'is_admin'=>true,
            'is_banned'=>false,
            'admin_role'=>'primary_admin',
            'admin_permissions'=>[
                'all'=>true,'users'=>true,'store'=>true,'rooms'=>true,'clubs'=>true,
                'tournaments'=>true,'economy'=>true,'security'=>true,'social_world'=>true,
                'designer'=>true,'moderation'=>true,'analytics'=>true,'settings'=>true,
                'releases'=>true,'support'=>true
            ],
        ];

        if(!$this->option('keep-password')){
            $password=(string)env('WARQNAA_ADNAN_ADMIN_PASSWORD','');
            while(strlen($password)<8){
                $password=(string)$this->secret('Choose Adnan admin password (8+ characters)');
                if(strlen($password)<8) $this->warn('Password must be at least 8 characters.');
            }
            $payload['password']=Hash::make($password);
        } elseif(!$primary->exists){
            $this->error('--keep-password cannot be used before the account exists.');
            return self::FAILURE;
        }

        $primary->forceFill($payload)->save();

        Profile::updateOrCreate(['user_id'=>$primary->id],[
            'display_name'=>'Adnan','avatar'=>'🦁','country_code'=>'PS','country_name'=>'Palestine',
            'level'=>99,'xp'=>193947651,'games_played'=>20000,'wins'=>15000,
            'name_color'=>'#facc15','chat_color'=>'#facc15','pasha_days'=>36500,'badge'=>'king'
        ]);

        // 9e18 is within signed BIGINT. primary_admin is unlimited server-side,
        // so purchases do not decrease this stored reserve.
        Wallet::updateOrCreate(['user_id'=>$primary->id],[
            'tokens'=>9000000000000000000,
            'gems'=>100000000
        ]);

        try{
            $catalog=app(StoreCatalogService::class);
            $catalog->sync();
            $catalog->grantPrimaryAdminAllCollectibles();
        }catch(\Throwable $e){
            $this->warn('Store catalog sync deferred: '.$e->getMessage());
        }

        if(Schema::hasTable('competition_tickets')){
            foreach([50,100,200,500,1000,2000,4000,5000,8000,10000,20000,30000,50000,100000] as $d){
                CompetitionTicket::updateOrCreate(
                    ['user_id'=>$primary->id,'denomination'=>$d],
                    ['quantity'=>999999,'total_used'=>0]
                );
            }
        }

        $this->info('Adnan primary admin is ready.');
        $this->line('Username: Adnan');
        $this->line('Email: adnanasd63@gmail.com');
        $this->line('Level: 99');
        $this->line('Tokens: UNLIMITED server-side (9e18 safe DB reserve)');
        $this->line('Pasha: 36500 days');
        $this->line('All current active store collectibles granted to inventory.');
        return self::SUCCESS;
    }
}
