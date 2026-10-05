<?php

namespace Tests\Feature;

use App\Services\Platform\ResiliencePolicyService;
use Tests\TestCase;

final class R25ResiliencePolicyTest extends TestCase
{
    public function test_retry_policy_is_bounded_and_exponential(): void
    {
        $service = new ResiliencePolicyService();

        $this->assertSame(250, $service->retryPolicy('reconnect', 1)['delay_ms']);
        $this->assertSame(500, $service->retryPolicy('reconnect', 2)['delay_ms']);
        $this->assertSame(1000, $service->retryPolicy('reconnect', 3)['delay_ms']);
        $this->assertSame(2000, $service->retryPolicy('reconnect', 4)['delay_ms']);

        $last = $service->retryPolicy('reconnect', 99);
        $this->assertSame(5, $last['attempt']);
        $this->assertSame(4000, $last['delay_ms']);
        $this->assertFalse($last['retryable']);
    }

    public function test_only_transient_failures_are_retryable(): void
    {
        $service = new ResiliencePolicyService();

        $this->assertTrue($service->shouldRetry(null));
        $this->assertTrue($service->shouldRetry(408));
        $this->assertTrue($service->shouldRetry(429));
        $this->assertTrue($service->shouldRetry(503));
        $this->assertTrue($service->shouldRetry(400, true));

        $this->assertFalse($service->shouldRetry(400));
        $this->assertFalse($service->shouldRetry(401));
        $this->assertFalse($service->shouldRetry(403));
        $this->assertFalse($service->shouldRetry(409));
    }

    public function test_mutating_boundaries_require_idempotency(): void
    {
        $service = new ResiliencePolicyService();

        foreach ([
            'economy_mutation',
            'store_purchase',
            'matchmaking_join',
            'matchmaking_leave',
            'reconnect',
        ] as $operation) {
            $this->assertTrue($service->idempotencyRequired($operation), $operation);
        }

        $this->assertFalse($service->idempotencyRequired('health_probe'));
        $this->assertFalse($service->idempotencyRequired('catalog_read'));
    }
}
