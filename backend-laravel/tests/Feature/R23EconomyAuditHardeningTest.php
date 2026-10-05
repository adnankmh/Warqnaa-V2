<?php

namespace Tests\Feature;

use App\Models\{User, WalletTransaction};
use App\Services\Economy\EconomyAuditService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class R23EconomyAuditHardeningTest extends TestCase
{
    use RefreshDatabase;

    public function test_duplicate_idempotency_key_is_flagged_without_mutating_ledger(): void
    {
        $user = User::create([
            'username' => 'r23-audit-user',
            'email' => 'r23-audit@example.test',
            'password' => Hash::make('password'),
        ]);

        $first = WalletTransaction::create([
            'user_id' => $user->id,
            'type' => 'reward',
            'amount' => 100,
            'fee' => 0,
            'meta' => ['idempotency_key' => 'reward:req:42'],
        ]);
        $duplicate = WalletTransaction::create([
            'user_id' => $user->id,
            'type' => 'reward',
            'amount' => 100,
            'fee' => 0,
            'meta' => ['idempotency_key' => 'reward:req:42'],
        ]);

        $service = app(EconomyAuditService::class);
        $event = $service->inspect($duplicate);

        $this->assertNotNull($event);
        $this->assertContains('duplicate_idempotency_key', $event->payload['reasons']);
        $this->assertGreaterThanOrEqual(70, $event->risk_score);
        $this->assertSame(2, WalletTransaction::where('user_id', $user->id)->count());
        $this->assertSame(100, (int) $first->fresh()->amount);
        $this->assertSame(100, (int) $duplicate->fresh()->amount);

        $sameEvent = $service->inspect($duplicate);
        $this->assertSame($event->id, $sameEvent->id);
    }

    public function test_malformed_fee_and_missing_transfer_counterparty_are_flagged(): void
    {
        $user = User::create([
            'username' => 'r23-fee-user',
            'email' => 'r23-fee@example.test',
            'password' => Hash::make('password'),
        ]);

        $transaction = WalletTransaction::create([
            'user_id' => $user->id,
            'type' => 'transfer_sent',
            'amount' => 10,
            'fee' => 25,
            'meta' => ['fee_percent' => 10],
        ]);

        $event = app(EconomyAuditService::class)->inspect($transaction);

        $this->assertNotNull($event);
        $this->assertContains('missing_transfer_counterparty', $event->payload['reasons']);
        $this->assertContains('fee_exceeds_amount', $event->payload['reasons']);
        $this->assertContains('transfer_fee_mismatch', $event->payload['reasons']);
        $this->assertSame(100, (int) $event->risk_score);
    }
}
