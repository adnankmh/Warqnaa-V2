<?php

namespace App\Services\Competitive;

use App\Models\{CompetitiveMatch, CompetitiveSeason, Friendship, Game, Notification, RankedQueueEntry, Room, RoomPlayer, SiteSetting, User};
use App\Services\GameEngine\GameFactory;
use App\Services\Games\GameCatalog;
use App\Services\Notifications\FirebasePushService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class CompetitiveMatchmakingService
{
    private const SEAT_LAYOUTS = [
        2=>['south','north'],3=>['south','west','east'],4=>['south','west','north','east'],
        6=>['south','south_west','west','north','east','south_east'],
    ];

    public function __construct(private readonly CompetitiveSeasonService $seasons) {}

    /** @return array<string,mixed> */
    public function join(User $user, string $gameKey, int $preferredSeats, string $region = 'global'): array
    {
        abort_unless((bool)SiteSetting::getValue('competitive_enabled', true), 503, 'الساحة التنافسية متوقفة مؤقتاً.');
        abort_unless((bool)SiteSetting::getValue('ranked_matchmaking_enabled', true), 503, 'البحث المصنف متوقف مؤقتاً.');
        abort_if((bool)$user->is_banned, 403, 'الحساب موقوف ولا يمكنه دخول Ranked.');
        $season = $this->seasons->activeSeason();
        $game = Game::where('active',true)->where('key',$gameKey)->firstOrFail();
        abort_unless(GameCatalog::isCustomerVisible($game->key), 422, 'هذه اللعبة غير متاحة في Ranked.');
        $allowed = $this->allowedSeatCounts($game);
        abort_unless(in_array($preferredSeats,$allowed,true), 422, 'عدد اللاعبين غير مدعوم لهذه اللعبة.');
        $region = $this->normalizeRegion($region);

        $entry = DB::transaction(function () use ($user,$season,$game,$preferredSeats,$region) {
            $lockedUser = User::lockForUpdate()->findOrFail($user->id);
            $activeRoom = RoomPlayer::where('user_id',$lockedUser->id)->where('connected',true)
                ->whereHas('room',fn ($q)=>$q->whereIn('status',['waiting','bidding','playing']))->exists();
            if ($activeRoom) throw new RuntimeException('أنت داخل مباراة أخرى بالفعل.');
            $existing = RankedQueueEntry::with(['game','room'])->where('user_id',$lockedUser->id)
                ->whereIn('status',['waiting','matching','matched'])->latest()->lockForUpdate()->first();
            if($existing && in_array($existing->status,['waiting','matching'],true) && ($existing->expires_at?->lte(now()) || $existing->last_heartbeat_at?->lt(now()->subMinutes(3)))){
                $existing->update(['status'=>'expired']);$existing=null;
            }
            if ($existing) return $existing;
            $rating = $this->seasons->ratingFor($lockedUser,$season,$game->id,$game->key);
            return RankedQueueEntry::create([
                'queue_token'=>(string)Str::uuid(),'season_id'=>$season->id,'user_id'=>$lockedUser->id,'game_id'=>$game->id,
                'queue_mode'=>'ranked','preferred_seats'=>$preferredSeats,'region'=>$region,
                'country_code'=>strtoupper((string)($lockedUser->profile?->country_code ?: 'PS')),
                'rating_snapshot'=>$rating->rating,'search_window'=>(int)config('warqna_competitive.search_window_initial',100),
                'status'=>'waiting','joined_at'=>now(),'last_heartbeat_at'=>now(),
                'expires_at'=>now()->addMinutes(max(2,(int)SiteSetting::getValue('ranked_queue_timeout_minutes',config('warqna_competitive.queue_timeout_minutes',15)))),
                'meta'=>['client_release'=>request()->header('X-Warqna-Version'),'server_authoritative'=>true],
            ]);
        });

        if ($entry->status === 'waiting') $this->matchGame($season,$game,(int)$entry->preferred_seats);
        $entry->refresh()->load(['game','room']);
        return ['ok'=>true,'queue'=>$this->payload($entry)];
    }

    /** @return array<string,mixed> */
    public function status(User $user, ?string $token = null): array
    {
        $query = RankedQueueEntry::with(['game','room'])->where('user_id',$user->id);
        if ($token) $query->where('queue_token',$token);
        $entry = $query->latest()->first();
        if (!$entry) return ['ok'=>true,'queue'=>null];
        if ($entry->status === 'waiting') {
            if($entry->expires_at?->lte(now())){$entry->update(['status'=>'expired']);return ['ok'=>true,'queue'=>$this->payload($entry->fresh(['game','room']))];}
            $entry->update(['last_heartbeat_at'=>now()]);
            $this->matchGame($entry->season,$entry->game,(int)$entry->preferred_seats);
            $entry->refresh()->load(['game','room']);
        }
        return ['ok'=>true,'queue'=>$this->payload($entry)];
    }

    /** @return array<string,mixed> */
    public function cancel(User $user, ?string $token = null): array
    {
        return DB::transaction(function () use ($user,$token) {
            $query = RankedQueueEntry::where('user_id',$user->id)->whereIn('status',['waiting','matching']);
            if ($token) $query->where('queue_token',$token);
            $entry = $query->latest()->lockForUpdate()->first();
            if (!$entry) {
                $matched = RankedQueueEntry::where('user_id',$user->id)->where('status','matched')->latest()->first();
                if ($matched) throw new RuntimeException('تم تكوين المباراة ولا يمكن إلغاء الطابور الآن.');
                return ['ok'=>true,'cancelled'=>false];
            }
            $entry->update(['status'=>'cancelled','meta'=>array_merge((array)$entry->meta,['cancelled_at'=>now()->toIso8601String()])]);
            return ['ok'=>true,'cancelled'=>true,'queue'=>$this->payload($entry->fresh(['game','room']))];
        });
    }

    /** @return array<string,int> */
    public function tick(): array
    {
        $expired = RankedQueueEntry::whereIn('status',['waiting','matching'])->where(function ($q) {
            $q->where('expires_at','<=',now())->orWhere('last_heartbeat_at','<',now()->subMinutes(3));
        })->update(['status'=>'expired']);
        $matched = 0;
        $groups = RankedQueueEntry::query()->where('status','waiting')->where('expires_at','>',now())
            ->select(['season_id','game_id','preferred_seats'])->distinct()->get();
        foreach ($groups as $group) {
            $season = CompetitiveSeason::find($group->season_id);
            $game = Game::find($group->game_id);
            if ($season && $game) $matched += $this->matchGame($season,$game,(int)$group->preferred_seats);
        }
        return ['expired'=>$expired,'matches_created'=>$matched];
    }

    public function matchGame(CompetitiveSeason $season, Game $game, int $seats): int
    {
        $created = 0;
        while (true) {
            $match = DB::transaction(function () use ($season,$game,$seats) {
                $candidates = RankedQueueEntry::query()->with('user.profile')
                    ->where('season_id',$season->id)->where('game_id',$game->id)->where('preferred_seats',$seats)
                    ->where('status','waiting')->where('expires_at','>',now())->orderBy('joined_at')->limit(max(24,$seats*4))->lockForUpdate()->get();
                if ($candidates->count() < $seats) return null;
                foreach ($candidates as $candidate) {
                    $waitSeconds = max(0,$candidate->joined_at?->diffInSeconds(now()) ?? 0);
                    $window = min((int)config('warqna_competitive.search_window_max',500),
                        (int)config('warqna_competitive.search_window_initial',100) + ((int)floor($waitSeconds/30)*50));
                    if ((int)$candidate->search_window !== $window) $candidate->update(['search_window'=>$window]);
                }
                $selected=null;
                foreach($candidates as $anchor){
                    $group=collect([$anchor]);
                    foreach($candidates as $candidate){
                        if($group->count()>=$seats) break;
                        if($candidate->id===$anchor->id) continue;
                        if(!$this->compatibleAgainstAll($candidate,$group) || $this->blockedAgainstAny($candidate,$group->pluck('user_id')->map(fn ($id)=>(int)$id)->all())) continue;
                        $group->push($candidate);
                    }
                    if($group->count()>=$seats){$selected=$group;break;}
                }
                if (!$selected || $selected->count() < $seats) return null;
                $selected->each(fn ($entry) => $entry->update(['status'=>'matching']));
                return $this->createMatch($season,$game,$selected->values());
            });
            if (!$match) break;
            $created++;
        }
        return $created;
    }

    private function createMatch(CompetitiveSeason $season, Game $game, $entries): CompetitiveMatch
    {
        $participantIds = $entries->pluck('user_id')->map(fn ($id)=>(int)$id)->values()->all();
        $keys = array_map(fn ($id)=>'user:'.$id,$participantIds);
        $teamMap = [];
        foreach ($participantIds as $index=>$id) $teamMap[(string)$id] = $game->partnership ? ($index % 2 === 0 ? 'teamA' : 'teamB') : 'player:'.$id;
        $engine = GameFactory::make($game->key);
        $target = $this->defaultTarget($game->key);
        $state = $engine->initialState($keys,['target'=>$target,'turn_seconds'=>10,'partners'=>(bool)$game->partnership,'single_round'=>false,'deal_nonce'=>bin2hex(random_bytes(8))]);
        $state = array_merge($state,[
            'game'=>$game->key,'ranked'=>true,'competitive'=>true,'competitive_release'=>config('warqna_competitive.release'),
            'season_id'=>$season->id,'season_key'=>$season->key,'queue_mode'=>'ranked','team_map'=>$teamMap,
            'server_authoritative'=>true,'anti_cheat_review'=>true,'allow_owner_kick'=>false,'allow_spectators'=>false,
            'voice_enabled'=>false,'voice_room'=>false,'free_play'=>true,'entry_fee'=>0,'turn_seconds'=>10,'_revision'=>1,
        ]);
        $state['messages'] = array_values(array_merge((array)($state['messages'] ?? []),[
            '🏆 مباراة Ranked رسمية ضمن '.$this->localized($season->name).'.',
            '🛡️ النتيجة وMMR يعتمدان حصراً من محرك الخادم بعد فحص النزاهة.',
        ]));
        $room = Room::create([
            'code'=>$this->uniqueRoomCode(),'game_id'=>$game->id,'owner_id'=>$participantIds[0] ?? null,
            'visibility'=>'friends','password'=>null,'entry_fee'=>0,'min_level'=>1,
            'status'=>in_array((string)($state['phase'] ?? 'playing'),['waiting','bidding'],true) ? (string)$state['phase'] : 'playing',
            'max_players'=>count($participantIds),'target_score'=>(string)$target,'state'=>$state,'started_at'=>now(),
        ]);
        foreach ($participantIds as $index=>$id) {
            RoomPlayer::create(['room_id'=>$room->id,'user_id'=>$id,'seat'=>self::SEAT_LAYOUTS[count($participantIds)][$index] ?? (string)$index,'is_bot'=>false,'connected'=>false,'missed_turns'=>0]);
        }
        $ratingSnapshot = $entries->mapWithKeys(fn ($entry)=>[(string)$entry->user_id=>(int)$entry->rating_snapshot])->all();
        $match = CompetitiveMatch::create([
            'match_key'=>(string)Str::uuid(),'season_id'=>$season->id,'room_id'=>$room->id,'game_id'=>$game->id,
            'mode'=>'ranked','status'=>'active','region'=>$entries->pluck('region')->unique()->count() === 1 ? (string)$entries->first()->region : 'cross-region',
            'team_size'=>$game->partnership ? max(1,intdiv(count($participantIds),2)) : 1,
            'participant_ids'=>$participantIds,'team_map'=>$teamMap,'rating_snapshot'=>$ratingSnapshot,
            'anti_cheat_status'=>'pending','started_at'=>now(),'meta'=>['queue_tokens'=>$entries->pluck('queue_token')->values()->all(),'matchmaker'=>'r12_v1'],
        ]);
        $state['competitive_match_id']=$match->id;
        $state['competitive_match_key']=$match->match_key;
        $room->update(['state'=>$state]);
        $entries->each(fn ($entry) => $entry->update(['status'=>'matched','room_id'=>$room->id,'matched_at'=>now()]));
        foreach ($participantIds as $userId) {
            Notification::create([
                'user_id'=>$userId,'type'=>'ranked_match_found','title'=>['ar'=>'وجدنا منافستك','en'=>'Ranked match found'],
                'body'=>['ar'=>'مباراة Ranked جاهزة في الغرفة '.$room->code.'.','en'=>'Your Ranked match is ready in room '.$room->code.'.'],
                'url'=>url('/room/'.$room->code),'meta'=>['room_code'=>$room->code,'match_key'=>$match->match_key,'season_key'=>$season->key],
            ]);
            try { app(FirebasePushService::class)->sendToUser(User::find($userId),'Warqnaa • Ranked','تم العثور على مباراة مصنفة.',['type'=>'ranked_match_found','room_code'=>$room->code]); } catch (\Throwable) {}
        }
        return $match;
    }

    private function compatible(RankedQueueEntry $a, RankedQueueEntry $b): bool
    {
        $waitA = $a->joined_at?->diffInSeconds(now()) ?? 0;
        $waitB = $b->joined_at?->diffInSeconds(now()) ?? 0;
        if ($a->region !== $b->region && min($waitA,$waitB) < 120) return false;
        $delta = abs((int)$a->rating_snapshot-(int)$b->rating_snapshot);
        return $delta <= min((int)$a->search_window,(int)$b->search_window);
    }

    private function compatibleAgainstAll(RankedQueueEntry $candidate, $selected): bool
    {
        foreach ($selected as $member) if (!$this->compatible($member,$candidate)) return false;
        return true;
    }

    /** @param array<int,int> $selectedIds */
    private function blockedAgainstAny(RankedQueueEntry $candidate, array $selectedIds): bool
    {
        if ($selectedIds === []) return false;
        return Friendship::where('status','blocked')->where(function ($q) use ($candidate,$selectedIds) {
            $q->where(fn ($x)=>$x->where('requester_id',$candidate->user_id)->whereIn('addressee_id',$selectedIds))
              ->orWhere(fn ($x)=>$x->whereIn('requester_id',$selectedIds)->where('addressee_id',$candidate->user_id));
        })->exists();
    }

    /** @return array<int,int> */
    private function allowedSeatCounts(Game $game): array
    {
        return match($game->key) {
            'pinochle','banakil'=>[2,4], 'hand','saudi_hand'=>[2,3,4], 'hand_partner'=>[4],
            default=>[(int)$game->max_players],
        };
    }

    private function defaultTarget(string $game): int
    {
        return match($game) {'tarneeb_400'=>400,'tarneeb_41','syrian_tarneeb'=>41,'hand','hand_partner','saudi_hand'=>151,'pinochle','banakil'=>222,'domino'=>100,'backgammon','chess','jackaroo'=>1,default=>31};
    }

    private function normalizeRegion(string $region): string
    {
        $region = strtolower(trim($region));
        return in_array($region,['global','mena','gcc','levant','europe','americas','asia'],true) ? $region : 'global';
    }

    private function uniqueRoomCode(): string
    {
        do {$code=(string)random_int(100000,999999);} while (Room::where('code',$code)->exists());
        return $code;
    }

    private function localized(mixed $value): string
    {
        if (is_array($value)) return (string)($value[app()->getLocale()] ?? $value['ar'] ?? $value['en'] ?? reset($value));
        return (string)$value;
    }

    /** @return array<string,mixed> */
    public function payload(RankedQueueEntry $entry): array
    {
        return ['token'=>$entry->queue_token,'status'=>$entry->status,'game'=>$entry->game?->key,'game_name'=>$entry->game?->name,
            'preferred_seats'=>(int)$entry->preferred_seats,'region'=>$entry->region,'rating'=>(int)$entry->rating_snapshot,
            'search_window'=>(int)$entry->search_window,'room_code'=>$entry->room?->code,'room_status'=>$entry->room?->status,
            'joined_at'=>$entry->joined_at?->toIso8601String(),'matched_at'=>$entry->matched_at?->toIso8601String(),
            'expires_at'=>$entry->expires_at?->toIso8601String()];
    }
}
