<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class PartyMember extends Model
{
    protected $fillable = ['party_id','user_id','role','status','joined_at','last_seen_at'];
    protected $casts = ['joined_at'=>'datetime','last_seen_at'=>'datetime'];
    public function party(){ return $this->belongsTo(Party::class); }
    public function user(){ return $this->belongsTo(User::class); }
}
