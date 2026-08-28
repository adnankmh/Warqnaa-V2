<?php

namespace App\Http\Controllers;

use App\Models\Room;
use App\Services\Gameplay\MatchLifecycleService;
use Illuminate\Http\Request;

class MobileLifecycleController extends Controller
{
    public function heartbeat(Request $request, Room $room, MatchLifecycleService $lifecycle)
    {
        $lifecycle->heartbeat($room, $request->user());
        $lifecycle->sweep($room->fresh());
        return response()->json(['ok'=>true,'lifecycle'=>$lifecycle->snapshot($room->fresh(),$request->user())]);
    }

    public function disconnect(Request $request, Room $room, MatchLifecycleService $lifecycle)
    {
        $data=$request->validate(['reason'=>'nullable|string|max:40']);
        $lifecycle->disconnect($room,$request->user(),$data['reason'] ?? 'client');
        return response()->json(['ok'=>true,'grace_seconds'=>MatchLifecycleService::RECONNECT_GRACE_SECONDS]);
    }

    public function reconnect(Request $request, Room $room, MatchLifecycleService $lifecycle)
    {
        $lifecycle->sweep($room);
        $player=$lifecycle->heartbeat($room->fresh(),$request->user());
        return response()->json(['ok'=>true,'message'=>'تمت استعادة نفس المقعد والجلسة.','seat'=>$player->seat,'lifecycle'=>$lifecycle->snapshot($room->fresh(),$request->user())]);
    }

    public function status(Request $request, Room $room, MatchLifecycleService $lifecycle)
    {
        $lifecycle->sweep($room);
        return response()->json(['ok'=>true,'lifecycle'=>$lifecycle->snapshot($room->fresh(),$request->user())]);
    }
}
