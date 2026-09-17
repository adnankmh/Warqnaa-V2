<?php
namespace App\Services\Admin;

use App\Models\{Profile,User,Wallet};

class PrimaryAdminStateService
{
    public const LEVEL = 99;
    public const XP_FLOOR = 193947651;
    public const PASHA_DAYS = 36500;
    public const TOKEN_RESERVE = 9000000000000000000;
    public const GEMS = 100000000;

    /**
     * Keep every durable primary_admin account at the promised administrative
     * progression/economy floor. The role is authoritative; usernames/emails
     * are intentionally not hard-coded in tracked source.
     */
    public function enforce(User $user): User
    {
        if (($user->admin_role ?? null) !== 'primary_admin') {
            return $user->refresh();
        }

        if (!(bool)$user->is_admin) {
            $user->forceFill(['is_admin' => true, 'is_banned' => false])->save();
        }

        $profile = $user->profile()->firstOrCreate([], [
            'display_name' => $user->username,
            'country_code' => 'PS',
            'country_name' => 'Palestine',
        ]);
        $profile->forceFill([
            'level' => max(self::LEVEL, (int)($profile->level ?? 1)),
            'xp' => max(self::XP_FLOOR, (int)($profile->xp ?? 0)),
            'pasha_days' => max(self::PASHA_DAYS, (int)($profile->pasha_days ?? 0)),
            'badge' => $profile->badge ?: 'king',
            'pasha_style' => 'red',
        ])->save();

        $wallet = $user->wallet()->firstOrCreate([], ['tokens' => 50, 'gems' => 0]);
        $wallet->forceFill([
            'tokens' => max(self::TOKEN_RESERVE, (int)$wallet->tokens),
            'gems' => max(self::GEMS, (int)$wallet->gems),
        ])->save();

        return $user->fresh(['profile','wallet']);
    }
}
