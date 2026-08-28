<?php
namespace App\Services\Wallet;

use App\Models\{User,WalletTransaction};
use App\Services\Economy\EconomyAuditService;
use Illuminate\Support\Facades\{DB,Schema};
use RuntimeException;

class WalletService
{
    private const MAX_TRANSACTION_AMOUNT = 10000000000000000; // delegated-admin ceiling; primary Adnan remains unlimited.

    private function validateAmount(int $amount): void
    {
        if ($amount < 0 || $amount > self::MAX_TRANSACTION_AMOUNT) {
            throw new RuntimeException('Invalid wallet amount');
        }
    }

    public function debit(User $user, int $amount, string $type, array $meta=[]): void
    {
        $this->validateAmount($amount);
        DB::transaction(function() use($user,$amount,$type,$meta){
            $w=$user->wallet()->lockForUpdate()->firstOrCreate(['user_id'=>$user->id],['tokens'=>50]);
            $transactionMeta = $user->isPrimaryAdmin() ? array_merge($meta,['primary_admin_unlimited'=>true]) : $meta;
            if (!$user->isPrimaryAdmin()) {
                if($w->tokens < $amount) throw new RuntimeException('Insufficient tokens');
                if($amount > 0) $w->decrement('tokens',$amount);
            }
            $transaction = $user->walletTransactions()->create($this->transactionPayload($type, -$amount, $transactionMeta));
            $this->audit($transaction);
        });
    }

    public function credit(User $user, int $amount, string $type, array $meta=[]): void
    {
        $this->validateAmount($amount);
        DB::transaction(function() use($user,$amount,$type,$meta){
            $w=$user->wallet()->lockForUpdate()->firstOrCreate(['user_id'=>$user->id],['tokens'=>50]);
            // Primary Adnan is represented as an unlimited server-side economy account. Keeping
            // its persisted BIGINT reserve fixed prevents overflow as store fees/revenue accumulate.
            $transactionMeta = $user->isPrimaryAdmin() ? array_merge($meta,['primary_admin_unlimited'=>true]) : $meta;
            if($amount > 0 && !$user->isPrimaryAdmin()) $w->increment('tokens',$amount);
            $transaction = $user->walletTransactions()->create($this->transactionPayload($type, $amount, $transactionMeta));
            $this->audit($transaction);
        });
    }

    /** @return array<string,mixed> */
    private function transactionPayload(string $type, int $amount, array $meta): array
    {
        $counterparty = $meta['counterparty_id'] ?? $meta['to'] ?? $meta['from'] ?? null;
        $fee = max(0, (int)($meta['fee'] ?? 0));
        return [
            'type' => $type,
            'amount' => $amount,
            'fee' => $fee,
            'counterparty_id' => is_numeric($counterparty) ? (int)$counterparty : null,
            'meta' => $meta,
        ];
    }

    private function audit(WalletTransaction $transaction): void
    {
        // Auditing is deliberately non-blocking: a telemetry/storage problem must
        // never partially apply or reject a valid player wallet operation.
        try {
            if (Schema::hasTable('economy_audit_events')) {
                app(EconomyAuditService::class)->inspect($transaction);
            }
        } catch (\Throwable $e) {
            report($e);
        }
    }

    /**
     * Credits every paid game-economy transaction to the primary Adnan admin.
     * The buyer is never credited back and self-purchases do not create income.
     */
    public function creditPrimaryAdminRevenue(User $buyer, int $amount, string $type='store_sale_income', array $meta=[]): void
    {
        $this->validateAmount($amount);
        if ($amount <= 0) return;
        $admin = User::where('is_admin', true)->where('admin_role', 'primary_admin')->first() ?: User::whereRaw('LOWER(username) = ?', ['adnan'])->where('is_admin', true)->first()
            ?? User::where('is_admin', true)->orderBy('id')->first();
        if (!$admin || (int)$admin->id === (int)$buyer->id) return;
        $this->credit($admin, $amount, $type, array_merge($meta, ['buyer_id'=>(int)$buyer->id]));
    }
}
