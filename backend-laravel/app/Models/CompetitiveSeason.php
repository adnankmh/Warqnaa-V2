<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CompetitiveSeason extends Model
{
    protected $fillable = ['key', 'name', 'description', 'status', 'starts_at', 'ends_at', 'rating_soft_reset_factor', 'placement_games', 'rules', 'reward_tiers', 'created_by', 'finalized_at'];
    protected $casts = ['name' => 'array', 'description' => 'array', 'rules' => 'array', 'reward_tiers' => 'array', 'starts_at' => 'datetime', 'ends_at' => 'datetime', 'finalized_at' => 'datetime', 'rating_soft_reset_factor' => 'float'];

    public function creator() { return $this->belongsTo(User::class, 'created_by'); }
    public function ratings() { return $this->hasMany(CompetitiveRating::class, 'season_id'); }
    public function matches() { return $this->hasMany(CompetitiveMatch::class, 'season_id'); }
    public function rewardClaims() { return $this->hasMany(SeasonRewardClaim::class, 'season_id'); }
}
