<?php

namespace Tests\Feature;

use App\Models\{
    AntiCheatEvent, CompetitionTicket, CompetitiveMatch, CompetitiveRating, CompetitiveRatingEvent,
    CompetitiveSeason, Game, Room, SeasonRewardClaim, Tournament, TournamentEntry, User, Wallet
};
use App\Services\Competitive\{
    CompetitiveMatchmakingService, CompetitiveRatingService, CompetitiveSeasonService,
    TournamentBracketService
};
use App\Services\WarqnaPro\CompetitionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

class V240CompetitiveArenaTest extends TestCase
{
    use RefreshDatabase;

    public function test_r12_schema_release_and_default_season_contract(): void
    {
        foreach ([
            'competitive_seasons','competitive_ratings','ranked_queue_entries','competitive_matches',
            'competitive_rating_events','season_reward_claims','competitive_standing_snapshots',
        ] as $table) $this->assertTrue(Schema::hasTable($table), "Missing R12 table: {$table}");

        $this->assertSame('0.7.0+240',config('warqna_competitive.release'));
        $this->assertCount(8,config('warqna_competitive.tiers'));
        $this->assertSame(2300,config('warqna_competitive.tiers.7.min'));
        $this->assertDatabaseHas('competitive_seasons',['key'=>'r12_launch_2026','status'=>'active']);
    }

    public function test_ranked_matchmaker_creates_server_authoritative_bot_free_room(): void
    {
        $game=$this->game('basra',2,false);
        $a=$this->player('r12_alpha'); $b=$this->player('r12_beta');
        $service=app(CompetitiveMatchmakingService::class);

        $first=$service->join($a,$game->key,2,'levant');
        $this->assertSame('waiting',$first['queue']['status']);
        $second=$service->join($b,$game->key,2,'levant');
        $this->assertSame('matched',$second['queue']['status']);

        $match=CompetitiveMatch::with('room.players')->firstOrFail();
        $this->assertSame('ranked',$match->mode);
        $this->assertCount(2,$match->participant_ids);
        $this->assertSame(0,$match->room->players->where('is_bot',true)->count());
        $this->assertSame(0,$match->room->players->where('connected',true)->count());
        $this->assertSame(['south','north'],$match->room->players->sortBy('id')->pluck('seat')->values()->all());
        $this->assertTrue((bool)data_get($match->room->state,'server_authoritative'));
        $this->assertTrue((bool)data_get($match->room->state,'competitive'));
        $this->assertSame('matched',$a->rankedQueueEntries()->latest()->value('status'));
    }

    public function test_ranked_matchmaker_expands_a_two_sided_mmr_window_without_forcing_an_unfair_match(): void
    {
        $game=$this->game('basra',2,false); $a=$this->player('r12_window_a'); $b=$this->player('r12_window_b');
        $season=app(CompetitiveSeasonService::class)->activeSeason();
        app(CompetitiveSeasonService::class)->ratingFor($a,$season,$game->id,$game->key)->update(['rating'=>1000]);
        app(CompetitiveSeasonService::class)->ratingFor($b,$season,$game->id,$game->key)->update(['rating'=>1450]);
        $service=app(CompetitiveMatchmakingService::class);
        $service->join($a,$game->key,2,'levant'); $service->join($b,$game->key,2,'levant');
        $this->assertSame(0,CompetitiveMatch::count());

        $a->rankedQueueEntries()->update(['joined_at'=>now()->subMinutes(3)]);
        $b->rankedQueueEntries()->update(['joined_at'=>now()->subMinutes(3)]);
        $service->tick();
        $this->assertSame(0,CompetitiveMatch::count());

        $a->rankedQueueEntries()->update(['joined_at'=>now()->subMinutes(4)]);
        $b->rankedQueueEntries()->update(['joined_at'=>now()->subMinutes(4)]);
        $service->tick();
        $this->assertSame(1,CompetitiveMatch::count());
    }

    public function test_incompatible_oldest_queue_entry_does_not_block_a_fair_pair_behind_it(): void
    {
        $game=$this->game('basra',2,false); $oldest=$this->player('r12_hol_oldest'); $a=$this->player('r12_hol_a'); $b=$this->player('r12_hol_b');
        $season=app(CompetitiveSeasonService::class)->activeSeason();
        app(CompetitiveSeasonService::class)->ratingFor($oldest,$season,$game->id,$game->key)->update(['rating'=>1000]);
        app(CompetitiveSeasonService::class)->ratingFor($a,$season,$game->id,$game->key)->update(['rating'=>1500]);
        app(CompetitiveSeasonService::class)->ratingFor($b,$season,$game->id,$game->key)->update(['rating'=>1510]);
        $service=app(CompetitiveMatchmakingService::class);
        $service->join($oldest,$game->key,2,'levant'); $service->join($a,$game->key,2,'levant'); $service->join($b,$game->key,2,'levant');

        $match=CompetitiveMatch::firstOrFail();
        $this->assertEqualsCanonicalizing([$a->id,$b->id],$match->participant_ids);
        $this->assertDatabaseHas('ranked_queue_entries',['user_id'=>$oldest->id,'status'=>'waiting']);
    }

    public function test_competitive_room_rejects_every_non_matched_player(): void
    {
        [, $room, $a]=$this->rankedMatch(); $outsider=$this->player('r12_outsider');
        $outsideToken=$outsider->createToken('outside')->plainTextToken;
        $this->withToken($outsideToken)->postJson('/api/mobile/v1/games/session/'.$room->code.'/join')->assertForbidden();
        $this->withToken($outsideToken)->getJson('/api/mobile/v1/games/session/'.$room->code)->assertForbidden();
        $this->actingAs($outsider)->get('/room/'.$room->code)->assertForbidden();
        $officialToken=$a->createToken('official')->plainTextToken;
        $this->withToken($officialToken)->postJson('/api/mobile/v1/games/session/'.$room->code.'/join')->assertOk();
        $this->withToken($officialToken)->postJson('/api/mobile/v1/games/session/'.$room->code.'/leave')->assertOk();
        $this->assertDatabaseHas('room_players',['room_id'=>$room->id,'user_id'=>$a->id,'is_bot'=>false,'connected'=>false]);
        $this->assertContains($a->id,array_map('intval',(array)data_get($room->fresh()->state,'competitive_abandons',[])));
        $this->withToken($officialToken)->postJson('/api/mobile/v1/games/session/'.$room->code.'/join')->assertOk();
        $this->assertDatabaseHas('room_players',['room_id'=>$room->id,'user_id'=>$a->id,'is_bot'=>false,'connected'=>true]);
    }

    public function test_rating_result_is_idempotent_and_writes_both_scopes(): void
    {
        [$match,$room,$a,$b]=$this->rankedMatch();
        $state=$room->state; $state['phase']='finished'; $state['winner']='user:'.$a->id; $state['score']=['user:'.$a->id=>1,'user:'.$b->id=>0];
        $room->update(['state'=>$state,'status'=>'finished','finished_at'=>now()]);

        $first=app(CompetitiveRatingService::class)->processRoom($room->fresh());
        $second=app(CompetitiveRatingService::class)->processRoom($room->fresh());

        $this->assertTrue($first['ok']); $this->assertFalse($first['duplicate']);
        $this->assertTrue($second['duplicate']);
        $this->assertSame(4,CompetitiveRatingEvent::where('competitive_match_id',$match->id)->count());
        $this->assertSame(2,CompetitiveRating::where('user_id',$a->id)->count());
        $this->assertGreaterThan(1000,CompetitiveRating::where('user_id',$a->id)->where('scope_key','overall')->value('rating'));
        $this->assertLessThan(1000,CompetitiveRating::where('user_id',$b->id)->where('scope_key','overall')->value('rating'));
    }

    public function test_severe_anti_cheat_event_holds_rating_until_admin_approval(): void
    {
        [$match,$room,$a]=$this->rankedMatch();
        $state=$room->state; $state['phase']='finished'; $state['winner']='user:'.$a->id;
        $room->update(['state'=>$state,'status'=>'finished','finished_at'=>now()]);
        AntiCheatEvent::create(['room_id'=>$room->id,'user_id'=>$a->id,'event'=>'impossible_state_transition','severity'=>5,'meta'=>['r12'=>true],'ip'=>'127.0.0.1']);

        $held=app(CompetitiveRatingService::class)->processRoom($room->fresh());
        $this->assertTrue($held['review']);
        $this->assertSame('review',$match->fresh()->status);
        $this->assertSame(0,CompetitiveRatingEvent::count());

        $approved=app(CompetitiveRatingService::class)->processRoom($room->fresh(),true);
        $this->assertTrue($approved['ok']);
        $this->assertSame('approved',$match->fresh()->anti_cheat_status);
        $this->assertSame(4,CompetitiveRatingEvent::count());
    }

    public function test_two_round_bracket_advances_and_pays_only_after_final(): void
    {
        $admin=$this->player('Adnan',true); $game=$this->game('basra',2,false);
        $season=app(CompetitiveSeasonService::class)->activeSeason();
        $players=collect(range(1,4))->map(fn($i)=>$this->player('r12_cup_'.$i));
        $tournament=Tournament::create([
            'creator_id'=>$admin->id,'season_id'=>$season->id,'game_id'=>$game->id,'key'=>'r12_test_cup',
            'name'=>['ar'=>'كأس الاختبار','en'=>'Test Cup'],'description'=>['ar'=>'اختبار','en'=>'Test'],
            'stages'=>2,'rounds'=>2,'seats_per_match'=>2,'max_players'=>4,'entry_fee'=>0,'prize_pool'=>1000,
            'status'=>'open','format'=>'single_elimination','scope'=>'global','starts_at'=>now(),
            'auto_accept'=>true,'random_seating'=>false,'chat_enabled'=>true,'turn_seconds'=>10,
            'bracket'=>['messages'=>[]],'competitive_rules'=>['server_authoritative'=>true],
        ]);
        foreach($players as $index=>$user) TournamentEntry::create(['tournament_id'=>$tournament->id,'user_id'=>$user->id,'status'=>'registered','entry_mode'=>'free','paid_tokens'=>0,'seed'=>$index+1]);

        $built=app(TournamentBracketService::class)->build($tournament);
        $this->assertCount(2,$built['rooms']);
        $this->assertSame([$players[0]->id,$players[3]->id,$players[1]->id,$players[2]->id],data_get($built,'bracket.seeded_user_ids'));
        $this->assertSame('registration_seed',data_get($built,'bracket.qualification.source'));
        $this->assertNull(data_get($tournament->fresh()->bracket,'settlement.paid_at'));
        foreach($built['rooms'] as $room) $this->finishRoom($room);

        $afterSemi=$tournament->fresh();
        $this->assertSame('running',$afterSemi->status);
        $this->assertSame(2,(int)$afterSemi->current_round);
        $this->assertNull(data_get($afterSemi->bracket,'settlement.paid_at'));
        $finalRoom=$afterSemi->competitiveMatches()->where('status','active')->latest()->firstOrFail()->room;
        $winner=$this->finishRoom($finalRoom);

        $finished=$tournament->fresh();
        $this->assertSame('finished',$finished->status);
        $this->assertNotNull(data_get($finished->bracket,'settlement.paid_at'));
        $this->assertSame(1000,(int)data_get($finished->bracket,'settlement.prize'));
        $this->assertSame(1000,(int)User::findOrFail($winner)->wallet()->value('tokens'));
    }

    public function test_mobile_registration_supports_an_admin_created_custom_championship_key(): void
    {
        $admin=$this->player('r12_custom_admin',true); $player=$this->player('r12_custom_player');
        $game=$this->game('basra',2,false); $season=app(CompetitiveSeasonService::class)->activeSeason();
        $tournament=Tournament::create([
            'creator_id'=>$admin->id,'season_id'=>$season->id,'game_id'=>$game->id,'key'=>'custom_world_final',
            'name'=>['ar'=>'نهائي عالمي','en'=>'World Final'],'description'=>['ar'=>'مخصص','en'=>'Custom'],
            'stages'=>1,'rounds'=>1,'seats_per_match'=>2,'max_players'=>2,'entry_fee'=>0,'prize_pool'=>0,
            'status'=>'open','format'=>'single_elimination','scope'=>'global','starts_at'=>now()->addHour(),
            'registration_closes_at'=>now()->addMinutes(45),'auto_accept'=>true,'random_seating'=>false,
            'chat_enabled'=>true,'turn_seconds'=>10,'bracket'=>['messages'=>[]],
        ]);

        CompetitionTicket::create(['user_id'=>$player->id,'denomination'=>500,'quantity'=>1,'total_used'=>0]);
        $result=app(CompetitionService::class)->join($player,$tournament->key,0);
        $this->assertSame($tournament->id,$result['tournament']->id);
        $this->assertSame('free',$result['entry_mode']);
        $this->assertDatabaseHas('tournament_entries',['tournament_id'=>$tournament->id,'user_id'=>$player->id]);
        $this->assertDatabaseHas('competition_tickets',['user_id'=>$player->id,'denomination'=>500,'quantity'=>1,'total_used'=>0]);
    }

    public function test_three_player_two_stage_bracket_uses_nine_entrants_and_finishes_cleanly(): void
    {
        $admin=$this->player('Adnan',true); $game=$this->game('hand',4,false);
        $season=app(CompetitiveSeasonService::class)->activeSeason();
        $players=collect(range(1,9))->map(fn($i)=>$this->player('r12_three_seat_'.$i));
        $tournament=Tournament::create([
            'creator_id'=>$admin->id,'season_id'=>$season->id,'game_id'=>$game->id,'key'=>'r12_three_seat_cup',
            'name'=>['ar'=>'كأس ثلاثي','en'=>'Three-seat Cup'],'description'=>['ar'=>'اختبار','en'=>'Test'],
            'stages'=>2,'rounds'=>2,'seats_per_match'=>3,'max_players'=>9,'entry_fee'=>0,'prize_pool'=>0,
            'status'=>'open','format'=>'single_elimination','scope'=>'global','starts_at'=>now(),
            'auto_accept'=>true,'random_seating'=>false,'chat_enabled'=>true,'turn_seconds'=>10,
            'bracket'=>['messages'=>[]],'competitive_rules'=>['server_authoritative'=>true],
        ]);
        foreach($players as $index=>$user) TournamentEntry::create(['tournament_id'=>$tournament->id,'user_id'=>$user->id,'status'=>'registered','entry_mode'=>'free','paid_tokens'=>0,'seed'=>$index+1]);

        $built=app(TournamentBracketService::class)->build($tournament);
        $this->assertCount(3,$built['rooms']);
        foreach($built['rooms'] as $room) $this->finishRoom($room);
        $final=$tournament->competitiveMatches()->where('status','active')->latest()->firstOrFail()->room;
        $this->assertCount(3,$final->players);
        $winner=$this->finishRoom($final);
        $this->assertSame([$winner],data_get($tournament->fresh()->bracket,'champion_user_ids'));
        $this->assertSame('finished',$tournament->fresh()->status);
    }

    public function test_solo_four_seat_final_crowns_and_pays_exactly_one_champion(): void
    {
        $admin=$this->player('Adnan',true); $game=$this->game('trix',4,false);
        $season=app(CompetitiveSeasonService::class)->activeSeason();
        $players=collect(range(1,4))->map(fn($i)=>$this->player('r12_solo_'.$i));
        $tournament=Tournament::create([
            'creator_id'=>$admin->id,'season_id'=>$season->id,'game_id'=>$game->id,'key'=>'r12_solo_final',
            'name'=>['ar'=>'نهائي فردي','en'=>'Solo Final'],'description'=>['ar'=>'اختبار','en'=>'Test'],
            'stages'=>1,'rounds'=>1,'seats_per_match'=>4,'max_players'=>4,'entry_fee'=>0,'prize_pool'=>400,
            'status'=>'open','format'=>'single_elimination','scope'=>'global','starts_at'=>now(),
            'auto_accept'=>true,'random_seating'=>false,'chat_enabled'=>true,'turn_seconds'=>10,
            'bracket'=>['messages'=>[]],'competitive_rules'=>['server_authoritative'=>true],
        ]);
        foreach($players as $index=>$user) TournamentEntry::create(['tournament_id'=>$tournament->id,'user_id'=>$user->id,'status'=>'registered','entry_mode'=>'free','paid_tokens'=>0,'seed'=>$index+1]);

        $built=app(TournamentBracketService::class)->build($tournament);
        $winner=$this->finishRoom($built['rooms'][0]);
        $finished=$tournament->fresh();
        $this->assertSame([$winner],data_get($finished->bracket,'champion_user_ids'));
        $this->assertSame($winner,(int)$finished->champion_user_id);
        $this->assertSame(400,(int)User::findOrFail($winner)->wallet()->value('tokens'));
        $this->assertSame(0,$players->where('id','!=',$winner)->sum(fn($user)=>(int)$user->fresh()->wallet()->value('tokens')));
    }

    public function test_voided_tournament_match_is_replaced_without_reusing_its_room(): void
    {
        $admin=$this->player('r12_integrity_admin',true); $game=$this->game('basra',2,false);
        $season=app(CompetitiveSeasonService::class)->activeSeason(); $a=$this->player('r12_rematch_a'); $b=$this->player('r12_rematch_b');
        $tournament=Tournament::create([
            'creator_id'=>$admin->id,'season_id'=>$season->id,'game_id'=>$game->id,'key'=>'r12_integrity_rematch',
            'name'=>['ar'=>'إعادة نزاهة','en'=>'Integrity Rematch'],'description'=>['ar'=>'اختبار','en'=>'Test'],
            'stages'=>1,'rounds'=>1,'seats_per_match'=>2,'max_players'=>2,'entry_fee'=>0,'prize_pool'=>0,
            'status'=>'open','format'=>'single_elimination','scope'=>'global','starts_at'=>now(),
            'auto_accept'=>true,'random_seating'=>false,'chat_enabled'=>true,'turn_seconds'=>10,'bracket'=>['messages'=>[]],
        ]);
        foreach([$a,$b] as $index=>$user) TournamentEntry::create(['tournament_id'=>$tournament->id,'user_id'=>$user->id,'status'=>'registered','entry_mode'=>'free','paid_tokens'=>0,'seed'=>$index+1]);
        $built=app(TournamentBracketService::class)->build($tournament); $room=$built['rooms'][0]; $oldMatch=$room->competitiveMatch()->firstOrFail();
        $state=$room->state; $state['phase']='finished'; $state['winner']='user:'.$a->id;
        $room->update(['state'=>$state,'status'=>'finished','finished_at'=>now()]);
        AntiCheatEvent::create(['room_id'=>$room->id,'user_id'=>$a->id,'event'=>'integrity_rematch_test','severity'=>5,'meta'=>[],'ip'=>'127.0.0.1']);
        $this->assertTrue(app(CompetitiveRatingService::class)->processRoom($room->fresh())['review']);

        $result=app(CompetitiveRatingService::class)->voidMatch($oldMatch->fresh(),'Verified integrity void',$admin->id);
        $this->assertTrue((bool)data_get($result,'rematch.ok'));
        $this->assertSame('voided',$oldMatch->fresh()->status);
        $this->assertSame('closed',$room->fresh()->status);
        $replacement=$tournament->competitiveMatches()->where('status','active')->firstOrFail();
        $this->assertNotSame($room->id,$replacement->room_id);
        $this->assertSame($replacement->id,(int)data_get($tournament->fresh()->bracket,'rounds.0.matches.0.competitive_match_id'));
    }

    public function test_drawn_tournament_match_awards_draw_mmr_then_issues_a_tiebreak_rematch(): void
    {
        $admin=$this->player('r12_draw_admin',true); $game=$this->game('basra',2,false);
        $season=app(CompetitiveSeasonService::class)->activeSeason(); $a=$this->player('r12_draw_a'); $b=$this->player('r12_draw_b');
        $tournament=Tournament::create([
            'creator_id'=>$admin->id,'season_id'=>$season->id,'game_id'=>$game->id,'key'=>'r12_draw_rematch',
            'name'=>['ar'=>'حسم التعادل','en'=>'Draw Tiebreak'],'description'=>['ar'=>'اختبار','en'=>'Test'],
            'stages'=>1,'rounds'=>1,'seats_per_match'=>2,'max_players'=>2,'entry_fee'=>0,'prize_pool'=>0,
            'status'=>'open','format'=>'single_elimination','scope'=>'global','starts_at'=>now(),
            'auto_accept'=>true,'random_seating'=>false,'chat_enabled'=>true,'turn_seconds'=>10,'bracket'=>['messages'=>[]],
        ]);
        foreach([$a,$b] as $index=>$user) TournamentEntry::create(['tournament_id'=>$tournament->id,'user_id'=>$user->id,'status'=>'registered','entry_mode'=>'free','paid_tokens'=>0,'seed'=>$index+1]);
        $built=app(TournamentBracketService::class)->build($tournament); $room=$built['rooms'][0]; $drawn=$room->competitiveMatch()->firstOrFail();
        $state=$room->state; $state['phase']='finished'; $state['winner']=null; $state['draw_reason']='server_draw';
        $room->update(['state'=>$state,'status'=>'finished','finished_at'=>now()]);

        $result=app(CompetitiveRatingService::class)->processRoom($room->fresh());
        $this->assertTrue($result['ok']);
        $this->assertSame(4,CompetitiveRatingEvent::where('competitive_match_id',$drawn->id)->where('result','draw')->count());
        $this->assertSame('closed',$room->fresh()->status);
        $replacement=$tournament->competitiveMatches()->where('status','active')->firstOrFail();
        $this->assertNotSame($drawn->id,$replacement->id);
        $this->assertSame($replacement->id,(int)data_get($tournament->fresh()->bracket,'rounds.0.matches.0.competitive_match_id'));
        $this->assertSame($drawn->id,(int)data_get($tournament->fresh()->bracket,'rounds.0.matches.0.draw_history.0.competitive_match_id'));
    }

    public function test_duplicate_final_advancement_recovers_a_deferred_settlement(): void
    {
        $admin=$this->player('Adnan',true); $game=$this->game('basra',2,false);
        $season=app(CompetitiveSeasonService::class)->activeSeason(); $a=$this->player('r12_recover_a'); $b=$this->player('r12_recover_b');
        $tournament=Tournament::create([
            'creator_id'=>$admin->id,'season_id'=>$season->id,'game_id'=>$game->id,'key'=>'r12_recover_final',
            'name'=>['ar'=>'استرداد النهائي','en'=>'Final Recovery'],'description'=>['ar'=>'اختبار','en'=>'Test'],
            'stages'=>1,'rounds'=>1,'seats_per_match'=>2,'max_players'=>2,'entry_fee'=>0,'prize_pool'=>0,
            'status'=>'open','format'=>'single_elimination','scope'=>'global','starts_at'=>now(),
            'auto_accept'=>true,'random_seating'=>false,'chat_enabled'=>true,'turn_seconds'=>10,'bracket'=>['messages'=>[]],
        ]);
        foreach([$a,$b] as $index=>$user) TournamentEntry::create(['tournament_id'=>$tournament->id,'user_id'=>$user->id,'status'=>'registered','entry_mode'=>'free','paid_tokens'=>0,'seed'=>$index+1]);
        $built=app(TournamentBracketService::class)->build($tournament); $match=CompetitiveMatch::firstOrFail();
        $bracket=$tournament->fresh()->bracket; $bracket['rounds'][0]['matches'][0]['status']='completed';
        $bracket['rounds'][0]['matches'][0]['winner_user_ids']=[$a->id]; $bracket['champion_user_ids']=[$a->id];
        $bracket['status']='completed'; $bracket['settlement_ready']=true;
        $tournament->update(['status'=>'running','bracket'=>$bracket,'champion_user_id'=>$a->id]);
        $match->update(['status'=>'completed','rating_processed'=>true,'result'=>['winner_user_ids'=>[$a->id],'ranking'=>[$a->id,$b->id]],'finished_at'=>now()]);

        $recovered=app(TournamentBracketService::class)->advanceFromMatch($match->fresh(),(array)$match->result);
        $this->assertTrue($recovered['duplicate']); $this->assertTrue($recovered['final']);
        $this->assertTrue((bool)data_get($recovered,'settlement.ok'));
        $this->assertSame('finished',$tournament->fresh()->status);
        $this->assertNotNull(data_get($tournament->fresh()->bracket,'settlement.paid_at'));
    }

    public function test_finalized_season_reward_is_atomic_and_claimable_once(): void
    {
        $user=$this->player('r12_reward'); $novice=$this->player('r12_unplaced'); $season=app(CompetitiveSeasonService::class)->activeSeason();
        $rating=app(CompetitiveSeasonService::class)->ratingFor($user,$season); $rating->update(['rating'=>1510,'games_played'=>20,'wins'=>12,'placement_complete'=>true]);
        app(CompetitiveSeasonService::class)->ratingFor($novice,$season);
        app(CompetitiveSeasonService::class)->finalize($season);
        $claim=SeasonRewardClaim::where('user_id',$user->id)->firstOrFail();
        $this->assertDatabaseMissing('season_reward_claims',['user_id'=>$novice->id]);
        $before=(int)$user->wallet()->value('tokens');
        $first=app(CompetitiveSeasonService::class)->claimReward($user,$claim->id);
        $second=app(CompetitiveSeasonService::class)->claimReward($user,$claim->id);
        $this->assertFalse($first['duplicate']); $this->assertTrue($second['duplicate']);
        $this->assertSame($before+(int)$claim->reward_tokens,(int)$user->wallet()->value('tokens'));
        $this->assertSame('season_diamond',$user->profile()->value('badge'));
    }

    public function test_admin_competitive_requires_explicit_permission(): void
    {
        $admin=$this->player('r12_moderator',true); $admin->update(['admin_permissions'=>[]]);
        $token=$admin->createToken('r12-admin')->plainTextToken;
        $this->withToken($token)->getJson('/api/mobile/v1/admin/competitive')->assertForbidden();
        $admin->update(['admin_permissions'=>['competitive'=>true]]);
        $this->withToken($token)->getJson('/api/mobile/v1/admin/competitive')->assertOk()->assertJsonPath('release.build',240);
    }

    public function test_admin_can_create_an_immediately_active_season_and_finalize_the_previous_one(): void
    {
        $previous=app(CompetitiveSeasonService::class)->activeSeason();
        $admin=$this->player('r12_season_admin',true); $admin->update(['admin_permissions'=>['competitive'=>true]]);
        $token=$admin->createToken('r12-season-admin')->plainTextToken;
        $this->withToken($token)->postJson('/api/mobile/v1/admin/competitive/seasons',[
            'key'=>'r12_live_successor','name_ar'=>'الموسم التالي','name_en'=>'Successor Season',
            'starts_at'=>now()->subMinute()->toIso8601String(),'ends_at'=>now()->addMonth()->toIso8601String(),
            'placement_games'=>10,'rating_soft_reset_factor'=>.75,
        ])->assertOk()->assertJsonPath('season.status','active');
        $this->assertSame('completed',$previous->fresh()->status);
        $this->assertNotNull($previous->fresh()->finalized_at);
    }

    /** @return array{0:CompetitiveMatch,1:Room,2:User,3:User} */
    private function rankedMatch(): array
    {
        $game=$this->game('basra',2,false); $a=$this->player('r12_a_'.Str::lower(Str::random(4))); $b=$this->player('r12_b_'.Str::lower(Str::random(4)));
        $service=app(CompetitiveMatchmakingService::class); $service->join($a,$game->key,2,'levant'); $service->join($b,$game->key,2,'levant');
        $match=CompetitiveMatch::with('room')->latest()->firstOrFail(); return [$match,$match->room,$a,$b];
    }

    private function finishRoom(Room $room): int
    {
        $match=$room->competitiveMatch()->firstOrFail(); $winner=(int)$match->participant_ids[0];
        $state=$room->state; $state['phase']='finished'; $state['winner']='user:'.$winner;
        $state['score']=collect($match->participant_ids)->mapWithKeys(fn($id)=>['user:'.$id=>(int)$id===$winner?1:0])->all();
        $room->update(['state'=>$state,'status'=>'finished','finished_at'=>now()]);
        $result=app(CompetitiveRatingService::class)->processRoom($room->fresh()); $this->assertTrue($result['ok']);
        return $winner;
    }

    private function game(string $key,int $max,bool $partnership): Game
    {
        return Game::firstOrCreate(['key'=>$key],['name'=>['ar'=>'لعبة R12','en'=>'R12 Game'],'min_players'=>2,'max_players'=>$max,'partnership'=>$partnership,'rules'=>[],'active'=>true]);
    }

    private function player(string $username,bool $admin=false): User
    {
        $role=$admin ? (Str::lower($username)==='adnan' ? 'primary_admin' : 'delegated_admin') : null;
        $user=User::factory()->create(['username'=>$username,'is_admin'=>$admin,'admin_role'=>$role]);
        $user->profile()->create(['display_name'=>$username,'country_code'=>'PS','country_name'=>'فلسطين','level'=>20,'xp'=>0]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>0,'gems'=>0]);
        return $user->fresh(['profile','wallet']);
    }
}
