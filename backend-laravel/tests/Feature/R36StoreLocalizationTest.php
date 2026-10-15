<?php

namespace Tests\Feature;

use App\Models\Profile;
use App\Models\StoreItem;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36StoreLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function authenticatedUser(): User
    {
        $user = User::factory()->create();
        Profile::create([
            'user_id' => $user->id,
            'display_name' => 'Store player',
            'country_code' => 'PS',
            'country_name' => 'Palestine',
        ]);
        Wallet::create(['user_id' => $user->id, 'tokens' => 1000, 'gems' => 0]);
        StoreItem::create([
            'key' => 'r36_bilingual_search_probe',
            'name' => ['ar' => 'اختبار البحث', 'en' => 'Search Probe'],
            'description' => ['ar' => 'عنصر اختبار', 'en' => 'Test item'],
            'category' => 'text_color',
            'price' => 100,
            'active' => true,
            'payload' => ['color' => '#25e4df'],
        ]);

        return $user;
    }

    public function test_english_store_localizes_controls_descriptions_and_empty_inventory(): void
    {
        app()->setLocale('en');
        $response = $this->actingAs($this->authenticatedUser())->get('/store');

        $response->assertOk()
            ->assertSee('dir="ltr"', false)
            ->assertSee('Search this category only...')
            ->assertSee('Everything you own appears here for activation and preview.')
            ->assertSee('All tables appear here, with a preview before purchase.')
            ->assertSee('No items match your search or filters.')
            ->assertSee('const resultPrefix=', false)
            ->assertSee("replace(/[أإآٱ]/g,'ا')", false)
            ->assertSee('اختبار البحث Search Probe r36_bilingual_search_probe text_color', false)
            ->assertSee('>Preview<', false)
            ->assertSee('>Buy<', false)
            ->assertDontSee('ابحث داخل القسم الحالي فقط...')
            ->assertDontSee('كل ما تملكه يظهر هنا للتفعيل والمعاينة.');
    }

    public function test_arabic_store_keeps_rtl_controls_and_category_descriptions(): void
    {
        app()->setLocale('ar');
        $response = $this->actingAs($this->authenticatedUser())->get('/store');

        $response->assertOk()
            ->assertSee('dir="rtl"', false)
            ->assertSee('ابحث داخل القسم الحالي فقط...')
            ->assertSee('كل ما تملكه يظهر هنا للتفعيل والمعاينة.')
            ->assertSee('كل الطاولات هنا فقط، مع معاينة شكل الطاولة قبل الشراء.')
            ->assertSee('لا توجد عناصر تطابق البحث أو عوامل التصفية.')
            ->assertSee('اختبار البحث Search Probe r36_bilingual_search_probe text_color', false)
            ->assertSee('>معاينة<', false)
            ->assertSee('>شراء<', false);
    }
}
