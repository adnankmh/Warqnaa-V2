<?php

namespace Tests\Feature;

use App\Models\{Party, PartyMember, User};
use App\Services\Platform\OperationsStatusService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class V650OperationsAndPartyTest extends TestCase
{
    use RefreshDatabase;

    private function player(string $name, array $extra = []): User
    {
        return User::create(array_merge(['username'=>$name, 'email'=>$name.'@example.test', 'password'=>bcrypt('test-password-650'), 'admin_role'=>'player'], $extra));
    }

    private function token(User $user): array
    {
        return ['Authorization'=>'Bearer '.$user->createToken('test')->plainTextToken];
    }

    public function test_operations_rejects_players_and_unprivileged_admins(): void
    {
        foreach ([[], ['is_admin'=>true, 'admin_role'=>'delegated_admin']] as $i=>$extra) {
            $this->getJson('/api/mobile/v1/admin/operations', $this->token($this->player('no_access_'.$i, $extra)))->assertForbidden();
        }
    }

    public function test_operations_requires_a_real_scheduler_heartbeat_and_hides_secrets(): void
    {
        $admin = $this->player('operations_admin', ['is_admin'=>true, 'admin_role'=>'delegated_admin', 'admin_permissions'=>['security'=>true]]);
        $headers = $this->token($admin);
        Cache::forget(OperationsStatusService::HEARTBEAT_KEY);
        $response = $this->getJson('/api/mobile/v1/admin/operations', $headers)->assertOk()->assertJsonPath('operations.checks.scheduler', false);
        $this->assertStringNotContainsString($admin->email, $response->getContent());
        $this->assertStringNotContainsString('APP_KEY', $response->getContent());
        Cache::put(OperationsStatusService::HEARTBEAT_KEY, time(), 600);
        $this->getJson('/api/mobile/v1/admin/operations', $headers)->assertOk()->assertJsonPath('operations.checks.scheduler', true);
        Cache::put(OperationsStatusService::HEARTBEAT_KEY, time()-181, 600);
        $this->getJson('/api/mobile/v1/admin/operations', $headers)->assertOk()->assertJsonPath('operations.checks.scheduler', false);
    }

    public function test_full_party_rejoin_is_idempotent_and_uninvited_join_is_rejected(): void
    {
        $owner=$this->player('owner'); $member=$this->player('member'); $outsider=$this->player('outsider');
        $party=Party::create(['owner_id'=>$owner->id,'code'=>'TEST650','status'=>'open','max_members'=>2]);
        foreach ([$owner,$member] as $user) PartyMember::create(['party_id'=>$party->id,'user_id'=>$user->id,'role'=>$user->id===$owner->id?'owner':'member','status'=>'joined','joined_at'=>now()]);
        $this->postJson('/api/mobile/v1/parties/join/TEST650', [], $this->token($member))->assertOk()->assertJsonMissing(['email'=>$owner->email]);
        $this->postJson('/api/mobile/v1/parties/join/TEST650', [], $this->token($outsider))->assertForbidden();
        $this->assertSame(2,$party->members()->where('status','joined')->count());
    }

    public function test_owner_leave_transfers_ownership_and_closed_party_disappears(): void
    {
        $owner=$this->player('leader'); $member=$this->player('nextleader');
        $party=Party::create(['owner_id'=>$owner->id,'code'=>'LEAVE65','status'=>'open','max_members'=>2]);
        foreach ([$owner,$member] as $user) PartyMember::create(['party_id'=>$party->id,'user_id'=>$user->id,'role'=>$user->id===$owner->id?'owner':'member','status'=>'joined','joined_at'=>now()]);
        $this->postJson('/api/mobile/v1/parties/'.$party->id.'/leave', [], $this->token($owner))->assertOk();
        $this->assertEquals($member->id,$party->fresh()->owner_id);
        $this->postJson('/api/mobile/v1/parties/'.$party->id.'/leave', [], $this->token($member))->assertOk();
        $this->assertSame('closed',$party->fresh()->status);
        $this->getJson('/api/mobile/v1/parties/mine', $this->token($member))->assertOk()->assertJsonPath('party',null);
    }
}
