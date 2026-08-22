<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SocialActivity extends Model
{
    protected $fillable = ['actor_id', 'room_id', 'club_id', 'type', 'audience', 'payload', 'published_at', 'expires_at', 'hidden', 'moderated_by', 'moderation_note'];
    protected $casts = ['payload' => 'array', 'published_at' => 'datetime', 'expires_at' => 'datetime', 'hidden' => 'boolean'];
    public function actor() { return $this->belongsTo(User::class, 'actor_id'); }
    public function room() { return $this->belongsTo(Room::class); }
    public function club() { return $this->belongsTo(Club::class); }
    public function moderator() { return $this->belongsTo(User::class, 'moderated_by'); }
    public function gifts() { return $this->hasMany(SocialGift::class); }
}
