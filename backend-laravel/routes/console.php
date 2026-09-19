<?php

use Illuminate\Support\Facades\Schedule;

Schedule::command('warqna:purge-cancelled-accounts')
    ->hourly()
    ->withoutOverlapping();

Schedule::command('warqna:cleanup-voice')
    ->everyMinute()
    ->withoutOverlapping();

Schedule::command('warqna:cleanup-social-world')
    ->everyFiveMinutes()
    ->withoutOverlapping();

Schedule::command('warqna:ensure-system-competition')->everyMinute()->withoutOverlapping();

Schedule::command('warqna:competitive-tick')
    ->everyMinute()
    ->withoutOverlapping()
    ->onOneServer();

// Record an actual scheduler execution; opening the dashboard never fakes this.
Schedule::call(function () {
    \Illuminate\Support\Facades\Cache::put(
        \App\Services\Platform\OperationsStatusService::HEARTBEAT_KEY,
        time(),
        600
    );
})->name('warqnaa-operations-heartbeat')->everyMinute();
