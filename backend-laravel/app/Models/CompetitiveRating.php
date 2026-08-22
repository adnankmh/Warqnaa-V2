<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CompetitiveRating extends Model
{
    protected $fillable = ['season_id', 'user_id', 'game_id', 'scope_key', 'rating', 'peak_rating', 'games_played', 'wins', 'losses', 'draws', 'streak', 'best_streak', 'provisional_games', 'placement_complete', 'abandons', 'clean_games', 'last_match_at', 'meta'];
    protected $casts = ['placement_complete' => 'boolean', 'last_match_at' => 'datetime', 'meta' => 'array'];

    public function season() { return $this->belongsTo(CompetitiveSeason::class, 'season_id'); }
    public function user() { return $this->belongsTo(User::class); }
    public function game() { return $this->belongsTo(Game::class); }
    public function events() { return $this->hasMany(CompetitiveRatingEvent::class); }
}
