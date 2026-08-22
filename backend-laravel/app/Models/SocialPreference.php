<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SocialPreference extends Model
{
    protected $fillable = [
        'user_id', 'profile_visibility', 'presence_visibility', 'activity_visibility',
        'message_policy', 'invite_policy', 'discoverable', 'allow_friend_requests',
        'allow_follows', 'allow_spectators', 'allow_replay_share', 'allow_voice',
        'show_online_status', 'show_current_room',
    ];

    protected $casts = [
        'discoverable' => 'boolean',
        'allow_friend_requests' => 'boolean',
        'allow_follows' => 'boolean',
        'allow_spectators' => 'boolean',
        'allow_replay_share' => 'boolean',
        'allow_voice' => 'boolean',
        'show_online_status' => 'boolean',
        'show_current_room' => 'boolean',
    ];

    public function user() { return $this->belongsTo(User::class); }
}
