<?php

namespace App\Http\Controllers;

use App\Models\{
    ClubMember, MatchReplay, Notification, Room, RoomSpectator, SocialActivity,
    SocialEvent, SocialEventAttendee, SocialFollow, SocialGift, User
};
use App\Services\Social\{MatchReplayService, SocialWorldPolicy};
use App\Services\Wallet\WalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use RuntimeException;

class SocialWorldController extends Controller
{
    public function __construct(
        private readonly SocialWorldPolicy $policy,
        private readonly MatchReplayService $replays,
    ) {}

    public function index(Request $request)
    {
        abort_unless($this->enabled('social_world_enabled', true), 503, 'العالم الاجتماعي متوقف مؤقتًا.');
        $user = $request->user();
        $activities = SocialActivity::with(['actor.profile', 'club', 'room.game', 'gifts.sender.profile'])
            ->where('hidden', false)->where(fn ($query) => $query->whereNull('expires_at')->orWhere('expires_at', '>', now()))
            ->latest('published_at')->limit(80)->get()
            ->filter(fn (SocialActivity $item) => $this->policy->canViewActivity($user, $item))->take(30)
            ->map(function (SocialActivity $item) use ($user) {
                $item->setRelation('gifts', $item->gifts->filter(fn (SocialGift $gift) =>
                    $gift->sender && !$this->policy->blocked($user->id, $gift->sender->id)
                )->values());
                return $item;
            });
        $events = SocialEvent::with(['creator.profile', 'club', 'game', 'room', 'attendees'])
            ->whereIn('status', ['scheduled', 'live'])->where('starts_at', '>=', now()->subHours(12))
            ->orderByDesc('featured')->orderBy('starts_at')->limit(30)->get()->filter(fn ($event) => $this->canViewEvent($user, $event));
        $liveRooms = Room::with(['owner.profile', 'game', 'players.user.profile', 'spectators'])
            ->whereIn('status', ['waiting', 'bidding', 'playing'])->latest('updated_at')->limit(50)->get()
            ->filter(fn (Room $room) => $this->policy->canSpectate($user, $room))->take(12);
        $replays = MatchReplay::with(['owner.profile', 'room.players.user.profile', 'game'])
            ->where('status', 'ready')->where(fn ($query) => $query->whereNull('expires_at')->orWhere('expires_at', '>', now()))
            ->latest('published_at')->limit(40)->get()
            ->filter(fn (MatchReplay $replay) => $this->policy->canViewReplay($user, $replay) && $this->replays->verify($replay))->take(12);
        $suggestions = User::with('profile')->where('id', '!=', $user->id)->where('is_banned', false)
            ->latest('last_seen_at')->limit(50)->get()->filter(fn (User $candidate) => $this->policy->canDiscover($user, $candidate))->take(10);

        return view('social-world.index', [
            'activities' => $activities, 'events' => $events, 'liveRooms' => $liveRooms,
            'replays' => $replays, 'suggestions' => $suggestions,
            'preferences' => $this->policy->preferences($user), 'giftCatalog' => config('warqna_social_world.gifts', []),
            'followingIds' => SocialFollow::where('follower_id', $user->id)->pluck('followed_id')->map(fn ($id) => (int) $id)->all(),
        ]);
    }

    public function updatePrivacy(Request $request)
    {
        $data = $request->validate([
            'profile_visibility' => 'required|in:public,friends,private',
            'presence_visibility' => 'required|in:public,friends,private',
            'activity_visibility' => 'required|in:public,friends,private',
            'message_policy' => 'required|in:everyone,friends,nobody',
            'invite_policy' => 'required|in:everyone,friends,nobody',
        ]);
        foreach (['discoverable', 'allow_friend_requests', 'allow_follows', 'allow_spectators', 'allow_replay_share', 'allow_voice', 'show_online_status', 'show_current_room'] as $key) {
            $data[$key] = $request->boolean($key);
        }
        $this->policy->preferences($request->user())->update($data);
        return back()->with('ok', 'تم حفظ خصوصيتك في Social World.');
    }

    public function publish(Request $request)
    {
        abort_unless($this->enabled('social_feed_enabled', true), 503);
        $data = $request->validate([
            'type' => ['required', Rule::in(['status', 'looking_for_game', 'achievement'])],
            'text' => 'required|string|min:1|max:500', 'audience' => 'required|in:public,friends,followers,private',
        ]);
        SocialActivity::create([
            'actor_id' => $request->user()->id, 'type' => $data['type'], 'audience' => $data['audience'],
            'payload' => ['text' => trim(strip_tags($data['text']))], 'published_at' => now(),
            'expires_at' => $data['type'] === 'looking_for_game' ? now()->addHours(3) : null,
        ]);
        return back()->with('ok', 'تم النشر في عالم ورقنا.');
    }

    public function follow(Request $request, User $user)
    {
        abort_unless($this->policy->canFollow($request->user(), $user), 403, 'هذا الحساب لا يسمح بالمتابعة.');
        SocialFollow::firstOrCreate(['follower_id' => $request->user()->id, 'followed_id' => $user->id]);
        return back()->with('ok', 'تمت متابعة اللاعب.');
    }

    public function unfollow(Request $request, User $user)
    {
        SocialFollow::where('follower_id', $request->user()->id)->where('followed_id', $user->id)->delete();
        return back()->with('ok', 'تم إلغاء المتابعة.');
    }

    public function createEvent(Request $request)
    {
        abort_unless($this->enabled('social_events_enabled', true), 503);
        $data = $request->validate([
            'title' => 'required|string|max:140', 'description' => 'nullable|string|max:2000',
            'visibility' => 'required|in:public,friends,club,private', 'starts_at' => 'required|date|after:now',
            'club_id' => 'nullable|integer|exists:clubs,id', 'capacity' => 'nullable|integer|min:2|max:100000',
        ]);
        if ($data['visibility'] === 'club') {
            abort_unless(!empty($data['club_id']) && ClubMember::where('club_id', $data['club_id'])
                ->where('user_id', $request->user()->id)->whereIn('role', ['owner', 'moderator'])->exists(), 403);
        }
        SocialEvent::create([
            'created_by' => $request->user()->id, 'club_id' => $data['club_id'] ?? null,
            'title' => ['ar' => trim($data['title']), 'en' => trim($data['title'])],
            'description' => ['ar' => trim(strip_tags($data['description'] ?? '')), 'en' => trim(strip_tags($data['description'] ?? ''))],
            'visibility' => $data['visibility'], 'status' => 'scheduled', 'starts_at' => $data['starts_at'],
            'capacity' => $data['capacity'] ?? null, 'settings' => ['spectator_ready' => true],
        ]);
        return back()->with('ok', 'تم إنشاء الفعالية.');
    }

    public function attend(Request $request, SocialEvent $event)
    {
        DB::transaction(function () use ($request, $event) {
            $locked = SocialEvent::with('creator')->lockForUpdate()->findOrFail($event->id);
            abort_unless($this->canViewEvent($request->user(), $locked), 403);
            abort_if(in_array($locked->status, ['finished', 'cancelled'], true), 410, 'انتهت الفعالية.');
            $existing = $locked->attendees()->where('user_id', $request->user()->id)->where('status', 'going')->exists();
            $going = $locked->attendees()->where('status', 'going')->count();
            abort_if(!$existing && $locked->capacity && $going >= $locked->capacity, 409, 'اكتمل عدد الحضور.');
            SocialEventAttendee::updateOrCreate(['social_event_id' => $locked->id, 'user_id' => $request->user()->id], ['status' => 'going', 'joined_at' => now()]);
        });
        return back()->with('ok', 'تم تأكيد حضورك.');
    }

    public function cancelAttendance(Request $request, SocialEvent $event)
    {
        SocialEventAttendee::where('social_event_id', $event->id)->where('user_id', $request->user()->id)
            ->update(['status' => 'cancelled']);
        return back()->with('ok', 'تم إلغاء الحضور.');
    }

    public function sendGift(Request $request, WalletService $wallet)
    {
        abort_unless($this->enabled('animated_gifts_enabled', true), 503);
        $data = $request->validate(['recipient_id' => 'required|integer|exists:users,id', 'gift_key' => 'required|string|max:60', 'message' => 'nullable|string|max:240']);
        $recipient = User::findOrFail($data['recipient_id']);
        abort_if($recipient->id === $request->user()->id || $this->policy->blocked($request->user()->id, $recipient->id), 403);
        abort_unless($this->policy->canViewProfile($request->user(), $recipient), 403, 'هذا اللاعب لا يستقبل تفاعلات اجتماعية منك.');
        $definition = config('warqna_social_world.gifts.'.$data['gift_key']);
        abort_unless(is_array($definition), 422, 'الهدية غير موجودة.');
        try {
            $gift = DB::transaction(function () use ($request, $wallet, $recipient, $definition, $data) {
                $cost = (int) $definition['cost'];
                $wallet->debit($request->user(), $cost, 'social_gift_sent', ['recipient_id' => $recipient->id, 'gift_key' => $data['gift_key']]);
                $wallet->creditPrimaryAdminRevenue($request->user(), $cost, 'social_gift_income', ['recipient_id' => $recipient->id, 'gift_key' => $data['gift_key']]);
                return SocialGift::create([
                    'sender_id' => $request->user()->id, 'recipient_id' => $recipient->id, 'gift_key' => $data['gift_key'],
                    'token_cost' => $cost, 'animation_key' => $definition['animation'], 'message' => trim(strip_tags($data['message'] ?? '')) ?: null,
                    'visible' => true, 'delivered_at' => now(), 'meta' => ['icon' => $definition['icon'], 'release' => 'R11'],
                ]);
            });
        } catch (RuntimeException) {
            return back()->withErrors(['gift' => 'رصيد التوكنز غير كافٍ لإرسال هذه الهدية.']);
        }
        Notification::create([
            'user_id' => $recipient->id, 'type' => 'social_gift', 'title' => ['ar' => 'هدية جديدة', 'en' => 'New gift'],
            'body' => ['ar' => $request->user()->username.' أرسل لك '.$definition['ar'], 'en' => $request->user()->username.' sent you '.$definition['en']],
            'meta' => ['gift_id' => $gift->id, 'animation' => $definition['animation']],
        ]);
        return back()->with('ok', 'وصلت الهدية المتحركة.');
    }

    public function spectate(Request $request, Room $room)
    {
        abort_unless($this->policy->canSpectate($request->user(), $room), 403, 'لا يمكن مشاهدة هذه الغرفة.');
        DB::transaction(function () use ($request, $room) {
            $lockedRoom = Room::with(['owner', 'players.user'])->whereKey($room->id)->lockForUpdate()->firstOrFail();
            abort_unless($this->policy->canSpectate($request->user(), $lockedRoom), 403, 'تم إغلاق المشاهدة لهذه الغرفة.');
            $staleBefore = now()->subSeconds(max(15, min(180, (int) config('warqna_social_world.spectator_stale_seconds', 30))));
            RoomSpectator::where('room_id', $room->id)->where('status', 'active')->where('last_seen_at', '<', $staleBefore)->update(['status' => 'left']);
            $limit = max(1, min(10000, (int) \App\Models\SiteSetting::getValue('max_room_spectators', 120)));
            $active = RoomSpectator::where('room_id', $room->id)->where('status', 'active')->where('last_seen_at', '>=', $staleBefore)->count();
            $existing = RoomSpectator::where('room_id', $room->id)->where('user_id', $request->user()->id)->first();
            $alreadyActive = $existing?->status === 'active' && $existing->last_seen_at?->gte($staleBefore);
            abort_if(!$alreadyActive && $active >= $limit, 409, 'اكتمل عدد مشاهدي الغرفة.');
            RoomSpectator::where('user_id', $request->user()->id)->where('room_id', '!=', $room->id)
                ->where('status', 'active')->update(['status' => 'left']);
            RoomSpectator::updateOrCreate(['room_id' => $room->id, 'user_id' => $request->user()->id], [
                'status' => 'active', 'joined_at' => now(), 'last_seen_at' => now(), 'can_chat' => false, 'voice_enabled' => false,
                'meta' => ['client' => 'web-r11'],
            ]);
        });
        $room->load(['owner.profile', 'game', 'players.user.profile', 'spectators']);
        return view('social-world.spectator', ['room' => $room, 'safeState' => $this->replays->spectatorState($room->state ?: [])]);
    }

    public function spectatorState(Request $request, Room $room)
    {
        $spectator = RoomSpectator::where('room_id', $room->id)->where('user_id', $request->user()->id)->where('status', 'active')->first();
        abort_unless($spectator && $this->policy->canSpectate($request->user(), $room), 403);
        $spectator->update(['last_seen_at' => now()]);
        $fresh = $room->fresh();
        return response()->json([
            'ok' => true, 'state' => $this->replays->spectatorState($fresh->state ?: []),
            'state_revision' => (int) data_get($fresh->state, '_revision', 0), 'server_time' => now()->toIso8601String(),
        ]);
    }

    public function replay(Request $request, MatchReplay $replay)
    {
        abort_unless($this->enabled('replay_system_enabled', true), 503, 'نظام الإعادات متوقف مؤقتًا.');
        $replay->load(['owner.profile', 'game', 'room.players.user.profile']);
        abort_unless($this->policy->canViewReplay($request->user(), $replay), 403, 'لا تملك صلاحية مشاهدة هذه الإعادة.');
        abort_unless($this->replays->verify($replay), 409, 'فشل تحقق سلامة الإعادة.');
        $replay->increment('views');
        return view('social-world.replay', ['replay' => $replay, 'payload' => $this->replays->payload($replay->fresh(), true)]);
    }

    private function canViewEvent(User $viewer, SocialEvent $event): bool
    {
        if ($viewer->is_admin || (int) $event->created_by === (int) $viewer->id) return true;
        if (!$event->creator || $this->policy->blocked($viewer->id, $event->created_by)) return false;
        return match ($event->visibility) {
            'public' => true, 'friends' => $this->policy->friends($viewer->id, $event->created_by),
            'club' => $event->club_id && ClubMember::where('club_id', $event->club_id)->where('user_id', $viewer->id)->exists(), default => false,
        };
    }

    private function enabled(string $key, bool $default): bool
    {
        return filter_var(\App\Models\SiteSetting::getValue($key, $default), FILTER_VALIDATE_BOOLEAN);
    }
}
