<?php
namespace Tests\Feature;

use App\Models\{Profile,RewardedAdClaim,RewardedAdSession,User,Wallet,WalletTransaction};
use App\Services\Commerce\AdMobSsvVerifier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\{Cache,Hash,Http};
use Tests\TestCase;

class R52AdMobSsvTest extends TestCase
{
    use RefreshDatabase;
    private User $player;
    private \OpenSSLAsymmetricKey $signer;

    protected function setUp(): void
    {
        parent::setUp();
        config(['warqna_commerce.ads.ssv_enabled'=>true,'warqna_commerce.ads.ssv_ad_units'=>['1234567890']]);
        Cache::forget('warqnaa.admob.ssv.keys');
        $this->signer=openssl_pkey_new(['private_key_type'=>OPENSSL_KEYTYPE_EC,'curve_name'=>'prime256v1']);
        $public=openssl_pkey_get_details($this->signer)['key'];
        Http::fake([AdMobSsvVerifier::KEYS_URL=>Http::response(['keys'=>[['keyId'=>52,'pem'=>$public]]])]);
        $this->player=User::create(['username'=>'AdPlayer','email'=>'adplayer@example.test','password'=>Hash::make(bin2hex(random_bytes(16))),'is_admin'=>false]);
        Profile::create(['user_id'=>$this->player->id,'display_name'=>'AdPlayer','level'=>app(\App\Services\Leveling\XpService::class)->levelForXp(100000),'xp'=>100000]);
        Wallet::create(['user_id'=>$this->player->id,'tokens'=>1000,'gems'=>0]);
        $this->withToken($this->player->createToken('r52-ad')->plainTextToken);
    }

    private function signed(array $session,array $overrides=[]): string
    {
        $parameters=array_merge(['ad_network'=>'5450213213286189855','ad_unit'=>'1234567890','custom_data'=>$session['session_id'],
            'reward_amount'=>'999999','reward_item'=>'tokens','timestamp'=>(string)now()->getTimestampMs(),
            'transaction_id'=>bin2hex(random_bytes(16)),'user_id'=>(string)$this->player->id],$overrides);
        ksort($parameters);$signed=http_build_query($parameters,'','&',PHP_QUERY_RFC3986);
        openssl_sign($signed,$signature,$this->signer,OPENSSL_ALGO_SHA256);
        return $signed.'&signature='.rtrim(strtr(base64_encode($signature),'+/','-_'),'=').'&key_id=52';
    }

    public function test_only_a_signed_callback_can_credit_once_and_client_cannot_set_amount(): void
    {
        $session=$this->postJson('/api/mobile/v1/rewards/ad-sessions',[])->assertOk()->json();
        $this->assertSame(1000,(int)$this->player->wallet()->first()->tokens);
        $this->getJson('/api/mobile/v1/rewards/ad-sessions/'.$session['session_id'])->assertJsonPath('status','pending');
        $query=$this->signed($session);
        $this->getJson('/api/mobile/v1/ads/admob/ssv?'.$query)->assertOk();
        $this->getJson('/api/mobile/v1/ads/admob/ssv?'.$query)->assertOk();
        $this->assertSame(1050,(int)$this->player->wallet()->first()->tokens);
        $this->assertSame(1,RewardedAdClaim::count());
        $this->assertSame(1,WalletTransaction::where('type','rewarded_ad')->count());
        $this->assertSame(15,RewardedAdClaim::first()->reward_xp);
        $this->getJson('/api/mobile/v1/rewards/ad-sessions/'.$session['session_id'])->assertJsonPath('status','rewarded')->assertJsonPath('tokens',50);
    }

    public function test_tampered_wrong_user_unit_expired_or_unsigned_callbacks_do_not_credit(): void
    {
        $session=$this->postJson('/api/mobile/v1/rewards/ad-sessions')->assertOk()->json();
        $good=$this->signed($session);
        $this->getJson('/api/mobile/v1/ads/admob/ssv?'.str_replace('reward_amount=999999','reward_amount=1',$good))->assertForbidden();
        foreach([['user_id'=>'999999'],['ad_unit'=>'unexpected'],['timestamp'=>(string)now()->subDays(2)->getTimestampMs()]] as $change)
            $this->getJson('/api/mobile/v1/ads/admob/ssv?'.$this->signed($session,$change))->assertForbidden();
        $this->getJson('/api/mobile/v1/ads/admob/ssv?custom_data='.$session['session_id'])->assertForbidden();
        $this->assertSame(0,RewardedAdClaim::count());
        $this->assertSame(1000,(int)$this->player->wallet()->first()->tokens);
    }

    public function test_configuration_is_required_and_reward_status_is_private(): void
    {
        config(['warqna_commerce.ads.ssv_enabled'=>false]);
        $this->postJson('/api/mobile/v1/rewards/ad-sessions')->assertStatus(503);
        config(['warqna_commerce.ads.ssv_enabled'=>true]);
        $session=$this->postJson('/api/mobile/v1/rewards/ad-sessions')->assertOk()->json();
        RewardedAdSession::whereKey($session['session_id'])->update(['expires_at'=>now()->subMinute()]);
        $this->getJson('/api/mobile/v1/rewards/ad-sessions/'.$session['session_id'])->assertJsonPath('status','expired');
        $this->getJson('/api/mobile/v1/ads/admob/ssv?'.$this->signed($session))->assertForbidden();
        $other=User::create(['username'=>'AdOther','email'=>'adother@example.test','password'=>Hash::make(bin2hex(random_bytes(16))),'is_admin'=>false]);
        $this->withToken($other->createToken('r52-other')->plainTextToken)
            ->getJson('/api/mobile/v1/rewards/ad-sessions/'.$session['session_id'])->assertNotFound();
    }

    public function test_daily_cap_is_enforced_after_eight_verified_rewards(): void
    {
        for($i=0;$i<8;$i++) {
            $session=$this->postJson('/api/mobile/v1/rewards/ad-sessions')->assertOk()->json();
            $this->getJson('/api/mobile/v1/ads/admob/ssv?'.$this->signed($session))->assertOk();
        }
        $this->postJson('/api/mobile/v1/rewards/ad-sessions')->assertStatus(429);
        $this->assertSame(8,RewardedAdClaim::count());
        $this->assertSame(1400,(int)$this->player->wallet()->first()->tokens);
    }
}
