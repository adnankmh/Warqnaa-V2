<?php

namespace App\Services\Competitive;

use App\Models\{AntiCheatEvent, CompetitiveMatch, CompetitiveRating, CompetitiveRatingEvent, Game, RankedQueueEntry, Room, User};
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class CompetitiveRatingService
{
    public function __construct(private readonly CompetitiveSeasonService $seasons) {}

    /** @return array<string,mixed> */
    public function processRoom(Room $room, bool $forceAfterReview = false): array
    {
        $room->loadMissing(['game','players.user']);
        $match = CompetitiveMatch::where('room_id',$room->id)->first();
        if (!$match) return ['ok'=>false,'reason'=>'not_competitive'];
        $state=(array)($room->state ?: []);
        if ($room->status !== 'finished' && ($state['phase'] ?? null) !== 'finished' && empty($state['gameOver'])) {
            return ['ok'=>false,'reason'=>'match_not_finished'];
        }
        $severe = AntiCheatEvent::where('room_id',$room->id)->where('severity','>=',4)->exists();
        if ($severe && !$forceAfterReview) {
            $match->update(['status'=>'review','anti_cheat_status'=>'review','finished_at'=>$match->finished_at ?: now(),'result'=>array_merge((array)$match->result,['held_for_review'=>true])]);
            return ['ok'=>false,'reason'=>'anti_cheat_review','review'=>true,'match_id'=>$match->id];
        }
        $resolved=$this->resolveResult($match,$room,$state);
        $processed=DB::transaction(function () use ($match,$room,$resolved,$severe,$forceAfterReview) {
            $locked=CompetitiveMatch::lockForUpdate()->findOrFail($match->id);
            if ($locked->rating_processed) return ['ok'=>true,'duplicate'=>true,'match'=>$locked,'result'=>$locked->result,'changes'=>[]];
            if (in_array($locked->status,['voided','cancelled'],true)) return ['ok'=>false,'reason'=>'match_voided'];
            $integrityHold=$severe || AntiCheatEvent::where('room_id',$room->id)->where('severity','>=',4)->exists();
            if($integrityHold && !$forceAfterReview){
                $locked->update(['status'=>'review','anti_cheat_status'=>'review','finished_at'=>$locked->finished_at ?: now(),'result'=>array_merge((array)$locked->result,['held_for_review'=>true])]);
                return ['ok'=>false,'reason'=>'anti_cheat_review','review'=>true,'match_id'=>$locked->id];
            }
            $participants=array_values(array_unique(array_filter(array_map('intval',(array)$locked->participant_ids),fn ($id)=>$id>0)));
            if (count($participants)<2) throw new RuntimeException('المباراة التنافسية لا تحتوي لاعبين كافيين.');
            $season=$locked->season()->firstOrFail();
            $game=$locked->game()->firstOrFail();
            $snapshots=(array)($locked->rating_snapshot ?: []);
            $teamMap=(array)($locked->team_map ?: []);
            $changes=[];
            foreach ($participants as $userId) {
                $user=User::find($userId); if(!$user) continue;
                $score=$this->scoreFor($userId,$resolved);
                $abandoned=in_array($userId,(array)($resolved['abandoned_user_ids'] ?? []),true);
                if($abandoned) $score=0.0;
                $opponentRating=$this->opponentAverage($userId,$participants,$teamMap,$snapshots);
                foreach ([['scope'=>'overall','game_id'=>null,'game_key'=>null],['scope'=>'game:'.$game->key,'game_id'=>$game->id,'game_key'=>$game->key]] as $scope) {
                    $rating=$this->seasons->ratingFor($user,$season,$scope['game_id'],$scope['game_key']);
                    $rating=CompetitiveRating::lockForUpdate()->findOrFail($rating->id);
                    $before=(int)$rating->rating;
                    $expected=1/(1+(10**(($opponentRating-$before)/400)));
                    $placementLimit=(int)($season->placement_games ?: config('warqna_competitive.placement_games',10));
                    $k=(int)$rating->provisional_games<$placementLimit?40:($locked->mode==='tournament'?24:32);
                    $delta=(int)round($k*($score-$expected));
                    if($abandoned) $delta-=max(0,(int)config('warqna_competitive.abandon_penalty',35));
                    $after=max((int)config('warqna_competitive.rating_floor',100),$before+$delta);
                    $actualDelta=$after-$before;
                    $resultKey=$abandoned?'abandon':($score>0.5?'win':($score<0.5?'loss':'draw'));
                    $nextStreak=$resultKey==='win'?max(1,(int)$rating->streak+1):($resultKey==='loss'||$resultKey==='abandon'?min(-1,(int)$rating->streak-1):0);
                    $provisional=min($placementLimit,(int)$rating->provisional_games+1);
                    $rating->update([
                        'rating'=>$after,'peak_rating'=>max((int)$rating->peak_rating,$after),'games_played'=>(int)$rating->games_played+1,
                        'wins'=>(int)$rating->wins+($resultKey==='win'?1:0),'losses'=>(int)$rating->losses+(in_array($resultKey,['loss','abandon'],true)?1:0),
                        'draws'=>(int)$rating->draws+($resultKey==='draw'?1:0),'streak'=>$nextStreak,
                        'best_streak'=>max((int)$rating->best_streak,max(0,$nextStreak)),'provisional_games'=>$provisional,
                        'placement_complete'=>$provisional>=$placementLimit,'abandons'=>(int)$rating->abandons+($abandoned?1:0),
                        'clean_games'=>(int)$rating->clean_games+($integrityHold?0:1),'last_match_at'=>now(),
                        'meta'=>array_merge((array)$rating->meta,['last_match_key'=>$locked->match_key,'last_tier'=>$this->seasons->tierFor($after)['key'] ?? 'bronze']),
                    ]);
                    CompetitiveRatingEvent::create([
                        'competitive_match_id'=>$locked->id,'competitive_rating_id'=>$rating->id,'user_id'=>$userId,'scope_key'=>$scope['scope'],
                        'rating_before'=>$before,'rating_after'=>$after,'rating_delta'=>$actualDelta,'result'=>$resultKey,
                        'expected_score'=>round($expected,5),'k_factor'=>$k,'reason'=>$abandoned?'ranked_abandon_penalty':($locked->mode.'_result'),
                        'meta'=>['opponent_rating'=>$opponentRating,'tier_before'=>$this->seasons->tierFor($before),'tier_after'=>$this->seasons->tierFor($after),'review_override'=>$forceAfterReview],
                    ]);
                    $changes[(string)$userId][$scope['scope']]=['before'=>$before,'after'=>$after,'delta'=>$actualDelta,'result'=>$resultKey,'tier'=>$this->seasons->tierFor($after)];
                }
            }
            $result=array_merge($resolved,['rating_changes'=>$changes,'processed_at'=>now()->toIso8601String()]);
            $locked->update(['status'=>'completed','result'=>$result,'rating_processed'=>true,'anti_cheat_status'=>$forceAfterReview?'approved':'clean','finished_at'=>$locked->finished_at ?: now(),'processed_at'=>now()]);
            RankedQueueEntry::where('room_id',$room->id)->where('status','matched')->update(['status'=>'completed']);
            return ['ok'=>true,'duplicate'=>false,'match'=>$locked->fresh(),'result'=>$result,'changes'=>$changes];
        });
        if (!empty($match->tournament_id) && !empty($processed['ok'])) {
            $processed['bracket']=app(TournamentBracketService::class)->advanceFromMatch($match->fresh(),(array)($processed['result'] ?? $resolved));
            if(!empty($processed['bracket']['ok'])){
                $freshMatch=$match->fresh();
                $freshMatch->update(['meta'=>array_merge((array)$freshMatch->meta,['bracket_advanced_at'=>now()->toIso8601String(),'bracket_duplicate'=>(bool)($processed['bracket']['duplicate'] ?? false)])]);
            }
        }
        return $processed;
    }

    /** @return array<string,mixed> */
    public function voidMatch(CompetitiveMatch $match, string $reason, ?int $adminId = null): array
    {
        return DB::transaction(function () use ($match,$reason,$adminId) {
            $locked=CompetitiveMatch::lockForUpdate()->findOrFail($match->id);
            if($locked->rating_processed) throw new RuntimeException('لا يمكن إلغاء مباراة بعد اعتماد تغييرات التصنيف؛ استخدم تسوية إدارية موثقة.');
            $locked->update(['status'=>'voided','anti_cheat_status'=>'voided','finished_at'=>$locked->finished_at ?: now(),'result'=>array_merge((array)$locked->result,['void_reason'=>$reason,'voided_by'=>$adminId,'voided_at'=>now()->toIso8601String()])]);
            RankedQueueEntry::where('room_id',$locked->room_id)->whereIn('status',['matched','matching'])->update(['status'=>'cancelled']);
            $rematch=$locked->tournament_id?app(TournamentBracketService::class)->rematchVoided($locked->fresh(),$reason):null;
            return ['ok'=>true,'match'=>$locked->fresh(),'rematch'=>$rematch];
        });
    }

    /** @return array<string,mixed> */
    public function adjust(User $user, Game $game, int $delta, string $reason, int $adminId): array
    {
        abort_if($delta===0 || abs($delta)>500,422,'التسوية يجب أن تكون بين -500 و500 وألا تكون صفراً.');
        $season=$this->seasons->activeSeason();
        return DB::transaction(function () use ($user,$game,$delta,$reason,$adminId,$season) {
            $match=CompetitiveMatch::create([
                'match_key'=>(string)Str::uuid(),'season_id'=>$season->id,'room_id'=>null,'game_id'=>$game->id,
                'mode'=>'admin_adjustment','status'=>'completed','region'=>'control-plane','team_size'=>1,
                'participant_ids'=>[$user->id],'team_map'=>[(string)$user->id=>'player:'.$user->id],
                'rating_snapshot'=>[],'result'=>['reason'=>$reason,'admin_id'=>$adminId,'delta'=>$delta],
                'rating_processed'=>true,'reward_processed'=>true,'anti_cheat_status'=>'approved','finished_at'=>now(),'processed_at'=>now(),
            ]);
            $changes=[];
            foreach ([['overall',null,null],['game:'.$game->key,$game->id,$game->key]] as [$scope,$gameId,$gameKey]) {
                $rating=$this->seasons->ratingFor($user,$season,$gameId,$gameKey);
                $rating=CompetitiveRating::lockForUpdate()->findOrFail($rating->id);
                $before=(int)$rating->rating; $after=max((int)config('warqna_competitive.rating_floor',100),$before+$delta); $actual=$after-$before;
                $rating->update(['rating'=>$after,'peak_rating'=>max((int)$rating->peak_rating,$after),'meta'=>array_merge((array)$rating->meta,['last_admin_adjustment'=>['admin_id'=>$adminId,'reason'=>$reason,'at'=>now()->toIso8601String()]])]);
                CompetitiveRatingEvent::create(['competitive_match_id'=>$match->id,'competitive_rating_id'=>$rating->id,'user_id'=>$user->id,'scope_key'=>$scope,
                    'rating_before'=>$before,'rating_after'=>$after,'rating_delta'=>$actual,'result'=>'adjustment','expected_score'=>0.5,'k_factor'=>0,
                    'reason'=>'admin_adjustment','meta'=>['admin_id'=>$adminId,'reason'=>$reason]]);
                $changes[$scope]=['before'=>$before,'after'=>$after,'delta'=>$actual,'tier'=>$this->seasons->tierFor($after)];
            }
            $match->update(['rating_snapshot'=>$changes]);
            return ['ok'=>true,'match'=>$match->fresh(),'changes'=>$changes];
        });
    }

    /** @return array<string,mixed> */
    public function resolveResult(CompetitiveMatch $match, Room $room, array $state): array
    {
        $participants=array_values(array_unique(array_filter(array_map('intval',(array)($match->participant_ids ?: $room->players->pluck('user_id')->all())),fn ($id)=>$id>0)));
        $teamMap=(array)($match->team_map ?: $state['team_map'] ?? []);
        $winnerRaw=$state['overall_winner'] ?? $state['overall_winner_team'] ?? $state['winner'] ?? $state['winner_team'] ?? null;
        $winnerKey=$this->normalizeWinnerKey($winnerRaw);
        $winners=[];
        if($winnerKey!==null) {
            foreach($participants as $id) {
                $playerKey='user:'.$id; $team=(string)($teamMap[(string)$id] ?? 'player:'.$id);
                if($winnerKey===$playerKey || $winnerKey===(string)$id || $winnerKey===$team || ($winnerKey==='teamA'&&$team==='0') || ($winnerKey==='teamB'&&$team==='1')) $winners[]=$id;
            }
        }
        $draw=isset($state['draw_reason']) || ($winnerRaw===null && (in_array((string)($state['phase'] ?? ''),['finished','game_over'],true) || !empty($state['gameOver']) || !empty($state['game_over'])));
        $ranking=$this->ranking($participants,$teamMap,$state,$winners);
        if($winners===[] && !$draw && $ranking!==[]) $winners=[$ranking[0]];
        $abandoned=array_values(array_unique(array_filter(array_map('intval',array_merge(
            (array)($state['abandoned_user_ids'] ?? []),(array)($state['competitive_abandons'] ?? []),
            array_keys(array_filter((array)($state['manual_exit_counts'] ?? $state['manual_leave_counts'] ?? []),fn ($count)=>(int)$count>0))
        )),fn ($id)=>in_array($id,$participants,true))));
        return [
            'winner_raw'=>$winnerRaw,'winner_key'=>$winnerKey,'winner_user_ids'=>array_values(array_unique($winners)),
            'ranking'=>$ranking,'draw'=>$draw && $winners===[],'abandoned_user_ids'=>$abandoned,
            'scores'=>$state['scores'] ?? $state['score'] ?? null,'room_revision'=>(int)($state['_revision'] ?? 0),
            'resolved_by'=>'r12_server_result_resolver','resolved_at'=>now()->toIso8601String(),
        ];
    }

    private function scoreFor(int $userId, array $result): float
    {
        if(!empty($result['draw'])) return 0.5;
        return in_array($userId,(array)($result['winner_user_ids'] ?? []),true)?1.0:0.0;
    }

    /** @param array<int,int> $participants @param array<string,mixed> $teamMap @param array<string,mixed> $snapshots */
    private function opponentAverage(int $userId,array $participants,array $teamMap,array $snapshots): int
    {
        $team=(string)($teamMap[(string)$userId] ?? 'player:'.$userId);
        $opponents=array_values(array_filter($participants,fn ($id)=>$id!==$userId && (string)($teamMap[(string)$id] ?? 'player:'.$id)!==$team));
        if($opponents===[]) $opponents=array_values(array_filter($participants,fn ($id)=>$id!==$userId));
        $values=array_map(fn ($id)=>(int)($snapshots[(string)$id] ?? config('warqna_competitive.initial_rating',1000)),$opponents);
        return $values===[]?(int)config('warqna_competitive.initial_rating',1000):(int)round(array_sum($values)/count($values));
    }

    private function normalizeWinnerKey(mixed $winner): ?string
    {
        if($winner===null || $winner==='') return null;
        if(is_int($winner) || ctype_digit((string)$winner)) {
            $numeric=(int)$winner;
            if($numeric===0) return 'teamA'; if($numeric===1) return 'teamB'; return (string)$numeric;
        }
        $value=(string)$winner;
        return match(strtolower($value)){'teama','team_a','a'=>'teamA','teamb','team_b','b'=>'teamB',default=>$value};
    }

    /** @param array<int,int> $participants @param array<string,mixed> $teamMap @param array<int,int> $winners @return array<int,int> */
    private function ranking(array $participants,array $teamMap,array $state,array $winners): array
    {
        $scores=(array)($state['scores'] ?? $state['score'] ?? []);
        $game=(string)($state['game'] ?? $state['game_type'] ?? '');
        $lowerWins=in_array($game,['hearts','leekha','trix','trix_partner','trix_complex','hand','hand_partner','saudi_hand'],true);
        $values=[];
        foreach($participants as $id) {
            $player='user:'.$id; $team=(string)($teamMap[(string)$id] ?? 'player:'.$id);
            $score=$scores[$player] ?? $scores[(string)$id] ?? $scores[$team] ?? null;
            if(is_array($score)) $score=array_sum(array_filter($score,'is_numeric'));
            $values[$id]=is_numeric($score)?(float)$score:0.0;
        }
        uasort($values,$lowerWins?fn ($a,$b)=>$a<=>$b:fn ($a,$b)=>$b<=>$a);
        $ordered=array_keys($values);
        return array_values(array_unique(array_merge($winners,$ordered)));
    }
}
