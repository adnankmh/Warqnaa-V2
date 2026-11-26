<?php

namespace Tests\Feature;

use App\Http\Controllers\VisualStudioController;
use App\Models\{AdminAuditLog, SiteSetting, User};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class R291VisualStudioTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): User
    {
        return User::factory()->create(['is_admin'=>true,'admin_role'=>'primary_admin']);
    }

    private function payload(): array
    {
        $values=[];
        $snapshot=[];
        foreach(VisualStudioController::fields() as $key=>$field) {
            $row=SiteSetting::where('key',$key)->first();
            $snapshot[$key]=$row ? $row->only(['value','type','group','label']) : null;
            $values[$key]=isset($field[3]) ? max($field[3],min($field[4],(int)($row?->value ?? $field[2]))) : ($row?->value ?? $field[2]);
        }
        return ['revision'=>hash('sha256',json_encode($snapshot,JSON_THROW_ON_ERROR)),'values'=>$values];
    }

    public function test_studio_rejects_players_and_unprivileged_admins(): void
    {
        $this->get('/admin/visual-studio')->assertRedirect();
        foreach([false,true] as $admin) {
            $user=User::factory()->create(['is_admin'=>$admin,'admin_role'=>'player','admin_permissions'=>[]]);
            $this->actingAs($user)->get('/admin/visual-studio')->assertForbidden();
            $this->post('/admin/visual-studio/publish',[])->assertForbidden();
            $this->post('/admin/visual-studio/restore',[])->assertForbidden();
        }
    }

    public function test_publish_and_restore_are_audited_and_preserve_unrelated_settings(): void
    {
        $this->actingAs($this->admin());
        SiteSetting::setValue('ui_button_bg','#123456','string','designer');
        SiteSetting::setValue('exit_penalty_xp',321,'int','gameplay');
        $payload=$this->payload();
        $payload['values']['ui_button_bg']='#155495';
        $this->post('/admin/visual-studio/publish',$payload)->assertRedirect(route('admin.visual-studio'));
        $this->assertSame('#155495',SiteSetting::getValue('ui_button_bg'));
        $entry=AdminAuditLog::where('action','admin.visual_studio.publish')->firstOrFail();
        $this->post('/admin/visual-studio/publish',$payload)->assertStatus(409);
        $this->post('/admin/visual-studio/restore',['revision'=>$this->payload()['revision'],'entry'=>$entry->id])->assertRedirect(route('admin.visual-studio'));
        $this->assertSame('#123456',SiteSetting::getValue('ui_button_bg'));
        $this->assertSame(321,SiteSetting::getValue('exit_penalty_xp'));
        $this->assertDatabaseHas('admin_audit_logs',['action'=>'admin.visual_studio.restore']);
    }

    public function test_unlisted_keys_invalid_colors_and_external_edits_are_rejected(): void
    {
        $this->actingAs($this->admin());
        $payload=$this->payload();
        $bad=$payload;
        $bad['values']['exit_penalty_xp']=0;
        $this->postJson('/admin/visual-studio/publish',$bad)->assertUnprocessable();
        $bad=$payload;
        $bad['values']['ui_button_bg']='</style>';
        $this->postJson('/admin/visual-studio/publish',$bad)->assertUnprocessable();
        $payload['values']['ui_button_bg']='#155495';
        $this->post('/admin/visual-studio/publish',$payload)->assertRedirect();
        $entry=AdminAuditLog::where('action','admin.visual_studio.publish')->firstOrFail();
        SiteSetting::setValue('ui_button_bg','#234567','string','designer');
        $this->post('/admin/visual-studio/restore',['revision'=>$this->payload()['revision'],'entry'=>$entry->id])->assertStatus(409);
        $this->assertSame('#234567',SiteSetting::getValue('ui_button_bg'));
    }
}
