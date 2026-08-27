<?php

namespace App\Services\Economy;

use App\Models\{EconomyAuditEvent,WalletTransaction};

class EconomyAuditService
{
    public function inspect(WalletTransaction $transaction): ?EconomyAuditEvent
    {
        $amount = abs((int)$transaction->amount);
        $fee = abs((int)$transaction->fee);
        $meta = is_array($transaction->meta) ? $transaction->meta : [];
        $recentCount = WalletTransaction::where('user_id',$transaction->user_id)->where('created_at','>=',now()->subMinutes(5))->count();
        $risk = 0;
        $reasons = [];
        if ($amount >= 1000000) { $risk += 45; $reasons[]='high_value'; }
        elseif ($amount >= 100000) { $risk += 25; $reasons[]='elevated_value'; }
        if ($recentCount >= 12) { $risk += 35; $reasons[]='burst_velocity'; }
        elseif ($recentCount >= 6) { $risk += 15; $reasons[]='velocity'; }
        if ($transaction->counterparty_id && (int)$transaction->counterparty_id === (int)$transaction->user_id) { $risk += 50; $reasons[]='self_counterparty'; }
        if ($transaction->type === 'transfer_sent') {
            $principal = max(0, $amount - $fee);
            $feePercent = max(0, min(100, (int)($meta['fee_percent'] ?? 10)));
            $expectedFee = (int)ceil($principal * ($feePercent / 100));
            if ($fee !== $expectedFee) { $risk += 55; $reasons[]='transfer_fee_mismatch'; }
            if ($feePercent !== 10) { $risk += 20; $reasons[]='nonstandard_transfer_fee'; }
        }
        $risk = min(100, $risk);
        if ($risk < 20) return null;
        return EconomyAuditEvent::updateOrCreate(
            ['wallet_transaction_id'=>$transaction->id],
            ['user_id'=>$transaction->user_id,'type'=>'transaction.risk','risk_score'=>$risk,'status'=>'open','payload'=>['reasons'=>$reasons,'amount'=>$amount,'fee'=>$fee,'recent_5m'=>$recentCount,'transaction_type'=>$transaction->type]]
        );
    }

    public function backfill(int $limit = 250): int
    {
        $count = 0;
        WalletTransaction::latest()->limit(max(1,min($limit,1000)))->get()->each(function($tx) use (&$count){ if($this->inspect($tx)) $count++; });
        return $count;
    }

    public function summary(): array
    {
        return [
            'open'=>EconomyAuditEvent::where('status','open')->count(),
            'critical'=>EconomyAuditEvent::where('status','open')->where('risk_score','>=',75)->count(),
            'high'=>EconomyAuditEvent::where('status','open')->whereBetween('risk_score',[50,74])->count(),
            'last_24h'=>EconomyAuditEvent::where('created_at','>=',now()->subDay())->count(),
        ];
    }
}
