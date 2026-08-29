<?php

namespace App\Services\WarqnaPro;

use App\Models\{ChallengeDefinition,ChallengeProgress,Game,InventoryItem,Notification,Room,RoomPlayer,StoreItem,User};
use App\Services\GameEngine\GameFactory;
use App\Services\Notifications\FirebasePushService;
use App\Services\Wallet\WalletService;
use Illuminate\Support\Facades\DB;
use RuntimeException;

/**
 * R9.1 stage-road challenge: one selected game, 10/12/15 stages and five lives.
 * Matchmaking is symmetric: it selects an eligible online opponent at random;
 * missing seats are filled by explicit BOT seats so partnership games remain legal.
 */
class ChallengeRoadService
{
    public const KEY = 'stage_road_r91';
    public const ATTEMPTS = 5;

    private array $seatOrder = ['south','south_east','east','north','west','south_west'];

    public function __construct(
        private readonly WalletService $wallet,
        private readonly FirebasePushService $push,
    ) {}

    public function state(User $user): array
    {
        $definition=$this->definition();
        $progress=ChallengeProgress::where('user_id',$user->id)
            ->where('challenge_definition_id',$definition->id)
            ->where('period_key','persistent')->first();
        return $this->payload($progress);
    }

    public function start(User $user, string $gameKey, int $totalStages): array
    {
        $game=Game::where('key',$gameKey)->where('active',true)->firstOrFail();
        if(!in_array($totalStages,[10,12,15],true)) $totalStages=12;
        $definition=$this->definition();
        $progress=ChallengeProgress::updateOrCreate([
            'user_id'=>$user->id,
            'challenge_definition_id'=>$definition->id,
            'period_key'=>'persistent',
        ],[
            'progress'=>0,
            'claimed_at'=>null,
            'payload'=>[
                'game_key'=>$game->key,
                'total_stages'=>$totalStages,
                'stage'=>0,
                'attempts'=>self::ATTEMPTS,
                'completed'=>false,
                'started_at'=>now()->toIso8601String(),
                'settled_room_ids'=>[],
                'active_room_code'=>null,
            ],
        ]);
        return $this->payload($progress->fresh());
    }

    public function matchmake(User $user): array
    {
        return DB::transaction(function() use($user){
            $definition=$this->definition();
            $progress=ChallengeProgress::where('user_id',$user->id)
                ->where('challenge_definition_id',$definition->id)
                ->where('period_key','persistent')->lockForUpdate()->first();
            if(!$progress) throw new RuntimeException('ابدأ مسار التحدي أولًا.');
            $payload=(array)($progress->payload ?? []);
            $stage=(int)($payload['stage'] ?? 0);
            $total=(int)($payload['total_stages'] ?? 12);
            $attempts=(int)($payload['attempts'] ?? 0);
            if(!empty($payload['completed']) || $stage >= $total) throw new RuntimeException('مسار التحدي مكتمل بالفعل.');
            if($attempts <= 0) throw new RuntimeException('انتهت المحاولات الخمس. ابدأ مسارًا جديدًا.');

            if(!empty($payload['active_room_code'])) {
                $existing=Room::where('code',$payload['active_room_code'])->whereIn('status',['waiting','bidding','playing'])->first();
                if($existing) return $this->matchPayload($user,$existing,$payload,null);
            }

            $game=Game::where('key',(string)($payload['game_key'] ?? ''))->where('active',true)->first();
            if(!$game) throw new RuntimeException('اللعبة المختارة غير متاحة حاليًا.');

            $busyIds=RoomPlayer::where('is_bot',false)->where('connected',true)
                ->whereHas('room',fn($q)=>$q->whereIn('status',['waiting','bidding','playing']))
                ->whereNotNull('user_id')->pluck('user_id');
            $opponent=User::with('profile')
                ->where('id','!=',$user->id)->where('is_admin',false)->where('is_banned',false)
                ->where('last_seen_at','>=',now()->subMinutes(5))
                ->whereNotIn('id',$busyIds)
                ->inRandomOrder()->first();

            $maxPlayers=$this->preferredPlayerCount($game->key,(int)$game->min_players,(int)$game->max_players);
            $room=Room::create([
                'code'=>$this->roomCode(),
                'game_id'=>$game->id,
                'owner_id'=>$user->id,
                'visibility'=>'public',
                'password'=>null,
                'entry_fee'=>0,
                'min_level'=>1,
                'status'=>'waiting',
                'max_players'=>$maxPlayers,
                'target_score'=>in_array($game->key,['tarneeb','tarneeb_41','tarneeb_61'],true)?'31':null,
                'state'=>[
                    'phase'=>'waiting',
                    'challenge_road'=>true,
                    'challenge_road_owner_id'=>$user->id,
                    'challenge_road_stage'=>$stage+1,
                    'challenge_road_total'=>$total,
                    'challenge_road_attempts'=>$attempts,
                    'single_round'=>true,
                    'speed'=>'medium',
                    'turn_timeout_seconds'=>7,
                    'messages'=>['🎯 مسار التحدي — المرحلة '.($stage+1).' من '.$total.'.'],
                ],
            ]);
            $room->players()->create(['user_id'=>$user->id,'seat'=>'south','is_bot'=>false,'connected'=>true,'missed_turns'=>0]);
            if($opponent){
                $room->players()->create(['user_id'=>$opponent->id,'seat'=>$this->opponentSeat($maxPlayers),'is_bot'=>false,'connected'=>false,'missed_turns'=>0]);
            }
            $this->fillBots($room);
            $this->startRoom($room);

            $payload['active_room_code']=$room->code;
            $payload['last_match_started_at']=now()->toIso8601String();
            $payload['last_opponent_user_id']=$opponent?->id;
            $progress->payload=$payload;
            $progress->save();

            if($opponent){
                Notification::create([
                    'user_id'=>$opponent->id,
                    'type'=>'challenge_road_match',
                    'title'=>['ar'=>'تم اختيارك لتحدٍ','en'=>'Challenge match selected'],
                    'body'=>['ar'=>$user->username.' ينتظرك في المرحلة '.($stage+1).' من مسار التحدي.','en'=>$user->username.' is waiting for you in challenge-road stage '.($stage+1).'.'],
                    'url'=>'/rooms/'.$room->code,
                    'meta'=>['room_code'=>$room->code,'challenge_road'=>true,'game'=>$game->key],
                ]);
                try{$this->push->sendToUser($opponent,'Warqnaa • Challenge','تم اختيارك لمواجهة عشوائية في '.$game->key.'.',['type'=>'challenge_road_match','room_code'=>$room->code]);}catch(\Throwable){}
            }

            return $this->matchPayload($user,$room,$payload,$opponent);
        });
    }

    public function recordRoomResult(User $user, Room $room, bool $won): array
    {
        return DB::transaction(function() use($user,$room,$won){
            $definition=$this->definition();
            $progress=ChallengeProgress::where('user_id',$user->id)
                ->where('challenge_definition_id',$definition->id)
                ->where('period_key','persistent')->lockForUpdate()->first();
            if(!$progress) return ['ignored'=>true];
            $payload=(array)($progress->payload ?? []);
            $settled=array_map('intval',(array)($payload['settled_room_ids'] ?? []));
            if(in_array((int)$room->id,$settled,true)) return $this->payload($progress)+['duplicate'=>true];
            $settled[]=(int)$room->id;
            $payload['settled_room_ids']=array_slice(array_values(array_unique($settled)),-50);
            $payload['active_room_code']=null;
            $payload['last_result']=$won?'win':'loss';
            $payload['last_result_at']=now()->toIso8601String();

            if($won){
                $payload['stage']=min((int)($payload['total_stages'] ?? 12),(int)($payload['stage'] ?? 0)+1);
                $reward=$this->rewardForStage((int)$payload['stage'],(int)($payload['total_stages'] ?? 12));
                $this->applyReward($user,$reward);
                $payload['last_reward']=$reward;
                if((int)$payload['stage'] >= (int)($payload['total_stages'] ?? 12)) $payload['completed']=true;
            } else {
                $payload['attempts']=max(0,(int)($payload['attempts'] ?? self::ATTEMPTS)-1);
            }
            $progress->progress=(int)($payload['stage'] ?? 0);
            $progress->payload=$payload;
            $progress->save();
            return $this->payload($progress->fresh());
        });
    }

    public function rewardForStage(int $stage,int $total): array
    {
        if($stage >= $total) return ['type'=>'bundle','tokens'=>1000,'pasha_days'=>3,'store_key'=>'b304_profile_legend_30d','days'=>7,'icon'=>'🏆','label_ar'=>'1000 توكن + 3 أيام باشا + لون بروفايل أسطوري 7 أيام','label_en'=>'1,000 tokens + 3 Pasha days + legendary profile color for 7 days'];
        return match($stage % 5){
            1 => ['type'=>'tokens','tokens'=>min(1800,200+$stage*80),'icon'=>'🪙','label_ar'=>min(1800,200+$stage*80).' توكن','label_en'=>min(1800,200+$stage*80).' tokens'],
            2 => ['type'=>'temporary_item','store_key'=>'b304_profile_aurora_30d','days'=>7,'icon'=>'🎨','label_ar'=>'لون بروفايل الشفق 7 أيام','label_en'=>'Aurora profile color for 7 days'],
            3 => ['type'=>'temporary_item','store_key'=>'booster_green_v183','days'=>7,'icon'=>'⚡','label_ar'=>'مسرع XP لمدة 7 أيام','label_en'=>'XP booster for 7 days'],
            4 => ['type'=>'temporary_item','store_key'=>'b304_profile_aurora_30d','days'=>7,'icon'=>'🌈','label_ar'=>'لون بروفايل الشفق 7 أيام','label_en'=>'Aurora profile color for 7 days'],
            default => ['type'=>'pasha','pasha_days'=>1,'icon'=>'👑','label_ar'=>'يوم باشا','label_en'=>'1 Pasha day'],
        };
    }

    private function applyReward(User $user,array $reward): void
    {
        $type=(string)($reward['type'] ?? '');
        if(in_array($type,['tokens','bundle'],true) && (int)($reward['tokens'] ?? 0)>0) $this->wallet->credit($user,(int)$reward['tokens'],'challenge_road_reward',['stage_road'=>true]);
        if(in_array($type,['pasha','bundle'],true) && (int)($reward['pasha_days'] ?? 0)>0) $user->profile?->increment('pasha_days',(int)$reward['pasha_days']);
        if(in_array($type,['temporary_item','bundle'],true) && !empty($reward['store_key'])){
            $item=StoreItem::where('key',$reward['store_key'])->where('active',true)->first();
            if($item) InventoryItem::create(['user_id'=>$user->id,'store_item_id'=>$item->id,'active'=>true,'activated_at'=>now(),'expires_at'=>now()->addDays((int)($reward['days'] ?? 7))]);
        }
    }

    private function definition(): ChallengeDefinition
    {
        return ChallengeDefinition::updateOrCreate(['key'=>self::KEY],[
            'name'=>['ar'=>'مسار المراحل','en'=>'Stage Road'],
            'description'=>['ar'=>'اختر لعبة واحدة وتقدم عبر 10 أو 12 أو 15 مرحلة بخمس محاولات.','en'=>'Pick one game and clear 10, 12 or 15 stages with five attempts.'],
            'cadence'=>'seasonal','metric'=>'challenge_road_win','target'=>15,'reward_tokens'=>0,'reward_xp'=>0,
            'settings'=>['icon'=>'🛤️','attempts'=>self::ATTEMPTS,'stage_options'=>[10,12,15]],'active'=>true,'sort_order'=>1,
        ]);
    }

    private function payload(?ChallengeProgress $progress): array
    {
        $payload=(array)($progress?->payload ?? []);
        $total=(int)($payload['total_stages'] ?? 12);
        $stage=(int)($payload['stage'] ?? 0);
        return [
            'active'=>(bool)$progress && empty($payload['completed']) && (int)($payload['attempts'] ?? 0)>0,
            'game_key'=>$payload['game_key'] ?? null,'total_stages'=>$total,'stage'=>$stage,
            'attempts'=>(int)($payload['attempts'] ?? self::ATTEMPTS),'completed'=>(bool)($payload['completed'] ?? false),
            'active_room_code'=>$payload['active_room_code'] ?? null,
            'next_reward'=>$stage<$total?$this->rewardForStage($stage+1,$total):null,
            'last_reward'=>$payload['last_reward'] ?? null,
        ];
    }

    private function matchPayload(User $user,Room $room,array $payload,?User $opponent): array
    {
        $opponent ??= $room->players()->where('is_bot',false)->where('user_id','!=',$user->id)->with('user.profile')->first()?->user;
        return [
            'road'=>$this->state($user),'room_code'=>$room->code,'game'=>$room->game?->key,
            'stage'=>(int)($payload['stage'] ?? 0)+1,
            'opponent'=>$opponent?->publicProfile() ?? ['bot'=>true,'display_name'=>'Warqnaa BOT','level'=>50],
        ];
    }

    private function startRoom(Room $room): void
    {
        $room->load('game','players');
        $players=$room->players->sortBy(fn($p)=>array_search($p->seat,$this->seatOrder,true))->map(fn($p)=>$p->is_bot?'bot:'.$p->id:'user:'.$p->user_id)->values()->all();
        $old=(array)$room->state;
        $engine=GameFactory::make($room->game->key);
        $state=$engine->initialState($players,[
            'target'=>$room->target_score ?: ($room->game->rules['targets'][0] ?? 31),
            'partners'=>(bool)$room->game->partnership,'deal_nonce'=>bin2hex(random_bytes(6)),'single_round'=>true,
        ]);
        foreach(['challenge_road','challenge_road_owner_id','challenge_road_stage','challenge_road_total','challenge_road_attempts'] as $key) $state[$key]=$old[$key] ?? null;
        $state['room_code']=$room->code;$state['game']=$room->game->key;$state['single_round']=true;$state['speed']='medium';$state['turn_timeout_seconds']=7;
        $state['messages']=array_values(array_merge((array)($state['messages'] ?? []),(array)($old['messages'] ?? []),['✅ تم اختيار المواجهة وبدء المرحلة تلقائيًا.']));
        $room->update(['status'=>($state['phase'] ?? '')==='bidding'?'bidding':'playing','started_at'=>now(),'state'=>$state]);
    }

    private function fillBots(Room $room): void
    {
        $names=['ليث BOT','جود BOT','آدم BOT','سيف BOT','رامي BOT','كنان BOT'];
        while($room->players()->count()<$room->max_players){
            $taken=$room->players()->pluck('seat')->all();
            $seat=collect(array_slice($this->seatOrder,0,$room->max_players))->first(fn($s)=>!in_array($s,$taken,true));
            if(!$seat) break;
            $idx=(int)$room->players()->count();
            $room->players()->create(['bot_key'=>$names[$idx%count($names)],'seat'=>$seat,'is_bot'=>true,'connected'=>true,'missed_turns'=>0]);
        }
    }

    private function preferredPlayerCount(string $gameKey,int $min,int $max): int
    {
        if(in_array($gameKey,['kout6'],true)) return 6;
        if(in_array($gameKey,['backgammon','chess'],true)) return 2;
        if(in_array($gameKey,['hand','hand_partner','saudi_hand','hand_saudi','rummy','konkan','domino','pinochle','banakil'],true)) return max(2,min(4,$max));
        return max(2,min(4,$max));
    }

    private function opponentSeat(int $count): string
    {
        return $count===2?'north':($count===4?'west':($this->seatOrder[min(2,$count-1)] ?? 'north'));
    }

    private function roomCode(): string
    {
        do{$code=(string)random_int(100000,999999);}while(Room::where('code',$code)->exists());
        return $code;
    }
}
