<?php
namespace App\Console\Commands;

use App\Models\{Game,Tournament,User};
use Illuminate\Console\Command;

class EnsureSystemCompetition extends Command
{
    protected $signature='warqna:ensure-system-competition';
    protected $description='Keep at least one Warqnaa system competition open for registration.';

    public function handle(): int
    {
        if(Tournament::whereIn('status',['open'])->where('key','like','system-auto-%')->exists()){
            $this->info('System competition already open.'); return self::SUCCESS;
        }
        $admin=User::where('is_admin',true)->where('admin_role','primary_admin')->first() ?: User::whereRaw('LOWER(username) = ?', ['adnan'])->where('is_admin',true)->first() ?: User::where('is_admin',true)->orderBy('id')->first();
        $game=Game::where('active',true)->where('key','tarneeb')->first() ?: Game::where('active',true)->first();
        if(!$admin || !$game){ $this->warn('Admin or active game not available yet.'); return self::SUCCESS; }
        $key='system-auto-'.now()->format('Ymd-His');
        Tournament::create([
            'key'=>$key,'creator_id'=>$admin->id,'game_id'=>$game->id,'stages'=>1,'seats_per_match'=>4,
            'entry_fee'=>50,'prize_pool'=>300,'status'=>'open','house_cut_percent'=>0,
            'name'=>['ar'=>'منافسة النظام السريعة','en'=>'System Quick Cup'],
            'description'=>['ar'=>'رسوم الدخول 50 توكنز والجائزة 300 توكنز. تبدأ تلقائيًا عند اكتمال المقاعد.','en'=>'50-token entry, 300-token prize; starts when seats fill.'],
            'max_players'=>4,'rounds'=>1,'starts_at'=>now(),'auto_accept'=>true,'random_seating'=>true,
            'chat_enabled'=>true,'turn_seconds'=>7,'entry_mode'=>'ticket_or_tokens','featured'=>true,
            'settings'=>['system_generated'=>true,'anti_cheat'=>true,'late_join_until_full'=>true,'exit_limit_per_tournament'=>5],
            'bracket'=>['round'=>1,'matches'=>[],'messages'=>['أنشأ النظام منافسة دورية جديدة.'],'exit_counts'=>[]],
        ]);
        $this->info('Created '.$key); return self::SUCCESS;
    }
}
