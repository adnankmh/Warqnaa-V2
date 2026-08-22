<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RankedQueueEntry extends Model
{
    protected $fillable = ['queue_token', 'season_id', 'user_id', 'game_id', 'room_id', 'queue_mode', 'preferred_seats', 'region', 'country_code', 'rating_snapshot', 'search_window', 'status', 'joined_at', 'last_heartbeat_at', 'matched_at', 'expires_at', 'meta'];
    protected $casts = ['joined_at' => 'datetime', 'last_heartbeat_at' => 'datetime', 'matched_at' => 'datetime', 'expires_at' => 'datetime', 'meta' => 'array'];

    public function season() { return $this->belongsTo(CompetitiveSeason::class, 'season_id'); }
    public function user() { return $this->belongsTo(User::class); }
    public function game() { return $this->belongsTo(Game::class); }
    public function room() { return $this->belongsTo(Room::class); }
}
