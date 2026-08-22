<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SocialEventAttendee extends Model
{
    protected $fillable = ['social_event_id', 'user_id', 'status', 'joined_at'];
    protected $casts = ['joined_at' => 'datetime'];
    public function event() { return $this->belongsTo(SocialEvent::class, 'social_event_id'); }
    public function user() { return $this->belongsTo(User::class); }
}
