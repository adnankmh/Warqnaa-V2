<?php

namespace App\Http\Controllers;

use App\Models\MatchReplay;
use App\Services\Social\{MatchReplayService, SocialWorldPolicy};
use Illuminate\Http\Request;

class MobileReplayController extends Controller
{
    public function __construct(
        private readonly SocialWorldPolicy $policy,
        private readonly MatchReplayService $replays,
    ) {}

    public function index(Request $request)
    {
        $this->assertEnabled();
        $mine = $request->boolean('mine');
        $query = MatchReplay::with(['owner.profile', 'game', 'room.players.user.profile'])
            ->where('status', 'ready')->where(fn ($q) => $q->whereNull('expires_at')->orWhere('expires_at', '>', now()))
            ->orderByDesc('featured')->latest('published_at');
        if ($mine) $query->where('owner_id', $request->user()->id);

        $page = $query->paginate(40);
        $items = collect($page->items())
            ->filter(fn (MatchReplay $replay) => $this->policy->canViewReplay($request->user(), $replay) && $this->replays->verify($replay))
            ->map(fn (MatchReplay $replay) => $this->replays->payload($replay))->values();

        return response()->json([
            'ok' => true, 'replays' => $items,
            'next_page' => $page->hasMorePages() ? $page->currentPage() + 1 : null,
            'privacy' => ['hands_visible' => false, 'voice_included' => false, 'private_chat_included' => false],
        ]);
    }

    public function show(Request $request, MatchReplay $replay)
    {
        $this->assertEnabled();
        $replay->loadMissing(['owner.profile', 'game', 'room.players.user.profile']);
        abort_unless($this->policy->canViewReplay($request->user(), $replay), 403, 'لا تملك صلاحية مشاهدة هذه الإعادة.');
        abort_unless($this->replays->verify($replay), 409, 'فشل تحقق سلامة الإعادة.');
        $replay->increment('views');
        return response()->json(['ok' => true, 'replay' => $this->replays->payload($replay->fresh(), true)]);
    }

    public function updateVisibility(Request $request, MatchReplay $replay)
    {
        abort_unless($request->user()->is_admin || (int) $replay->owner_id === (int) $request->user()->id, 403);
        $data = $request->validate(['visibility' => 'required|in:public,friends,private']);
        if ($data['visibility'] !== 'private') {
            $owner = $replay->owner;
            abort_unless($owner && $this->policy->canShareReplay($owner, $replay), 403, 'تتطلب المشاركة موافقة جميع لاعبي المباراة.');
        }
        $replay->update(['visibility' => $data['visibility']]);
        return response()->json(['ok' => true, 'message' => 'تم تحديث خصوصية الإعادة.', 'replay' => $this->replays->payload($replay->fresh())]);
    }

    public function hide(Request $request, MatchReplay $replay)
    {
        abort_unless($request->user()->is_admin || (int) $replay->owner_id === (int) $request->user()->id, 403);
        $replay->update(['status' => 'hidden', 'visibility' => 'private']);
        return response()->json(['ok' => true, 'message' => 'تم إخفاء الإعادة مع الاحتفاظ بسجل النزاهة.']);
    }

    private function assertEnabled(): void
    {
        abort_unless(filter_var(\App\Models\SiteSetting::getValue('replay_system_enabled', true), FILTER_VALIDATE_BOOLEAN), 503, 'نظام الإعادات متوقف مؤقتًا.');
    }
}
