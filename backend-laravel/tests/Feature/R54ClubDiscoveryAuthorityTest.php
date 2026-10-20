<?php

namespace Tests\Feature;

use App\Models\{Club,ClubJoinRequest,ClubMember,User,Wallet};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R54ClubDiscoveryAuthorityTest extends TestCase
{
    use RefreshDatabase;

    public function test_client_discovery_flags_cannot_bypass_privacy_capacity_approval_or_roles(): void
    {
        $owner=User::factory()->create(['is_admin'=>false]);
        $player=User::factory()->create(['is_admin'=>false]);
        Wallet::create(['user_id'=>$player->id,'tokens'=>10000,'gems'=>0]);
        $clubs=[];
        foreach(['private','full','request','public'] as $kind) {
            $club=Club::create(['owner_id'=>$owner->id,'name'=>'R54 '.$kind,
                'visibility'=>$kind==='full'?'public':$kind,'level'=>1]);
            ClubMember::create(['club_id'=>$club->id,'user_id'=>$owner->id,'role'=>'owner','permissions'=>['all'=>true]]);
            $clubs[$kind]=$club;
        }
        foreach(User::factory()->count(19)->create(['is_admin'=>false]) as $member) {
            ClubMember::create(['club_id'=>$clubs['full']->id,'user_id'=>$member->id,'role'=>'member','permissions'=>[]]);
        }
        $this->withToken($player->createToken('r54-discovery')->plainTextToken);
        $directory=$this->getJson('/api/mobile/v1/clubs-world')->assertOk()->json('clubs');
        $this->assertNotContains($clubs['private']->id,array_column($directory,'id'));
        $full=collect($directory)->firstWhere('id',$clubs['full']->id);
        $this->assertSame(20,$full['members_count']);$this->assertSame(20,$full['capacity']);
        $forged=['visibility'=>'public','capacity'=>999999,'members_count'=>0,
            'join_request_pending'=>false,'status'=>'accepted','role'=>'owner','permissions'=>['all'=>true]];
        $base='/api/mobile/v1/clubs-world/';
        $this->postJson($base.$clubs['private']->id.'/join',$forged)->assertForbidden();
        $this->postJson($base.$clubs['full']->id.'/join',$forged)->assertStatus(409);
        $this->assertDatabaseMissing('club_members',['user_id'=>$player->id]);
        $this->postJson($base.$clubs['request']->id.'/join',$forged)->assertStatus(202)->assertJsonPath('status','pending');
        $this->postJson($base.$clubs['request']->id.'/join',$forged)->assertStatus(202);
        $this->assertSame(1,ClubJoinRequest::where('club_id',$clubs['request']->id)->where('user_id',$player->id)->count());
        $this->assertDatabaseHas('club_join_requests',['club_id'=>$clubs['request']->id,'user_id'=>$player->id,'status'=>'pending']);
        $this->assertDatabaseMissing('club_members',['user_id'=>$player->id]);
        $pending=collect($this->getJson('/api/mobile/v1/clubs-world')->assertOk()->json('clubs'))->firstWhere('id',$clubs['request']->id);
        $this->assertTrue($pending['join_request_pending']);
        $this->postJson($base.$clubs['public']->id.'/join',$forged)->assertCreated()->assertJsonPath('status','accepted');
        $membership=ClubMember::where('user_id',$player->id)->firstOrFail();
        $this->assertSame('member',$membership->role);$this->assertSame([],$membership->permissions);
        $this->postJson($base.$clubs['public']->id.'/join',$forged)->assertStatus(409);
        $this->postJson($base.$clubs['request']->id.'/join',$forged)->assertStatus(409);
        $this->assertSame(1,ClubMember::where('user_id',$player->id)->count());
        $this->assertSame(10000,(int)$player->wallet()->firstOrFail()->tokens);
        $this->assertFalse($player->fresh()->is_admin);
    }
}
