<?php

namespace App\Http\Controllers;

use App\Models\{
    MatchReplay, RoomSpectator, SiteSetting, SocialActivity, SocialEvent,
    SocialGift, SocialPreference
};
use App\Services\Platform\AdminAuditService;
use App\Services\Social\MatchReplayService;
use App\Support\AuthenticatedActor;
use Illuminate\Http\Request;

class AdminSocialWorldController extends Controller
{
    private const BOOL_SETTINGS = [
        'social_world_enabled', 'social_feed_enabled', 'social_events_enabled',
        'spectator_mode_enabled', 'replay_system_enabled', 'animated_gifts_enabled',
    ];

    public function dashboard(Request $request)
    {
        $this->guard($request);
        return response()->json([
            'ok' => true,
            'release' => ['version' => '0.6.0', 'build' => 230, 'name' => 'R11 Social World'],
            'stats' => [
                'activities' => SocialActivity::where('hidden', false)->count(),
                'events_upcoming' => SocialEvent::whereIn('status', ['scheduled', 'live'])->where('starts_at', '>=', now()->subDay())->count(),
                'spectators_live' => RoomSpectator::where('status', 'active')->where('last_seen_at', '>=', now()->subMinute())->count(),
                'replays_ready' => MatchReplay::where('status', 'ready')->count(),
                'gifts_delivered' => SocialGift::count(),
                'privacy_profiles' => SocialPreference::count(),
            ],
            'settings' => $this->settings(),
            'activities' => SocialActivity::with(['actor.profile', 'club', 'moderator.profile'])->latest('published_at')->limit(60)->get(),
            'events' => SocialEvent::with(['creator.profile', 'club', 'game'])->latest('starts_at')->limit(60)->get(),
            'spectators' => RoomSpectator::with(['user.profile', 'room.game'])->where('status', 'active')->latest('last_seen_at')->limit(80)->get(),
            'replays' => MatchReplay::query()->select([
                'id', 'room_id', 'owner_id', 'game_id', 'visibility', 'status', 'duration_seconds',
                'frames_count', 'sha256', 'views', 'featured', 'published_at', 'expires_at', 'created_at', 'updated_at',
            ])->with(['owner.profile', 'room', 'game'])->latest('published_at')->limit(80)->get(),
            'gifts' => SocialGift::with(['sender.profile', 'recipient.profile', 'room'])->latest()->limit(80)->get(),
        ]);
    }

    public function updateSettings(Request $request, AdminAuditService $audit)
    {
        $this->guard($request);
        $data = $request->validate([
            'social_world_enabled' => 'sometimes|boolean', 'social_feed_enabled' => 'sometimes|boolean',
            'social_events_enabled' => 'sometimes|boolean', 'spectator_mode_enabled' => 'sometimes|boolean',
            'replay_system_enabled' => 'sometimes|boolean', 'animated_gifts_enabled' => 'sometimes|boolean',
            'max_room_spectators' => 'sometimes|integer|min:1|max:10000',
            'replay_retention_days' => 'sometimes|integer|min:1|max:365',
            'social_feed_page_size' => 'sometimes|integer|min:10|max:100',
        ]);
        $before = $this->settings();
        foreach (self::BOOL_SETTINGS as $key) {
            if (array_key_exists($key, $data)) SiteSetting::setValue($key, (bool) $data[$key], 'bool', 'social_world', $key);
        }
        foreach (['max_room_spectators', 'replay_retention_days', 'social_feed_page_size'] as $key) {
            if (array_key_exists($key, $data)) SiteSetting::setValue($key, (int) $data[$key], 'int', 'social_world', $key);
        }
        $after = $this->settings();
        $audit->record($request, 'admin.social_world.settings', 'social_world', $before, $after);
        return $this->respond($request, 'تم حفظ إعدادات Social World.', ['settings' => $after]);
    }

    public function activityAction(Request $request, SocialActivity $activity, AdminAuditService $audit)
    {
        $this->guard($request);
        $data = $request->validate(['action' => 'required|in:hide,restore', 'note' => 'nullable|string|max:500']);
        $before = $activity->toArray();
        $activity->update([
            'hidden' => $data['action'] === 'hide',
            'moderated_by' => $request->user()->id,
            'moderation_note' => trim(strip_tags($data['note'] ?? '')) ?: 'admin_'.$data['action'],
        ]);
        $audit->record($request, 'admin.social_world.activity.'.$data['action'], $activity, $before, $activity->fresh()->toArray());
        return $this->respond($request, 'تم تحديث المنشور الاجتماعي.');
    }

    public function eventAction(Request $request, SocialEvent $event, AdminAuditService $audit)
    {
        $this->guard($request);
        $data = $request->validate(['action' => 'required|in:feature,unfeature,live,cancel,finish']);
        $before = $event->toArray();
        match ($data['action']) {
            'feature' => $event->update(['featured' => true]),
            'unfeature' => $event->update(['featured' => false]),
            'live' => $event->update(['status' => 'live']),
            'cancel' => $event->update(['status' => 'cancelled']),
            'finish' => $event->update(['status' => 'finished']),
        };
        $audit->record($request, 'admin.social_world.event.'.$data['action'], $event, $before, $event->fresh()->toArray());
        return $this->respond($request, 'تم تحديث الفعالية.');
    }

    public function replayAction(Request $request, MatchReplay $replay, AdminAuditService $audit, MatchReplayService $replays)
    {
        $this->guard($request);
        $data = $request->validate(['action' => 'required|in:feature,unfeature,hide,restore']);
        abort_if($data['action'] === 'feature' && $replay->status !== 'ready', 422, 'لا يمكن تمييز إعادة لم تكتمل.');
        abort_if($data['action'] === 'feature' && !$replays->verify($replay), 409, 'فشل تحقق سلامة الإعادة.');
        $before = $replay->toArray();
        match ($data['action']) {
            'feature' => $replay->update(['featured' => true]),
            'unfeature' => $replay->update(['featured' => false]),
            'hide' => $replay->update(['status' => 'hidden', 'visibility' => 'private', 'featured' => false]),
            'restore' => $replay->update([
                'status' => $replay->published_at && $replay->sha256 && $replay->frames_count > 0 ? 'ready' : 'recording',
                'visibility' => 'private',
                'featured' => false,
            ]),
        };
        $audit->record($request, 'admin.social_world.replay.'.$data['action'], $replay, $before, $replay->fresh()->toArray());
        return $this->respond($request, 'تم تحديث الإعادة.');
    }

    public function evictSpectator(Request $request, RoomSpectator $spectator, AdminAuditService $audit)
    {
        $this->guard($request);
        $before = $spectator->toArray();
        $spectator->update(['status' => 'evicted', 'voice_enabled' => false, 'can_chat' => false, 'last_seen_at' => now()]);
        $audit->record($request, 'admin.social_world.spectator.evict', $spectator, $before, $spectator->fresh()->toArray());
        return $this->respond($request, 'تم إخراج المشاهد من المدرجات.');
    }

    /** @return array<string,mixed> */
    private function settings(): array
    {
        $defaults = [
            'social_world_enabled' => true, 'social_feed_enabled' => true, 'social_events_enabled' => true,
            'spectator_mode_enabled' => true, 'replay_system_enabled' => true, 'animated_gifts_enabled' => true,
            'max_room_spectators' => 120, 'replay_retention_days' => 30, 'social_feed_page_size' => 30,
        ];
        foreach ($defaults as $key => $default) {
            $value = SiteSetting::getValue($key, $default);
            $defaults[$key] = in_array($key, self::BOOL_SETTINGS, true) ? filter_var($value, FILTER_VALIDATE_BOOLEAN) : (int) $value;
        }
        return $defaults;
    }

    private function guard(Request $request): void
    {
        $actor = AuthenticatedActor::resolve($request);
        abort_unless((bool) $actor->is_admin, 403, 'هذه الصفحة للإدارة فقط.');
        abort_unless($actor->hasAdminPermission('social_world'), 403, 'تحتاج صلاحية إدارة Social World.');
    }

    /** @param array<string,mixed> $extra */
    private function respond(Request $request, string $message, array $extra = [])
    {
        if ($request->expectsJson()) return response()->json(['ok' => true, 'message' => $message] + $extra);
        return back()->with('ok', $message);
    }
}
