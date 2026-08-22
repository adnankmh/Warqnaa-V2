<?php

namespace App\Http\Controllers;

use App\Models\{CompetitiveMatch, Game, Tournament};
use App\Services\Competitive\{CompetitiveMatchmakingService, CompetitiveSeasonService};
use App\Services\WarqnaPro\CompetitionService;
use Illuminate\Http\Request;

class MobileCompetitiveController extends Controller
{
    public function dashboard(Request $request, CompetitiveSeasonService $seasons)
    {
        return response()->json(['ok'=>true,'competitive'=>$seasons->dashboard($request->user())]);
    }

    public function joinQueue(Request $request, CompetitiveMatchmakingService $matchmaking)
    {
        $data=$request->validate(['game'=>'required|string|max:80','preferred_seats'=>'required|integer|min:2|max:6','region'=>'nullable|string|max:24']);
        return response()->json($matchmaking->join($request->user(),$data['game'],(int)$data['preferred_seats'],(string)($data['region'] ?? 'global')),201);
    }

    public function queueStatus(Request $request, CompetitiveMatchmakingService $matchmaking)
    {
        $data=$request->validate(['token'=>'nullable|uuid']);
        return response()->json($matchmaking->status($request->user(),$data['token'] ?? null));
    }

    public function cancelQueue(Request $request, CompetitiveMatchmakingService $matchmaking)
    {
        $data=$request->validate(['token'=>'nullable|uuid']);
        return response()->json($matchmaking->cancel($request->user(),$data['token'] ?? null));
    }

    public function leaderboard(Request $request, CompetitiveSeasonService $seasons)
    {
        $data=$request->validate(['game'=>'nullable|string|max:80','country'=>'nullable|string|size:2','club_id'=>'nullable|integer|exists:clubs,id','limit'=>'nullable|integer|min:1|max:200']);
        $season=$seasons->activeSeason();
        $scope='overall';
        if(!empty($data['game'])) { $game=Game::where('key',$data['game'])->firstOrFail(); $scope='game:'.$game->key; }
        return response()->json(['ok'=>true,'leaderboard'=>$seasons->leaderboard($season,$scope,$data['country'] ?? null,$data['club_id'] ?? null,(int)($data['limit'] ?? 100))]);
    }

    public function tournament(Request $request, Tournament $tournament)
    {
        $tournament->load(['game','season','entries.user.profile','champion.profile','championClub']);
        return response()->json(['ok'=>true,'tournament'=>[
            'id'=>$tournament->id,'key'=>$tournament->key,'name'=>$tournament->name,'description'=>$tournament->description,
            'game'=>$tournament->game?->key,'game_name'=>$tournament->game?->name,'season'=>$tournament->season?->key,
            'format'=>$tournament->format,'scope'=>$tournament->scope,'country_code'=>$tournament->country_code,
            'status'=>$tournament->status,'current_round'=>(int)$tournament->current_round,'stages'=>(int)$tournament->stages,
            'entry_fee'=>(int)$tournament->entry_fee,'prize_pool'=>(int)$tournament->prize_pool,
            'players'=>$tournament->entries->count(),'max_players'=>(int)($tournament->max_players ?: 0),
            'registered'=>$tournament->entries->contains('user_id',$request->user()->id),
            'rating_range'=>['min'=>$tournament->min_rating,'max'=>$tournament->max_rating],
            'starts_at'=>$tournament->starts_at?->toIso8601String(),'registration_closes_at'=>$tournament->registration_closes_at?->toIso8601String(),
            'bracket'=>$tournament->bracket,'champion'=>$tournament->champion?->publicProfile(),'champion_club'=>$tournament->championClub,
        ]]);
    }

    public function joinTournament(Request $request, Tournament $tournament, CompetitionService $competitions)
    {
        abort_unless($tournament->key,422,'هذه البطولة تستخدم التسجيل عبر صفحة الويب حالياً.');
        $result=$competitions->join($request->user(),$tournament->key,(int)$tournament->entry_fee);
        return response()->json(['ok'=>true,'message'=>'تم تسجيلك في البطولة.']+$result,201);
    }

    public function leaveTournament(Request $request, Tournament $tournament, CompetitionService $competitions)
    {
        abort_unless($tournament->key,422,'هذه البطولة تستخدم التسجيل عبر صفحة الويب حالياً.');
        return response()->json(['ok'=>true,'message'=>'تم الخروج من البطولة.']+$competitions->leave($request->user(),$tournament->key));
    }

    public function claimReward(Request $request, int $claim, CompetitiveSeasonService $seasons)
    {
        return response()->json($seasons->claimReward($request->user(),$claim));
    }

    public function history(Request $request)
    {
        $userId=(int)$request->user()->id;
        $matches=CompetitiveMatch::with(['game','room','season','ratingEvents'=>fn ($q)=>$q->where('user_id',$userId)])
            ->whereJsonContains('participant_ids',$userId)->latest('started_at')->limit(40)->get();
        return response()->json(['ok'=>true,'matches'=>$matches->map(fn ($match)=>[
            'key'=>$match->match_key,'mode'=>$match->mode,'status'=>$match->status,'game'=>$match->game?->key,
            'season'=>$match->season?->key,'room_code'=>$match->room?->code,'result'=>$match->result,
            'rating_events'=>$match->ratingEvents->map(fn ($event)=>['scope'=>$event->scope_key,'before'=>$event->rating_before,'after'=>$event->rating_after,'delta'=>$event->rating_delta,'result'=>$event->result]),
            'started_at'=>$match->started_at?->toIso8601String(),'finished_at'=>$match->finished_at?->toIso8601String(),
        ])->values()]);
    }
}
