<?php

namespace App\Http\Controllers;

use App\Models\{EconomySeason, RareCollectible, StoreItem, StoreOffer};
use App\Services\Platform\AdminAuditService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AdminEconomyOperationsController extends Controller
{
    private function authorizeEconomy(Request $request): void
    {
        abort_unless($request->user()?->is_admin && $request->user()?->hasAdminPermission('economy'), 403);
    }

    public function saveSeason(Request $request, AdminAuditService $audit)
    {
        $this->authorizeEconomy($request);
        $data = $request->validate([
            'key' => ['required', 'regex:/^[a-z0-9_-]{3,80}$/i'],
            'name_ar' => 'required|string|min:2|max:120',
            'name_en' => 'nullable|string|max:120',
            'starts_at' => 'required|date',
            'ends_at' => 'required|date|after:starts_at',
            'active' => 'nullable|boolean',
        ]);
        DB::transaction(function () use ($request, $data, $audit): void {
            $season = EconomySeason::query()->lockForUpdate()->firstOrNew(['key' => $data['key']]);
            $before = $season->exists ? $season->toArray() : null;
            $season->fill([
                'name' => ['ar' => $data['name_ar'], 'en' => $data['name_en'] ?: $data['name_ar']],
                'starts_at' => $data['starts_at'],
                'ends_at' => $data['ends_at'],
                'active' => $request->boolean('active'),
            ])->save();
            $audit->record($request, 'admin.economy.season.save', $season, $before, $season->fresh()->toArray());
        });
        return back()->with('ok', 'تم حفظ الموسم في قاعدة البيانات.');
    }

    public function saveOffer(Request $request, AdminAuditService $audit)
    {
        $this->authorizeEconomy($request);
        $data = $request->validate([
            'key' => ['required', 'regex:/^[a-z0-9_-]{3,80}$/i'],
            'title_ar' => 'required|string|min:2|max:120',
            'title_en' => 'nullable|string|max:120',
            'discount_percent' => 'required|integer|min:0|max:95',
            'item_keys' => 'required|string|max:4000',
            'starts_at' => 'required|date',
            'ends_at' => 'required|date|after:starts_at',
            'active' => 'nullable|boolean',
        ]);
        $keys = array_values(array_unique(array_filter(array_map('trim', explode(',', $data['item_keys'])))));
        if (!$keys || count($keys) > 60 || StoreItem::whereIn('key', $keys)->where('active', true)->count() !== count($keys)) {
            throw ValidationException::withMessages(['item_keys' => 'حدد مفاتيح منتجات فعّالة من المتجر، مفصولة بفواصل.']);
        }
        DB::transaction(function () use ($request, $data, $keys, $audit): void {
            $offer = StoreOffer::query()->lockForUpdate()->firstOrNew(['key' => $data['key']]);
            $before = $offer->exists ? $offer->toArray() : null;
            $offer->fill([
                'title' => ['ar' => $data['title_ar'], 'en' => $data['title_en'] ?: $data['title_ar']],
                'description' => ['ar' => 'خصم محدود المدة', 'en' => 'Time-limited promotion'],
                'discount_percent' => (int)$data['discount_percent'],
                'item_keys' => $keys,
                'starts_at' => $data['starts_at'],
                'ends_at' => $data['ends_at'],
                'active' => $request->boolean('active'),
            ])->save();
            $audit->record($request, 'admin.economy.offer.save', $offer, $before, $offer->fresh()->toArray());
        });
        return back()->with('ok', 'تم حفظ العرض وربطه بالمنتجات المختارة.');
    }

    public function saveRare(Request $request, AdminAuditService $audit)
    {
        $this->authorizeEconomy($request);
        $data = $request->validate([
            'key' => ['required', 'regex:/^[a-z0-9_-]{3,80}$/i'],
            'name_ar' => 'required|string|min:2|max:120',
            'name_en' => 'nullable|string|max:120',
            'rarity' => 'required|in:rare,epic,legendary,mythic',
            'supply' => 'required|integer|min:0|max:1000000',
            'active' => 'nullable|boolean',
        ]);
        DB::transaction(function () use ($request, $data, $audit): void {
            $rare = RareCollectible::query()->lockForUpdate()->firstOrNew(['key' => $data['key']]);
            if ($rare->exists && (int)$rare->claimed > (int)$data['supply']) {
                throw ValidationException::withMessages(['supply' => 'لا يمكن تقليل العدد المتاح عن العدد الممنوح سابقاً.']);
            }
            $before = $rare->exists ? $rare->toArray() : null;
            $rare->fill([
                'name' => ['ar' => $data['name_ar'], 'en' => $data['name_en'] ?: $data['name_ar']],
                'rarity' => $data['rarity'],
                'supply' => $data['supply'],
                'active' => $request->boolean('active'),
            ])->save();
            $audit->record($request, 'admin.economy.rare.save', $rare, $before, $rare->fresh()->toArray());
        });
        return back()->with('ok', 'تم حفظ المقتنى النادر دون إعادة ضبط عدد الممنوح.');
    }
}
