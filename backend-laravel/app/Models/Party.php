<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Party extends Model
{
    protected $fillable = ['owner_id','code','status','max_members','game_key','room_id','settings'];
    protected $casts = ['settings'=>'array'];
    public function owner(){ return $this->belongsTo(User::class, 'owner_id'); }
    public function members(){ return $this->hasMany(PartyMember::class); }
    public function room(){ return $this->belongsTo(Room::class); }
}
