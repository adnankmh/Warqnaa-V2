<?php

namespace App\Http\Controllers;

use App\Models\{CompetitiveMatch, CompetitiveRating, CompetitiveSeason, Game, RankedQueueEntry, SiteSetting, Tournament, User};
use App\Services\Competitive\{CompetitiveRatingService,CompetitiveSeasonService,TournamentBracketService};
use App\Services\Games\GameCatalog;
use App\Services\Platform\AdminAuditService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AdminCompetitiveController extends Controller
{
    private const BOOL_SETTINGS=['competitive_enabled','ranked_matchmaking_enabled','season_rewards_enabled','club_championships_enabled','country_championships_enabled'];

    public function dashboard(Request $request, CompetitiveSeasonService $seasons)
    {
        $this->guard($request);
        $active=$seasons->activeSeason(false);
        $payload=[
            'ok'=>true,'release'=>['version'=>'0.7.0','build'=>240,'name'=>'R12 Competitive Arena'],
            'stats'=>[
                'active_seasons'=>CompetitiveSeason::where('status','active')->count(),
                'ranked_waiting'=>RankedQueueEntry::where('status','waiting')->count(),
                'matches_live'=>CompetitiveMatch::whereIn('status',['forming','active'])->count(),
                'matches_review'=>CompetitiveMatch::where('status','review')->count(),
                'rated_players'=>$active?CompetitiveRating::where('season_id',$active->id)->where('scope_key','overall')->count():0,
                'tournaments_open'=>Tournament::whereIn('status',['open','running'])->count(),
            ],
            'settings'=>$this->settings(),'active_season'=>$active?$seasons->seasonPayload($active):null,
            'seasons'=>CompetitiveSeason::withCount(['ratings','matches','rewardClaims'])->latest('starts_at')->limit(24)->get(),
            'leaders'=>$active?$seasons->leaderboard($active,'overall',null,null,30)['rows']:[],
            'queue'=>RankedQueueEntry::with(['user.profile','game','room'])->whereIn('status',['waiting','matching','matched'])->latest('joined_at')->limit(80)->get(),
            'review_matches'=>CompetitiveMatch::with(['room','game','season','tournament'])->where('status','review')->latest('finished_at')->limit(80)->get(),
            'recent_matches'=>CompetitiveMatch::with(['room','game','season','tournament'])->latest('started_at')->limit(80)->get(),
            'tournaments'=>Tournament::with(['game','season','club'])->latest()->limit(80)->get(),
            'games'=>Game::where('active',true)->whereIn('key',GameCatalog::customerKeys())->get(),'tiers'=>config('warqna_competitive.tiers',[]),
        ];
        if($request->expectsJson()) return response()->json($payload);
        return view('admin.competitive',$payload);
    }

    public function updateSettings(Request $request, AdminAuditService $audit)
    {
        $this->guard($request);
        $data=$request->validate([
            'competitive_enabled'=>'sometimes|boolean','ranked_matchmaking_enabled'=>'sometimes|boolean','season_rewards_enabled'=>'sometimes|boolean',
            'club_championships_enabled'=>'sometimes|boolean','country_championships_enabled'=>'sometimes|boolean',
            'ranked_queue_timeout_minutes'=>'sometimes|integer|min:2|max:60','ranked_abandon_penalty'=>'sometimes|integer|min:0|max:250',
        ]);
        $before=$this->settings();
        foreach(self::BOOL_SETTINGS as $key) if(array_key_exists($key,$data)) SiteSetting::setValue($key,(bool)$data[$key],'bool','competitive',$key);
        foreach(['ranked_queue_timeout_minutes','ranked_abandon_penalty'] as $key) if(array_key_exists($key,$data)) SiteSetting::setValue($key,(int)$data[$key],'int','competitive',$key);
        $after=$this->settings(); $audit->record($request,'admin.competitive.settings','competitive',$before,$after);
        return $this->respond($request,'تم حفظ إعدادات R12 Competitive.',['settings'=>$after]);
    }

    public function createSeason(Request $request, CompetitiveSeasonService $seasons, AdminAuditService $audit)
    {
        $this->guard($request);
        $data=$request->validate([
            'key'=>'required|string|min:3|max:80|alpha_dash|unique:competitive_seasons,key','name_ar'=>'required|string|max:120','name_en'=>'nullable|string|max:120',
            'description_ar'=>'nullable|string|max:500','description_en'=>'nullable|string|max:500','starts_at'=>'required|date','ends_at'=>'required|date|after:starts_at',
            'rating_soft_reset_factor'=>'nullable|numeric|min:0|max:1','placement_games'=>'nullable|integer|min:1|max:30','reward_tiers'=>'nullable|array',
        ]);
        $activateNow=now()->between($data['starts_at'],$data['ends_at']);
        $season=CompetitiveSeason::create([
            'key'=>$data['key'],'name'=>['ar'=>$data['name_ar'],'en'=>$data['name_en'] ?? $data['name_ar']],
            'description'=>['ar'=>$data['description_ar'] ?? '','en'=>$data['description_en'] ?? ($data['description_ar'] ?? '')],
            'status'=>'scheduled','starts_at'=>$data['starts_at'],'ends_at'=>$data['ends_at'],
            'rating_soft_reset_factor'=>$data['rating_soft_reset_factor'] ?? .75,'placement_games'=>$data['placement_games'] ?? 10,
            'rules'=>['server_authoritative'=>true,'anti_cheat_review'=>true,'one_active_queue'=>true],
            'reward_tiers'=>$data['reward_tiers'] ?? config('warqna_competitive.season_rewards',[]),'created_by'=>$request->user()->id,
        ]);
        if($activateNow){
            $season=$seasons->activate($season);
        }
        $audit->record($request,'admin.competitive.season.create',$season,null,$season->toArray());
        return $this->respond($request,'تم إنشاء الموسم التنافسي.',['season'=>$season]);
    }

    public function seasonAction(Request $request, CompetitiveSeason $season, CompetitiveSeasonService $seasons, AdminAuditService $audit)
    {
        $this->guard($request); $data=$request->validate(['action'=>'required|in:activate,finalize,cancel']); $before=$season->toArray();
        if($data['action']==='activate') {
            $season=$seasons->activate($season);
        }
        elseif($data['action']==='finalize') $seasons->finalize($season);
        else $season->update(['status'=>'cancelled']);
        $audit->record($request,'admin.competitive.season.'.$data['action'],$season,$before,$season->fresh()->toArray());
        return $this->respond($request,'تم تنفيذ إجراء الموسم.',['season'=>$season->fresh()]);
    }

    public function adjustRating(Request $request, User $user, CompetitiveRatingService $ratings, AdminAuditService $audit)
    {
        $this->guard($request); $data=$request->validate(['game_id'=>'required|exists:games,id','delta'=>'required|integer|min:-500|max:500|not_in:0','reason'=>'required|string|min:5|max:500']);
        $game=Game::findOrFail($data['game_id']); $result=$ratings->adjust($user,$game,(int)$data['delta'],trim(strip_tags($data['reason'])),$request->user()->id);
        $audit->record($request,'admin.competitive.rating.adjust',$user,null,$result,['game_id'=>$game->id,'reason'=>$data['reason']]);
        return $this->respond($request,'تمت تسوية التصنيف مع إنشاء سجل غير قابل للتكرار.',$result);
    }

    public function matchAction(Request $request, CompetitiveMatch $match, CompetitiveRatingService $ratings, AdminAuditService $audit)
    {
        $this->guard($request); $data=$request->validate(['action'=>'required|in:approve,void','reason'=>'required|string|min:5|max:500']); $before=$match->toArray();
        if($data['action']==='approve') { abort_unless($match->room,422,'لا توجد غرفة لمعالجة النتيجة.'); $result=$ratings->processRoom($match->room,true); }
        else $result=$ratings->voidMatch($match,trim(strip_tags($data['reason'])),$request->user()->id);
        $audit->record($request,'admin.competitive.match.'.$data['action'],$match,$before,$match->fresh()->toArray(),['reason'=>$data['reason'],'result'=>$result]);
        return $this->respond($request,'تم تنفيذ إجراء المباراة.',$result);
    }

    public function createTournament(Request $request, CompetitiveSeasonService $seasons, AdminAuditService $audit)
    {
        $this->guard($request);
        $data=$request->validate([
            'key'=>'required|string|min:3|max:80|alpha_dash|unique:tournaments,key','game_id'=>'required|exists:games,id','name_ar'=>'required|string|max:120','name_en'=>'nullable|string|max:120',
            'description_ar'=>'nullable|string|max:500','description_en'=>'nullable|string|max:500','format'=>['required',Rule::in(['single_elimination','league_playoffs','group_playoffs'])],
            'scope'=>['required',Rule::in(['global','club','country'])],'club_id'=>'nullable|required_if:scope,club|exists:clubs,id','country_code'=>'nullable|required_if:scope,country|string|size:2',
            'stages'=>'required|integer|min:1|max:6','seats_per_match'=>'required|integer|min:2|max:6','entry_fee'=>'nullable|integer|min:0|max:1000000','prize_pool'=>'nullable|integer|min:0|max:1000000000',
            'min_rating'=>'nullable|integer|min:0|max:5000','max_rating'=>'nullable|integer|min:0|max:5000|gte:min_rating','starts_at'=>'required|date','registration_closes_at'=>'nullable|date|before_or_equal:starts_at',
        ]);
        $game=Game::findOrFail($data['game_id']);
        abort_unless($game->active && GameCatalog::isCustomerVisible($game->key),422,'هذه اللعبة غير متاحة للبطولات التنافسية.');
        abort_unless(in_array((int)$data['seats_per_match'],$this->allowedSeats($game),true),422,'عدد المقاعد غير متوافق مع محرك اللعبة.');
        $max=$this->requiredPlayers($game,(int)$data['seats_per_match'],(int)$data['stages']);
        $season=$seasons->activeSeason(false);
        $tournament=Tournament::create([
            'creator_id'=>$request->user()->id,'season_id'=>$season?->id,'club_id'=>$data['club_id'] ?? null,'game_id'=>$data['game_id'],
            'key'=>$data['key'],'name'=>['ar'=>$data['name_ar'],'en'=>$data['name_en'] ?? $data['name_ar']],
            'description'=>['ar'=>$data['description_ar'] ?? '','en'=>$data['description_en'] ?? ($data['description_ar'] ?? '')],
            'format'=>$data['format'],'scope'=>$data['scope'],'country_code'=>isset($data['country_code'])?strtoupper($data['country_code']):null,
            'stages'=>$data['stages'],'rounds'=>$data['stages'],'seats_per_match'=>$data['seats_per_match'],'max_players'=>$max,
            'entry_fee'=>$data['entry_fee'] ?? 0,'prize_pool'=>$data['prize_pool'] ?? 0,'min_rating'=>$data['min_rating'] ?? null,'max_rating'=>$data['max_rating'] ?? null,
            'status'=>'open','starts_at'=>$data['starts_at'],'registration_closes_at'=>$data['registration_closes_at'] ?? $data['starts_at'],
            'auto_accept'=>true,'random_seating'=>false,'chat_enabled'=>true,'turn_seconds'=>10,'entry_mode'=>'ticket_or_tokens','featured'=>true,
            'competitive_rules'=>['server_authoritative'=>true,'anti_cheat_review'=>true,'bracket_engine'=>'r12','scope_locked'=>true],
            'bracket'=>['messages'=>['أُنشئت البطولة من Admin Competitive Control Plane.']],
        ]);
        $audit->record($request,'admin.competitive.tournament.create',$tournament,null,$tournament->toArray());
        return $this->respond($request,'تم إنشاء البطولة التنافسية.',['tournament'=>$tournament]);
    }

    public function buildBracket(Request $request, Tournament $tournament, TournamentBracketService $brackets, AdminAuditService $audit)
    {
        $this->guard($request); $data=$request->validate(['force'=>'nullable|boolean']); $before=$tournament->toArray();
        $result=$brackets->build($tournament,(bool)($data['force'] ?? false));
        $audit->record($request,'admin.competitive.tournament.bracket',$tournament,$before,$tournament->fresh()->toArray(),['force'=>(bool)($data['force'] ?? false)]);
        return $this->respond($request,'تم بناء جدول البطولة واعتماد غرف المرحلة.',$result);
    }

    /** @return array<string,mixed> */
    private function settings(): array
    {
        $values=['competitive_enabled'=>true,'ranked_matchmaking_enabled'=>true,'season_rewards_enabled'=>true,'club_championships_enabled'=>true,'country_championships_enabled'=>true,'ranked_queue_timeout_minutes'=>15,'ranked_abandon_penalty'=>35];
        foreach($values as $key=>$default) $values[$key]=in_array($key,self::BOOL_SETTINGS,true)?(bool)SiteSetting::getValue($key,$default):(int)SiteSetting::getValue($key,$default);
        return $values;
    }

    private function guard(Request $request): void
    {
        abort_unless((bool)$request->user()?->is_admin,403,'هذه الصفحة للإدارة فقط.');
        abort_unless($request->user()->hasAdminPermission('competitive'),403,'تحتاج صلاحية إدارة Competitive Arena.');
    }

    /** @return array<int,int> */
    private function allowedSeats(Game $game): array
    {
        return match($game->key) {
            'pinochle','banakil'=>[2,4], 'hand','saudi_hand'=>[2,3,4], 'hand_partner'=>[4],
            default=>[(int)$game->max_players],
        };
    }

    private function requiredPlayers(Game $game,int $seats,int $stages): int
    {
        $advance=max(1,intdiv($seats,2));
        $required=max(2,$seats);
        for($round=1;$round<max(1,$stages);$round++){
            $numerator=$required*$seats;
            abort_unless($numerator%$advance===0,422,'إعداد المقاعد والمراحل لا يكوّن جدولاً كاملاً.');
            $required=intdiv($numerator,$advance);
        }
        return $required;
    }

    private function respond(Request $request,string $message,array $extra=[])
    {
        if($request->expectsJson()) return response()->json(['ok'=>true,'message'=>$message]+$extra);
        return back()->with('ok',$message);
    }
}
