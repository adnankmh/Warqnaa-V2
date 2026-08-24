<?php

namespace Tests\Unit;

use App\Services\Platform\GlobalReleaseReadinessService;
use Tests\TestCase;

class V260GlobalReleaseContractTest extends TestCase
{
    public function test_global_release_has_four_channels_and_engine_gold(): void
    {
        $this->assertSame(['backend','web','android','ios'], config('warqna_global_release.channels'));
        $this->assertSame(['ar','en'], config('warqna_global_release.locales'));
        $this->assertSame(20, config('warqna_global_release.engine_gold.engines'));
        $this->assertGreaterThanOrEqual(2000, config('warqna_global_release.engine_gold.matches_per_engine'));
    }

    public function test_non_strict_readiness_distinguishes_source_gates_from_deployment_secrets(): void
    {
        $report = app(GlobalReleaseReadinessService::class)->report(false);
        $this->assertTrue($report['ready']);
        $this->assertStringStartsWith('r14', $report['contract']);
        $this->assertNotEmpty($report['warnings']);
        $this->assertNotContains(false, $report['checks'], true);
    }
}
