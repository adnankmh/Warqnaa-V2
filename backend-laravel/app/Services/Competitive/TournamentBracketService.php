<?php

namespace App\Services\Competitive;

use App\Models\{ClubMember, CompetitiveMatch, CompetitiveRating, Game, Notification, Room, RoomPlayer, Tournament, TournamentEntry, User};
use App\Services\GameEngine\GameFactory;
use App\Services\Notifications\FirebasePushService;
use App\Services\WarqnaPro\TournamentSettlementService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class TournamentBracketService
{
    private const SEAT_LAYOUTS = [
        2=>['south','north'],3=>['south','west','east'],4=>['south','west','north','east'],
        6=>['south','south_west','west','north','east','south_east'],
    ];

    /** @return array<string,mixed> */
    public function build(Tournament $tournament, bool $force = false): array
    {
        return DB::transaction(function () use ($tournament,$force) {
            $locked = Tournament::with(['entries.user.profile','entries.user.clubMembership','game'])->lockForUpdate()->findOrFail($tournament->id);
            $current = (array)($locked->bracket ?: []);
            if (($current['schema'] ?? null) === 'r12_competitive_bracket_v1' && !empty($current['rounds'])) {
                if($force) throw new RuntimeException('جدول R12 غير قابل للاستبدال بعد إصدار غرفه؛ يمكن متابعته أو إلغاء البطولة مع سجل إداري.');
                return ['ok'=>true,'duplicate'=>true,'tournament'=>$locked,'rooms'=>$this->roomsFromBracket($current)];
            }
            if (!in_array($locked->status,['open','running'],true)) throw new RuntimeException('لا يمكن بناء جدول لهذه البطولة في حالتها الحالية.');
            $seats = max(2,(int)$locked->seats_per_match);
            $stages = max(1,(int)($locked->stages ?: $locked->rounds ?: 1));
            $game = $locked->game ?: Game::findOrFail($locked->game_id);
            $required = $this->requiredPlayers($game,$seats,$stages);
            $seasonId=(int)($locked->season_id ?: app(CompetitiveSeasonService::class)->activeSeason(false)?->id);
            if($seasonId<=0) throw new RuntimeException('يلزم موسم تنافسي نشط قبل بناء الجدول.');
            if(!$locked->season_id){$locked->season_id=$seasonId;$locked->save();}
            $entries = $this->seedEntries($locked,$locked->entries->whereIn('status',['registered','checked_in'])->values());
            if ($entries->count() < $required) throw new RuntimeException('يلزم '.$required.' لاعباً لبناء جدول من '.$stages.' مراحل. المسجلون حالياً: '.$entries->count().'.');
            $entries = $entries->take($required)->values();
            $seeded = $this->snakeSeed($entries->pluck('user_id')->map(fn ($id)=>(int)$id)->all(),$seats);
            $bracket = [
                'schema'=>'r12_competitive_bracket_v1','version'=>max(2,(int)$locked->bracket_version+1),
                'format'=>$locked->format ?: 'single_elimination','scope'=>$locked->scope ?: 'global',
                'stages'=>$stages,'seats_per_match'=>$seats,'current_round'=>1,'status'=>'running',
                'seeded_user_ids'=>$seeded,'qualification'=>$this->qualificationSnapshot($locked,$entries),
                'rounds'=>[],'messages'=>array_values(array_merge((array)($current['messages'] ?? []),[
                    'R12: تم قفل التسجيل وبناء جدول حتمي موثّق من الخادم.',
                ])),'settlement'=>null,'settlement_ready'=>false,
            ];
            [$round,$rooms] = $this->createRound($locked,1,$seeded);
            $bracket['rounds'][]=$round;
            $locked->update(['status'=>'running','bracket'=>$bracket,'bracket_version'=>$bracket['version'],'current_round'=>1,'season_id'=>$seasonId]);
            return ['ok'=>true,'duplicate'=>false,'tournament'=>$locked->fresh(),'rooms'=>$rooms,'bracket'=>$bracket];
        });
    }

    /** @param array<string,mixed> $result */
    public function advanceFromMatch(CompetitiveMatch $match, array $result): array
    {
        if (!$match->tournament_id) return ['ok'=>false,'reason'=>'not_tournament'];
        if(!empty($result['draw'])) return $this->rematchDrawn($match,$result);
        $outcome = DB::transaction(function () use ($match,$result) {
            $lockedMatch = CompetitiveMatch::lockForUpdate()->findOrFail($match->id);
            $tournament = Tournament::with('game')->lockForUpdate()->findOrFail($lockedMatch->tournament_id);
            $bracket = (array)($tournament->bracket ?: []);
            if (($bracket['schema'] ?? null) !== 'r12_competitive_bracket_v1') return ['ok'=>false,'reason'=>'legacy_bracket'];
            $roundIndex = null;
            $matchIndex = null;
            foreach ((array)($bracket['rounds'] ?? []) as $ri=>$round) {
                foreach ((array)($round['matches'] ?? []) as $mi=>$node) {
                    if ((int)($node['competitive_match_id'] ?? 0) === (int)$lockedMatch->id || (int)($node['room_id'] ?? 0) === (int)$lockedMatch->room_id) {
                        $roundIndex=$ri; $matchIndex=$mi; break 2;
                    }
                }
            }
            if ($roundIndex === null || $matchIndex === null) return ['ok'=>false,'reason'=>'match_not_in_bracket'];
            $node = (array)$bracket['rounds'][$roundIndex]['matches'][$matchIndex];
            if (($node['status'] ?? '') === 'completed') return [
                'ok'=>true,'duplicate'=>true,'final'=>(bool)($bracket['settlement_ready'] ?? false),
                'tournament_id'=>$tournament->id,'room_id'=>$lockedMatch->room_id,
                'winners'=>(array)($bracket['champion_user_ids'] ?? $node['winner_user_ids'] ?? []),
            ];
            $participants = array_values(array_unique(array_map('intval',(array)($node['player_ids'] ?? $lockedMatch->participant_ids ?? []))));
            $advanceCount = max(1,min(count($participants),(int)($node['advance_count'] ?? 1)));
            $winners = array_values(array_unique(array_filter(array_map('intval',(array)($result['winner_user_ids'] ?? [])),fn ($id)=>in_array($id,$participants,true))));
            $ranking = array_values(array_unique(array_filter(array_map('intval',(array)($result['ranking'] ?? [])),fn ($id)=>in_array($id,$participants,true))));
            foreach ($ranking as $id) if (count($winners)<$advanceCount && !in_array($id,$winners,true)) $winners[]=$id;
            foreach ($participants as $id) if (count($winners)<$advanceCount && !in_array($id,$winners,true)) $winners[]=$id;
            $winners=array_slice($winners,0,$advanceCount);
            if ($winners === []) throw new RuntimeException('لا يمكن ترقية مباراة بلا فائز معتمد.');
            $node['status']='completed';
            $node['completed_at']=now()->toIso8601String();
            $node['winner_user_ids']=$winners;
            $node['result']=$result;
            $bracket['rounds'][$roundIndex]['matches'][$matchIndex]=$node;
            $lockedMatch->update(['status'=>'completed','result'=>$result,'finished_at'=>$lockedMatch->finished_at ?: now()]);
            TournamentEntry::where('tournament_id',$tournament->id)->whereIn('user_id',array_values(array_diff($participants,$winners)))->update(['status'=>'eliminated']);
            $allDone = collect($bracket['rounds'][$roundIndex]['matches'])->every(fn ($item)=>($item['status'] ?? '') === 'completed');
            if (!$allDone) {
                $tournament->update(['bracket'=>$bracket]);
                return ['ok'=>true,'duplicate'=>false,'final'=>false,'waiting_for_round'=>true,'winners'=>$winners];
            }
            $roundNumber = (int)($bracket['rounds'][$roundIndex]['number'] ?? ($roundIndex+1));
            $bracket['rounds'][$roundIndex]['status']='completed';
            $bracket['rounds'][$roundIndex]['completed_at']=now()->toIso8601String();
            $qualified = collect($bracket['rounds'][$roundIndex]['matches'])->flatMap(fn ($item)=>(array)($item['winner_user_ids'] ?? []))->map(fn ($id)=>(int)$id)->values()->all();
            $stages = max(1,(int)($bracket['stages'] ?? $tournament->stages));
            if ($roundNumber >= $stages) {
                $champions = array_values(array_unique($qualified));
                $clubIds = ClubMember::whereIn('user_id',$champions)->pluck('club_id')->unique()->values();
                $championClubId = $clubIds->count() === 1 ? (int)$clubIds->first() : null;
                TournamentEntry::where('tournament_id',$tournament->id)->whereIn('user_id',$champions)->update(['status'=>'winner']);
                $bracket['status']='completed';
                $bracket['champion_user_ids']=$champions;
                $bracket['champion_club_id']=$championClubId;
                $bracket['settlement_ready']=true;
                $bracket['messages'][]='اكتمل النهائي واعتمد الخادم أبطال البطولة: '.implode('، ',User::whereIn('id',$champions)->pluck('username')->all()).'.';
                $tournament->update(['bracket'=>$bracket,'current_round'=>$roundNumber,'champion_user_id'=>$champions[0] ?? null,'champion_club_id'=>$championClubId]);
                return ['ok'=>true,'duplicate'=>false,'final'=>true,'winners'=>$champions,'room_id'=>$lockedMatch->room_id,'tournament_id'=>$tournament->id];
            }
            [$nextRound,$rooms] = $this->createRound($tournament,$roundNumber+1,$qualified);
            $bracket['rounds'][]=$nextRound;
            $bracket['current_round']=$roundNumber+1;
            $bracket['messages'][]='اكتملت المرحلة '.$roundNumber.' وبدأت المرحلة '.($roundNumber+1).'.';
            $tournament->update(['bracket'=>$bracket,'current_round'=>$roundNumber+1]);
            return ['ok'=>true,'duplicate'=>false,'final'=>false,'advanced'=>true,'round'=>$roundNumber+1,'rooms'=>array_map(fn ($room)=>$room->code,$rooms),'winners'=>$qualified];
        });
        if (!empty($outcome['final'])) {
            $settlement = app(TournamentSettlementService::class)->settle((int)$outcome['tournament_id'],(array)$outcome['winners'],(int)$outcome['room_id']);
            $outcome['settlement']=$settlement;
        }
        return $outcome;
    }

    /** @param array<int,int> $winnerUserIds */
    public function advanceFromRoom(int $roomId, array $winnerUserIds): array
    {
        $match = CompetitiveMatch::where('room_id',$roomId)->whereNotNull('tournament_id')->first();
        if (!$match) return ['ok'=>false,'reason'=>'competitive_match_missing'];
        return $this->advanceFromMatch($match,['winner_user_ids'=>$winnerUserIds,'ranking'=>$winnerUserIds,'source'=>'legacy_settlement_bridge']);
    }

    /** @return array<string,mixed> */
    public function rematchVoided(CompetitiveMatch $match, string $reason): array
    {
        return $this->replaceUnadvancedMatch($match,$reason,'void');
    }

    /** @param array<string,mixed> $result @return array<string,mixed> */
    public function rematchDrawn(CompetitiveMatch $match, array $result): array
    {
        return $this->replaceUnadvancedMatch($match,'server_verified_draw','draw',$result);
    }

    /** @param array<string,mixed> $result @return array<string,mixed> */
    private function replaceUnadvancedMatch(CompetitiveMatch $match,string $reason,string $kind,array $result=[]): array
    {
        return DB::transaction(function() use($match,$reason,$kind,$result){
            $source=CompetitiveMatch::lockForUpdate()->findOrFail($match->id);
            if(!$source->tournament_id) return ['ok'=>false,'reason'=>'not_tournament'];
            $validSource=$kind==='void'
                ? $source->status==='voided' && !$source->rating_processed
                : $source->rating_processed && !empty(((array)$source->result)['draw']);
            if(!$validSource) throw new RuntimeException('لا يمكن إعادة هذه المباراة في حالتها الحالية.');
            $tournament=Tournament::with('game')->lockForUpdate()->findOrFail($source->tournament_id);
            $bracket=(array)($tournament->bracket ?: []);
            if(($bracket['schema'] ?? null)!=='r12_competitive_bracket_v1') return ['ok'=>false,'reason'=>'legacy_bracket'];
            $roundIndex=null;$matchIndex=null;
            foreach((array)($bracket['rounds'] ?? []) as $ri=>$round){
                foreach((array)($round['matches'] ?? []) as $mi=>$node){
                    if((int)($node['competitive_match_id'] ?? 0)===(int)$source->id){$roundIndex=$ri;$matchIndex=$mi;break 2;}
                }
            }
            if($roundIndex===null || $matchIndex===null){
                $historyKey=$kind.'_history';
                foreach((array)($bracket['rounds'] ?? []) as $round){
                    foreach((array)($round['matches'] ?? []) as $node){
                        $already=collect($node[$historyKey] ?? [])->contains(fn($item)=>(int)($item['competitive_match_id'] ?? 0)===(int)$source->id);
                        if($already) return ['ok'=>true,'duplicate'=>true,'room_code'=>$node['room_code'] ?? null,'competitive_match_id'=>$node['competitive_match_id'] ?? null,'replaced_match_id'=>$source->id];
                    }
                }
                return ['ok'=>false,'reason'=>'match_not_in_bracket'];
            }
            $node=(array)$bracket['rounds'][$roundIndex]['matches'][$matchIndex];
            if(($node['status'] ?? '')==='completed') throw new RuntimeException('لا يمكن إعادة مباراة اعتُمد تأهلها.');
            $oldRoom=$source->room()->lockForUpdate()->first();
            if($oldRoom){
                $oldState=(array)($oldRoom->state ?: []);
                $oldState['messages'][]=$kind==='draw'?'انتهت المباراة بالتعادل وأصدر الخادم غرفة إعادة حاسمة.':'ألغت الإدارة نتيجة هذه الغرفة وأصدر الخادم غرفة إعادة موثقة.';
                $oldState['competitive_rematch_at']=now()->toIso8601String();
                $oldState['competitive_rematch_reason']=$reason;
                $oldRoom->update(['status'=>'closed','state'=>$oldState,'finished_at'=>$oldRoom->finished_at ?: now()]);
            }
            $participants=array_values(array_unique(array_filter(array_map('intval',(array)($node['player_ids'] ?? $source->participant_ids)),fn($id)=>$id>0)));
            [$room,$replacement,$teamMap]=$this->createMatchRoom($tournament,(int)($node['round'] ?? ($roundIndex+1)),(int)($node['number'] ?? ($matchIndex+1)),$participants);
            $historyKey=$kind.'_history';$history=(array)($node[$historyKey] ?? []);
            $history[]=['competitive_match_id'=>$source->id,'room_id'=>$source->room_id,'reason'=>$reason,'result'=>$result,'replaced_at'=>now()->toIso8601String()];
            $node['competitive_match_id']=$replacement->id;$node['room_id']=$room->id;$node['room_code']=$room->code;
            $node['team_map']=$teamMap;$node['status']='active';$node['winner_user_ids']=[];$node['result']=null;$node[$historyKey]=$history;
            $bracket['rounds'][$roundIndex]['matches'][$matchIndex]=$node;
            $bracket['messages'][]='أصدر الخادم إعادة رقم '.count($history).' للمباراة '.$node['id'].' بسبب '.($kind==='draw'?'تعادل معتمد':'قرار نزاهة موثق').'.';
            $tournament->update(['bracket'=>$bracket,'status'=>'running']);
            return ['ok'=>true,'duplicate'=>false,'rematch_reason'=>$kind,'room_code'=>$room->code,'competitive_match_id'=>$replacement->id,'replaced_match_id'=>$source->id];
        });
    }

    /** @param array<int,int> $participantIds @return array{0:array<string,mixed>,1:array<int,Room>} */
    private function createRound(Tournament $tournament, int $roundNumber, array $participantIds): array
    {
        $seats = max(2,(int)$tournament->seats_per_match);
        if (count($participantIds) < $seats || count($participantIds) % $seats !== 0) {
            throw new RuntimeException('عدد المتأهلين لا يكوّن غرفاً كاملة للمرحلة التالية.');
        }
        $game=$tournament->game ?: Game::findOrFail($tournament->game_id);
        $isFinal=$roundNumber>=max(1,(int)$tournament->stages);
        $advanceCount=$this->advanceCount($game,$seats,$isFinal);
        $round = ['number'=>$roundNumber,'label'=>$this->roundLabel($roundNumber,(int)$tournament->stages),'status'=>'active','created_at'=>now()->toIso8601String(),'matches'=>[]];
        $rooms=[];
        foreach (array_chunk($participantIds,$seats) as $index=>$players) {
            [$room,$match,$teamMap] = $this->createMatchRoom($tournament,$roundNumber,$index+1,$players);
            $round['matches'][]=[
                'id'=>'r'.$roundNumber.'-m'.($index+1),'round'=>$roundNumber,'number'=>$index+1,
                'room_id'=>$room->id,'room_code'=>$room->code,'competitive_match_id'=>$match->id,
                'player_ids'=>$players,'team_map'=>$teamMap,'advance_count'=>$advanceCount,
                'status'=>'active','winner_user_ids'=>[],'result'=>null,
            ];
            $rooms[]=$room;
        }
        return [$round,$rooms];
    }

    /** @param array<int,int> $participantIds @return array{0:Room,1:CompetitiveMatch,2:array<string,string>} */
    private function createMatchRoom(Tournament $tournament, int $round, int $number, array $participantIds): array
    {
        $game = $tournament->game ?: Game::findOrFail($tournament->game_id);
        $seasonId=(int)($tournament->season_id ?: app(CompetitiveSeasonService::class)->activeSeason(false)?->id);
        if($seasonId<=0) throw new RuntimeException('يلزم موسم تنافسي نشط لإنشاء غرفة البطولة.');
        $keys = array_map(fn ($id)=>'user:'.$id,$participantIds);
        $teamMap=[];
        foreach ($participantIds as $index=>$id) $teamMap[(string)$id]=$game->partnership ? ($index%2===0?'teamA':'teamB') : 'player:'.$id;
        $target=$this->defaultTarget($game->key);
        $state=GameFactory::make($game->key)->initialState($keys,['target'=>$target,'turn_seconds'=>(int)($tournament->turn_seconds ?: 10),'partners'=>(bool)$game->partnership,'single_round'=>false,'deal_nonce'=>bin2hex(random_bytes(8))]);
        $state=array_merge($state,[
            'game'=>$game->key,'tournament_id'=>$tournament->id,'tournament_key'=>$tournament->key,
            'tournament_stage'=>$this->roundLabel($round,(int)$tournament->stages),'tournament_round'=>$round,
            'tournament_match_number'=>$number,'competitive'=>true,'competitive_release'=>config('warqna_competitive.release'),
            'season_id'=>$seasonId,'team_map'=>$teamMap,'server_authoritative'=>true,'anti_cheat_review'=>true,
            'recording_enabled'=>true,'allow_spectators'=>true,'voice_enabled'=>false,'voice_room'=>false,
            'allow_owner_kick'=>false,'entry_fee'=>0,'turn_seconds'=>(int)($tournament->turn_seconds ?: 10),'_revision'=>1,
        ]);
        $state['messages']=array_values(array_merge((array)($state['messages'] ?? []),[
            '🏟️ مباراة رسمية في '.$this->localized($tournament->name).' — '.$state['tournament_stage'].'.',
            '🛡️ التأهل والجوائز يعتمدان من الخادم بعد إغلاق النتيجة وفحص النزاهة.',
        ]));
        $room=Room::create([
            'code'=>$this->uniqueRoomCode(),'game_id'=>$game->id,'owner_id'=>$participantIds[0] ?? $tournament->creator_id,
            'visibility'=>'friends','password'=>null,'entry_fee'=>0,'min_level'=>1,
            'status'=>in_array((string)($state['phase'] ?? 'playing'),['waiting','bidding'],true)?(string)$state['phase']:'playing',
            'max_players'=>count($participantIds),'target_score'=>(string)$target,'state'=>$state,'started_at'=>now(),
        ]);
        foreach ($participantIds as $index=>$userId) RoomPlayer::create(['room_id'=>$room->id,'user_id'=>$userId,'seat'=>self::SEAT_LAYOUTS[count($participantIds)][$index] ?? (string)$index,'is_bot'=>false,'connected'=>false,'missed_turns'=>0]);
        $ratings=[];
        foreach ($participantIds as $id) $ratings[(string)$id]=(int)(app(CompetitiveSeasonService::class)->ratingFor(User::findOrFail($id),\App\Models\CompetitiveSeason::findOrFail($seasonId),$game->id,$game->key)->rating);
        $match=CompetitiveMatch::create([
            'match_key'=>(string)Str::uuid(),'season_id'=>$seasonId,'tournament_id'=>$tournament->id,'room_id'=>$room->id,'game_id'=>$game->id,
            'mode'=>'tournament','status'=>'active','region'=>'global','team_size'=>$game->partnership?max(1,intdiv(count($participantIds),2)):1,
            'participant_ids'=>$participantIds,'team_map'=>$teamMap,'rating_snapshot'=>$ratings,'anti_cheat_status'=>'pending','started_at'=>now(),
            'meta'=>['round'=>$round,'match_number'=>$number,'format'=>$tournament->format,'scope'=>$tournament->scope],
        ]);
        $state['competitive_match_id']=$match->id; $state['competitive_match_key']=$match->match_key; $room->update(['state'=>$state]);
        foreach ($participantIds as $userId) {
            Notification::create(['user_id'=>$userId,'type'=>'tournament_round_ready','title'=>['ar'=>'مباراة البطولة جاهزة','en'=>'Tournament match ready'],
                'body'=>['ar'=>$state['tournament_stage'].' جاهزة في الغرفة '.$room->code.'.','en'=>$state['tournament_stage'].' is ready in room '.$room->code.'.'],
                'url'=>url('/room/'.$room->code),'meta'=>['tournament_id'=>$tournament->id,'round'=>$round,'room_code'=>$room->code]]);
            try {app(FirebasePushService::class)->sendToUser(User::find($userId),'Warqnaa • Tournament','غرفة البطولة '.$room->code.' جاهزة.',['type'=>'tournament_round_ready','room_code'=>$room->code]);} catch (\Throwable) {}
        }
        return [$room,$match,$teamMap];
    }

    /** @param array<int,int> $ids @return array<int,int> */
    private function snakeSeed(array $ids, int $seats): array
    {
        $matchCount=max(1,intdiv(count($ids),max(2,$seats)));
        $groups=array_fill(0,$matchCount,[]);
        foreach(array_values($ids) as $index=>$id){
            $band=intdiv($index,$matchCount); $slot=$index%$matchCount;
            $group=$band%2===0?$slot:($matchCount-1-$slot);
            $groups[$group][]=(int)$id;
        }
        return array_values(array_merge(...$groups));
    }

    private function seedEntries(Tournament $tournament, $entries)
    {
        $ratingByUser=[];
        if($tournament->season_id){
            $ratingByUser=CompetitiveRating::where('season_id',$tournament->season_id)->where('scope_key','overall')
                ->whereIn('user_id',$entries->pluck('user_id'))->pluck('rating','user_id')->map(fn($value)=>(int)$value)->all();
        }
        $leagueSeed=in_array((string)$tournament->format,['league_playoffs','group_playoffs','round_robin'],true);
        return $entries->sortBy(function($entry) use($ratingByUser,$leagueSeed){
            $explicit=(int)($entry->seed ?: PHP_INT_MAX);
            $rating=(int)($ratingByUser[$entry->user_id] ?? config('warqna_competitive.initial_rating',1000));
            return $leagueSeed
                ? sprintf('%012d:%012d',999999-$rating,(int)$entry->id)
                : sprintf('%012d:%012d:%012d',$explicit,999999-$rating,(int)$entry->id);
        })->values();
    }

    /** @return array<string,mixed> */
    private function qualificationSnapshot(Tournament $tournament, $entries): array
    {
        $ratings=[];
        if($tournament->season_id){
            $ratings=CompetitiveRating::where('season_id',$tournament->season_id)->where('scope_key','overall')
                ->whereIn('user_id',$entries->pluck('user_id'))->pluck('rating','user_id')->map(fn($value)=>(int)$value)->all();
        }
        return [
            'source'=>match($tournament->format){'league_playoffs'=>'season_league_ladder','group_playoffs'=>'group_qualification','round_robin'=>'round_robin_seed','single_elimination'=>'registration_seed',default=>'registration_seed'},
            'locked_at'=>now()->toIso8601String(),
            'entries'=>$entries->values()->map(fn($entry,$index)=>[
                'seed'=>$index+1,'user_id'=>(int)$entry->user_id,
                'rating'=>(int)($ratings[$entry->user_id] ?? config('warqna_competitive.initial_rating',1000)),
                'club_id'=>(int)($entry->user?->clubMembership?->club_id ?? 0),
                'country_code'=>strtoupper((string)($entry->user?->profile?->country_code ?? '')),
            ])->all(),
        ];
    }

    /** @return array<int,Room> */
    private function roomsFromBracket(array $bracket): array
    {
        $ids=collect($bracket['rounds'] ?? [])->flatMap(fn ($round)=>collect($round['matches'] ?? [])->pluck('room_id'))->filter()->map(fn ($id)=>(int)$id)->all();
        return Room::whereIn('id',$ids)->get()->all();
    }

    private function roundLabel(int $round, int $stages): string
    {
        $remaining=max(1,$stages-$round+1);
        return match($remaining){1=>'النهائي',2=>'نصف النهائي',3=>'ربع النهائي',4=>'ثمن النهائي',default=>'المرحلة '.$round};
    }

    private function defaultTarget(string $game): int
    {
        return match($game){'tarneeb_400'=>400,'tarneeb_41','syrian_tarneeb'=>41,'hand','hand_partner','saudi_hand'=>151,'pinochle','banakil'=>222,'domino'=>100,'backgammon','chess','jackaroo'=>1,default=>31};
    }

    private function advanceCount(Game $game, int $seats, bool $final): int
    {
        if($final) return $game->partnership ? max(1,intdiv($seats,2)) : 1;
        return max(1,intdiv($seats,2));
    }

    private function requiredPlayers(Game $game, int $seats, int $stages): int
    {
        $required=max(2,$seats);
        $advance=$this->advanceCount($game,$seats,false);
        for($round=1;$round<max(1,$stages);$round++){
            $numerator=$required*$seats;
            if($numerator%$advance!==0) throw new RuntimeException('إعداد المقاعد والمراحل لا يكوّن جدولاً كاملاً.');
            $required=intdiv($numerator,$advance);
        }
        return $required;
    }

    private function uniqueRoomCode(): string
    {
        do {$code=(string)random_int(100000,999999);} while(Room::where('code',$code)->exists()); return $code;
    }

    private function localized(mixed $value): string
    {
        if(is_array($value)) return (string)($value[app()->getLocale()]??$value['ar']??$value['en']??reset($value)); return (string)$value;
    }
}
