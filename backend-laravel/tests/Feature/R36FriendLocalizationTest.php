<?php

namespace Tests\Feature;

use App\Models\Friendship;
use App\Models\Notification;
use App\Models\Profile;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36FriendLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function player(string $username): User
    {
        $user=User::factory()->create(['username'=>$username]);
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>$username,
            'country_code'=>'PS',
            'country_name'=>'Palestine',
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>1000,'gems'=>0]);
        return $user;
    }

    private function socialFixture(): array
    {
        $viewer=$this->player('viewer_r36');
        $incoming=$this->player('incoming_r36');
        $outgoing=$this->player('outgoing_r36');
        $accepted=$this->player('accepted_r36');
        $blocked=$this->player('blocked_r36');

        Friendship::create(['requester_id'=>$incoming->id,'addressee_id'=>$viewer->id,'status'=>'pending']);
        Friendship::create(['requester_id'=>$viewer->id,'addressee_id'=>$outgoing->id,'status'=>'pending']);
        Friendship::create(['requester_id'=>$viewer->id,'addressee_id'=>$accepted->id,'status'=>'accepted']);
        Friendship::create(['requester_id'=>$viewer->id,'addressee_id'=>$blocked->id,'status'=>'blocked']);

        return compact('viewer','incoming','outgoing','accepted','blocked');
    }

    public function test_english_friends_page_localizes_every_relationship_state(): void
    {
        app()->setLocale('en');
        $users=$this->socialFixture();

        $this->actingAs($users['viewer'])->get('/friends')
            ->assertOk()
            ->assertSee('dir="ltr"',false)
            ->assertSee('Friends &amp; Requests',false)
            ->assertSee('Incoming requests')
            ->assertSee('Sent requests')
            ->assertSee('Blocked players')
            ->assertSee('Accept')
            ->assertSee('Decline')
            ->assertSee('Cancel request')
            ->assertSee('Message')
            ->assertSee('Unblock')
            ->assertSee('incoming_r36')
            ->assertSee('outgoing_r36')
            ->assertSee('accepted_r36')
            ->assertSee('blocked_r36');
    }

    public function test_arabic_friends_page_keeps_rtl_and_arabic_actions(): void
    {
        app()->setLocale('ar');
        $users=$this->socialFixture();

        $this->actingAs($users['viewer'])->get('/friends')
            ->assertOk()
            ->assertSee('dir="rtl"',false)
            ->assertSee('الأصدقاء وطلبات الصداقة')
            ->assertSee('طلبات واردة')
            ->assertSee('طلبات مرسلة')
            ->assertSee('المحظورون')
            ->assertSee('قبول')
            ->assertSee('رفض')
            ->assertSee('إلغاء الطلب')
            ->assertSee('رسالة')
            ->assertSee('إلغاء الحظر');
    }

    public function test_friend_request_returns_localized_message_and_creates_bilingual_notification(): void
    {
        app()->setLocale('en');
        $sender=$this->player('sender_r36');
        $recipient=$this->player('recipient_r36');

        $this->actingAs($sender)->postJson(route('friends.request',$recipient))
            ->assertOk()
            ->assertJson([
                'ok'=>true,
                'message'=>'Friend request sent',
                'status'=>'pending',
            ]);

        $notification=Notification::where('user_id',$recipient->id)->where('type','friend_request')->firstOrFail();
        $this->assertSame('طلب صداقة',$notification->title['ar']);
        $this->assertSame('Friend request',$notification->title['en']);
        $this->assertSame('sender_r36 أرسل لك طلب صداقة',$notification->body['ar']);
        $this->assertSame('sender_r36 sent you a friend request',$notification->body['en']);
    }
}
