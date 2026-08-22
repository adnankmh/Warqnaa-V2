<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CompetitiveMatch extends Model
{
    protected $fillable = ['match_key', 'season_id', 'tournament_id', 'room_id', 'game_id', 'mode', 'status', 'region', 'team_size', 'participant_ids', 'team_map', 'rating_snapshot', 'result', 'rating_processed', 'reward_processed', 'anti_cheat_status', 'started_at', 'finished_at', 'processed_at', 'meta'];
    protected $casts = ['participant_ids' => 'array', 'team_map' => 'array', 'rating_snapshot' => 'array', 'result' => 'array', 'rating_processed' => 'boolean', 'reward_processed' => 'boolean', 'started_at' => 'datetime', 'finished_at' => 'datetime', 'processed_at' => 'datetime', 'meta' => 'array'];

    public function season() { return $this->belongsTo(CompetitiveSeason::class, 'season_id'); }
    public function tournament() { return $this->belongsTo(Tournament::class); }
    public function room() { return $this->belongsTo(Room::class); }
    public function game() { return $this->belongsTo(Game::class); }
    public function ratingEvents() { return $this->hasMany(CompetitiveRatingEvent::class); }
}
