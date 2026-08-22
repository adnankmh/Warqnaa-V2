<?php

namespace App\Services\Competitive;

use App\Models\{ClubMember, CompetitiveRating, CompetitiveSeason, CompetitiveStandingSnapshot, SeasonRewardClaim, SiteSetting, User};
use App\Services\Leveling\XpService;
use App\Services\Wallet\WalletService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\{DB, Schema};
use RuntimeException;

class CompetitiveSeasonService
{
    public function __construct(
        private readonly WalletService $wallet,
        private readonly XpService $xp,
    ) {}

    public function activeSeason(bool $required = true): ?CompetitiveSeason
    {
        $season = CompetitiveSeason::query()
            ->where('status', 'active')
            ->where('starts_at', '<=', now())
            ->where('ends_at', '>', now())
            ->orderByDesc('starts_at')
            ->first();
        if (!$season) {
            foreach(CompetitiveSeason::where('status','active')->where('ends_at','<=',now())->get() as $expired) $this->finalize($expired);
            $season=DB::transaction(function(){
                // Lock one stable season row so concurrent API/scheduler calls
                // cannot activate two scheduled seasons at the boundary.
                CompetitiveSeason::query()->orderBy('id')->lockForUpdate()->first();
                $active=CompetitiveSeason::query()->where('status','active')->where('starts_at','<=',now())->where('ends_at','>',now())->orderByDesc('starts_at')->first();
                if($active) return $active;
                $scheduled=CompetitiveSeason::query()->where('status','scheduled')->where('starts_at','<=',now())->where('ends_at','>',now())->orderBy('starts_at')->lockForUpdate()->first();
                if(!$scheduled) return null;
                $scheduled->update(['status'=>'active']);
                return $scheduled->fresh();
            });
        }
        if ($required && !$season) throw new RuntimeException('لا يوجد موسم تنافسي نشط حالياً.');
        return $season;
    }

    /** @return array<string,mixed> */
    public function tierFor(int $rating): array
    {
        $tiers = collect(config('warqna_competitive.tiers', []))->sortBy('min')->values();
        return (array)($tiers->last(fn ($tier) => $rating >= (int)($tier['min'] ?? 0))
            ?? ['key'=>'bronze','ar'=>'برونزي','en'=>'Bronze','min'=>0,'color'=>'#B7794B','icon'=>'◆']);
    }

    public function ratingFor(User $user, CompetitiveSeason $season, ?int $gameId = null, ?string $gameKey = null): CompetitiveRating
    {
        $scopeKey = $gameId ? 'game:'.($gameKey ?: $gameId) : 'overall';
        $existing = CompetitiveRating::query()
            ->where('season_id', $season->id)->where('user_id', $user->id)->where('scope_key', $scopeKey)->first();
        if ($existing) return $existing;

        $initial = (int) config('warqna_competitive.initial_rating', 1000);
        $previous = CompetitiveRating::query()
            ->where('user_id', $user->id)->where('scope_key', $scopeKey)
            ->where('season_id', '!=', $season->id)->latest('season_id')->first();
        if ($previous) {
            $factor = max(0.0, min(1.0, (float)$season->rating_soft_reset_factor));
            $initial = (int)round(1000 + (((int)$previous->rating - 1000) * $factor));
        }
        return CompetitiveRating::firstOrCreate(
            ['season_id'=>$season->id,'user_id'=>$user->id,'scope_key'=>$scopeKey],
            ['game_id'=>$gameId,'rating'=>$initial,'peak_rating'=>$initial,'meta'=>['source'=>$previous ? 'soft_reset' : 'initial','previous_rating'=>$previous?->rating]]
        );
    }

    /** @return array<string,mixed> */
    public function dashboard(User $user): array
    {
        $season = $this->activeSeason(false);
        if (!$season) return ['enabled'=>false,'release'=>config('warqna_competitive.release'),'season'=>null];
        $overall = $this->ratingFor($user, $season);
        $rank = CompetitiveRating::where('season_id',$season->id)->where('scope_key','overall')->where('rating','>',$overall->rating)->count() + 1;
        $queue = $user->rankedQueueEntries()->whereIn('status',['waiting','matching','matched'])->latest()->first();
        $gameRatings = $user->competitiveRatings()->with('game')->where('season_id',$season->id)->whereNotNull('game_id')->orderByDesc('rating')->get();
        $rewards = $user->seasonRewardClaims()->with('season')->whereIn('status',['pending','claimed'])->latest()->limit(12)->get();
        $featured = \App\Models\Tournament::query()->with('game')->whereIn('status',['open','running'])->where(function ($q) use ($season) {
            $q->whereNull('season_id')->orWhere('season_id',$season->id);
        })->orderByDesc('featured')->orderBy('starts_at')->limit(8)->get();

        return [
            'enabled'=>(bool)SiteSetting::getValue('competitive_enabled', true),
            'release'=>config('warqna_competitive.release'),
            'season'=>$this->seasonPayload($season),
            'rating'=>$this->ratingPayload($overall) + ['rank'=>$rank],
            'game_ratings'=>$gameRatings->map(fn ($rating) => $this->ratingPayload($rating) + ['game'=>$rating->game?->key,'game_name'=>$rating->game?->name])->values(),
            'queue'=>$queue ? $this->queuePayload($queue) : null,
            'pending_rewards'=>$rewards->where('status','pending')->count(),
            'rewards'=>$rewards->map(fn ($claim) => [
                'id'=>$claim->id,'season_key'=>$claim->season?->key,'tier'=>$claim->tier_key,
                'final_rating'=>(int)$claim->final_rating,'tokens'=>(int)$claim->reward_tokens,
                'xp'=>(int)$claim->reward_xp,'status'=>$claim->status,'payload'=>$claim->reward_payload,
                'claimed_at'=>$claim->claimed_at?->toIso8601String(),
            ])->values(),
            'tournaments'=>$featured->map(fn ($t) => [
                'id'=>$t->id,'key'=>$t->key,'name'=>$t->name,'game'=>$t->game?->key,'game_name'=>$t->game?->name,
                'format'=>$t->format,'scope'=>$t->scope,'status'=>$t->status,'entry_fee'=>(int)$t->entry_fee,
                'prize_pool'=>(int)$t->prize_pool,'players'=>$t->entries()->count(),'max_players'=>(int)($t->max_players ?: 0),
                'starts_at'=>$t->starts_at?->toIso8601String(),'current_round'=>(int)$t->current_round,
            ])->values(),
            'tiers'=>config('warqna_competitive.tiers', []),
        ];
    }

    /** @return array<string,mixed> */
    public function leaderboard(CompetitiveSeason $season, string $scope = 'overall', ?string $country = null, ?int $clubId = null, int $limit = 100): array
    {
        $query = CompetitiveRating::query()->with(['user.profile','user.clubMembership.club','game'])
            ->where('season_id',$season->id)->where('scope_key',$scope);
        if ($country) $query->whereHas('user.profile', fn ($q) => $q->where('country_code', strtoupper($country)));
        if ($clubId) $query->whereHas('user.clubMembership', fn ($q) => $q->where('club_id',$clubId));
        $ratings = $query->orderByDesc('rating')->orderByDesc('wins')->orderBy('games_played')->limit(max(1,min(200,$limit)))->get();
        return [
            'season'=>$this->seasonPayload($season),'scope'=>$scope,'country'=>$country,'club_id'=>$clubId,
            'rows'=>$ratings->values()->map(fn ($rating,$index) => [
                'rank'=>$index+1,'user_id'=>$rating->user_id,'username'=>$rating->user?->username,
                'display_name'=>$rating->user?->profile?->display_name,'avatar'=>$rating->user?->profile?->avatar,
                'country_code'=>$rating->user?->profile?->country_code,'club'=>$rating->user?->clubMembership?->club?->name,
                'rating'=>(int)$rating->rating,'tier'=>$this->tierFor((int)$rating->rating),
                'games'=>(int)$rating->games_played,'wins'=>(int)$rating->wins,
                'losses'=>(int)$rating->losses,'draws'=>(int)$rating->draws,'streak'=>(int)$rating->streak,
                'provisional'=>!$rating->placement_complete,
            ])->all(),
        ];
    }

    /** @return array<string,mixed> */
    public function claimReward(User $user, int $claimId): array
    {
        abort_unless((bool)SiteSetting::getValue('season_rewards_enabled', true), 503, 'مكافآت الموسم متوقفة مؤقتاً.');
        return DB::transaction(function () use ($user,$claimId) {
            $claim = SeasonRewardClaim::where('user_id',$user->id)->lockForUpdate()->findOrFail($claimId);
            if ($claim->status === 'claimed') return ['ok'=>true,'duplicate'=>true,'claim'=>$claim->fresh()];
            if ($claim->status !== 'pending') throw new RuntimeException('هذه المكافأة غير قابلة للاستلام.');
            $payload = (array)($claim->reward_payload ?: []);
            $profile=$user->profile()->lockForUpdate()->first();
            if(!$profile) $profile=$user->profile()->create(['display_name'=>$user->username,'country_code'=>'PS','country_name'=>country_name('PS')]);
            $user->setRelation('profile',$profile);
            $this->wallet->credit($user,(int)$claim->reward_tokens,'competitive_season_reward',['season_id'=>$claim->season_id,'claim_id'=>$claim->id,'tier'=>$claim->tier_key]);
            $this->xp->award($user,(int)$claim->reward_xp,0,false,false,false);
            if (!empty($payload['badge'])) {
                $profile->badge = (string)$payload['badge'];
                $profile->save();
            }
            $claim->update(['status'=>'claimed','claimed_at'=>now()]);
            return ['ok'=>true,'duplicate'=>false,'claim'=>$claim->fresh(),'wallet_tokens'=>(int)($user->wallet()->value('tokens') ?? 0)];
        });
    }

    /** @return array<string,int> */
    public function lifecycleTick(): array
    {
        $finalized = 0;
        foreach (CompetitiveSeason::where('status','active')->where('ends_at','<=',now())->get() as $season) {
            $this->finalize($season);
            $finalized++;
        }
        $hadActive=CompetitiveSeason::where('status','active')->where('starts_at','<=',now())->where('ends_at','>',now())->exists();
        $current=$this->activeSeason(false);
        $activated=!$hadActive && $current?1:0;
        return ['activated'=>$activated,'finalized'=>$finalized];
    }

    public function activate(CompetitiveSeason $season): CompetitiveSeason
    {
        if ($season->ends_at && $season->ends_at->lte(now())) {
            throw new RuntimeException('لا يمكن تفعيل موسم انتهى موعده.');
        }
        return DB::transaction(function () use ($season) {
            // A stable lock serializes scheduler and Admin activation attempts.
            CompetitiveSeason::query()->orderBy('id')->lockForUpdate()->first();
            $locked=CompetitiveSeason::query()->lockForUpdate()->findOrFail($season->id);
            if($locked->finalized_at || in_array($locked->status,['completed','cancelled'],true)) {
                throw new RuntimeException('لا يمكن تفعيل موسم مغلق.');
            }
            $previous=CompetitiveSeason::query()->where('id','!=',$locked->id)->where('status','active')->lockForUpdate()->get();
            foreach($previous as $active) $this->finalize($active);
            $startsAt=$locked->starts_at && $locked->starts_at->lte(now()) ? $locked->starts_at : now();
            $locked->update(['status'=>'active','starts_at'=>$startsAt]);
            return $locked->fresh();
        });
    }

    public function finalize(CompetitiveSeason $season): CompetitiveSeason
    {
        if ($season->finalized_at) return $season;
        DB::transaction(function () use ($season) {
            $locked = CompetitiveSeason::lockForUpdate()->findOrFail($season->id);
            if ($locked->finalized_at) return;
            $this->captureStandings($locked);
            $rewardTiers = (array)($locked->reward_tiers ?: config('warqna_competitive.season_rewards', []));
            CompetitiveRating::where('season_id',$locked->id)->where('scope_key','overall')->where('placement_complete',true)->orderBy('id')->chunkById(250, function ($ratings) use ($locked,$rewardTiers) {
                foreach ($ratings as $rating) {
                    $tier = $this->tierFor((int)$rating->rating);
                    $reward = (array)($rewardTiers[$tier['key']] ?? []);
                    SeasonRewardClaim::firstOrCreate(
                        ['season_id'=>$locked->id,'user_id'=>$rating->user_id,'tier_key'=>$tier['key']],
                        ['final_rating'=>$rating->rating,'reward_tokens'=>(int)($reward['tokens'] ?? 0),'reward_xp'=>(int)($reward['xp'] ?? 0),'status'=>'pending','reward_payload'=>['badge'=>$reward['badge'] ?? null,'tier'=>$tier,'season_key'=>$locked->key]]
                    );
                }
            });
            $locked->update(['status'=>'completed','finalized_at'=>now()]);
        });
        return $season->fresh();
    }

    public function captureStandings(CompetitiveSeason $season): int
    {
        $capturedAt = now();
        CompetitiveStandingSnapshot::where('season_id',$season->id)->where('captured_at','<',$capturedAt->copy()->subMinutes(5))->delete();
        $count = 0;
        $scopes = CompetitiveRating::where('season_id',$season->id)->distinct()->pluck('scope_key');
        foreach ($scopes as $scope) {
            $rows = CompetitiveRating::with(['user.profile','user.clubMembership'])->where('season_id',$season->id)->where('scope_key',$scope)->orderByDesc('rating')->orderByDesc('wins')->limit(200)->get();
            foreach ($rows as $index=>$rating) {
                CompetitiveStandingSnapshot::create([
                    'season_id'=>$season->id,'game_id'=>$rating->game_id,'user_id'=>$rating->user_id,
                    'club_id'=>$rating->user?->clubMembership?->club_id,'scope_type'=>$scope === 'overall' ? 'global' : 'game',
                    'scope_key'=>$scope,'rank'=>$index+1,'rating'=>$rating->rating,'games_played'=>$rating->games_played,
                    'wins'=>$rating->wins,'payload'=>['tier'=>$this->tierFor((int)$rating->rating),'country_code'=>$rating->user?->profile?->country_code],
                    'captured_at'=>$capturedAt,
                ]);
                $count++;
            }
        }
        return $count;
    }

    /** @return array<string,mixed> */
    public function seasonPayload(CompetitiveSeason $season): array
    {
        return ['id'=>$season->id,'key'=>$season->key,'name'=>$season->name,'description'=>$season->description,'status'=>$season->status,
            'starts_at'=>$season->starts_at?->toIso8601String(),'ends_at'=>$season->ends_at?->toIso8601String(),
            'placement_games'=>(int)$season->placement_games,'remaining_seconds'=>max(0,now()->diffInSeconds($season->ends_at,false)),
            'rules'=>$season->rules,'finalized_at'=>$season->finalized_at?->toIso8601String()];
    }

    /** @return array<string,mixed> */
    public function ratingPayload(CompetitiveRating $rating): array
    {
        return ['id'=>$rating->id,'scope'=>$rating->scope_key,'rating'=>(int)$rating->rating,'peak'=>(int)$rating->peak_rating,
            'tier'=>$this->tierFor((int)$rating->rating),'games'=>(int)$rating->games_played,'wins'=>(int)$rating->wins,
            'losses'=>(int)$rating->losses,'draws'=>(int)$rating->draws,'streak'=>(int)$rating->streak,
            'best_streak'=>(int)$rating->best_streak,'placements_played'=>(int)$rating->provisional_games,
            'placement_complete'=>(bool)$rating->placement_complete,'abandons'=>(int)$rating->abandons];
    }

    /** @return array<string,mixed> */
    private function queuePayload($queue): array
    {
        return ['token'=>$queue->queue_token,'status'=>$queue->status,'game_id'=>$queue->game_id,'game'=>$queue->game?->key,
            'room_code'=>$queue->room?->code,'region'=>$queue->region,'rating'=>(int)$queue->rating_snapshot,
            'search_window'=>(int)$queue->search_window,'joined_at'=>$queue->joined_at?->toIso8601String(),
            'expires_at'=>$queue->expires_at?->toIso8601String()];
    }
}
