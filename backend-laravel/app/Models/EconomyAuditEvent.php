<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class EconomyAuditEvent extends Model
{
    protected $fillable = ['wallet_transaction_id','user_id','type','risk_score','status','payload','reviewed_by','reviewed_at'];
    protected $casts = ['payload'=>'array','reviewed_at'=>'datetime'];
    public function user(){ return $this->belongsTo(User::class); }
    public function reviewer(){ return $this->belongsTo(User::class, 'reviewed_by'); }
    public function transaction(){ return $this->belongsTo(WalletTransaction::class, 'wallet_transaction_id'); }
}
