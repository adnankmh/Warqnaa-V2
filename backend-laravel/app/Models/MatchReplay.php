<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MatchReplay extends Model
{
    protected $fillable = ['room_id', 'owner_id', 'game_id', 'visibility', 'status', 'duration_seconds', 'frames_count', 'event_log', 'final_state', 'sha256', 'views', 'featured', 'published_at', 'expires_at'];
    protected $casts = ['event_log' => 'array', 'final_state' => 'array', 'featured' => 'boolean', 'published_at' => 'datetime', 'expires_at' => 'datetime'];
    public function room() { return $this->belongsTo(Room::class); }
    public function owner() { return $this->belongsTo(User::class, 'owner_id'); }
    public function game() { return $this->belongsTo(Game::class); }
}
