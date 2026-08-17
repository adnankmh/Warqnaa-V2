<?php
namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    public static function setUpBeforeClass(): void
    {
        parent::setUpBeforeClass();
        foreach ([
            __DIR__.'/../storage/framework/views',
            __DIR__.'/../storage/framework/cache/data',
            __DIR__.'/../storage/framework/sessions',
            __DIR__.'/../bootstrap/cache',
        ] as $directory) {
            if (!is_dir($directory)) {
                @mkdir($directory, 0777, true);
            }
        }
    }
}
