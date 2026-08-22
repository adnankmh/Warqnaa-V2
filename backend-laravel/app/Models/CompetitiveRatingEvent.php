<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CompetitiveRatingEvent extends Model
{
    protected $fillable = ['competitive_match_id', 'competitive_rating_id', 'user_id', 'scope_key', 'rating_before', 'rating_after', 'rating_delta', 'result', 'expected_score', 'k_factor', 'reason', 'meta'];
    protected $casts = ['expected_score' => 'float', 'meta' => 'array'];

    public function match() { return $this->belongsTo(CompetitiveMatch::class, 'competitive_match_id'); }
    public function rating() { return $this->belongsTo(CompetitiveRating::class, 'competitive_rating_id'); }
    public function user() { return $this->belongsTo(User::class); }
}
