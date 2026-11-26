<?php

namespace App\Http\Controllers;

use App\Models\{AdminAuditLog, SiteSetting};
use App\Services\Platform\AdminAuditService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class VisualStudioController
{
    private const ACTION = 'admin.visual_studio.publish';
    private const RESTORE = 'admin.visual_studio.restore';

    // Allowlisted presentation tokens only: never executable source or game rules.
    public static function fields(): array
    {
        return [
            'ui_site_bg1'=>['خلفية الموقع العلوية','Upper background','#07170f'],
            'ui_site_bg2'=>['خلفية الموقع السفلية','Lower background','#020617'],
            'ui_panel_bg'=>['اللوحات','Panels','#0f172a'],
            'ui_card_bg'=>['البطاقات','Cards','#1e293b'],
            'ui_nav_bg'=>['شريط التنقل','Navigation','#020617'],
            'ui_button_bg'=>['الأزرار','Buttons','#2e225f'],
            'ui_button_text'=>['نص الأزرار','Button text','#ffffff'],
            'ui_primary_bg'=>['التدرج الأساسي 1','Primary gradient 1','#facc15'],
            'ui_primary_bg2'=>['التدرج الأساسي 2','Primary gradient 2','#ec4899'],
            'ui_button_height'=>['ارتفاع الأزرار','Button height',46,44,64],
            'ui_button_radius'=>['حواف الأزرار','Button radius',16,0,32],
            'ui_button_font'=>['خط الأزرار','Button font',14,12,20],
            'ui_card_radius'=>['حواف البطاقات','Card radius',24,4,40],
            'ui_card_padding'=>['حشو البطاقات','Card padding',18,8,32],
            'ui_card_gap'=>['تباعد البطاقات','Card spacing',16,6,28],
            'ui_page_padding'=>['هوامش الصفحة','Page padding',18,6,24],
        ];
    }

    private function guard(Request $request): void
    {
        abort_unless($request->user()?->is_admin && $request->user()->hasAdminPermission('site_design'),403);
    }

    private function snapshot(bool $lock = false): array
    {
        $query = SiteSetting::whereIn('key',array_keys(self::fields()))->orderBy('key');
        if ($lock) $query->lockForUpdate();
        $rows = $query->get()->keyBy('key');
        $result = [];
        foreach (self::fields() as $key=>$field) {
            $row = $rows->get($key);
            $result[$key] = $row ? $row->only(['value','type','group','label']) : null;
        }
        return $result;
    }

    private function revision(array $snapshot): string
    {
        return hash('sha256',json_encode($snapshot,JSON_THROW_ON_ERROR));
    }

    private function history()
    {
        return AdminAuditLog::whereIn('action',[self::ACTION,self::RESTORE])->latest('id');
    }

    public function index(Request $request)
    {
        $this->guard($request);
        $snapshot = $this->snapshot();
        $values = [];
        foreach (self::fields() as $key=>$field) {
            $value = $snapshot[$key]['value'] ?? $field[2];
            $values[$key] = isset($field[3])
                ? (int)$value
                : (preg_match('/^#[0-9a-fA-F]{6}$/',(string)$value) ? $value : $field[2]);
        }
        return view('admin.visual-studio',[
            'fields'=>self::fields(),'values'=>$values,
            'revision'=>$this->revision($snapshot),'history'=>$this->history()->limit(10)->get(),
        ]);
    }

    public function publish(Request $request, AdminAuditService $audit)
    {
        $this->guard($request);
        $rules=['revision'=>'required|string|size:64','values'=>'required|array:'.implode(',',array_keys(self::fields()))];
        foreach (self::fields() as $key=>$field) {
            $rules['values.'.$key] = isset($field[3])
                ? ['required','integer','between:'.$field[3].','.$field[4]]
                : ['required','regex:/^#[0-9a-fA-F]{6}$/'];
        }
        $data=$request->validate($rules);
        return DB::transaction(function () use ($request,$audit,$data) {
            $before=$this->snapshot(true);
            abort_unless(hash_equals($this->revision($before),$data['revision']),409,'Design changed. Reload before publishing.');
            foreach(self::fields() as $key=>$field) {
                $value=$data['values'][$key];
                if ((string)($before[$key]['value'] ?? $field[2]) === (string)$value) continue;
                SiteSetting::setValue($key,$value,isset($field[3])?'int':'string','designer',$before[$key]['label'] ?? $key);
            }
            $after=$this->snapshot();
            if ($before !== $after) $audit->record($request,self::ACTION,SiteSetting::class,$before,$after);
            return redirect()->route('admin.visual-studio')->with('ok',__('Design published.'));
        });
    }

    public function restore(Request $request, AdminAuditService $audit)
    {
        $this->guard($request);
        $data=$request->validate(['revision'=>'required|string|size:64','entry'=>'required|integer']);
        return DB::transaction(function () use ($request,$audit,$data) {
            $current=$this->snapshot(true);
            abort_unless(hash_equals($this->revision($current),$data['revision']),409);
            $entry=$this->history()->firstOrFail();
            // Only undo the most recent studio operation, and never overwrite later external edits.
            abort_unless($entry->id === (int)$data['entry'] && $entry->after == $current,409);
            $previous=$entry->before;
            abort_unless(is_array($previous) && array_keys($previous)===array_keys(self::fields()),409);
            foreach($previous as $key=>$row) {
                if ($row===null) SiteSetting::where('key',$key)->delete();
                else SiteSetting::updateOrCreate(['key'=>$key],$row);
            }
            $audit->record($request,self::RESTORE,SiteSetting::class,$current,$this->snapshot(),['restored_entry'=>$entry->id]);
            return redirect()->route('admin.visual-studio')->with('ok',__('Design restored.'));
        });
    }
}
