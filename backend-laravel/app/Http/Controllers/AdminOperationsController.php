<?php

namespace App\Http\Controllers;

use App\Services\Platform\OperationsStatusService;
use App\Support\AuthenticatedActor;
use Illuminate\Http\Request;

final class AdminOperationsController extends Controller
{
    public function index(Request $request, OperationsStatusService $operations)
    {
        $actor = AuthenticatedActor::resolve($request);
        abort_unless($actor->is_admin && !$actor->is_banned && $actor->hasAdminPermission('security'), 403);
        $report = $operations->snapshot();
        if ($request->expectsJson()) {
            return response()->json(['ok' => true, 'operations' => $report])->header('Cache-Control', 'no-store');
        }
        return response()->view('admin.operations', ['report' => $report])->header('Cache-Control', 'no-store');
    }
}
