<?php

namespace App\Services\WarqnaPro;

use App\Models\{CompetitionTicket,Game,Tournament,TournamentEntry,User};
use App\Services\Wallet\WalletService;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class CompetitionService
{
    public function __construct(private readonly WalletService $wallet) {}

    /** @return array<string,mixed> */
    public function join(User $user, string $key, int $requestedFee): array
    {
        $preset = $this->preset($key, $requestedFee);
        $game = Game::where('active', true)->where('key', $preset['game'])->first() ?: Game::where('active', true)->firstOrFail();
        $tournament = Tournament::firstOrCreate(
            ['key'=>$key],
            [
                'creator_id'=>$user->id,
                'game_id'=>$game->id,
                'stages'=>$preset['rounds'],
                'seats_per_match'=>4,
                'entry_fee'=>$preset['fee'],
                'prize_pool'=>$preset['prize'] ?? ($preset['fee'] * max(8, intdiv($preset['max_players'], 2))),
                'status'=>'open',
                'name'=>['ar'=>$preset['name_ar'],'en'=>$preset['name_en']],
                'description'=>['ar'=>$preset['description_ar'],'en'=>$preset['description_en']],
                'max_players'=>$preset['max_players'],
                'rounds'=>$preset['rounds'],
                'starts_at'=>now()->addMinutes(10),
                'auto_accept'=>true,
                'random_seating'=>true,
                'chat_enabled'=>true,
                'turn_seconds'=>$preset['turn_seconds'],
                'entry_mode'=>'ticket_or_tokens',
                'ad_entry_enabled'=>$preset['fee'] <= 500,
                'featured'=>$preset['featured'],
                'settings'=>['anti_cheat'=>true,'disconnect_grace_seconds'=>45,'entry_fee_locked'=>true,'category'=>$preset['category'] ?? 'cup','prizes'=>$preset['prizes'] ?? ['1st'=>($preset['prize'] ?? 0)]],
            ]
        );

        if (!in_array((string)$tournament->status, ['open','running'], true)) {
            throw new RuntimeException('هذه المنافسة لم تعد متاحة للدخول.');
        }
        $bracket = (array)($tournament->bracket ?: []);
        $exitCounts = (array)($bracket['exit_counts'] ?? []);
        if ((int)($exitCounts[(string)$user->id] ?? 0) >= 5) {
            throw new RuntimeException('لا يمكنك العودة إلى هذه المنافسة بعد الخروج منها 5 مرات.');
        }
        if ($tournament->entries()->where('user_id', $user->id)->exists()) {
            throw new RuntimeException('أنت مسجل في هذه المنافسة مسبقاً.');
        }
        if ($tournament->entries()->count() >= (int)($tournament->max_players ?: 64)) {
            throw new RuntimeException('اكتمل عدد المشاركين في هذه المنافسة.');
        }

        $entryMode = 'tokens';
        $usedTicket = null;
        DB::transaction(function () use ($user, $tournament, &$entryMode, &$usedTicket) {
            $ticket = CompetitionTicket::where('user_id', $user->id)
                ->where('quantity', '>', 0)
                ->where('denomination', '>=', (int)$tournament->entry_fee)
                ->orderBy('denomination')
                ->lockForUpdate()
                ->first();
            if ($ticket) {
                $ticket->decrement('quantity');
                $ticket->increment('total_used');
                $entryMode = 'ticket';
                $usedTicket = (int)$ticket->denomination;
            } else {
                $this->wallet->debit($user, (int)$tournament->entry_fee, 'competition_entry', ['tournament_id'=>$tournament->id,'key'=>$tournament->key]);
                $this->wallet->creditPrimaryAdminRevenue($user, (int)$tournament->entry_fee, 'competition_entry_income', ['tournament_id'=>$tournament->id,'key'=>$tournament->key]);
            }
            TournamentEntry::create([
                'tournament_id'=>$tournament->id,
                'user_id'=>$user->id,
                'status'=>'registered',
                'entry_mode'=>$entryMode,
                'ticket_denomination'=>$usedTicket,
                'paid_tokens'=>$entryMode === 'tokens' ? (int)$tournament->entry_fee : 0,
                'seed'=>random_int(1, 999999),
            ]);
        });

        return ['tournament'=>$tournament->fresh('game'),'entry_mode'=>$entryMode,'ticket_denomination'=>$usedTicket];
    }


    /** @return array<string,mixed> */
    public function leave(User $user, string $key): array
    {
        return DB::transaction(function () use ($user, $key) {
            $tournament = Tournament::where('key', $key)->lockForUpdate()->first();
            if (!$tournament) throw new RuntimeException('المنافسة غير موجودة.');
            $entry = $tournament->entries()->where('user_id', $user->id)->lockForUpdate()->first();
            if (!$entry) throw new RuntimeException('أنت غير مسجل في هذه المنافسة.');

            $bracket = (array)($tournament->bracket ?: []);
            $counts = (array)($bracket['exit_counts'] ?? []);
            $userKey = (string)$user->id;
            $counts[$userKey] = min(5, (int)($counts[$userKey] ?? 0) + 1);
            $bracket['exit_counts'] = $counts;
            $bracket['messages'] = array_values(array_merge((array)($bracket['messages'] ?? []), [
                'خرج اللاعب '.$user->username.' من المنافسة ('.$counts[$userKey].'/5).',
            ]));
            $tournament->forceFill(['bracket'=>$bracket])->save();
            $entry->delete();

            return [
                'tournament_key'=>$tournament->key,
                'exit_count'=>$counts[$userKey],
                'return_allowed'=>$counts[$userKey] < 5,
            ];
        });
    }

    /** @return array<string,mixed> */
    private function preset(string $key, int $requestedFee): array
    {
        $presets = [
            'system_50'=>['name_ar'=>'منافسة النظام السريعة','name_en'=>'System Quick Cup','description_ar'=>'منافسة دورية برسوم 50 توكنز وجائزة 300 توكنز','description_en'=>'Recurring system competition with 50-token entry and 300-token prize','fee'=>50,'prize'=>300,'max_players'=>4,'rounds'=>1,'turn_seconds'=>7,'game'=>'tarneeb','featured'=>true,'category'=>'quick','prizes'=>['1st'=>300]],
            'champions'=>['name_ar'=>'بطولة الأبطال','name_en'=>'Champions Cup','description_ar'=>'بطولة طرنيب من أربع جولات','description_en'=>'Four-round Tarneeb tournament','fee'=>2000,'max_players'=>64,'rounds'=>4,'turn_seconds'=>10,'game'=>'tarneeb','featured'=>true,'category'=>'cup','prizes'=>['1st'=>50000,'2nd'=>15000,'3rd'=>5000]],
            'weekend'=>['name_ar'=>'كأس نهاية الأسبوع','name_en'=>'Weekend Cup','description_ar'=>'منافسة أسبوعية سريعة','description_en'=>'Fast weekly competition','fee'=>1000,'max_players'=>32,'rounds'=>3,'turn_seconds'=>10,'game'=>'trix','featured'=>true,'category'=>'cup','prizes'=>['1st'=>12000,'2nd'=>4000]],
            'elite'=>['name_ar'=>'دوري النخبة','name_en'=>'Elite League','description_ar'=>'دوري مصنف للنخبة','description_en'=>'Ranked elite league','fee'=>5000,'max_players'=>128,'rounds'=>4,'turn_seconds'=>10,'game'=>'tarneeb','featured'=>true,'category'=>'league','prizes'=>['1st'=>150000,'2nd'=>40000,'3rd'=>20000]],
            'clubs_war'=>['name_ar'=>'حرب المجموعات','name_en'=>'Club Wars','description_ar'=>'بطولة فرق المجموعات','description_en'=>'Club team competition','fee'=>10000,'max_players'=>64,'rounds'=>4,'turn_seconds'=>10,'game'=>'tarneeb','featured'=>true,'category'=>'groups','prizes'=>['1st'=>200000,'2nd'=>50000]],
            'quick'=>['name_ar'=>'المواجهة السريعة','name_en'=>'Quick Clash','description_ar'=>'مواجهة قصيرة بزمن 8 ثوانٍ','description_en'=>'Eight-second quick clash','fee'=>500,'max_players'=>16,'rounds'=>2,'turn_seconds'=>8,'game'=>'basra','featured'=>false,'category'=>'quick','prizes'=>['1st'=>4000]],
            'legend'=>['name_ar'=>'كأس الأساطير','name_en'=>'Legends Cup','description_ar'=>'أعلى منافسة موسمية','description_en'=>'Top seasonal tournament','fee'=>20000,'max_players'=>256,'rounds'=>5,'turn_seconds'=>10,'game'=>'tarneeb','featured'=>true,'category'=>'seasonal','prizes'=>['1st'=>500000,'2nd'=>150000,'3rd'=>75000]],
            'royal_league'=>['name_ar'=>'الدوري الملكي','name_en'=>'Royal League','description_ar'=>'دوري احترافي بنظام مجموعات وتصفيات','description_en'=>'Professional league with groups and playoffs','fee'=>7500,'max_players'=>96,'rounds'=>5,'turn_seconds'=>10,'game'=>'tarneeb','featured'=>true,'category'=>'league','prizes'=>['1st'=>250000,'2nd'=>90000,'3rd'=>30000]],
            'night_challenge'=>['name_ar'=>'تحدي الليل السريع','name_en'=>'Night Turbo Challenge','description_ar'=>'بطولة ليلية خاطفة بجائزة فورية','description_en'=>'Fast nightly challenge with instant rewards','fee'=>750,'max_players'=>24,'rounds'=>2,'turn_seconds'=>7,'game'=>'tarneeb','featured'=>false,'category'=>'challenge','prizes'=>['1st'=>8000,'2nd'=>2500]],
            'masters_cup'=>['name_ar'=>'كأس المحترفين','name_en'=>'Masters Cup','description_ar'=>'بطولة للمتمرسين مع جوائز وتصنيف','description_en'=>'Advanced competition with rewards and ranking points','fee'=>12000,'max_players'=>48,'rounds'=>4,'turn_seconds'=>8,'game'=>'hand_partner','featured'=>true,'category'=>'cup','prizes'=>['1st'=>160000,'2nd'=>50000,'3rd'=>20000]],
        ];
        $preset = $presets[$key] ?? $presets['quick'];
        if ($requestedFee > 0 && $requestedFee !== $preset['fee']) throw new RuntimeException('قيمة دخول المنافسة غير مطابقة لإعدادات الخادم.');
        return $preset;
    }
}
