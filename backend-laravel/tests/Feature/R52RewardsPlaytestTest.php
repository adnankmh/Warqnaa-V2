<?php

namespace Tests\Feature;

use App\Models\{PrizeBox,Profile,StoreItem,User,Wallet};
use App\Services\WarqnaPro\{LuckyWheelService,PrizeBoxService};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class R52RewardsPlaytestTest extends TestCase
{
    use RefreshDatabase;

    private function player(string $name): User
    {
        $user=User::create(['username'=>$name,'email'=>$name.'@example.test','password'=>Hash::make(bin2hex(random_bytes(16))),'is_admin'=>false]);
        Profile::create(['user_id'=>$user->id,'display_name'=>$name,'locale'=>'ar']);
        Wallet::create(['user_id'=>$user->id,'tokens'=>10000,'gems'=>0]);
        return $user;
    }

    public function test_reward_table_uses_a_separate_sku_and_preserves_paid_price(): void
    {
        $user=$this->player('RewardTable');
        $paid=StoreItem::create(['key'=>'table_v173_royal_09','category'=>'table','name'=>['ar'=>'ملكية','en'=>'Royal'],'price'=>50000,'currency'=>'tokens','active'=>true,'payload'=>['asset_key'=>'table_v173_royal_09']]);
        $box=app(PrizeBoxService::class)->awardForCompletedGame($user,'r52-table','hand','normal',true);
        $reward=LuckyWheelService::segments()[5]['reward'];
        $result=app(PrizeBoxService::class)->open($user,$box,$reward);
        $this->assertSame('table',$result['reward']['type']);
        $this->assertSame('table_v173_royal_09',$user->profile()->first()->active_table_skin);
        $this->assertSame(50000,(int)$paid->fresh()->price);
        $this->assertDatabaseHas('store_items',['key'=>'r52_reward_royal_table_24h','price'=>0]);
        $this->assertNotNull($result['reward']['expires_at']);
    }

    public function test_web_rewards_require_auth_and_enforce_box_ownership_and_single_open(): void
    {
        $this->get('/rewards')->assertRedirect('/login');
        $owner=$this->player('BoxOwner');$other=$this->player('OtherPlayer');
        $box=app(PrizeBoxService::class)->awardForCompletedGame($owner,'r52-box','hand','normal',true);
        $this->actingAs($other)->post('/rewards/boxes/'.$box->id.'/open')->assertNotFound();
        $this->assertNull($box->fresh()->opened_at);
        $this->actingAs($owner)->get('/rewards')->assertOk()->assertSee('r52-web-wheel')->assertSee('r52-web-boxes');
        $this->post('/rewards/boxes/'.$box->id.'/open')->assertRedirect()->assertSessionHas('r52_reward');
        $this->assertNotNull($box->fresh()->opened_at);
        $this->postJson('/rewards/boxes/'.$box->id.'/open')->assertUnprocessable();
        $this->post('/rewards/wheel',['source'=>'free'])->assertRedirect()->assertSessionHas('r52_reward');
        $this->postJson('/rewards/wheel',['source'=>'free'])->assertUnprocessable();
        $this->postJson('/rewards/wheel',['source'=>'client_free_reward','reward'=>['type'=>'tokens','value'=>999999]])->assertUnprocessable();
    }

    public function test_ten_playtest_accounts_have_unique_passwords_no_admin_and_no_overwrite(): void
    {
        $directory=sys_get_temp_dir().'/warqnaa-r52-'.bin2hex(random_bytes(8));
        $old=storage_path();$this->app->useStoragePath($directory);
        try {
            $this->artisan('warqna:playtest-accounts')->assertSuccessful();
            $path=$directory.'/app/private/playtest/accounts.json';
            $accounts=json_decode(file_get_contents($path),true,512,JSON_THROW_ON_ERROR);
            $this->assertCount(10,$accounts);
            $this->assertCount(10,array_unique(array_column($accounts,'password')));
            $this->assertSame(0600,fileperms($path)&0777);
            foreach ($accounts as $account) {
                $user=User::where('username',$account['username'])->firstOrFail();
                $this->assertFalse($user->is_admin);
                $this->assertTrue(Hash::check($account['password'],$user->password));
                $this->assertSame(10000,(int)$user->wallet()->first()->tokens);
            }
            $this->artisan('warqna:playtest-accounts')->assertFailed();
            $this->assertSame($accounts,json_decode(file_get_contents($path),true));
            $this->assertSame(10,User::count());
        } finally {
            $this->app->useStoragePath($old);
            if(is_file($directory.'/app/private/playtest/accounts.json')) unlink($directory.'/app/private/playtest/accounts.json');
            @rmdir($directory.'/app/private/playtest');@rmdir($directory.'/app/private');@rmdir($directory.'/app');@rmdir($directory);
        }
    }
}
