<?php
namespace App\Services\WarqnaPro;

use App\Models\{Tournament,User};
use App\Services\Wallet\WalletService;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class TournamentSettlementService
{
    public function __construct(private readonly WalletService $wallet) {}

    /** @return array<string,mixed> */
    public function settle(int $tournamentId, array $winnerUserIds, int $roomId): array
    {
        $winnerUserIds=array_values(array_unique(array_filter(array_map('intval',$winnerUserIds),fn($id)=>$id>0)));
        if($winnerUserIds===[]) return ['ok'=>false,'reason'=>'no_real_winner'];
        return DB::transaction(function() use($tournamentId,$winnerUserIds,$roomId){
            $t=Tournament::lockForUpdate()->find($tournamentId);
            if(!$t) return ['ok'=>false,'reason'=>'missing_tournament'];
            $bracket=(array)($t->bracket ?: []);
            if(!empty($bracket['settlement']['paid_at'])) return ['ok'=>true,'duplicate'=>true,'settlement'=>$bracket['settlement']];
            $eligible=$t->entries()->whereIn('user_id',$winnerUserIds)->pluck('user_id')->map(fn($v)=>(int)$v)->all();
            if($eligible===[]) return ['ok'=>false,'reason'=>'winner_not_registered'];
            $prize=max(0,(int)$t->prize_pool);
            if($prize<=0){
                $bracket['settlement']=['paid_at'=>now()->toIso8601String(),'room_id'=>$roomId,'winners'=>$eligible,'prize'=>0];
                $t->update(['status'=>'finished','bracket'=>$bracket]);
                return ['ok'=>true,'prize'=>0,'winners'=>$eligible];
            }
            $admin=User::whereRaw('LOWER(username) = ?', ['adnan'])->where('is_admin',true)->first() ?: User::where('is_admin',true)->orderBy('id')->first();
            if(!$admin) throw new RuntimeException('Primary admin wallet is unavailable for tournament settlement.');
            $share=intdiv($prize,count($eligible));
            $remainder=$prize-($share*count($eligible));
            $this->wallet->debit($admin,$prize,'tournament_prize_payout',['tournament_id'=>$t->id,'room_id'=>$roomId]);
            foreach($eligible as $i=>$uid){
                $user=User::find($uid); if(!$user) continue;
                $amount=$share+($i===0?$remainder:0);
                $this->wallet->credit($user,$amount,'tournament_prize',['tournament_id'=>$t->id,'room_id'=>$roomId]);
            }
            $bracket['settlement']=['paid_at'=>now()->toIso8601String(),'room_id'=>$roomId,'winners'=>$eligible,'prize'=>$prize];
            $bracket['messages'][]='تم دفع جائزة المنافسة بقيمة '.number_format($prize).' توكنز.';
            $t->update(['status'=>'finished','bracket'=>$bracket]);
            return ['ok'=>true,'prize'=>$prize,'winners'=>$eligible];
        });
    }
}
