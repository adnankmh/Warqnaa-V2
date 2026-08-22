<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Services\Competitive\{CompetitiveMatchmakingService,CompetitiveSeasonService};
use App\Services\Games\GameCatalog;
use Illuminate\Http\Request;

class CompetitiveController extends Controller
{
    public function index(Request $request, CompetitiveSeasonService $seasons)
    {
        $season=$seasons->activeSeason(false);
        return view('competitive.index',[
            'competitive'=>$seasons->dashboard($request->user()),
            'leaderboard'=>$season?$seasons->leaderboard($season,'overall',null,null,50):['rows'=>[]],
            'games'=>Game::where('active',true)->whereIn('key',GameCatalog::customerKeys())->orderBy('id')->get(),
        ]);
    }

    public function queue(Request $request, CompetitiveMatchmakingService $matchmaking)
    {
        $data=$request->validate(['game'=>'required|string|max:80','preferred_seats'=>'required|integer|min:2|max:6','region'=>'nullable|string|max:24']);
        $result=$matchmaking->join($request->user(),$data['game'],(int)$data['preferred_seats'],(string)($data['region'] ?? 'global'));
        $roomCode=data_get($result,'queue.room_code');
        return $roomCode?redirect()->route('rooms.show',$roomCode)->with('ok','تم العثور على مباراة Ranked.'):back()->with('ok','دخلت طابور Ranked؛ سيتم تحديث الحالة تلقائياً.');
    }

    public function cancel(Request $request, CompetitiveMatchmakingService $matchmaking)
    {
        $matchmaking->cancel($request->user(),$request->input('token'));
        return back()->with('ok','تم إلغاء البحث المصنف.');
    }

    public function claim(Request $request, int $claim, CompetitiveSeasonService $seasons)
    {
        $seasons->claimReward($request->user(),$claim);
        return back()->with('ok','تمت إضافة مكافأة الموسم إلى حسابك.');
    }
}
