<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RoomSpectator extends Model
{
    protected $fillable = ['room_id', 'user_id', 'status', 'joined_at', 'last_seen_at', 'can_chat', 'voice_enabled', 'meta'];
    protected $casts = ['joined_at' => 'datetime', 'last_seen_at' => 'datetime', 'can_chat' => 'boolean', 'voice_enabled' => 'boolean', 'meta' => 'array'];
    public function room() { return $this->belongsTo(Room::class); }
    public function user() { return $this->belongsTo(User::class); }
}
