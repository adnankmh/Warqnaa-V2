<?php

namespace App\Services\WarqnaPro;

use App\Models\{LuckyWheelSpin, PrizeBox, User};
use App\Services\Wallet\WalletService;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class LuckyWheelService
{
    public const TOKEN_COST = 100;
    public const MAX_TOKEN_SPINS_PER_DAY = 5;
    public const FREE_SPIN_COOLDOWN_HOURS = 12;

    public function __construct(
        private readonly PrizeBoxService $prizeBoxes,
        private readonly WalletService $wallet,
    ) {}

    /** @return array<int,array<string,mixed>> */
    public static function segments(): array
    {
        // R10.1: twelve varied rewards, all server-authorized. Cosmetic values
        // use the same values/keys shown by the store; token rewards stay <=1000.
        return [
            ['key'=>'ticket_500','label_ar'=>'تذكرة 500','label_en'=>'Ticket 500','icon'=>'🎟️','weight'=>12,'color'=>'#5b21b6','reward'=>['type'=>'ticket','value'=>'500','duration_hours'=>0,'rarity'=>'rare','icon'=>'🎟️','label_ar'=>'تذكرة مسابقة 500','label_en'=>'Competition ticket 500']],
            ['key'=>'tokens_500','label_ar'=>'500 توكن','label_en'=>'500 Tokens','icon'=>'🪙','weight'=>17,'color'=>'#047857','reward'=>['type'=>'tokens','value'=>'500','duration_hours'=>0,'rarity'=>'common','icon'=>'🪙','label_ar'=>'500 توكن مجاني','label_en'=>'500 free tokens']],
            ['key'=>'writing_red','label_ar'=>'كتابة حمراء','label_en'=>'Red Writing','icon'=>'✍️','weight'=>9,'color'=>'#b91c1c','reward'=>['type'=>'writing_color','value'=>'#ef4444','duration_hours'=>24,'rarity'=>'rare','icon'=>'✍️','label_ar'=>'لون كتابة أحمر لمدة يوم','label_en'=>'Red writing color for 24 hours','store_item_key'=>'lucky_wheel_chat_red_r91']],
            ['key'=>'player_gold','label_ar'=>'لاعب ذهبي','label_en'=>'Gold Player','icon'=>'🎨','weight'=>9,'color'=>'#ca8a04','reward'=>['type'=>'player_color','value'=>'#facc15','duration_hours'=>24,'rarity'=>'rare','icon'=>'🎨','label_ar'=>'لون لاعب ذهبي لمدة يوم','label_en'=>'Gold player color for 24 hours','store_item_key'=>'lucky_wheel_name_gold_v182']],
            ['key'=>'xp_booster','label_ar'=>'XP ×1.5','label_en'=>'XP ×1.5','icon'=>'⚡','weight'=>9,'color'=>'#6d28d9','reward'=>['type'=>'xp_booster','value'=>'1.5','duration_hours'=>6,'rarity'=>'epic','icon'=>'⚡','label_ar'=>'مسرّع خبرة ×1.5 لمدة 6 ساعات','label_en'=>'XP ×1.5 for 6 hours','store_item_key'=>'daily_pack_xp_15x_6h_v176']],
            ['key'=>'royal_table','label_ar'=>'طاولة ملكية','label_en'=>'Royal Table','icon'=>'🃏','weight'=>7,'color'=>'#0f766e','reward'=>['type'=>'table','value'=>'table_v173_royal_01','duration_hours'=>24,'rarity'=>'epic','icon'=>'🃏','label_ar'=>'طاولة الزمرد الملكي لمدة 24 ساعة','label_en'=>'Royal Emerald table for 24 hours','store_item_key'=>'table_v173_royal_01']],
            ['key'=>'pasha_day','label_ar'=>'يوم باشا','label_en'=>'Pasha Day','icon'=>'👑','weight'=>5,'color'=>'#dc2626','reward'=>['type'=>'pasha_day','value'=>'1','duration_hours'=>24,'rarity'=>'legendary','icon'=>'👑','label_ar'=>'يوم باشا','label_en'=>'One Pasha Day','store_item_key'=>'lucky_wheel_pasha_day_v182']],
            ['key'=>'royal_cover','label_ar'=>'غلاف ملكي','label_en'=>'Royal Cover','icon'=>'🖼️','weight'=>7,'color'=>'#be123c','reward'=>['type'=>'profile_cover','value'=>'cover_v02_royal','duration_hours'=>72,'rarity'=>'epic','icon'=>'🖼️','label_ar'=>'غلاف شخصي ملكي لمدة 3 أيام','label_en'=>'Royal profile cover for 3 days','store_item_key'=>'lucky_wheel_royal_cover_v182']],
            ['key'=>'tokens_900','label_ar'=>'900 توكن','label_en'=>'900 Tokens','icon'=>'💰','weight'=>11,'color'=>'#0e7490','reward'=>['type'=>'tokens','value'=>'900','duration_hours'=>0,'rarity'=>'rare','icon'=>'💰','label_ar'=>'900 توكن مجاني','label_en'=>'900 free tokens']],
            ['key'=>'ticket_1000','label_ar'=>'تذكرة 1000','label_en'=>'Ticket 1000','icon'=>'🎫','weight'=>5,'color'=>'#9333ea','reward'=>['type'=>'ticket','value'=>'1000','duration_hours'=>0,'rarity'=>'epic','icon'=>'🎫','label_ar'=>'تذكرة مسابقة 1000','label_en'=>'Competition ticket 1000']],
            ['key'=>'writing_cyan','label_ar'=>'كتابة سماوية','label_en'=>'Cyan Writing','icon'=>'🖋️','weight'=>9,'color'=>'#0891b2','reward'=>['type'=>'writing_color','value'=>'#22d3ee','duration_hours'=>12,'rarity'=>'rare','icon'=>'🖋️','label_ar'=>'لون كتابة سماوي لمدة 12 ساعة','label_en'=>'Cyan writing color for 12 hours','store_item_key'=>'lucky_wheel_chat_cyan_r101']],
            ['key'=>'xp_booster_2x','label_ar'=>'XP ×2','label_en'=>'XP ×2','icon'=>'🚀','weight'=>5,'color'=>'#ea580c','reward'=>['type'=>'xp_booster','value'=>'2.0','duration_hours'=>3,'rarity'=>'legendary','icon'=>'🚀','label_ar'=>'مسرّع خبرة ×2 لمدة 3 ساعات','label_en'=>'XP ×2 for 3 hours','store_item_key'=>'lucky_wheel_xp_2x_r101']],
        ];
    }

    /** @return array<string,mixed> */
    public function center(User $user): array
    {
        $today = now()->toDateString();
        $lastFree = LuckyWheelSpin::where('user_id',$user->id)->where('source','free')->latest('created_at')->first();
        $nextFreeAt = $lastFree?->created_at?->copy()?->addHours(self::FREE_SPIN_COOLDOWN_HOURS);
        $freeAvailable = !$nextFreeAt || $nextFreeAt->isPast();
        $tokenSpins = LuckyWheelSpin::where('user_id',$user->id)->whereDate('spin_date',$today)->where('source','tokens')->count();
        return [
            'segments'=>self::segments(),
            'free_available'=>$freeAvailable,
            'free_cooldown_hours'=>self::FREE_SPIN_COOLDOWN_HOURS,
            'token_cost'=>self::TOKEN_COST,
            'token_spins_today'=>$tokenSpins,
            'token_spins_remaining'=>max(0,self::MAX_TOKEN_SPINS_PER_DAY-$tokenSpins),
            'next_free_at'=>($nextFreeAt ?: now())->toIso8601String(),
        ];
    }

    /** @return array<string,mixed> */
    public function spin(User $user, string $source='free'): array
    {
        if (!in_array($source, ['free','tokens'], true)) throw new RuntimeException('طريقة التدوير غير صالحة.');

        return DB::transaction(function () use ($user,$source) {
            // Lock the user row first so two simultaneous taps cannot both pass
            // the free-spin or daily token-spin checks before either insert.
            $user = User::whereKey($user->id)->lockForUpdate()->firstOrFail();
            $today = now()->toDateString();
            $spins = LuckyWheelSpin::where('user_id',$user->id)->whereDate('spin_date',$today)->lockForUpdate()->get();
            $lastFree = $spins->where('source','free')->sortByDesc('created_at')->first() ?: LuckyWheelSpin::where('user_id',$user->id)->where('source','free')->latest('created_at')->first();
            $nextFreeAt = $lastFree?->created_at?->copy()?->addHours(self::FREE_SPIN_COOLDOWN_HOURS);
            if ($source === 'free' && $nextFreeAt && $nextFreeAt->isFuture()) {
                throw new RuntimeException('التدويرة المجانية متاحة كل 12 ساعة.');
            }
            if ($source === 'tokens' && $spins->where('source','tokens')->count() >= self::MAX_TOKEN_SPINS_PER_DAY) {
                throw new RuntimeException('وصلت إلى الحد اليومي للتدوير بالتوكنز.');
            }
            $tokenCost = $source === 'tokens' ? self::TOKEN_COST : 0;
            if ($tokenCost > 0) {
                $this->wallet->debit($user,$tokenCost,'lucky_wheel_spin',['source'=>$source]);
                $this->wallet->creditPrimaryAdminRevenue($user,$tokenCost,'lucky_wheel_income',['source'=>$source]);
            }

            [$index,$segment] = $this->weightedSegment();
            $sourceKey = 'wheel:'.$user->id.':'.now()->format('YmdHisv').':'.bin2hex(random_bytes(3));
            $box = PrizeBox::create([
                'user_id'=>$user->id,
                'box_key'=>'diamond_phoenix',
                'source_type'=>'lucky_wheel',
                'source_key'=>$sourceKey,
                'awarded_date'=>$today,
                'payload'=>['segment_key'=>$segment['key'],'version'=>'R10.1-B221','cooldown_hours'=>self::FREE_SPIN_COOLDOWN_HOURS],
            ]);
            $opened = $this->prizeBoxes->open($user,$box,$segment['reward']);
            $spin = LuckyWheelSpin::create([
                'user_id'=>$user->id,'spin_date'=>$today,'source'=>$source,
                'segment_key'=>$segment['key'],'segment_index'=>$index,
                'token_cost'=>$tokenCost,'prize_box_id'=>$box->id,'reward'=>$opened['reward'],
            ]);
            return [
                'spin_id'=>$spin->id,
                'segment_index'=>$index,
                'segment'=>$segment,
                'reward'=>$opened['reward'],
                'inventory'=>$opened['inventory'],
                'tickets'=>$opened['tickets'],
                'wallet'=>$opened['wallet'],
                'profile'=>$opened['profile'],
                'center'=>$this->center($user->fresh()),
            ];
        });
    }

    /** @return array{0:int,1:array<string,mixed>} */
    private function weightedSegment(): array
    {
        $segments = self::segments();
        $total = array_sum(array_map(fn($segment)=>(int)$segment['weight'],$segments));
        $pick = random_int(1,max(1,$total));
        foreach ($segments as $index=>$segment) {
            $pick -= (int)$segment['weight'];
            if ($pick <= 0) return [$index,$segment];
        }
        return [0,$segments[0]];
    }
}
