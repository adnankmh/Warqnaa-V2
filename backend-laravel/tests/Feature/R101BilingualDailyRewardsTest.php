<?php

namespace Tests\Feature;

use Tests\TestCase;

class R101BilingualDailyRewardsTest extends TestCase
{
    public function test_daily_rewards_localize_copy_without_changing_claim_authority_or_economy(): void
    {
        $view = file_get_contents(resource_path('views/rewards/index.blade.php'));
        $controller = file_get_contents(app_path('Http/Controllers/RewardController.php'));

        $this->assertIsString($view);
        $this->assertIsString($controller);

        foreach ([
            'المكافآت اليومية',
            'Daily rewards',
            'استلمت مكافأة اليوم:',
            "Today's reward claimed:",
            'استلام مكافأة اليوم',
            "Claim today's reward",
            'آخر المكافآت',
            'Recent rewards',
            'لا توجد مكافآت بعد.',
            'No rewards yet.',
            'قيمة المكافأة',
            'Reward value',
        ] as $localizedCopy) {
            $this->assertStringContainsString($localizedCopy, $view);
        }

        foreach ([
            "route('rewards.wheel')",
            "route('rewards.box.open',\$box['id'])",
            "route('rewards.claim')",
            'name="source" value="free"',
            'name="source" value="tokens"',
            "\$wheel['free_available']",
            "\$wheel['token_spins_remaining']",
            "\$claim->streak",
            "\$claim->coins",
        ] as $stableViewContract) {
            $this->assertStringContainsString($stableViewContract, $view);
        }

        foreach ([
            "latest('claim_date')->first()",
            'isYesterday()',
            'rewardForStreak($streak)',
            'DailyRewardClaim::firstOrCreate(',
            "['user_id'=>auth()->id(),'claim_date'=>today()]",
            "if(\$claim->wasRecentlyCreated)",
            "\$wallet->increment('tokens',\$claim->coins)",
            "['ok'=>true,'message'=>\$message,'claim'=>\$claim]",
            'تم استلام المكافأة اليومية',
            'Daily reward claimed',
        ] as $stableControllerContract) {
            $this->assertStringContainsString($stableControllerContract, $controller);
        }
    }
}
