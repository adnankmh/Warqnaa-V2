<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

final class EnvironmentSanityTest extends TestCase
{
    public function test_runtime_meets_the_supported_php_baseline(): void
    {
        self::assertGreaterThanOrEqual(80200, PHP_VERSION_ID);
    }
}
