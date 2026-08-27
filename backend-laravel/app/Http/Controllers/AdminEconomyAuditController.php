<?php

namespace App\Http\Controllers;

use App\Models\EconomyAuditEvent;
use App\Services\Economy\EconomyAuditService;
use Illuminate\Http\Request;

class AdminEconomyAuditController extends Controller
{
    private function guard(Request $request): void { abort_unless((bool)$request->user()?->is_admin,403,'هذه الصفحة للإدارة فقط'); }

    public function index(Request $request, EconomyAuditService $audit)
    {
        $this->guard($request);
        if($request->boolean('refresh')) $audit->backfill(300);
        return response()->json(['ok'=>true,'summary'=>$audit->summary(),'events'=>EconomyAuditEvent::with(['user.profile','transaction'])->latest()->limit(150)->get()]);
    }

    public function review(Request $request, EconomyAuditEvent $event)
    {
        $this->guard($request);
        $data=$request->validate(['status'=>'required|in:reviewing,cleared,confirmed']);
        $event->update(['status'=>$data['status'],'reviewed_by'=>$request->user()->id,'reviewed_at'=>now()]);
        return response()->json(['ok'=>true,'event'=>$event->fresh()]);
    }
}
