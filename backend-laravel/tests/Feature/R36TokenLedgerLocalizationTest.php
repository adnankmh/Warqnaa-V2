<?php

namespace Tests\Feature;

use App\Models\Profile;
use App\Models\User;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R36TokenLedgerLocalizationTest extends TestCase
{
    use RefreshDatabase;

    private function player(string $username, int $tokens=1000, bool $admin=false): User
    {
        $user=User::factory()->create([
            'username'=>$username,
            'is_admin'=>$admin,
        ]);
        Profile::create([
            'user_id'=>$user->id,
            'display_name'=>$username,
            'country_code'=>'PS',
            'country_name'=>'Palestine',
        ]);
        Wallet::create(['user_id'=>$user->id,'tokens'=>$tokens,'gems'=>0]);

        return $user;
    }

    public function test_english_token_ledger_is_complete_ltr_and_matches_server_limits(): void
    {
        app()->setLocale('en');
        $user=$this->player('ledger_english');

        $this->actingAs($user)->get('/tokens')
            ->assertOk()
            ->assertSee('dir="ltr"',false)
            ->assertSee('Token history')
            ->assertSee('Current balance')
            ->assertSee('Total received')
            ->assertSee('Send tokens to a player')
            ->assertSee('A 10% transfer fee is charged to the sender.')
            ->assertSee('min="10"',false)
            ->assertSee('max="100000000"',false)
            ->assertSee('Recent transactions')
            ->assertSee('Purchases &amp; spending',false)
            ->assertSee('No transactions yet.')
            ->assertDontSee('لا توجد عمليات بعد.');
    }

    public function test_arabic_token_ledger_keeps_rtl_content(): void
    {
        app()->setLocale('ar');
        $user=$this->player('ledger_arabic');

        $this->actingAs($user)->get('/tokens')
            ->assertOk()
            ->assertSee('dir="rtl"',false)
            ->assertSee('سجل التوكنز')
            ->assertSee('رصيدك الحالي')
            ->assertSee('إجمالي الداخل')
            ->assertSee('إرسال توكنز للاعب')
            ->assertSee('تُخصم عمولة تحويل بنسبة 10% من المرسل.')
            ->assertSee('كل الحركات الأخيرة')
            ->assertSee('لا توجد عمليات بعد.');
    }

    public function test_english_transfer_moves_exact_amount_and_fee_and_localizes_ledger(): void
    {
        app()->setLocale('en');
        $admin=$this->player('ledger_fee_admin',1000,true);
        $sender=$this->player('ledger_sender',1000);
        $receiver=$this->player('ledger_receiver',100);

        $this->actingAs($sender)
            ->withHeader('X-Requested-With','XMLHttpRequest')
            ->post('/wallet/transfer',['receiver'=>$receiver->username,'amount'=>100])
            ->assertOk()
            ->assertJson([
                'ok'=>true,
                'message'=>'100 tokens sent successfully. A 10% fee was deducted.',
            ]);

        $this->assertSame(890,(int)$sender->wallet->fresh()->tokens);
        $this->assertSame(200,(int)$receiver->wallet->fresh()->tokens);
        $this->assertSame(1010,(int)$admin->wallet->fresh()->tokens);
        $this->assertFalse((bool)$sender->fresh()->is_admin);
        $this->assertTrue((bool)$admin->fresh()->is_admin);

        $sent=WalletTransaction::where('user_id',$sender->id)->where('type','transfer_sent')->sole();
        $this->assertSame(-110,(int)$sent->amount);
        $this->assertSame(10,(int)$sent->fee);
        $this->assertSame($receiver->id,(int)$sent->counterparty_id);
        $this->assertSame(10,(int)$sent->meta['fee']);

        $this->actingAs($sender)->get('/tokens')
            ->assertOk()
            ->assertSee('Sent transfer')
            ->assertSee('Fee: 10')
            ->assertSee('-110');
    }

    public function test_transfer_errors_follow_active_language_without_mutating_balances(): void
    {
        $sender=$this->player('ledger_errors',100);
        $receiver=$this->player('ledger_error_receiver',100);

        app()->setLocale('en');
        $this->actingAs($sender)
            ->withHeader('X-Requested-With','XMLHttpRequest')
            ->post('/wallet/transfer',['receiver'=>'missing_player','amount'=>10])
            ->assertJson(['ok'=>false,'message'=>'The receiving player was not found.']);

        $this->actingAs($sender)
            ->withHeader('X-Requested-With','XMLHttpRequest')
            ->post('/wallet/transfer',['receiver'=>$receiver->username,'amount'=>100])
            ->assertJson([
                'ok'=>false,
                'message'=>'Your balance is insufficient. The total including the fee is 110 tokens.',
            ]);

        app()->setLocale('ar');
        $this->actingAs($sender)
            ->withHeader('X-Requested-With','XMLHttpRequest')
            ->post('/wallet/transfer',['receiver'=>$sender->username,'amount'=>10])
            ->assertJson(['ok'=>false,'message'=>'لا يمكنك إرسال التوكنز لنفسك.']);

        $this->assertSame(100,(int)$sender->wallet->fresh()->tokens);
        $this->assertSame(100,(int)$receiver->wallet->fresh()->tokens);
        $this->assertSame(0,WalletTransaction::count());
    }
}
