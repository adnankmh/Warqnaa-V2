<?php

namespace App\Services\Platform;

final class ResiliencePolicyService
{
    private const MAX_ATTEMPTS = 5;
    private const BASE_DELAY_MS = 250;
    private const MAX_DELAY_MS = 4000;

    public function retryPolicy(string $operation, int $attempt): array
    {
        $attempt = max(1, min(self::MAX_ATTEMPTS, $attempt));
        $delay = min(self::MAX_DELAY_MS, self::BASE_DELAY_MS * (2 ** ($attempt - 1)));

        return [
            'operation' => $operation,
            'attempt' => $attempt,
            'max_attempts' => self::MAX_ATTEMPTS,
            'delay_ms' => $delay,
            'retryable' => $attempt < self::MAX_ATTEMPTS,
        ];
    }

    public function shouldRetry(?int $statusCode, bool $timedOut = false): bool
    {
        if ($timedOut) {
            return true;
        }

        if ($statusCode === null) {
            return true;
        }

        return $statusCode === 408
            || $statusCode === 425
            || $statusCode === 429
            || $statusCode >= 500;
    }

    public function idempotencyRequired(string $operation): bool
    {
        return in_array($operation, [
            'economy_mutation',
            'store_purchase',
            'matchmaking_join',
            'matchmaking_leave',
            'reconnect',
        ], true);
    }
}
