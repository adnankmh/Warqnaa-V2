<?php

namespace App\Http\Controllers;

use App\Models\{CompetitionAppeal, CompetitiveMatch, Game, Tournament};
use App\Services\Competitive\{CompetitiveMatchmakingService, CompetitiveSeasonService};
use App\Services\WarqnaPro\CompetitionService;
use App\Support\AuthenticatedActor;
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
        $data=$request->validate(['expected_entry_fee'=>'nullable|integer|min:0|max:1000000']);
        $result=$competitions->join($request->user(),$tournament->key,(int)$tournament->entry_fee,
            isset($data['expected_entry_fee']) ? (int)$data['expected_entry_fee'] : null);
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

    public function appeals(Request $request)
    {
        $actor = AuthenticatedActor::resolve($request);
        $appeals = CompetitionAppeal::with(['match.game', 'match.room', 'tournament'])
            ->where('user_id', $actor->id)
            ->latest('submitted_at')
            ->limit(50)
            ->get();

        return response()->json([
            'ok' => true,
            'appeals' => $appeals->map(fn (CompetitionAppeal $appeal) => [
                'id' => $appeal->id,
                'match_key' => $appeal->match?->match_key,
                'game' => $appeal->match?->game?->key,
                'room_code' => $appeal->match?->room?->code,
                'tournament_id' => $appeal->tournament_id,
                'category' => $appeal->category,
                'reason' => $appeal->reason,
                'evidence' => $appeal->evidence,
                'status' => $appeal->status,
                'decision_note' => $appeal->decision_note,
                'submitted_at' => $appeal->submitted_at?->toIso8601String(),
                'resolved_at' => $appeal->resolved_at?->toIso8601String(),
            ])->values(),
        ]);
    }

    public function submitAppeal(Request $request, CompetitiveMatch $match)
    {
        $actor = AuthenticatedActor::resolve($request);
        $userId = (int) $actor->id;
        $participants = array_values(array_unique(array_map('intval', (array) $match->participant_ids)));
        abort_unless(in_array($userId, $participants, true), 403, 'يمكن فقط للاعب شارك في المباراة تقديم اعتراض عليها.');
        abort_if(in_array($match->status, ['voided', 'cancelled'], true), 422, 'هذه المباراة ملغاة ولا تقبل اعتراضًا جديدًا.');
        abort_unless($match->finished_at || in_array($match->status, ['completed', 'review'], true), 422, 'لا يمكن الاعتراض قبل انتهاء المباراة.');
        if ($match->finished_at && $match->finished_at->lt(now()->subHours(48))) {
            abort(422, 'انتهت مهلة الاعتراض البالغة 48 ساعة.');
        }

        $data = $request->validate([
            'category' => 'required|in:result,score,disconnect,illegal_move,integrity,other',
            'reason' => 'required|string|min:10|max:1200',
            'evidence' => 'nullable|array|max:10',
            'evidence.*' => 'nullable|string|max:500',
        ]);

        $existing = CompetitionAppeal::where('competitive_match_id', $match->id)
            ->where('user_id', $userId)
            ->first();
        abort_if($existing && $existing->status !== 'pending', 409, 'تم حسم اعتراضك السابق على هذه المباراة.');

        $appeal = CompetitionAppeal::updateOrCreate(
            ['competitive_match_id' => $match->id, 'user_id' => $userId],
            [
                'tournament_id' => $match->tournament_id,
                'category' => $data['category'],
                'reason' => trim(strip_tags($data['reason'])),
                'evidence' => array_values(array_filter(array_map(
                    fn ($value) => mb_substr(trim(strip_tags((string) $value)), 0, 500),
                    (array) ($data['evidence'] ?? [])
                ))),
                'status' => 'pending',
                'resolved_by' => null,
                'decision_note' => null,
                'submitted_at' => now(),
                'resolved_at' => null,
            ]
        );

        $meta = array_merge((array) $match->meta, [
            'appeal_pending' => true,
            'latest_appeal_id' => $appeal->id,
            'latest_appeal_at' => now()->toIso8601String(),
        ]);
        $update = ['meta' => $meta];
        if (!$match->rating_processed) {
            $update['status'] = 'review';
        }
        $match->update($update);

        return response()->json([
            'ok' => true,
            'message' => 'تم تسجيل الاعتراض وتحويله إلى مراجعة موثقة.',
            'appeal' => $appeal->fresh(),
        ], 201);
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
