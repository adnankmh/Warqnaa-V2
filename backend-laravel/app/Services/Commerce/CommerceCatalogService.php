<?php
namespace App\Services\Commerce;

use App\Models\StoreOffer;
use App\Models\SiteSetting;

class CommerceCatalogService
{
    public function catalog(): array
    {
        $packages=[];
        foreach ((array) config('warqna_commerce.packages',[]) as $key=>$row) {
            $packages[]=[
                'key'=>$key,
                'product_id'=>$row['product_id'] ?? $key,
                'price_minor'=>(int)($row['usd_minor'] ?? 0),
                'currency'=>'USD',
                'tokens'=>(int)($row['tokens'] ?? 0),
                'badge'=>$row['badge'] ?? '',
                'icon'=>$row['icon'] ?? '🪙',
            ];
        }
        $offers=StoreOffer::query()
            ->where('active',true)
            ->where(fn($q)=>$q->whereNull('starts_at')->orWhere('starts_at','<=',now()))
            ->where(fn($q)=>$q->whereNull('ends_at')->orWhere('ends_at','>=',now()))
            ->orderBy('ends_at')->get()->map(fn($offer)=>[
                'key'=>$offer->key,
                'title'=>$offer->title,
                'description'=>$offer->description,
                'discount_percent'=>(int)$offer->discount_percent,
                'starts_at'=>$offer->starts_at?->toIso8601String(),
                'ends_at'=>$offer->ends_at?->toIso8601String(),
                'item_keys'=>$offer->item_keys ?: [],
            ])->values()->all();
        return [
            'enabled'=>(bool)SiteSetting::getValue('commerce_enabled',config('warqna_commerce.enabled',true)),
            'sandbox'=>(bool)config('warqna_commerce.sandbox',false),
            'packages'=>$packages,
            'offers'=>$offers,
            'ads'=>array_merge((array)config('warqna_commerce.ads',[]),[
                'rewarded'=>SiteSetting::getValue('ads_rewarded_enabled',true),
                'interstitial'=>SiteSetting::getValue('ads_interstitial_enabled',true),
                'during_match'=>false,
            ]),
            'cadences'=>(array)config('warqna_commerce.offer_cadences',[]),
        ];
    }
}
