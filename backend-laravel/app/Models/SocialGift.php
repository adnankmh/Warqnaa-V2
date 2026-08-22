<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SocialGift extends Model
{
    protected $fillable = ['sender_id', 'recipient_id', 'room_id', 'social_activity_id', 'gift_key', 'token_cost', 'animation_key', 'message', 'visible', 'delivered_at', 'meta'];
    protected $casts = ['visible' => 'boolean', 'delivered_at' => 'datetime', 'meta' => 'array'];
    public function sender() { return $this->belongsTo(User::class, 'sender_id'); }
    public function recipient() { return $this->belongsTo(User::class, 'recipient_id'); }
    public function room() { return $this->belongsTo(Room::class); }
    public function activity() { return $this->belongsTo(SocialActivity::class, 'social_activity_id'); }
}
