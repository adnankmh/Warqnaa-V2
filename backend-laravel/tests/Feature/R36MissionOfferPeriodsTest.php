<?php

namespace Tests\Feature;

use App\Models\{ChallengeDefinition,StoreItem,StoreOffer,User};
use App\Services\Commerce\StoreOfferPricingService;
use App\Services\WarqnaPro\ChallengeService;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36MissionOfferPeriodsTest extends TestCase
{
    use RefreshDatabase;

    protected function tearDown(): void { Carbon::setTestNow(); parent::tearDown(); }

    public function test_daily_weekly_and_seasonal_reset_times_come_from_the_server(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-10-14T12:00:00+00:00'));
        $user=User::factory()->create();$service=app(ChallengeService::class);
        foreach(['daily'=>'2026-10-15','weekly'=>'2026-10-19','seasonal'=>'2026-11-01'] as $cadence=>$date) {
            $definition=ChallengeDefinition::create(['key'=>'r36_'.$cadence,'name'=>['ar'=>'مهمة','en'=>'Mission'],
                'description'=>[],'cadence'=>$cadence,'metric'=>'r36_wins','target'=>2,'reward_tokens'=>10,'reward_xp'=>0,
                'settings'=>[],'active'=>true,'sort_order'=>1]);
            $payload=$service->activate($user,$definition->key);
            $this->assertSame($date,Carbon::parse($payload['resets_at'])->toDateString());
            $this->assertTrue(Carbon::parse($payload['resets_at'])->gt(Carbon::parse($payload['server_time'])));
        }
        $service->record($user,'r36_wins',1);
        Carbon::setTestNow(Carbon::parse('2026-10-15T00:00:01+00:00'));
        $rows=collect($service->center($user));
        $this->assertSame(0,$rows->firstWhere('key','r36_daily')['progress']);
        $this->assertSame(1,$rows->firstWhere('key','r36_weekly')['progress']);
        $this->assertSame(1,$rows->firstWhere('key','r36_seasonal')['progress']);
    }

    public function test_offer_cadence_and_expiry_describe_the_actual_scoped_discount(): void
    {
        Carbon::setTestNow('2026-10-14 12:00:00');
        $item=StoreItem::create(['key'=>'r36_offer_item','category'=>'pasha','name'=>['ar'=>'عضوية'],'price'=>400,'active'=>true]);
        $offer=StoreOffer::create(['key'=>'r36_daily_offer','title'=>['ar'=>'عرض'],'discount_percent'=>25,
            'starts_at'=>now()->subHour(),'ends_at'=>now()->addHours(23),'active'=>true,'item_keys'=>[$item->key]]);
        $service=app(StoreOfferPricingService::class);$quote=$service->quote($item);
        $this->assertSame(300,$quote['price']);$this->assertSame('daily',$quote['offer_cadence']);
        $this->assertSame($offer->ends_at->toIso8601String(),$quote['offer_ends_at']);
        $offer->update(['starts_at'=>now()->subDay(),'ends_at'=>now()->addDays(6)]);
        $this->assertSame('weekly',$service->quote($item)['offer_cadence']);
        $offer->update(['ends_at'=>now()->subSecond()]);
        $this->assertSame(400,$service->quote($item)['price']);
        $this->assertNull($service->quote($item)['offer_cadence']);
    }
}
