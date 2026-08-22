<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CompetitiveStandingSnapshot extends Model
{
    protected $fillable = ['season_id', 'game_id', 'user_id', 'club_id', 'scope_type', 'scope_key', 'rank', 'rating', 'games_played', 'wins', 'payload', 'captured_at'];
    protected $casts = ['payload' => 'array', 'captured_at' => 'datetime'];

    public function season() { return $this->belongsTo(CompetitiveSeason::class, 'season_id'); }
    public function game() { return $this->belongsTo(Game::class); }
    public function user() { return $this->belongsTo(User::class); }
    public function club() { return $this->belongsTo(Club::class); }
}
