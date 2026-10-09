<?php

namespace App\Services\Commerce;

use App\Models\{StoreItem,StoreOffer};
use Carbon\CarbonInterface;

/**
 * R36: one authoritative, auditable virtual-token quote across Web and Mobile.
 *
 * Only active, date-eligible, item-scoped offers can change a price.
 * Customer-submitted prices, percentages, and offer identifiers are ignored.
 * Multiple eligible offers never stack: the highest discount wins.
 */
class StoreOfferPricingService
{
    /** @return array{price:int,original_price:int,discount_percent:int,offer_key:?string,offer_id:?int} */
    public function quote(StoreItem $item, ?CarbonInterface $at = null): array
    {
        $price = max(0, (int) $item->price);
        $now = $at ?? now();
        $winner = null;
        $percentage = 0;

        if ($item->active) {
            $eligible = StoreOffer::query()
                ->where('active', true)
                ->where(function ($query) use ($now) {
                    $query->whereNull('starts_at')->orWhere('starts_at', '<=', $now);
                })
                ->where(function ($query) use ($now) {
                    $query->whereNull('ends_at')->orWhere('ends_at', '>=', $now);
                })
                ->orderByDesc('discount_percent')
                ->orderBy('id')
                ->get();

            foreach ($eligible as $offer) {
                $keys = is_array($offer->item_keys) ? $offer->item_keys : [];
                if (!in_array((string) $item->key, $keys, true)) continue;
                $candidate = max(0, min(95, (int) $offer->discount_percent));
                if ($candidate > $percentage) {
                    $percentage = $candidate;
                    $winner = $offer;
                }
            }
        }

        // Avoid overflow even when the admin reserve uses 64-bit BIGINT.
        $factor = 100 - $percentage;
        $discounted = intdiv($price, 100) * $factor
            + intdiv(($price % 100) * $factor + 99, 100);

        return [
            'price' => $price === 0 ? 0 : max(1, $discounted),
            'original_price' => $price,
            'discount_percent' => $percentage,
            'offer_key' => $winner?->key,
            'offer_id' => $winner?->id,
        ];
    }
}
