<?php
namespace App\Services\Admin;

use App\Models\{CompetitionTicket,InventoryItem,Profile,StoreItem,User,Wallet};
use Illuminate\Support\Facades\Schema;

class PrimaryAdminStateService
{
    public const LEVEL = 99;
    public const XP_FLOOR = 193947651;
    public const PASHA_DAYS = 36500;
    public const TOKEN_RESERVE = 9000000000000000000;
    public const GEMS = 100000000;
    public const INVENTORY_QUANTITY = 100;
    public const TICKET_QUANTITY = 100;
    public const COLOR_VALIDITY_DAYS = 365;

    /** @var array<string,bool> */
    public const FULL_PERMISSIONS = [
        'all'=>true,
        'users'=>true,
        'store'=>true,
        'rooms'=>true,
        'clubs'=>true,
        'tournaments'=>true,
        'economy'=>true,
        'security'=>true,
        'social_world'=>true,
        'competitive'=>true,
        'site_settings'=>true,
        'site_design'=>true,
        'game_rules'=>true,
        'designer'=>true,
        'moderation'=>true,
        'analytics'=>true,
        'settings'=>true,
        'releases'=>true,
        'support'=>true,
        'operations'=>true,
        'voice'=>true,
        'commerce'=>true,
        'offers'=>true,
        'rewards'=>true,
        'translations'=>true,
    ];

    /** @var list<int> */
    private const DEFAULT_TICKET_DENOMINATIONS = [
        50,100,200,500,1000,2000,4000,5000,8000,10000,20000,30000,50000,100000,
    ];

    /**
     * Keep every durable primary_admin account at the promised administrative
     * progression/economy/ownership floor. The role is authoritative;
     * usernames/emails are intentionally not hard-coded in tracked source.
     */
    public function enforce(User $user): User
    {
        if (($user->admin_role ?? null) !== 'primary_admin') {
            return $user->refresh();
        }

        $user->forceFill([
            'is_admin' => true,
            'is_banned' => false,
            'admin_permissions' => self::FULL_PERMISSIONS,
        ])->save();

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
            // Preserve the owner's selected fez instead of resetting it on every
            // login/catalog sync. Red remains the safe default for new profiles.
            'pasha_style' => $profile->pasha_style ?: 'red',
        ])->save();

        // Primary-admin color and text cosmetics always have at least one full
        // year of active display time, without changing purchased inventory expiry.
        // A later valid expiry is never shortened. Renewal is idempotent on login.
        $annualFloor = now()->addDays(self::COLOR_VALIDITY_DAYS);
        foreach ([
            'name_color_expires_at' => !empty($profile->name_color) || !empty($profile->active_name_frame),
            'chat_color_expires_at' => !empty($profile->chat_color) || !empty($profile->text_color),
            'profile_color_expires_at' => !empty($profile->active_profile_color),
        ] as $column => $isEquipped) {
            if ($isEquipped && (!$profile->{$column} || $profile->{$column}->lt($annualFloor))) {
                $profile->{$column} = $annualFloor->copy();
            }
        }
        if ($profile->isDirty()) $profile->save();

        $wallet = $user->wallet()->firstOrCreate([], ['tokens' => 50, 'gems' => 0]);
        $wallet->forceFill([
            // Primary-admin debits are also bypassed in WalletService. This
            // BIGINT-safe reserve is repaired whenever the account is loaded.
            'tokens' => max(self::TOKEN_RESERVE, (int)$wallet->tokens),
            'gems' => max(self::GEMS, (int)$wallet->gems),
        ])->save();

        $this->enforceStoreOwnership($user);
        $this->enforceTickets($user);

        return $user->fresh(['profile','wallet']);
    }

    private function enforceStoreOwnership(User $user): void
    {
        if (!Schema::hasTable('store_items') || !Schema::hasTable('inventory_items')) return;

        $hasQuantity = Schema::hasColumn('inventory_items', 'quantity');
        StoreItem::query()
            ->where('active', true)
            ->where('category', '!=', 'competition_ticket')
            ->orderBy('id')
            ->chunkById(100, function ($items) use ($user, $hasQuantity): void {
                foreach ($items as $item) {
                    $inventory = InventoryItem::firstOrNew([
                        'user_id' => $user->id,
                        'store_item_id' => $item->id,
                    ]);
                    if (!$inventory->exists) {
                        $inventory->active = false;
                        $inventory->activated_at = null;
                    }
                    // Admin ownership never expires. We preserve whichever
                    // cosmetic is currently active instead of resetting it.
                    $inventory->expires_at = null;
                    if ($hasQuantity) {
                        $inventory->quantity = max(self::INVENTORY_QUANTITY, (int)($inventory->quantity ?? 1));
                    }
                    $inventory->save();
                }
            });
    }

    private function enforceTickets(User $user): void
    {
        if (!Schema::hasTable('competition_tickets')) return;

        $denominations = self::DEFAULT_TICKET_DENOMINATIONS;
        if (Schema::hasTable('store_items')) {
            $configured = StoreItem::query()
                ->where('active', true)
                ->where('category', 'competition_ticket')
                ->get()
                ->map(fn (StoreItem $item) => (int)data_get($item->payload, 'denomination', 0))
                ->filter(fn (int $value) => $value > 0)
                ->values()
                ->all();
            $denominations = array_values(array_unique(array_merge($denominations, $configured)));
            sort($denominations);
        }

        foreach ($denominations as $denomination) {
            $ticket = CompetitionTicket::firstOrNew([
                'user_id' => $user->id,
                'denomination' => $denomination,
            ]);
            $ticket->quantity = max(self::TICKET_QUANTITY, (int)($ticket->quantity ?? 0));
            if (!$ticket->exists) $ticket->total_used = 0;
            $ticket->save();
        }
    }
}
