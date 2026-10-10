<?php
namespace App\Http\Controllers;

use App\Models\{CompetitionTicket,StoreItem,InventoryItem,User,StoreOffer};
use App\Services\Wallet\WalletService;
use App\Services\WarqnaPro\StoreCatalogService;
use App\Services\Commerce\StoreOfferPricingService;
use App\Services\Commerce\CommerceCatalogService;
use Illuminate\Support\Facades\{DB,Log};
use RuntimeException;
use Throwable;

class StoreController
{
    public function index(StoreCatalogService $catalog, CommerceCatalogService $commerce, StoreOfferPricingService $pricing)
    {
        $catalog->sync();
        if(auth()->check() && auth()->user()->admin_role==='primary_admin') app(\App\Services\Admin\PrimaryAdminStateService::class)->enforce(auth()->user());
        if(class_exists('\\App\\Models\\SiteSetting') && !\App\Models\SiteSetting::getValue('store_enabled',true)) return view('store.index',['items'=>collect(),'inventory'=>auth()->user()->inventoryItems()->with('storeItem')->latest()->get(),'storeDisabled'=>true]);
        $allItems=StoreItem::where('active',true)
            ->orderByRaw("CASE category WHEN 'table' THEN 10 WHEN 'card_back' THEN 20 WHEN 'pasha' THEN 30 WHEN 'profile_frame' THEN 40 WHEN 'profile_cover' THEN 50 WHEN 'name_frame' THEN 60 WHEN 'name_color' THEN 70 WHEN 'text_color' THEN 80 WHEN 'profile_color' THEN 90 WHEN 'badge' THEN 100 WHEN 'effect' THEN 110 WHEN 'emoji_pack' THEN 120 WHEN 'xp_booster' THEN 130 WHEN 'competition_ticket' THEN 140 ELSE 999 END")
            ->orderBy('price')->orderBy('id')->get();
        $grouped=$allItems->groupBy(function($item){ return $item->category==='name_frame' ? 'name_color' : $item->category; });
        $priceQuotes=$pricing->quotesFor($allItems);
        return view('store.index', [
            'items'=>$grouped,
            'priceQuotes'=>$priceQuotes,
            'inventory'=>auth()->user()->inventoryItems()->with('storeItem')->latest()->get(),
            'commerceOffers'=>StoreOffer::where('active',true)->where(fn($q)=>$q->whereNull('starts_at')->orWhere('starts_at','<=',now()))->where(fn($q)=>$q->whereNull('ends_at')->orWhere('ends_at','>=',now()))->latest()->get(),
            'commerceCatalog'=>$commerce->catalog(),
        ]);
    }


    public function offers(CommerceCatalogService $commerce)
    {
        return view('store.offers', [
            'commerceCatalog'=>$commerce->catalog(),
        ]);
    }

    public function buy(StoreItem $item, WalletService $wallet, StoreOfferPricingService $pricing)
    {
        if (class_exists('\\App\\Models\\SiteSetting') && !\App\Models\SiteSetting::getValue('store_enabled', true)) {
            return $this->friendlyFail('المتجر متوقف مؤقتًا من الإدارة.');
        }

        $user = auth()->user();
        if (!$item->duration_days && in_array($item->category, ['badge','table','pasha_style','card_back','name_color','text_color','profile_color','name_frame','effect','emoji_pack','profile_cover','profile_frame'], true)) {
            if ($user->inventoryItems()->where('store_item_id', $item->id)->exists()) {
                return $this->friendlyFail('هذا العنصر موجود لديك بالفعل. يمكنك تفعيله من مشترياتي.');
            }
        }

        $payload = $item->payload ?: [];
        $ticketDenomination = $item->category === 'competition_ticket'
            ? (int)($payload['denomination'] ?? 0)
            : 0;
        if ($item->category === 'competition_ticket' && $ticketDenomination <= 0) {
            return $this->friendlyFail('فئة التذكرة غير صحيحة.');
        }

        try {
            $purchase = DB::transaction(function () use ($user, $item, $wallet, $pricing) {
                // Serialize web and mobile purchases for the same player before wallet debit.
                User::query()->lockForUpdate()->findOrFail($user->id);
                $item = StoreItem::query()->lockForUpdate()->findOrFail($item->id);
                if (!$item->active) throw new \DomainException('inactive_item');
                // The initial preflight check is only a UX optimization. Enforce
                // permanent ownership again under the player/item transaction locks.
                if (!$item->duration_days && in_array($item->category, ['badge','table','pasha_style','card_back','name_color','text_color','profile_color','name_frame','effect','emoji_pack','profile_cover','profile_frame'], true)) {
                    if (InventoryItem::where('user_id', $user->id)
                        ->where('store_item_id', $item->id)->lockForUpdate()->exists()) {
                        throw new \DomainException('already_owned');
                    }
                }
                $payload = $item->payload ?: [];
                $ticketDenomination = $item->category === 'competition_ticket'
                    ? (int)($payload['denomination'] ?? 0) : 0;
                if ($item->category === 'competition_ticket' && $ticketDenomination <= 0)
                    throw new \DomainException('invalid_ticket');
                $quote = $pricing->quote($item);
                $expected = request()->input('expected_price');
                if ($expected !== null && (string)$expected !== (string)$quote['price'])
                    throw new \DomainException('price_changed');
                if ($quote['price'] > 0) {
                    $wallet->debit($user, (int)$quote['price'], 'store_buy', [
                        'item'=>$item->key,
                        'category'=>$item->category,
                        'original_price'=>$quote['original_price'],
                        'charged_price'=>$quote['price'],
                        'discount_percent'=>$quote['discount_percent'],
                        'offer_key'=>$quote['offer_key'],
                    ]);
                    $wallet->creditPrimaryAdminRevenue($user, (int)$quote['price'], 'store_sale_income', [
                        'item'=>$item->key,
                        'category'=>$item->category,
                    ]);
                }

                if ($item->category === 'pasha') {
                    $days = (int)($item->duration_days ?: ($payload['days'] ?? 30));
                    $profile = $user->profile()->lockForUpdate()->firstOrCreate([], [
                        'display_name'=>$user->username,
                        'country_code'=>'PS',
                        'country_name'=>country_name('PS'),
                    ]);
                    $profile->increment('pasha_days', $days);
                    return ['kind'=>'pasha', 'days'=>$days, 'quote'=>$quote];
                }

                if ($item->category === 'competition_ticket') {
                    $ticket = CompetitionTicket::firstOrCreate(
                        ['user_id'=>$user->id, 'denomination'=>$ticketDenomination],
                        ['quantity'=>0, 'total_used'=>0],
                    );
                    $ticket->increment('quantity');
                    return ['kind'=>'ticket', 'denomination'=>$ticketDenomination, 'quantity'=>(int)$ticket->fresh()->quantity, 'quote'=>$quote];
                }

                $validDays = (int)($payload['valid_days'] ?? $item->duration_days ?? 0);
                $inventory = InventoryItem::create([
                    'user_id'=>$user->id,
                    'store_item_id'=>$item->id,
                    'expires_at'=>$validDays > 0 ? now()->addDays($validDays) : null,
                ]);
                return ['kind'=>'inventory', 'inventory_id'=>$inventory->id, 'quote'=>$quote];
            });
        } catch (\DomainException $e) {
            return $this->friendlyFail(match ($e->getMessage()) {
                'price_changed' => 'تغير سعر المنتج. يرجى تحديث صفحة المتجر والتأكد من السعر الجديد.',
                'already_owned' => 'هذا العنصر موجود لديك بالفعل. يمكنك تفعيله من مشترياتي.',
                default => 'هذا المنتج غير متاح للشراء حالياً.',
            });
        } catch (RuntimeException $e) {
            return $this->friendlyFail('رصيدك من التوكنز غير كافٍ. تحتاج إلى شراء توكنز أو ترقية مستواك للحصول على مكافآت.');
        } catch (Throwable $e) {
            Log::error('Warqnaa store purchase failed', [
                'user_id'=>(int)$user->id,
                'item_id'=>(int)$item->id,
                'error'=>$e->getMessage(),
            ]);
            return $this->friendlyFail('تعذر إتمام الشراء بأمان. لم يتم خصم أي مبلغ؛ حاول مرة أخرى بعد تحديث المتجر.');
        }

        if ($purchase['kind'] === 'pasha') {
            return $this->friendlyOk('✅ تم شراء '.$purchase['days'].' يوم باشا.', ['pricing'=>$purchase['quote']]);
        }
        if ($purchase['kind'] === 'ticket') {
            return $this->friendlyOk('✅ تم شراء تذكرة منافسة بقيمة '.$purchase['denomination'].' توكنز.', [
                'ticket'=>['denomination'=>$purchase['denomination'], 'quantity'=>$purchase['quantity']],
                'pricing'=>$purchase['quote'],
            ]);
        }

        return $this->friendlyOk('✅ تم شراء '.($item->name['ar'] ?? $item->key).' بنجاح. تم خصم التوكنز وتحويل قيمة الشراء إلى حساب الإدارة وإضافة العنصر إلى مشترياتك.', [
            'inventory_id'=>$purchase['inventory_id'],
            'pricing'=>$purchase['quote'],
            'item'=>[
                'id'=>$item->id,
                'name'=>$item->name['ar'] ?? $item->key,
                'category'=>$item->category,
                'key'=>$item->key,
                'payload'=>$payload,
                'duration_days'=>$item->duration_days,
            ],
            'category'=>$item->category,
            'payload'=>$payload,
        ]);
    }

    public function activate(InventoryItem $inventory)
    {
        abort_unless($inventory->user_id===auth()->id(),403);
        try {
            $item = DB::transaction(function () use ($inventory) {
                $user = auth()->user();
                User::query()->lockForUpdate()->findOrFail($user->id);
                $owned = InventoryItem::query()->where('user_id', $user->id)
                    ->lockForUpdate()->findOrFail($inventory->id);
                $item = $owned->storeItem;
                if (!$item) throw new \DomainException('missing_item');
                if ($owned->expires_at && $owned->expires_at->lte(now())) {
                    throw new \DomainException('expired');
                }
                if ($item->category === 'xp_booster' && $owned->activated_at !== null) {
                    throw new \DomainException('already_activated');
                }

                // Equipping an owned cosmetic NEVER renews the purchased expiry.
                if (in_array($item->category, ['name_color','text_color','profile_color','badge','table','pasha_style','xp_booster','card_back','name_frame','effect','emoji_pack','profile_cover','profile_frame'], true)) {
                    InventoryItem::where('user_id', $user->id)
                        ->whereHas('storeItem', fn ($query) => $query->where('category', $item->category))
                        ->update(['active' => false]);
                }
                $payload = $item->payload ?: [];
                $booster = $item->category === 'xp_booster';
                $expiry = $booster
                    ? now()->addHours(max(1, min(168, (int) ($payload['activate_hours'] ?? 24))))
                    : $owned->expires_at;
                $owned->update([
                    'active' => true,
                    'activated_at' => $owned->activated_at ?? now(),
                    'expires_at' => $expiry,
                ]);
            $profile=auth()->user()->profile;
            if($profile){
                if($item->category==='name_color' && isset($payload['color'])) { $profile->name_color=$payload['color']; $profile->active_name_frame=$payload['frame'] ?? $payload['glow'] ?? ('glow-'.str_replace('#','',$payload['color'])); }
                if($item->category==='text_color' && isset($payload['color'])) { $profile->chat_color=$payload['color']; $profile->text_color=$payload['color']; }
                if($item->category==='profile_color') { $gradient=(array)($payload['gradient'] ?? []); $profile->active_profile_color=count($gradient)>=2 ? implode('|',array_slice($gradient,0,2)) : ($payload['color'] ?? $item->key); $profile->profile_color_expires_at=$expiry; }
                if($item->category==='badge') $profile->badge=$payload['badge'] ?? $item->key;
                if($item->category==='table') $profile->active_table_skin=$payload['table'] ?? $item->key;
                if($item->category==='pasha_style') {
                    $profile->pasha_style=$payload['style'] ?? 'red';
                    if(isset($payload['color1'])) { $profile->name_color=$payload['color1']; $profile->chat_color=$payload['color1']; $profile->text_color=$payload['color1']; }
                }
                if($item->category==='card_back') $profile->active_card_back=$payload['card_back'] ?? $item->key;
                if($item->category==='name_frame') { $profile->active_name_frame=$payload['frame'] ?? $item->key; if(isset($payload['color'])) $profile->name_color=$payload['color']; }
                if($item->category==='effect') { if(isset($payload['theme'])) $profile->active_site_theme=(string)$payload['theme']; else $profile->active_effect=$payload['effect'] ?? $item->key; }
                if($item->category==='profile_cover') $profile->active_profile_cover=$payload['cover'] ?? $item->key;
                if($item->category==='xp_booster') { $profile->xp_boost_multiplier=(float)($payload['multiplier'] ?? 1.25); $profile->xp_boost_expires_at=$expiry; }
                $profile->save();
            }
            return $item;
            });
        } catch (\DomainException $e) {
            $message = match ($e->getMessage()) {
                'expired' => 'انتهت صلاحية العنصر. يلزم شراء صلاحية جديدة.',
                'already_activated' => 'تم استخدام المسرّع مسبقاً ولا يمكن تفعيله مجدداً.',
                default => 'العنصر غير متاح للتفعيل.',
            };
            if (request()->expectsJson() || request()->ajax()) {
                return response()->json(['ok'=>false, 'message'=>$message], $e->getMessage()==='expired' ? 410 : 409);
            }
            return back()->withErrors(['msg'=>$message]);
        }
        return $this->friendlyOk('تم التفعيل بنجاح', [
            'activated'=>true, 'category'=>$item->category,
            'payload'=>$item->payload ?: [], 'inventory_id'=>$inventory->id,
        ]);
    }
    private function friendlyOk(string $message, array $extra=[]){ if(request()->expectsJson() || request()->ajax()) return response()->json(array_merge(['ok'=>true,'message'=>$message],$extra)); return back()->with('ok',$message); }
    private function friendlyFail(string $message){ if(request()->expectsJson() || request()->ajax()) return response()->json(['ok'=>false,'message'=>$message],200); return back()->withErrors(['msg'=>$message]); }
}

