<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SeasonRewardClaim extends Model
{
    protected $fillable = ['season_id', 'user_id', 'tier_key', 'final_rating', 'reward_tokens', 'reward_xp', 'status', 'reward_payload', 'claimed_at'];
    protected $casts = ['reward_payload' => 'array', 'claimed_at' => 'datetime'];

    public function season() { return $this->belongsTo(CompetitiveSeason::class, 'season_id'); }
    public function user() { return $this->belongsTo(User::class); }
}
