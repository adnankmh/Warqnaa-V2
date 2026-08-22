<?php

namespace App\Console\Commands;

use App\Services\Platform\GlobalReleaseReadinessService;
use Illuminate\Console\Command;

class GlobalReleaseCheck extends Command
{
    protected $signature = 'warqna:global-release-check {--strict} {--json}';
    protected $description = 'Verify the R14 Global Release channel and production-readiness contract.';

    public function handle(GlobalReleaseReadinessService $readiness): int
    {
        $report = $readiness->report((bool)$this->option('strict'));
        if ($this->option('json')) $this->line(json_encode($report, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES));
        else {
            $this->info('Warqnaa '.$report['release'].' — '.($report['ready'] ? 'READY' : 'NOT READY'));
            foreach ($report['checks'] as $name => $passed) $this->line(($passed ? '[PASS] ' : '[FAIL] ').$name);
            foreach ($report['warnings'] as $warning) $this->warn($warning);
        }
        return $report['ready'] ? self::SUCCESS : self::FAILURE;
    }
}
