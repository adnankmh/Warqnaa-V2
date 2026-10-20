<?php

namespace Tests\Feature;

use App\Models\{Club,ClubMember,Profile,User};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class R52ClubDelegationTest extends TestCase
{
    use RefreshDatabase;

    public function test_only_owner_can_delegate_scoped_permissions_and_deputy_cannot_escalate(): void
    {
        $users=[];
        foreach(['Owner','Deputy','Player'] as $name) {
            $user=User::create(['username'=>$name,'email'=>$name.'@example.test','password'=>Hash::make(bin2hex(random_bytes(16))),'is_admin'=>false]);
            Profile::create(['user_id'=>$user->id,'display_name'=>$name]);$users[]=$user;
        }
        [$owner,$deputy,$player]=$users;
        $club=Club::create(['owner_id'=>$owner->id,'name'=>'R52 Club','visibility'=>'public','level'=>1]);
        foreach($users as $i=>$user) ClubMember::create(['club_id'=>$club->id,'user_id'=>$user->id,'role'=>$i===0?'owner':'member','permissions'=>[]]);
        $base='/api/mobile/v1/clubs-world/'.$club->id.'/members/';
        Sanctum::actingAs($player);
        $this->patchJson($base.$deputy->id.'/role',['preset'=>'deputy'])->assertForbidden();
        Sanctum::actingAs($owner);
        $this->patchJson($base.$deputy->id.'/role',['preset'=>'deputy'])->assertOk()->assertJsonPath('can_assign_roles',true);
        $membership=ClubMember::where('club_id',$club->id)->where('user_id',$deputy->id)->firstOrFail();
        $this->assertTrue($membership->permissions['accept_members']);
        $this->assertSame('moderator',$membership->role);
        Sanctum::actingAs($deputy);
        $this->patchJson($base.$player->id.'/role',['preset'=>'deputy'])->assertForbidden();
        Sanctum::actingAs($owner);
        $this->patchJson($base.$owner->id.'/role',['preset'=>'member'])->assertUnprocessable();
        $this->patchJson($base.$player->id.'/role',['preset'=>'all','permissions'=>['all'=>true]])->assertUnprocessable();
        $this->patchJson($base.$deputy->id.'/role',['preset'=>'events'])->assertOk();
        $permissions=$membership->fresh()->permissions;
        $this->assertTrue($permissions['create_announcements']);
        $this->assertArrayNotHasKey('kick_members',$permissions);
        $this->patchJson($base.$deputy->id.'/role',['preset'=>'member'])->assertOk();
        $this->assertSame('member',$membership->fresh()->role);
        $this->assertSame([],$membership->fresh()->permissions);
        $this->assertFalse($deputy->fresh()->is_admin);
    }
}
