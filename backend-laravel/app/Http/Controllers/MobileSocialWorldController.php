<?php

namespace App\Http\Controllers;

use App\Models\{
    ClubMember, MatchReplay, Notification, PresenceSession, Room, RoomSpectator,
    SocialActivity, SocialEvent, SocialEventAttendee, SocialFollow, SocialGift,
    SocialPreference, User
};
use App\Services\Notifications\FirebasePushService;
use App\Services\Social\{MatchReplayService, SocialWorldPolicy};
use App\Services\Wallet\WalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use RuntimeException;

class MobileSocialWorldController extends Controller
{
    public function __construct(private readonly SocialWorldPolicy $policy) {}

    public function dashboard(Request $request, MatchReplayService $replays)
    {
        $user = $request->user();
        abort_unless($this->enabled('social_world_enabled', true), 503, 'العالم الاجتماعي متوقف مؤقتًا.');

        $activities = SocialActivity::with(['actor.profile', 'club', 'room.game', 'gifts.sender.profile'])
            ->where('hidden', false)
            ->where(fn ($q) => $q->whereNull('expires_at')->orWhere('expires_at', '>', now()))
            ->latest('published_at')->limit(90)->get()
            ->filter(fn (SocialActivity $activity) => $this->policy->canViewActivity($user, $activity))
            ->take(max(10, min(60, (int) \App\Models\SiteSetting::getValue('social_feed_page_size', 30))))
            ->map(fn (SocialActivity $activity) => $this->activityPayload($activity, $user))->values();

        $events = SocialEvent::with(['creator.profile', 'club', 'game', 'room', 'attendees'])
            ->whereIn('status', ['scheduled', 'live'])
            ->where('starts_at', '>=', now()->subHours(12))
            ->orderByDesc('featured')->orderBy('starts_at')->limit(40)->get()
            ->filter(fn (SocialEvent $event) => $this->canViewEvent($user, $event))
            ->map(fn (SocialEvent $event) => $this->eventPayload($event, $user))->values();

        $liveRooms = Room::with(['owner.profile', 'game', 'players.user.profile', 'spectators'])
            ->whereIn('status', ['waiting', 'bidding', 'playing'])
            ->latest('updated_at')->limit(50)->get()
            ->filter(fn (Room $room) => $this->policy->canSpectate($user, $room))
            ->take(16)->map(fn (Room $room) => $this->liveRoomPayload($room))->values();

        $recentReplays = MatchReplay::with(['owner.profile', 'game', 'room.players.user.profile'])
            ->where('status', 'ready')->latest('published_at')->limit(50)->get()
            ->filter(fn (MatchReplay $replay) => $this->policy->canViewReplay($user, $replay) && $replays->verify($replay))
            ->take(12)->map(fn (MatchReplay $replay) => $replays->payload($replay))->values();

        $suggestions = User::with(['profile', 'socialPreference'])->where('id', '!=', $user->id)
            ->where('is_banned', false)->latest('last_seen_at')->limit(60)->get()
            ->filter(fn (User $candidate) => $this->policy->canDiscover($user, $candidate))
            ->take(12)->map(fn (User $candidate) => $this->userPayload($candidate, $user))->values();

        $preferences = $this->policy->preferences($user);
        return response()->json([
            'ok' => true,
            'release' => '0.6.0+230',
            'world' => [
                'activities' => $activities,
                'events' => $events,
                'live_rooms' => $liveRooms,
                'recent_replays' => $recentReplays,
                'suggestions' => $suggestions,
                'gift_catalog' => $this->giftCatalog(),
            ],
            'stats' => [
                'followers' => SocialFollow::where('followed_id', $user->id)->count(),
                'following' => SocialFollow::where('follower_id', $user->id)->count(),
                'friends_online' => $this->friendsOnlineCount($user),
                'live_rooms' => $liveRooms->count(),
                'events' => $events->count(),
            ],
            'privacy' => $preferences->only($preferences->getFillable()),
            'capabilities' => [
                'spectator' => $this->enabled('spectator_mode_enabled', true),
                'replays' => $this->enabled('replay_system_enabled', true),
                'animated_gifts' => $this->enabled('animated_gifts_enabled', true),
                'voice_for_players_only' => true,
                'spectator_hands_visible' => false,
            ],
        ]);
    }

    public function privacy(Request $request)
    {
        $preference = $this->policy->preferences($request->user());
        return response()->json(['ok' => true, 'privacy' => $preference->only($preference->getFillable())]);
    }

    public function updatePrivacy(Request $request)
    {
        $data = $request->validate([
            'profile_visibility' => 'sometimes|in:public,friends,private',
            'presence_visibility' => 'sometimes|in:public,friends,private',
            'activity_visibility' => 'sometimes|in:public,friends,private',
            'message_policy' => 'sometimes|in:everyone,friends,nobody',
            'invite_policy' => 'sometimes|in:everyone,friends,nobody',
            'discoverable' => 'sometimes|boolean',
            'allow_friend_requests' => 'sometimes|boolean',
            'allow_follows' => 'sometimes|boolean',
            'allow_spectators' => 'sometimes|boolean',
            'allow_replay_share' => 'sometimes|boolean',
            'allow_voice' => 'sometimes|boolean',
            'show_online_status' => 'sometimes|boolean',
            'show_current_room' => 'sometimes|boolean',
        ]);
        $preference = $this->policy->preferences($request->user());
        $preference->update($data);
        return response()->json(['ok' => true, 'message' => 'تم حفظ خصوصية العالم الاجتماعي.', 'privacy' => $preference->fresh()->only($preference->getFillable())]);
    }

    public function heartbeat(Request $request)
    {
        $data = $request->validate(['screen' => 'nullable|string|max:60', 'room_code' => 'nullable|string|max:20']);
        $preferences = $this->policy->preferences($request->user());
        $roomCode = $preferences->show_current_room ? ($data['room_code'] ?? null) : null;
        PresenceSession::updateOrCreate(
            ['user_id' => $request->user()->id, 'scope' => 'social_world', 'room_code' => null],
            ['last_seen_at' => now(), 'meta' => ['screen' => $data['screen'] ?? 'world', 'room_code' => $roomCode]]
        );
        $request->user()->update(['last_seen_at' => now()]);
        return response()->json(['ok' => true, 'server_time' => now()->toIso8601String()]);
    }

    public function follow(Request $request, User $user)
    {
        abort_unless($this->policy->canFollow($request->user(), $user), 403, 'هذا الحساب لا يسمح بالمتابعة.');
        SocialFollow::firstOrCreate(['follower_id' => $request->user()->id, 'followed_id' => $user->id]);
        return response()->json(['ok' => true, 'message' => 'تمت متابعة اللاعب.']);
    }

    public function unfollow(Request $request, User $user)
    {
        SocialFollow::where('follower_id', $request->user()->id)->where('followed_id', $user->id)->delete();
        return response()->json(['ok' => true, 'message' => 'تم إلغاء المتابعة.']);
    }

    public function publish(Request $request)
    {
        abort_unless($this->enabled('social_feed_enabled', true), 503, 'النشر الاجتماعي متوقف مؤقتًا.');
        $data = $request->validate([
            'type' => ['required', Rule::in(['status', 'looking_for_game', 'achievement', 'club_update', 'replay_share'])],
            'text' => 'required|string|min:1|max:500',
            'audience' => 'nullable|in:public,friends,followers,club,private',
            'room_code' => 'nullable|string|max:20',
            'club_id' => 'nullable|integer|exists:clubs,id',
            'replay_id' => 'required_if:type,replay_share|nullable|integer|exists:match_replays,id',
        ]);
        $preferences = $this->policy->preferences($request->user());
        $audience = $data['audience'] ?? $preferences->activity_visibility;
        abort_if(!empty($data['replay_id']) && $data['type'] !== 'replay_share', 422, 'اربط الإعادة بمنشور مشاركة إعادة فقط.');
        if (!empty($data['club_id'])) {
            abort_unless(ClubMember::where('club_id', $data['club_id'])->where('user_id', $request->user()->id)->exists(), 403, 'لا يمكنك ربط منشور بنادٍ لا تنتمي إليه.');
        }
        if ($audience === 'club') {
            abort_unless(!empty($data['club_id']) && ClubMember::where('club_id', $data['club_id'])->where('user_id', $request->user()->id)->exists(), 403);
        }
        if ($data['type'] === 'replay_share') {
            $replay = MatchReplay::with('room.players.user')->findOrFail((int) ($data['replay_id'] ?? 0));
            abort_unless($this->policy->canShareReplay($request->user(), $replay), 403, 'لا يمكن مشاركة هذه الإعادة دون موافقة جميع اللاعبين.');
            $allowedAudiences = match ($replay->visibility) {
                'public' => ['public', 'friends', 'followers', 'private'],
                'friends' => ['friends', 'private'],
                default => ['private'],
            };
            abort_unless(in_array($audience, $allowedAudiences, true), 422, 'نطاق المنشور أوسع من خصوصية الإعادة.');
        }
        $room = !empty($data['room_code']) ? Room::where('code', strtoupper($data['room_code']))->first() : null;
        if (!empty($data['room_code'])) {
            abort_unless($room, 422, 'رمز الغرفة غير موجود.');
            $canLinkRoom = $request->user()->is_admin || (int) $room->owner_id === (int) $request->user()->id
                || $room->players()->where('user_id', $request->user()->id)->where('is_bot', false)->exists();
            abort_unless($canLinkRoom, 403, 'لا يمكنك ربط منشور بغرفة لست أحد لاعبيها.');
            abort_if($room->visibility === 'private' && $audience !== 'private', 422, 'لا يمكن نشر رابط غرفة خاصة خارج النطاق الخاص.');
        }
        $activity = SocialActivity::create([
            'actor_id' => $request->user()->id,
            'room_id' => $room?->id,
            'club_id' => $data['club_id'] ?? null,
            'type' => $data['type'],
            'audience' => $audience,
            'payload' => ['text' => trim(strip_tags($data['text'])), 'replay_id' => $data['replay_id'] ?? null],
            'published_at' => now(),
            'expires_at' => $data['type'] === 'looking_for_game' ? now()->addHours(3) : null,
        ]);
        return response()->json(['ok' => true, 'message' => 'تم النشر في عالم ورقنا.', 'activity' => $this->activityPayload($activity->load(['actor.profile', 'club', 'room.game']), $request->user())], 201);
    }

    public function deleteActivity(Request $request, SocialActivity $activity)
    {
        abort_unless((int) $activity->actor_id === (int) $request->user()->id || $request->user()->is_admin, 403);
        $activity->update(['hidden' => true, 'moderated_by' => $request->user()->is_admin ? $request->user()->id : null, 'moderation_note' => 'owner_removed']);
        return response()->json(['ok' => true, 'message' => 'تمت إزالة المنشور.']);
    }

    public function events(Request $request)
    {
        $events = SocialEvent::with(['creator.profile', 'club', 'game', 'room', 'attendees'])
            ->whereIn('status', ['scheduled', 'live'])->where('starts_at', '>=', now()->subDay())
            ->orderByDesc('featured')->orderBy('starts_at')->paginate(30);
        $items = collect($events->items())->filter(fn (SocialEvent $event) => $this->canViewEvent($request->user(), $event))
            ->map(fn (SocialEvent $event) => $this->eventPayload($event, $request->user()))->values();
        return response()->json(['ok' => true, 'events' => $items, 'next_page' => $events->hasMorePages() ? $events->currentPage() + 1 : null]);
    }

    public function createEvent(Request $request)
    {
        abort_unless($this->enabled('social_events_enabled', true), 503, 'الفعاليات متوقفة مؤقتًا.');
        $data = $request->validate([
            'title_ar' => 'required|string|max:140', 'title_en' => 'nullable|string|max:140',
            'description_ar' => 'nullable|string|max:2000', 'description_en' => 'nullable|string|max:2000',
            'visibility' => 'required|in:public,friends,club,private',
            'starts_at' => 'required|date|after:now', 'ends_at' => 'nullable|date|after:starts_at',
            'capacity' => 'nullable|integer|min:2|max:100000',
            'club_id' => 'nullable|integer|exists:clubs,id', 'game_id' => 'nullable|integer|exists:games,id',
        ]);
        if ($data['visibility'] === 'club') {
            abort_unless(!empty($data['club_id']) && ClubMember::where('club_id', $data['club_id'])->where('user_id', $request->user()->id)->whereIn('role', ['owner', 'moderator'])->exists(), 403);
        }
        $event = SocialEvent::create([
            'created_by' => $request->user()->id,
            'club_id' => $data['club_id'] ?? null,
            'game_id' => $data['game_id'] ?? null,
            'title' => ['ar' => trim($data['title_ar']), 'en' => trim($data['title_en'] ?? $data['title_ar'])],
            'description' => ['ar' => trim(strip_tags($data['description_ar'] ?? '')), 'en' => trim(strip_tags($data['description_en'] ?? $data['description_ar'] ?? ''))],
            'visibility' => $data['visibility'], 'status' => 'scheduled',
            'starts_at' => $data['starts_at'], 'ends_at' => $data['ends_at'] ?? null,
            'capacity' => $data['capacity'] ?? null, 'settings' => ['voice_lounge' => false, 'spectator_ready' => true],
        ]);
        return response()->json(['ok' => true, 'message' => 'تم إنشاء الفعالية.', 'event' => $this->eventPayload($event->load(['creator.profile', 'club', 'game', 'attendees']), $request->user())], 201);
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
            SocialEventAttendee::updateOrCreate(
                ['social_event_id' => $locked->id, 'user_id' => $request->user()->id],
                ['status' => 'going', 'joined_at' => now()]
            );
        });
        return response()->json(['ok' => true, 'message' => 'تم تأكيد حضورك.']);
    }

    public function cancelAttendance(Request $request, SocialEvent $event)
    {
        SocialEventAttendee::where('social_event_id', $event->id)->where('user_id', $request->user()->id)->update(['status' => 'cancelled']);
        return response()->json(['ok' => true, 'message' => 'تم إلغاء الحضور.']);
    }

    public function gifts()
    {
        return response()->json(['ok' => true, 'gifts' => $this->giftCatalog(), 'competitive_advantage' => false]);
    }

    public function sendGift(Request $request, WalletService $wallet, FirebasePushService $push)
    {
        abort_unless($this->enabled('animated_gifts_enabled', true), 503, 'الهدايا المتحركة متوقفة مؤقتًا.');
        $data = $request->validate([
            'recipient_id' => 'required|integer|exists:users,id',
            'gift_key' => 'required|string|max:60',
            'room_code' => 'nullable|string|max:20',
            'activity_id' => 'nullable|integer|exists:social_activities,id',
            'message' => 'nullable|string|max:240',
            'visible' => 'nullable|boolean',
        ]);
        $catalog = config('warqna_social_world.gifts', []);
        $gift = $catalog[$data['gift_key']] ?? null;
        abort_unless(is_array($gift), 422, 'الهدية غير موجودة.');
        $recipient = User::findOrFail($data['recipient_id']);
        abort_if((int) $recipient->id === (int) $request->user()->id, 422, 'اختر لاعبًا آخر لإرسال الهدية.');
        abort_if($this->policy->blocked($request->user()->id, $recipient->id), 403);
        abort_unless($this->policy->canViewProfile($request->user(), $recipient), 403, 'هذا اللاعب لا يستقبل تفاعلات اجتماعية منك.');
        $room = !empty($data['room_code']) ? Room::where('code', strtoupper($data['room_code']))->first() : null;
        abort_if(!empty($data['room_code']) && !$room, 422, 'رمز الغرفة غير موجود.');
        $activity = !empty($data['activity_id']) ? SocialActivity::with('actor')->findOrFail($data['activity_id']) : null;
        if ($activity) {
            abort_unless($this->policy->canViewActivity($request->user(), $activity), 403, 'لا يمكنك الإهداء داخل منشور غير متاح لك.');
            abort_unless((int) $activity->actor_id === (int) $recipient->id, 422, 'يجب أن تكون الهدية لصاحب المنشور.');
        }
        if ($room) {
            $inRoom = $room->players()->where('user_id', $request->user()->id)->exists()
                || RoomSpectator::where('room_id', $room->id)->where('user_id', $request->user()->id)->where('status', 'active')->exists();
            abort_unless($inRoom, 403, 'يجب أن تكون لاعبًا أو مشاهدًا في الغرفة.');
            $recipientInRoom = $room->players()->where('user_id', $recipient->id)->exists()
                || RoomSpectator::where('room_id', $room->id)->where('user_id', $recipient->id)->where('status', 'active')->exists();
            abort_unless($recipientInRoom, 422, 'المستلم ليس داخل هذه الغرفة.');
        }
        $cost = (int) ($gift['cost'] ?? 0);
        try {
            $socialGift = DB::transaction(function () use ($wallet, $request, $recipient, $gift, $data, $room, $cost) {
                $wallet->debit($request->user(), $cost, 'social_gift_sent', ['recipient_id' => $recipient->id, 'gift_key' => $data['gift_key']]);
                $wallet->creditPrimaryAdminRevenue($request->user(), $cost, 'social_gift_income', ['recipient_id' => $recipient->id, 'gift_key' => $data['gift_key']]);
                return SocialGift::create([
                    'sender_id' => $request->user()->id, 'recipient_id' => $recipient->id,
                    'room_id' => $room?->id, 'social_activity_id' => $data['activity_id'] ?? null,
                    'gift_key' => $data['gift_key'], 'token_cost' => $cost,
                    'animation_key' => $gift['animation'], 'message' => trim(strip_tags($data['message'] ?? '')) ?: null,
                    'visible' => $data['visible'] ?? true, 'delivered_at' => now(),
                    'meta' => ['icon' => $gift['icon'], 'release' => 'R11'],
                ]);
            });
        } catch (RuntimeException) {
            abort(422, 'رصيد التوكنز غير كافٍ لإرسال هذه الهدية.');
        }
        Notification::create([
            'user_id' => $recipient->id, 'type' => 'social_gift',
            'title' => ['ar' => 'هدية جديدة', 'en' => 'New gift'],
            'body' => ['ar' => $request->user()->username.' أرسل لك '.$gift['ar'], 'en' => $request->user()->username.' sent you '.$gift['en']],
            'meta' => ['gift_id' => $socialGift->id, 'animation' => $gift['animation'], 'room_code' => $room?->code],
        ]);
        $push->sendToUser($recipient, 'هدية من '.$request->user()->username, $gift['icon'].' '.$gift['ar'], ['type' => 'social_gift', 'gift_id' => $socialGift->id, 'room_code' => $room?->code]);
        return response()->json(['ok' => true, 'message' => 'وصلت الهدية المتحركة.', 'gift' => $this->giftPayload($socialGift->load(['sender.profile', 'recipient.profile']))], 201);
    }

    /** @return array<int,array<string,mixed>> */
    private function giftCatalog(): array
    {
        return collect(config('warqna_social_world.gifts', []))->map(fn ($gift, $key) => ['key' => $key] + $gift)->values()->all();
    }

    private function enabled(string $key, bool $default): bool
    {
        return filter_var(\App\Models\SiteSetting::getValue($key, $default), FILTER_VALIDATE_BOOLEAN);
    }

    private function canViewEvent(User $viewer, SocialEvent $event): bool
    {
        if ($viewer->is_admin || (int) $event->created_by === (int) $viewer->id) return true;
        if (!$event->creator || $this->policy->blocked($viewer->id, $event->creator->id)) return false;
        return match ($event->visibility) {
            'public' => true,
            'friends' => $this->policy->friends($viewer->id, $event->created_by),
            'club' => $event->club_id && ClubMember::where('club_id', $event->club_id)->where('user_id', $viewer->id)->exists(),
            default => false,
        };
    }

    /** @return array<string,mixed> */
    private function activityPayload(SocialActivity $activity, User $viewer): array
    {
        return [
            'id' => $activity->id, 'type' => $activity->type, 'audience' => $activity->audience,
            'actor' => $this->userPayload($activity->actor, $viewer),
            'text' => (string) data_get($activity->payload, 'text', ''),
            'payload' => $activity->payload ?: [],
            'club' => $activity->club ? ['id' => $activity->club->id, 'name' => $activity->club->name, 'logo' => $activity->club->logo] : null,
            'room' => $activity->room ? ['code' => $activity->room->code, 'game' => $activity->room->game?->key, 'status' => $activity->room->status] : null,
            'gifts' => $activity->gifts?->where('visible', true)
                ->filter(fn ($gift) => $gift->sender && !$this->policy->blocked($viewer->id, $gift->sender->id))
                ->take(12)->map(fn ($gift) => $this->giftPayload($gift))->values()->all() ?? [],
            'published_at' => $activity->published_at?->toIso8601String(),
            'mine' => (int) $activity->actor_id === (int) $viewer->id,
        ];
    }

    /** @return array<string,mixed> */
    private function eventPayload(SocialEvent $event, User $viewer): array
    {
        $attendance = $event->attendees?->firstWhere('user_id', $viewer->id);
        return [
            'id' => $event->id, 'title' => $event->title, 'description' => $event->description,
            'visibility' => $event->visibility, 'status' => $event->status, 'featured' => (bool) $event->featured,
            'starts_at' => $event->starts_at?->toIso8601String(), 'ends_at' => $event->ends_at?->toIso8601String(),
            'capacity' => $event->capacity, 'going' => $event->attendees?->where('status', 'going')->count() ?? 0,
            'attendance' => $attendance?->status,
            'creator' => $this->userPayload($event->creator, $viewer),
            'club' => $event->club ? ['id' => $event->club->id, 'name' => $event->club->name, 'logo' => $event->club->logo] : null,
            'game' => $event->game ? ['id' => $event->game->id, 'key' => $event->game->key, 'name' => $event->game->name] : null,
            'room_code' => $event->room?->code,
        ];
    }

    /** @return array<string,mixed> */
    private function liveRoomPayload(Room $room): array
    {
        $state = $room->state ?: [];
        return [
            'code' => $room->code, 'name' => $state['room_name'] ?? ($room->game?->name['ar'] ?? $room->game?->key),
            'game' => $room->game?->key, 'status' => $room->status, 'voice_for_players' => (bool) ($state['voice_enabled'] ?? $state['voice_room'] ?? false),
            'spectators' => $room->spectators?->where('status', 'active')->where('last_seen_at', '>=', now()->subSeconds(30))->count() ?? 0,
            'players' => $room->players?->where('is_bot', false)->map(fn ($player) => [
                'id' => $player->user_id, 'name' => $player->user?->profile?->display_name ?: $player->user?->username,
                'avatar' => $player->user?->profile?->avatar, 'level' => (int) ($player->user?->profile?->level ?? 1),
            ])->values()->all() ?? [],
            'updated_at' => $room->updated_at?->toIso8601String(),
        ];
    }

    /** @return array<string,mixed> */
    private function userPayload(?User $target, User $viewer): array
    {
        if (!$target) return [];
        $target->loadMissing('profile');
        $onlineVisible = $this->policy->canSeePresence($viewer, $target);
        return [
            'id' => $target->id, 'username' => $target->username,
            'display_name' => $target->profile?->display_name ?: $target->username,
            'avatar' => $target->profile?->avatar, 'level' => (int) ($target->profile?->level ?? 1),
            'country_code' => safe_country_code($target->profile?->country_code ?? 'PS'),
            'online' => $onlineVisible ? ($target->last_seen_at?->gt(now()->subMinutes(3)) ?? false) : null,
            'following' => SocialFollow::where('follower_id', $viewer->id)->where('followed_id', $target->id)->exists(),
            'friend' => $this->policy->friends($viewer->id, $target->id),
        ];
    }

    /** @return array<string,mixed> */
    private function giftPayload(SocialGift $gift): array
    {
        return [
            'id' => $gift->id, 'gift_key' => $gift->gift_key, 'animation' => $gift->animation_key,
            'icon' => data_get($gift->meta, 'icon'), 'message' => $gift->message, 'token_cost' => (int) $gift->token_cost,
            'sender' => $gift->sender ? ['id' => $gift->sender->id, 'name' => $gift->sender->profile?->display_name ?: $gift->sender->username, 'avatar' => $gift->sender->profile?->avatar] : null,
            'created_at' => $gift->created_at?->toIso8601String(),
        ];
    }

    private function friendsOnlineCount(User $user): int
    {
        $ids = \App\Models\Friendship::where('status', 'accepted')->where(fn ($q) => $q->where('requester_id', $user->id)->orWhere('addressee_id', $user->id))
            ->get()->map(fn ($friendship) => (int) ($friendship->requester_id === $user->id ? $friendship->addressee_id : $friendship->requester_id))
            ->unique()->values();
        return User::whereKey($ids->all())->get()->filter(fn (User $friend) =>
            $this->policy->canSeePresence($user, $friend)
            && ($friend->last_seen_at?->gte(now()->subMinutes(3)) ?? false)
        )->count();
    }
}
