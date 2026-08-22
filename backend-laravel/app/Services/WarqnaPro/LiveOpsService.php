<?php
namespace App\Services\WarqnaPro;

use App\Models\SiteSetting;

class LiveOpsService
{
    /** R9 exposes a stable live-ops contract; R10 will attach real-money products and ad-network verification. */
    public function center(): array
    {
        return [
            'version'=>'r9',
            'ads'=>[
                'rewarded_enabled'=>$this->bool('ads_rewarded_enabled', true),
                'interstitial_enabled'=>$this->bool('ads_interstitial_enabled', false),
                'in_match_ads'=>false,
                'rewarded_daily_cap'=>(int)$this->value('ads_rewarded_daily_cap', 5),
                'rewarded_tokens'=>(int)$this->value('ads_rewarded_tokens', 50),
            ],
            'offers'=>[
                'daily'=>['enabled'=>$this->bool('offer_daily_enabled', true),'rotation_hours'=>24],
                'weekly'=>['enabled'=>$this->bool('offer_weekly_enabled', true),'rotation_hours'=>168],
                'monthly'=>['enabled'=>$this->bool('offer_monthly_enabled', true),'rotation_hours'=>720],
                'annual'=>['enabled'=>$this->bool('offer_annual_enabled', true),'rotation_hours'=>8760],
            ],
            'rewards'=>[
                'wheel_cooldown_hours'=>12,
                'free_box_cooldown_hours'=>12,
            ],
        ];
    }

    private function value(string $key, mixed $default): mixed
    {
        if(!class_exists(SiteSetting::class)) return $default;
        return SiteSetting::getValue($key,$default);
    }

    private function bool(string $key, bool $default): bool
    {
        return filter_var($this->value($key,$default), FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE) ?? $default;
    }
}
