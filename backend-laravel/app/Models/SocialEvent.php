<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SocialEvent extends Model
{
    protected $fillable = ['created_by', 'club_id', 'game_id', 'room_id', 'title', 'description', 'visibility', 'status', 'starts_at', 'ends_at', 'capacity', 'banner_url', 'featured', 'settings'];
    protected $casts = ['title' => 'array', 'description' => 'array', 'settings' => 'array', 'starts_at' => 'datetime', 'ends_at' => 'datetime', 'featured' => 'boolean'];
    public function creator() { return $this->belongsTo(User::class, 'created_by'); }
    public function club() { return $this->belongsTo(Club::class); }
    public function game() { return $this->belongsTo(Game::class); }
    public function room() { return $this->belongsTo(Room::class); }
    public function attendees() { return $this->hasMany(SocialEventAttendee::class); }
}
