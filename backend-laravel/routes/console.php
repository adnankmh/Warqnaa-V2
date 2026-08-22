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
