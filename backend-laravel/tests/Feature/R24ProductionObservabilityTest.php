<?php

namespace Tests\Feature;

use App\Services\Platform\PlatformHealthService;
use Illuminate\Support\Str;
use Tests\TestCase;

class R24ProductionObservabilityTest extends TestCase
{
    public function test_health_snapshot_exposes_privacy_safe_operational_fields(): void
    {
        $snapshot = app(PlatformHealthService::class)->snapshot();

        $this->assertContains($snapshot['status'], ['ready', 'degraded']);
        $this->assertSame($snapshot['ok'] ? 'ready' : 'degraded', $snapshot['status']);
        $this->assertTrue(Str::isUuid($snapshot['correlation_id']));
        $this->assertIsInt($snapshot['duration_ms']);
        $this->assertGreaterThanOrEqual(0, $snapshot['duration_ms']);
        $this->assertIsArray($snapshot['failure_classes']);
        $this->assertIsArray($snapshot['missing_tables']);
        $this->assertSame(
            array_keys(array_filter($snapshot['database'], static fn (bool $ready): bool => !$ready)),
            $snapshot['missing_tables'],
        );

        $encoded = strtolower(json_encode($snapshot, JSON_THROW_ON_ERROR));
        foreach (['password', 'authorization', 'bearer ', 'access_token', 'refresh_token', 'secret_key'] as $sensitive) {
            $this->assertStringNotContainsString($sensitive, $encoded);
        }
    }

    public function test_health_probes_use_distinct_correlation_ids(): void
    {
        $service = app(PlatformHealthService::class);

        $first = $service->snapshot();
        $second = $service->snapshot();

        $this->assertNotSame($first['correlation_id'], $second['correlation_id']);
    }

    public function test_public_health_endpoint_keeps_operational_contract(): void
    {
        $this->get('/health')->assertOk()->assertJsonStructure([
            'ok',
            'status',
            'correlation_id',
            'version',
            'build',
            'environment',
            'database_connected',
            'cache_connected',
            'database',
            'failure_classes',
            'missing_tables',
            'counts',
            'voice_turn_configured',
            'queue',
            'duration_ms',
            'time',
        ]);
    }
}
