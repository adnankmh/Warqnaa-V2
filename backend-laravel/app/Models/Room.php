<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    protected $casts = [
        'state' => 'array',
        'started_at' => 'datetime',
        'finished_at' => 'datetime',
    ];

    protected $fillable = [
        'code', 'game_id', 'owner_id', 'visibility', 'password', 'entry_fee',
        'min_level', 'status', 'started_at', 'finished_at', 'max_players',
        'target_score', 'state',
    ];

    public function game() { return $this->belongsTo(Game::class); }
    public function owner() { return $this->belongsTo(User::class, 'owner_id'); }
    public function players() { return $this->hasMany(RoomPlayer::class); }
    public function spectators() { return $this->hasMany(RoomSpectator::class); }
    public function replay() { return $this->hasOne(MatchReplay::class); }
    public function competitiveMatch() { return $this->hasOne(CompetitiveMatch::class); }
}
