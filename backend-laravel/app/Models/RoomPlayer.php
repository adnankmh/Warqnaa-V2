<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RoomPlayer extends Model
{
    protected $fillable = [
        'room_id',
        'user_id',
        'bot_key',
        'seat',
        'is_bot',
        'connected',
        'missed_turns',
        'last_heartbeat_at',
        'disconnected_at',
        'afk_since',
        'bot_difficulty',
        'voice_joined_at',
        'voice_last_seen_at',
        'voice_muted',
        'voice_deafened',
    ];

    protected $casts = [
        'is_bot' => 'boolean',
        'connected' => 'boolean',
        'last_heartbeat_at' => 'datetime',
        'disconnected_at' => 'datetime',
        'afk_since' => 'datetime',
        'voice_joined_at' => 'datetime',
        'voice_last_seen_at' => 'datetime',
        'voice_muted' => 'boolean',
        'voice_deafened' => 'boolean',
    ];

    public function room()
    {
        return $this->belongsTo(Room::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
