<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class PurchaseReceipt extends Model {
 protected $fillable=['user_id','provider','package_key','product_id','receipt_token','transaction_id','status','amount_minor','currency','verified_at','payload'];
 protected $casts=['payload'=>'array','verified_at'=>'datetime','amount_minor'=>'integer'];
 public function user(){ return $this->belongsTo(User::class); }
}
