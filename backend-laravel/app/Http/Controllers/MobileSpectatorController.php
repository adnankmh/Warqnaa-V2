<?php

namespace App\Http\Controllers;

use App\Models\{Room, RoomSpectator, SocialGift};
use App\Services\Social\{MatchReplayService, SocialWorldPolicy};
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MobileSpectatorController extends Controller
{
    public function __construct(
        private readonly SocialWorldPolicy $policy,
        private readonly MatchReplayService $replays,
    ) {}

    public function lobby(Request $request)
    {
        $this->assertEnabled();
        $rooms = Room::with(['owner.profile', 'game', 'players.user.profile', 'spectators'])
            ->whereIn('status', ['waiting', 'bidding', 'playing'])
            ->latest('updated_at')->limit(80)->get()
            ->filter(fn (Room $room) => $this->policy->canSpectate($request->user(), $room))
            ->take(30)->map(fn (Room $room) => $this->roomSummary($room, $request->user()))->values();

        return response()->json([
            'ok' => true,
            'rooms' => $rooms,
            'contract' => [
                'read_only' => true,
                'hands_visible' => false,
                'voice_enabled' => false,
                'private_chat_visible' => false,
                'state_poll_seconds' => 2,
            ],
        ]);
    }

    public function join(Request $request, Room $room)
    {
        $this->assertEnabled();
        $room->loadMissing(['owner.profile', 'game', 'players.user.profile', 'spectators']);
        abort_unless($this->policy->canSpectate($request->user(), $room), 403, 'لا تسمح خصوصية هذه الغرفة بالمشاهدة.');

        DB::transaction(function () use ($request, $room) {
            $lockedRoom = Room::with(['owner', 'players.user'])->whereKey($room->id)->lockForUpdate()->firstOrFail();
            abort_unless($this->policy->canSpectate($request->user(), $lockedRoom), 403, 'تم إغلاق المشاهدة لهذه الغرفة.');
            $staleBefore = now()->subSeconds($this->staleSeconds());
            RoomSpectator::where('room_id', $room->id)->where('status', 'active')
                ->where('last_seen_at', '<', $staleBefore)->update(['status' => 'left']);
            $limit = max(1, min(10000, (int) \App\Models\SiteSetting::getValue('max_room_spectators', 120)));
            $active = RoomSpectator::where('room_id', $room->id)->where('status', 'active')
                ->where('last_seen_at', '>=', $staleBefore)->count();
            $existing = RoomSpectator::where('room_id', $room->id)->where('user_id', $request->user()->id)->first();
            $alreadyActive = $existing?->status === 'active' && $existing->last_seen_at?->gte($staleBefore);
            abort_if(!$alreadyActive && $active >= $limit, 409, 'اكتمل عدد مشاهدي الغرفة.');
            RoomSpectator::where('user_id', $request->user()->id)->where('room_id', '!=', $room->id)
                ->where('status', 'active')->update(['status' => 'left']);
            RoomSpectator::updateOrCreate(
                ['room_id' => $room->id, 'user_id' => $request->user()->id],
                [
                    'status' => 'active', 'joined_at' => now(), 'last_seen_at' => now(),
                    'can_chat' => false, 'voice_enabled' => false,
                    'meta' => ['client' => 'r11', 'privacy_acknowledged' => true],
                ]
            );
        });

        return response()->json([
            'ok' => true,
            'message' => 'أهلًا بك في المدرجات — المشاهدة آمنة وبدون كشف الأوراق.',
            'spectator' => $this->statePayload($room->fresh(['owner.profile', 'game', 'players.user.profile', 'spectators']), $request->user()),
        ], 201);
    }

    public function show(Request $request, Room $room)
    {
        $this->assertEnabled();
        $membership = RoomSpectator::where('room_id', $room->id)->where('user_id', $request->user()->id)
            ->where('status', 'active')->first();
        abort_unless($membership || $request->user()->is_admin, 403, 'انضم كمشاهد أولًا.');
        abort_unless($request->user()->is_admin || $this->policy->canSpectate($request->user(), $room), 403, 'تم إغلاق المشاهدة لهذه الغرفة.');
        $membership?->update(['last_seen_at' => now()]);

        return response()->json(['ok' => true, 'spectator' => $this->statePayload($room->fresh(['owner.profile', 'game', 'players.user.profile', 'spectators']), $request->user())]);
    }

    public function heartbeat(Request $request, Room $room)
    {
        $spectator = RoomSpectator::where('room_id', $room->id)->where('user_id', $request->user()->id)
            ->where('status', 'active')->firstOrFail();
        abort_unless($this->policy->canSpectate($request->user(), $room), 403, 'تم إغلاق المشاهدة لهذه الغرفة.');
        $spectator->update(['last_seen_at' => now()]);
        return response()->json(['ok' => true, 'server_time' => now()->toIso8601String()]);
    }

    public function leave(Request $request, Room $room)
    {
        RoomSpectator::where('room_id', $room->id)->where('user_id', $request->user()->id)
            ->update(['status' => 'left', 'last_seen_at' => now(), 'voice_enabled' => false]);
        return response()->json(['ok' => true, 'message' => 'غادرت المدرجات.']);
    }

    /** @return array<string,mixed> */
    private function statePayload(Room $room, \App\Models\User $viewer): array
    {
        $room->loadMissing(['owner.profile', 'game', 'players.user.profile', 'spectators']);
        $state = $room->state ?: [];
        $safeState = $this->replays->spectatorState($state);
        $gifts = SocialGift::with('sender.profile')->where('room_id', $room->id)->where('visible', true)
            ->latest()->limit(24)->get()
            ->filter(fn (SocialGift $gift) => $gift->sender && !$this->policy->blocked($viewer->id, $gift->sender->id))
            ->take(12)->map(fn (SocialGift $gift) => [
                'id' => $gift->id, 'gift_key' => $gift->gift_key, 'animation' => $gift->animation_key,
                'icon' => data_get($gift->meta, 'icon', '✨'), 'message' => $gift->message,
                'sender' => $gift->sender?->profile?->display_name ?: $gift->sender?->username,
                'created_at' => $gift->created_at?->toIso8601String(),
            ])->values();

        return [
            'room' => $this->roomSummary($room, $viewer),
            'state_revision' => (int) ($state['_revision'] ?? 0),
            'state' => $safeState,
            'gifts' => $gifts,
            'restrictions' => ['read_only' => true, 'hands_visible' => false, 'voice_enabled' => false, 'private_chat_visible' => false],
            'server_time' => now()->toIso8601String(),
        ];
    }

    /** @return array<string,mixed> */
    private function roomSummary(Room $room, \App\Models\User $viewer): array
    {
        $staleBefore = now()->subSeconds($this->staleSeconds());
        return [
            'code' => $room->code,
            'name' => data_get($room->state, 'room_name', $room->game?->key),
            'game' => $room->game?->key,
            'game_name' => $room->game?->name,
            'status' => $room->status,
            'owner' => $room->owner ? ['id' => $room->owner->id, 'name' => $room->owner->profile?->display_name ?: $room->owner->username] : null,
            'players' => $room->players?->where('is_bot', false)
                ->filter(fn ($player) => $player->user && !$this->policy->blocked($viewer->id, $player->user->id))
                ->map(fn ($player) => [
                'id' => $player->user_id, 'name' => $player->user?->profile?->display_name ?: $player->user?->username,
                'avatar' => $player->user?->profile?->avatar, 'seat' => (int) $player->seat,
            ])->values()->all() ?? [],
            'spectators' => $room->spectators?->where('status', 'active')->filter(fn ($item) => $item->last_seen_at?->gte($staleBefore))->count() ?? 0,
            'allow_gifts' => true,
            'voice_for_players_only' => true,
            'updated_at' => $room->updated_at?->toIso8601String(),
        ];
    }

    private function staleSeconds(): int
    {
        return max(15, min(180, (int) config('warqna_social_world.spectator_stale_seconds', 45)));
    }

    private function assertEnabled(): void
    {
        abort_unless(filter_var(\App\Models\SiteSetting::getValue('spectator_mode_enabled', true), FILTER_VALIDATE_BOOLEAN), 503, 'وضع المشاهدة متوقف مؤقتًا.');
    }
}
