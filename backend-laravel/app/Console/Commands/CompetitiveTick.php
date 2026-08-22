<?php

namespace App\Console\Commands;

use App\Models\{CompetitiveMatch, CompetitiveSeason};
use App\Services\Competitive\{CompetitiveMatchmakingService, CompetitiveRatingService, CompetitiveSeasonService, TournamentBracketService};
use Illuminate\Console\Command;
use Illuminate\Support\Facades\{Cache, Schema};

class CompetitiveTick extends Command
{
    protected $signature = 'warqna:competitive-tick {--dry-run : Report pending work without changing it}';
    protected $description = 'Run R12 season lifecycle, Ranked matchmaking, result recovery, rewards, and leaderboard snapshots.';

    public function handle(CompetitiveSeasonService $seasons, CompetitiveMatchmakingService $matchmaking, CompetitiveRatingService $ratings, TournamentBracketService $brackets): int
    {
        foreach (['competitive_seasons','competitive_ratings','ranked_queue_entries','competitive_matches'] as $table) {
            if (!Schema::hasTable($table)) { $this->warn("Competitive tick skipped until {$table} is migrated."); return self::SUCCESS; }
        }
        $pending = [
            'waiting_queue'=>\App\Models\RankedQueueEntry::where('status','waiting')->count(),
            'finished_unprocessed'=>CompetitiveMatch::where('rating_processed',false)->whereHas('room',fn ($q)=>$q->where('status','finished'))->count(),
            'brackets_recoverable'=>CompetitiveMatch::where('rating_processed',true)->whereNotNull('tournament_id')->whereHas('tournament',fn($q)=>$q->whereIn('status',['open','running']))->get()->filter(fn($match)=>empty(((array)$match->meta)['bracket_advanced_at']))->count(),
            'seasons_due'=>CompetitiveSeason::where('status','active')->where('ends_at','<=',now())->count(),
        ];
        if($this->option('dry-run')) { $this->line(json_encode($pending,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES)); return self::SUCCESS; }

        $errors=[];
        try {
            $lifecycle=$seasons->lifecycleTick();
        } catch (\Throwable $error) {
            report($error);
            $lifecycle=['error'=>true];
            $errors[]='season_lifecycle';
        }
        try {
            $queue=$matchmaking->tick();
        } catch (\Throwable $error) {
            report($error);
            $queue=['error'=>true];
            $errors[]='ranked_queue';
        }
        $processed=0; $reviews=0;
        CompetitiveMatch::with('room')->where('rating_processed',false)->whereNotIn('status',['voided','cancelled'])->whereHas('room',fn ($q)=>$q->where('status','finished'))->limit(100)->get()->each(function ($match) use ($ratings,&$processed,&$reviews,&$errors) {
            if(!$match->room) return;
            try {
                $result=$ratings->processRoom($match->room);
                if(!empty($result['ok'])) $processed++; elseif(!empty($result['review'])) $reviews++;
            } catch (\Throwable $error) {
                report($error);
                $errors[]='rating_match:'.$match->id;
            }
        });
        $bracketsRecovered=0;
        CompetitiveMatch::with(['room','tournament'])->where('rating_processed',true)->whereNotNull('tournament_id')
            ->whereHas('tournament',fn($q)=>$q->whereIn('status',['open','running']))->latest('finished_at')->limit(100)->get()
            ->each(function($match) use($brackets,&$bracketsRecovered,&$errors){
                if(!empty(((array)$match->meta)['bracket_advanced_at'])) return;
                try{
                    $result=$brackets->advanceFromMatch($match,(array)$match->result);
                    if(!empty($result['ok'])){
                        $match->update(['meta'=>array_merge((array)$match->meta,['bracket_advanced_at'=>now()->toIso8601String(),'bracket_recovered'=>true])]);
                        if(empty($result['duplicate'])) $bracketsRecovered++;
                    }
                }catch(\Throwable $error){
                    report($error);
                    $errors[]='bracket_match:'.$match->id;
                }
            });
        $snapshot=0;
        try {
            $active=$seasons->activeSeason(false);
            if($active && Cache::add('warqna:r12:standing-snapshot:'.$active->id,true,now()->addMinutes(55))) $snapshot=$seasons->captureStandings($active);
        } catch (\Throwable $error) {
            report($error);
            $errors[]='standing_snapshot';
        }
        $summary=['lifecycle'=>$lifecycle,'queue'=>$queue,'processed'=>$processed,'reviews'=>$reviews,'brackets_recovered'=>$bracketsRecovered,'snapshots'=>$snapshot,'errors'=>count($errors),'error_refs'=>array_slice($errors,0,20)];
        if($errors) {
            $this->error('R12 tick completed with isolated errors: '.json_encode($summary,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES));
            return self::FAILURE;
        }
        $this->info('R12 tick complete: '.json_encode($summary,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES));
        return self::SUCCESS;
    }
}
