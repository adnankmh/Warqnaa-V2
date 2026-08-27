<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class GameSessionEvent extends Model
{
    protected $fillable = ['room_id','user_id','type','severity','payload'];
    protected $casts = ['payload'=>'array'];
    public function room(){ return $this->belongsTo(Room::class); }
    public function user(){ return $this->belongsTo(User::class); }
}
