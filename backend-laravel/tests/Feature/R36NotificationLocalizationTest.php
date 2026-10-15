<?php

namespace Tests\Feature;

use App\Models\Notification;
use App\Models\Profile;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36NotificationLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function userWithNotification(array $title, array $body): User
    {
        $user = User::factory()->create();
        Profile::create([
            'user_id' => $user->id,
            'display_name' => 'Notification player',
            'country_code' => 'PS',
            'country_name' => 'Palestine',
        ]);
        Wallet::create(['user_id' => $user->id, 'tokens' => 1000, 'gems' => 0]);
        Notification::create([
            'user_id' => $user->id,
            'type' => 'friend_request',
            'title' => $title,
            'body' => $body,
            'url' => '/friends',
            'read' => false,
            'meta' => [],
        ]);

        return $user;
    }

    public function test_english_notifications_use_ltr_ui_and_english_payload(): void
    {
        app()->setLocale('en');
        $user = $this->userWithNotification(
            ['ar' => 'طلب صداقة جديد', 'en' => 'New friend request'],
            ['ar' => 'لديك طلب جديد', 'en' => 'You have a new request'],
        );

        $this->actingAs($user)->get('/notifications')
            ->assertOk()
            ->assertSee('dir="ltr"', false)
            ->assertSee('Notifications')
            ->assertSee('Mark all as read')
            ->assertSee('New friend request')
            ->assertSee('You have a new request')
            ->assertSee('Unread');
    }

    public function test_arabic_notifications_use_rtl_ui_and_arabic_payload(): void
    {
        app()->setLocale('ar');
        $user = $this->userWithNotification(
            ['ar' => 'طلب صداقة جديد', 'en' => 'New friend request'],
            ['ar' => 'لديك طلب جديد', 'en' => 'You have a new request'],
        );

        $this->actingAs($user)->get('/notifications')
            ->assertOk()
            ->assertSee('dir="rtl"', false)
            ->assertSee('الإشعارات')
            ->assertSee('تعليم الكل كمقروء')
            ->assertSee('طلب صداقة جديد')
            ->assertSee('لديك طلب جديد')
            ->assertSee('غير مقروء');
    }

    public function test_notification_payload_falls_back_to_the_available_language(): void
    {
        app()->setLocale('en');
        $user = $this->userWithNotification(
            ['ar' => 'دعوة بطولة'],
            ['ar' => 'لديك دعوة متاحة'],
        );

        $this->actingAs($user)->get('/notifications')
            ->assertOk()
            ->assertSee('Notifications')
            ->assertSee('دعوة بطولة')
            ->assertSee('لديك دعوة متاحة');
    }
}
