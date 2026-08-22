<?php
namespace App\Http\Controllers;

use App\Models\{Friendship,Tournament,TournamentEntry,Game,Room,RoomPlayer,Notification,SiteSetting,User};
use App\Services\Wallet\WalletService;
use App\Services\Notifications\FirebasePushService;
use App\Services\Games\GameCatalog;
use App\Services\Competitive\{CompetitiveSeasonService,TournamentBracketService};
use Illuminate\Http\Request; use RuntimeException;
use Illuminate\Support\Facades\{DB,Schema};

class TournamentController
{
    private array $seatOrder = ['south','north','west','east','south_west','south_east'];

    public function index()
    {
        return view('tournaments.index', [
            'tournaments'=>Tournament::with('creator.profile','game','entries.user.profile')->latest()->get(),
            'games'=>Game::where('active',true)->whereIn('key', GameCatalog::customerKeys())->get(),
        ]);
    }

    public function store(Request $r, WalletService $wallet)
    {
        abort_unless((auth()->user()->profile?->pasha_days ?? 0)>0 || auth()->user()->is_admin,403,'إنشاء المنافسات ميزة لأعضاء الباشا فقط.');
        $data=$r->validate([
            'club_id'=>'nullable|exists:clubs,id','game_id'=>'required|exists:games,id','stages'=>'required|integer|min:1|max:4','seats_per_match'=>'required|integer|min:2|max:6','entry_fee'=>'required|integer|min:0|max:1000000','prize_pool'=>'required|integer|min:0|max:100000000'
        ]);
        $game=Game::findOrFail($data['game_id']);
        abort_unless($game->active && GameCatalog::isCustomerVisible($game->key), 422, 'هذه اللعبة غير متاحة للمنافسات حالياً.');
        if (!empty($data['club_id'])) {
            $club=\App\Models\Club::findOrFail($data['club_id']);
            $membership=$club->members()->where('user_id',auth()->id())->first();
            $allowedClubTournament=$club->owner_id===auth()->id() || auth()->user()->is_admin || ($membership && $membership->role==='moderator' && (!empty(($membership->permissions ?: [])['all']) || !empty(($membership->permissions ?: [])['create_tournaments'])));
            abort_unless($allowedClubTournament,403,'ليس لديك صلاحية إنشاء مسابقة لهذا النادي.');
        }
        $allowed=$this->allowedSeatsForGame($game);
        if(!in_array((int)$data['seats_per_match'],$allowed,true)) return back()->withErrors(['msg'=>'عدد مقاعد المسابقة غير مناسب لهذه اللعبة. الخيارات الصحيحة: '.implode(' / ',$allowed)]);
        $capacity=$this->requiredPlayers($game,(int)$data['seats_per_match'],(int)$data['stages']);
        $distribution=$this->prizeDistribution((int)$data['prize_pool'],(bool)$game->partnership,(int)$data['stages']);
        $leaderboard=$this->leaderboardPoints((int)$data['stages']);
        $season=Schema::hasTable('competitive_seasons') ? app(CompetitiveSeasonService::class)->activeSeason(false) : null;
        try{
            $t=DB::transaction(function() use($wallet,$data,$season,$distribution,$leaderboard,$capacity){
                // V240: prize escrow and tournament creation commit or roll back together.
                if(!auth()->user()->is_admin && (int)$data['prize_pool']>0){
                    $wallet->debit(auth()->user(),(int)$data['prize_pool'],'tournament_prize_escrow',['game_id'=>$data['game_id']]);
                    $wallet->creditPrimaryAdminRevenue(auth()->user(),(int)$data['prize_pool'],'tournament_prize_escrow_income',['game_id'=>$data['game_id']]);
                }
                return Tournament::create($this->safeColumns('tournaments',['creator_id'=>auth()->id()]+$data+['max_players'=>$capacity,'status'=>'open','season_id'=>$season?->id,'format'=>'single_elimination','scope'=>!empty($data['club_id'])?'club':'global','house_cut_percent'=>10,'prize_distribution'=>$distribution,'leaderboard_points'=>$leaderboard,'competitive_rules'=>['server_authoritative'=>true,'anti_cheat_review'=>true,'bracket_engine'=>'r12'],'bracket'=>['round'=>1,'matches'=>[],'messages'=>['تم إنشاء المسابقة بنظام خروج المغلوب.'],'distribution'=>$distribution,'leaderboard_points'=>$leaderboard]]));
            });
        }catch(\Throwable $e){ return back()->withErrors(['msg'=>'رصيدك لا يكفي لتمويل جائزة المنافسة أو تعذر حفظها.']); }
        return back()->with('ok','تم إنشاء المسابقة رقم '.$t->id);
    }

    public function join(Tournament $tournament, WalletService $wallet)
    {
        abort_unless(in_array($tournament->status,['open','running'],true),403,'المسابقة ليست مفتوحة للتسجيل');
        $bracketState=(array)($tournament->bracket ?: []);
        abort_if(($bracketState['schema'] ?? null)==='r12_competitive_bracket_v1',403,'تم قفل التسجيل بعد بناء جدول البطولة.');
        abort_if($tournament->registration_closes_at && now()->gte($tournament->registration_closes_at),403,'أُغلق التسجيل في هذه البطولة.');
        $season=$tournament->season ?: (Schema::hasTable('competitive_seasons')?app(CompetitiveSeasonService::class)->activeSeason(false):null);
        if($season){
            $rating=(int)app(CompetitiveSeasonService::class)->ratingFor(auth()->user(),$season)->rating;
            abort_if($tournament->min_rating!==null && $rating<(int)$tournament->min_rating,403,'تصنيفك أقل من الحد المطلوب.');
            abort_if($tournament->max_rating!==null && $rating>(int)$tournament->max_rating,403,'تصنيفك أعلى من نطاق البطولة.');
        }
        if(($tournament->scope ?? 'global')==='country'){
            abort_unless((bool)SiteSetting::getValue('country_championships_enabled',true),503,'بطولات الدول متوقفة مؤقتاً.');
            abort_if($tournament->country_code && strtoupper((string)auth()->user()->profile?->country_code)!==strtoupper((string)$tournament->country_code),403,'هذه بطولة مخصصة لدولة مختلفة.');
        }
        if(($tournament->scope ?? 'global')==='club'){
            abort_unless((bool)SiteSetting::getValue('club_championships_enabled',true),503,'بطولات الأندية متوقفة مؤقتاً.');
            $membership=auth()->user()->clubMembership;
            abort_if(!$membership,403,'يلزم الانضمام إلى نادٍ لدخول بطولة الأندية.');
            abort_if($tournament->club_id && (int)$membership->club_id!==(int)$tournament->club_id,403,'هذه البطولة مخصصة لنادٍ مختلف.');
        }
        $exitCount=(int)data_get($bracketState,'exit_counts.'.auth()->id(),0);
        abort_if($exitCount>=5,403,'لا يمكنك العودة إلى هذه المنافسة بعد الخروج منها 5 مرات.');
        $capacity=$this->requiredPlayers($tournament->game,(int)$tournament->seats_per_match,(int)$tournament->stages);
        abort_if($tournament->entries()->count()>=$capacity,409,'اكتمل عدد المشاركين في هذه المنافسة.');
        $activeTournament = TournamentEntry::where('user_id',auth()->id())->whereHas('tournament', fn($q)=>$q->whereIn('status',['open','running']))->where('tournament_id','!=',$tournament->id)->first();
        abort_if($activeTournament,403,'أنت مشترك في مسابقة أخرى بالفعل. اخرج أو انتظر انتهاء المسابقة الحالية قبل الاشتراك في مسابقة جديدة.');
        abort_if($tournament->entries()->where('user_id',auth()->id())->exists(),409,'أنت مسجل بالفعل');
        $blockedWithCreator = Friendship::where('status','blocked')->where(function($query) use($tournament){
            $query->where(fn($q)=>$q->where('requester_id',auth()->id())->where('addressee_id',$tournament->creator_id))
                ->orWhere(fn($q)=>$q->where('requester_id',$tournament->creator_id)->where('addressee_id',auth()->id()));
        })->exists();
        abort_if($blockedWithCreator,403,'لا يمكنك التسجيل في مسابقة ينظمها لاعب محظور بينكما.');
        $participantIds = $tournament->entries()->pluck('user_id')->map(fn($id)=>(int)$id)->all();
        $blockedWithParticipant = $participantIds !== [] && Friendship::where('status','blocked')->where(function($query) use($participantIds){
            $query->where(fn($q)=>$q->where('requester_id',auth()->id())->whereIn('addressee_id',$participantIds))
                ->orWhere(fn($q)=>$q->whereIn('requester_id',$participantIds)->where('addressee_id',auth()->id()));
        })->exists();
        abort_if($blockedWithParticipant,403,'لا يمكنك التسجيل في مسابقة تضم لاعباً محظوراً بينكما.');
        try{
            DB::transaction(function() use($wallet,$tournament,$capacity){
                $locked=Tournament::with('game')->lockForUpdate()->findOrFail($tournament->id);
                $state=(array)($locked->bracket ?: []);
                if(!in_array((string)$locked->status,['open','running'],true)) throw new RuntimeException('المسابقة ليست مفتوحة للتسجيل.');
                if(($state['schema'] ?? null)==='r12_competitive_bracket_v1') throw new RuntimeException('تم قفل التسجيل بعد بناء جدول البطولة.');
                if($locked->registration_closes_at && now()->gte($locked->registration_closes_at)) throw new RuntimeException('أُغلق التسجيل في هذه البطولة.');
                if($locked->entries()->where('user_id',auth()->id())->exists()) throw new RuntimeException('أنت مسجل بالفعل.');
                if($locked->entries()->count()>=$capacity) throw new RuntimeException('اكتمل عدد المشاركين في هذه المنافسة.');
                if((int)$locked->entry_fee>0){
                    $wallet->debit(auth()->user(),(int)$locked->entry_fee,'tournament_entry',['tournament_id'=>$locked->id]);
                    $wallet->creditPrimaryAdminRevenue(auth()->user(),(int)$locked->entry_fee,'tournament_entry_income',['tournament_id'=>$locked->id]);
                }
                TournamentEntry::create(['tournament_id'=>$locked->id,'user_id'=>auth()->id(),'status'=>'registered','entry_mode'=>(int)$locked->entry_fee>0?'tokens':'free','paid_tokens'=>(int)$locked->entry_fee]);
                $state['messages'][]='سجل اللاعب '.auth()->user()->username.' في المسابقة.';
                $locked->update(['bracket'=>$state]);
                $this->tryCreateMatchRoom($locked->fresh(['entries','game']));
            });
        }catch(\Throwable $e){
            $message=$e instanceof RuntimeException?$e->getMessage():'الرصيد غير كافٍ أو تعذر تسجيلك في المنافسة.';
            return back()->withErrors(['msg'=>$message]);
        }
        return back()->with('ok','تم التسجيل في المسابقة');
    }

    public function leave(Tournament $tournament)
    {
        $entry=$tournament->entries()->where('user_id',auth()->id())->first();
        abort_unless($entry,404,'أنت غير مسجل في هذه المنافسة.');
        $bracket=(array)($tournament->bracket ?: ['round'=>1,'matches'=>[],'messages'=>[]]);
        abort_if(($bracket['schema'] ?? null)==='r12_competitive_bracket_v1',403,'تم قفل الانسحاب بعد بناء جدول البطولة؛ تُطبّق قواعد الانسحاب التنافسي على المباراة.');
        $counts=(array)($bracket['exit_counts'] ?? []);
        $key=(string)auth()->id();
        $counts[$key]=(int)($counts[$key] ?? 0)+1;
        $bracket['exit_counts']=$counts;
        $bracket['messages'][]='خرج اللاعب '.auth()->user()->username.' من المنافسة ('.$counts[$key].'/5).';
        $tournament->update(['bracket'=>$bracket]);
        $entry->delete();
        return back()->with('ok',$counts[$key]>=5?'تم الخروج. وصلت إلى حد 5 مرات ولن تستطيع العودة إلى هذه المنافسة.':'تم الخروج ويمكنك العودة ما دمت لم تصل إلى 5 مرات.');
    }

    public function launch(Tournament $tournament)
    {
        abort_unless($tournament->creator_id===auth()->id() || auth()->user()->is_admin,403);
        $room = $this->tryCreateMatchRoom($tournament->fresh(['entries','game']));
        if(!$room) return back()->withErrors(['msg'=>'لا يوجد عدد كافٍ من المسجلين لبدء مباراة.']);
        return redirect()->route('rooms.show',$room->code)->with('ok','تم فتح غرفة المسابقة');
    }

    public function replay(Tournament $tournament)
    {
        $tournament->load('game','entries.user.profile');
        $match = $tournament->bracket['matches'][0] ?? collect((array)($tournament->bracket['rounds'] ?? []))->flatMap(fn($round)=>(array)($round['matches'] ?? []))->first() ?? [];
        $room = !empty($match['room_code']) ? Room::with('players.user.profile','game')->where('code',$match['room_code'])->first() : null;
        $state = $room?->state ?: [];
        $frames = [];
        foreach(($state['log'] ?? []) as $i=>$event){
            $frames[] = [
                'title' => 'الحركة '.($i+1),
                'body' => ($event['player'] ?? $event['system'] ?? 'النظام').' — '.($event['action'] ?? $event['system'] ?? 'تحديث'),
                'payload' => $event['payload'] ?? [],
                'at' => $event['at'] ?? '',
            ];
        }
        if(empty($frames)){
            foreach(($tournament->bracket['messages'] ?? []) as $i=>$msg){ $frames[]=['title'=>'مرحلة '.($i+1),'body'=>$msg,'payload'=>[],'at'=>'']; }
        }
        $finalHands = (($state['phase'] ?? '') === 'finished') ? ($state['hands'] ?? []) : [];
        return view('tournaments.replay', compact('tournament','room','state','frames','finalHands'));
    }


    private function safeColumns(string $table,array $data): array{ try{return array_filter($data,fn($v,$k)=>Schema::hasColumn($table,$k),ARRAY_FILTER_USE_BOTH);}catch(\Throwable $e){return $data;} }
    private function requiredPlayers(Game $game,int $seats,int $stages): int
    {
        $advance=max(1,intdiv($seats,2)); $required=max(2,$seats);
        for($round=1;$round<max(1,$stages);$round++){
            $numerator=$required*$seats;
            if($numerator%$advance!==0) throw new RuntimeException('إعداد المقاعد والمراحل لا يكوّن جدولاً كاملاً.');
            $required=intdiv($numerator,$advance);
        }
        return $required;
    }
    private function stageLabel(int $stages): string { return match($stages){1=>'نهائي فقط',2=>'نصف نهائي ثم نهائي',3=>'ربع نهائي ثم نصف نهائي ثم نهائي',4=>'ثمن نهائي ثم ربع نهائي ثم نصف نهائي ثم نهائي',default=>'نهائي'}; }

    private function prizeDistribution(int $basePrize, bool $partnership, int $stages): array
    {
        $base=max(0,$basePrize);
        $partner=$partnership;
        return [
            'mode'=>$partner?'team_split':'winner_takes_all',
            'first_percent'=>$partner?55:100,
            'second_percent'=>$partner?30:0,
            'semifinal_percent'=>$partner?10:0,
            'house_cut_percent'=>10,
            'first_estimate'=>$partner?(int)floor($base*.55):$base,
            'second_estimate'=>$partner?(int)floor($base*.30):0,
            'note'=>$partner?'في ألعاب 4 مقاعد/الشراكة تقسم الجائزة على الفريق أو المراكز حسب نظام المنافسة.':'في ألعاب المقعدين يحصل الفائز على الجائزة كاملة.',
        ];
    }

    private function leaderboardPoints(int $stages): array
    {
        return ['first'=>1000,'second'=>600,'semifinal'=>$stages>=2?350:0,'quarterfinal'=>$stages>=3?150:0,'early'=>50];
    }

    private function allowedSeatsForGame(Game $game): array
    {
        return match($game->key){
            'tarneeb','tarneeb_400','tarneeb_41','trix','trix_partner','baloot','hokm','kout4','estimation','leekha','hearts'=>[4],
            'kout6'=>[6],
            'backgammon','basra'=>[2],
            'pinochle','banakil'=>[2,4],
            'hand','saudi_hand','konkan','domino'=>[2,3,4],
            'hand_partner'=>[4],
            default=>array_values(array_unique(range((int)$game->min_players,min((int)$game->max_players,6))))
        };
    }

    private function tryCreateMatchRoom(Tournament $tournament): ?Room
    {
        $tournament->load('entries','game');
        $bracket = $tournament->bracket ?: ['round'=>1,'matches'=>[],'messages'=>[]];
        if(Schema::hasTable('competitive_matches') && Schema::hasColumn('tournaments','bracket_version')){
            try{
                $built=app(TournamentBracketService::class)->build($tournament);
                $rooms=(array)($built['rooms'] ?? []);
                if($rooms!==[]) return $rooms[0];
            }catch(RuntimeException $e){
                if(str_contains($e->getMessage(),'لاعباً لبناء جدول')) return null;
                throw $e;
            }
        }
        if(!empty($bracket['matches'][0]['room_code'])) return Room::where('code',$bracket['matches'][0]['room_code'])->first();
        $needed=$this->requiredPlayers($tournament->game,(int)$tournament->seats_per_match,(int)$tournament->stages);
        if($tournament->entries->count() < $needed) return null;

        return DB::transaction(function() use($tournament,$bracket){
            $code=(string)random_int(100000,999999);
            while(Room::where('code',$code)->exists()) $code=(string)random_int(100000,999999);
            $room=Room::create($this->safeColumns('rooms',[
                'code'=>$code,'game_id'=>$tournament->game_id,'owner_id'=>$tournament->creator_id,'visibility'=>'public','password'=>null,'entry_fee'=>0,'min_level'=>1,'target_score'=>$tournament->game->rules['targets'][0] ?? null,'max_players'=>$tournament->seats_per_match,'status'=>'waiting','state'=>['phase'=>'waiting','scores'=>[0,0],'tournament_id'=>$tournament->id,'tournament_stage'=>$this->stageLabel((int)$tournament->stages),'prize_split'=>$tournament->game?->partnership?'تقسم الجائزة على الفريق الفائز':'الفائز يأخذ الجائزة كاملة','prize_distribution'=>$tournament->prize_distribution ?? [],'leaderboard_points'=>$tournament->leaderboard_points ?? [],'log'=>[['system'=>'غرفة مسابقة جاهزة','at'=>now()->toIso8601String()]]]
            ]));
            foreach($tournament->entries->take($tournament->seats_per_match)->values() as $i=>$entry){
                RoomPlayer::create($this->safeColumns('room_players',['room_id'=>$room->id,'user_id'=>$entry->user_id,'seat'=>$this->seatOrder[$i] ?? 'south','is_bot'=>false,'connected'=>true]));
            }
            $bracket['matches'][]=['round'=>1,'room_code'=>$room->code,'players'=>$tournament->entries->take($tournament->seats_per_match)->pluck('user_id')->values()->all(),'status'=>'ready','recording'=>true,'replay_mode'=>'event_log_with_final_hands'];
            $bracket['recording_enabled']=true;
            $bracket['messages'][]='تم إنشاء غرفة المسابقة '.$room->code.' وتفعيل سجل المسابقة وإعادة المشاهدة النصية. بعد انتهاء المباراة يمكن إظهار الحركات والنتائج وأوراق اللاعبين النهائية من سجل الغرفة.';
            $tournament->update(['status'=>'running','bracket'=>$bracket]);
            $push=app(FirebasePushService::class);
            foreach($tournament->entries as $entry){
                $participant=User::find($entry->user_id);
                if(!$participant) continue;
                Notification::create([
                    'user_id'=>$participant->id,
                    'type'=>'tournament_started',
                    'title'=>['ar'=>'بدأت المنافسة','en'=>'Competition started'],
                    'body'=>['ar'=>'بدأت المنافسة رقم '.$tournament->id.' وغرفة المرحلة الحالية '.$room->code.' جاهزة.','en'=>'Competition #'.$tournament->id.' has started and room '.$room->code.' is ready.'],
                    'url'=>route('rooms.show',$room->code),
                    'meta'=>['tournament_id'=>$tournament->id,'room_code'=>$room->code,'started'=>true],
                ]);
                $push->sendToUser($participant,'Warqnaa • بدأت المنافسة','غرفة المنافسة '.$room->code.' جاهزة الآن.',['type'=>'tournament_started','tournament_id'=>$tournament->id,'room_code'=>$room->code]);
            }
            return $room;
        });
    }
}
