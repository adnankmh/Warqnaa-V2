<?php

namespace App\Http\Controllers;

use App\Models\{
    Club, ClubActivityLog, ClubAnnouncement, ClubJoinRequest, ClubMember,
    Notification, SocialActivity, User
};
use App\Services\Social\SocialWorldPolicy;
use App\Services\Wallet\WalletService;
use App\Support\AuthenticatedActor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class MobileClubWorldController extends Controller
{
    private const CAPS = [1 => 20, 2 => 30, 3 => 40, 4 => 50, 5 => 70, 6 => 100];
    private const LEAGUES = [
        1 => ['ar' => 'برونزي', 'en' => 'Bronze'], 2 => ['ar' => 'فضي', 'en' => 'Silver'],
        3 => ['ar' => 'ذهبي', 'en' => 'Gold'], 4 => ['ar' => 'بلاتيني', 'en' => 'Platinum'],
        5 => ['ar' => 'ماسي', 'en' => 'Diamond'], 6 => ['ar' => 'أسطوري', 'en' => 'Legendary'],
    ];

    public function __construct(private readonly SocialWorldPolicy $policy) {}

    public function index(Request $request)
    {
        AuthenticatedActor::resolve($request);
        $this->assertEnabled();
        $membership = ClubMember::with('club')->where('user_id', $request->user()->id)->first();
        $clubs = Club::with(['owner.profile', 'members.user.profile'])->withCount('members')
            ->where('visibility', '!=', 'private')->orderByDesc('weekly_points')->latest()->limit(60)->get()
            ->map(fn (Club $club) => $this->clubPayload($club, $request))->values();

        return response()->json([
            'ok' => true,
            'my_club' => $membership?->club ? $this->clubPayload($membership->club->load(['owner.profile', 'members.user.profile']), $request, true) : null,
            'clubs' => $clubs,
            'creation' => ['cost' => 5000, 'requires_pasha' => true, 'one_club_per_user' => true],
            'leagues' => self::LEAGUES,
        ]);
    }

    public function show(Request $request, Club $club)
    {
        AuthenticatedActor::resolve($request);
        $this->assertEnabled();
        $member = $club->members()->where('user_id', $request->user()->id)->first();
        abort_if($club->visibility === 'private' && !$member && !$request->user()->is_admin, 403, 'هذا النادي خاص.');
        $club->load([
            'owner.profile', 'members.user.profile', 'announcements.author.profile',
            'tournaments.game', 'activityLogs.actor.profile', 'socialEvents.attendees',
            'joinRequests.user.profile',
        ]);
        return response()->json([
            'ok' => true,
            'club' => $this->clubPayload($club, $request, true),
            'membership' => $member ? ['role' => $member->role, 'permissions' => $member->permissions ?: [], 'can_manage' => $this->can($club, $request, 'manage_club')] : null,
            'announcements' => $club->announcements
                ->filter(fn ($item) => !$item->author || $request->user()->is_admin || (int) $item->author_id === (int) $request->user()->id || !$this->policy->blocked($request->user()->id, $item->author_id))
                ->take(20)->map(fn ($item) => [
                'id' => $item->id, 'title' => $item->title, 'body' => $item->body, 'pinned' => (bool) $item->pinned,
                'author' => $item->author?->profile?->display_name ?: $item->author?->username,
                'created_at' => $item->created_at?->toIso8601String(),
            ])->values(),
            'events' => $club->socialEvents->whereIn('status', ['scheduled', 'live'])->sortBy('starts_at')->take(20)->values()->map(fn ($event) => [
                'id' => $event->id, 'title' => $event->title, 'status' => $event->status,
                'starts_at' => $event->starts_at?->toIso8601String(), 'going' => $event->attendees->where('status', 'going')->count(),
            ]),
            'activity' => $club->activityLogs
                ->filter(fn ($item) => !$item->actor || $request->user()->is_admin || (int) $item->actor_id === (int) $request->user()->id || !$this->policy->blocked($request->user()->id, $item->actor_id))
                ->take(30)->map(fn ($item) => [
                'id' => $item->id, 'type' => $item->event_type, 'description' => $item->description,
                'actor' => $item->actor?->profile?->display_name ?: $item->actor?->username,
                'created_at' => $item->created_at?->toIso8601String(),
            ])->values(),
            'join_requests' => $this->can($club, $request, 'accept_members')
                ? $club->joinRequests->where('status', 'pending')->take(40)->map(fn ($item) => [
                    'id' => $item->id, 'status' => $item->status,
                    'user' => ['id' => $item->user_id, 'name' => $item->user?->profile?->display_name ?: $item->user?->username, 'avatar' => $item->user?->profile?->avatar],
                    'created_at' => $item->created_at?->toIso8601String(),
                ])->values()
                : [],
        ]);
    }

    public function create(Request $request, WalletService $wallet)
    {
        AuthenticatedActor::resolve($request);
        $this->assertEnabled();
        abort_unless(($request->user()->profile?->pasha_days ?? 0) > 0 || $request->user()->is_admin, 403, 'إنشاء النادي متاح لأعضاء الباشا.');
        abort_if(ClubMember::where('user_id', $request->user()->id)->exists(), 409, 'أنت عضو في نادي بالفعل.');
        $data = $request->validate([
            'name' => 'required|string|min:3|max:120|unique:clubs,name',
            'description' => 'nullable|string|max:1000', 'logo' => 'nullable|string|max:500',
            'visibility' => 'nullable|in:public,request,private',
        ]);
        try {
            $club = DB::transaction(function () use ($request, $wallet, $data) {
                $lockedUser = User::with('profile')->whereKey($request->user()->id)->lockForUpdate()->firstOrFail();
                abort_unless(($lockedUser->profile?->pasha_days ?? 0) > 0 || $lockedUser->is_admin, 403, 'إنشاء النادي متاح لأعضاء الباشا.');
                abort_if(ClubMember::where('user_id', $lockedUser->id)->exists(), 409, 'أنت عضو في نادي بالفعل.');
                $wallet->debit($lockedUser, 5000, 'club_create', ['name' => $data['name'], 'release' => 'R11']);
                $club = Club::create([
                    'owner_id' => $lockedUser->id, 'name' => trim($data['name']),
                    'description' => trim(strip_tags($data['description'] ?? '')) ?: null,
                    'logo' => $data['logo'] ?? '🛡️', 'visibility' => $data['visibility'] ?? 'public',
                    'level' => 1, 'treasury' => 0, 'capacity' => self::CAPS[1], 'league_tier' => 'bronze',
                ]);
                ClubMember::create(['club_id' => $club->id, 'user_id' => $lockedUser->id, 'role' => 'owner', 'permissions' => ['all' => true], 'last_active_at' => now()]);
                $this->log($club, $request, 'club.created', 'تم إنشاء النادي في عالم ورقنا.');
                return $club;
            });
        } catch (\Symfony\Component\HttpKernel\Exception\HttpExceptionInterface $exception) {
            throw $exception;
        } catch (RuntimeException) {
            abort(422, 'لا تملك توكنز كافية لإنشاء النادي.');
        }
        return response()->json(['ok' => true, 'message' => 'ولد ناديك في عالم ورقنا.', 'club' => $this->clubPayload($club->load(['owner.profile', 'members.user.profile']), $request, true)], 201);
    }

    public function join(Request $request, Club $club)
    {
        AuthenticatedActor::resolve($request);
        $this->assertEnabled();
        $status = DB::transaction(function () use ($request, $club) {
            User::whereKey($request->user()->id)->lockForUpdate()->firstOrFail();
            $lockedClub = Club::whereKey($club->id)->lockForUpdate()->firstOrFail();
            abort_if($lockedClub->visibility === 'private', 403, 'هذا النادي خاص.');
            abort_if(ClubMember::where('user_id', $request->user()->id)->where('club_id', '!=', $lockedClub->id)->exists(), 409, 'غادر ناديك الحالي أولًا.');
            abort_if(ClubMember::where('club_id', $lockedClub->id)->where('user_id', $request->user()->id)->exists(), 409, 'أنت عضو في النادي بالفعل.');
            abort_if(ClubMember::where('club_id', $lockedClub->id)->count() >= $this->cap($lockedClub), 409, 'النادي مكتمل العدد.');

            if ($lockedClub->visibility === 'public') {
                ClubMember::create(['club_id' => $lockedClub->id, 'user_id' => $request->user()->id, 'role' => 'member', 'permissions' => [], 'last_active_at' => now()]);
                ClubJoinRequest::where('club_id', $lockedClub->id)->where('user_id', $request->user()->id)->update(['status' => 'accepted']);
                $this->log($lockedClub, $request, 'join.accepted', 'انضم '.$request->user()->username.' إلى النادي.');
                return 'accepted';
            }

            ClubJoinRequest::updateOrCreate(['club_id' => $lockedClub->id, 'user_id' => $request->user()->id], ['status' => 'pending']);
            $this->log($lockedClub, $request, 'join.requested', 'تم إرسال طلب انضمام جديد.');
            return 'pending';
        });

        if ($status === 'pending') {
            Notification::create([
                'user_id' => $club->owner_id, 'type' => 'club_join',
                'title' => ['ar' => 'طلب انضمام', 'en' => 'Join request'],
                'body' => ['ar' => $request->user()->username.' يريد الانضمام إلى '.$club->name, 'en' => $request->user()->username.' wants to join '.$club->name],
                'meta' => ['club_id' => $club->id],
            ]);
        }

        return response()->json([
            'ok' => true,
            'status' => $status,
            'message' => $status === 'accepted' ? 'تم الانضمام إلى النادي.' : 'تم إرسال طلب الانضمام.',
        ], $status === 'accepted' ? 201 : 202);
    }

    public function leave(Request $request, Club $club)
    {
        AuthenticatedActor::resolve($request);
        $this->assertEnabled();
        $closed = DB::transaction(function () use ($request, $club) {
            User::whereKey($request->user()->id)->lockForUpdate()->firstOrFail();
            $lockedClub = Club::whereKey($club->id)->lockForUpdate()->firstOrFail();
            $member = ClubMember::where('club_id', $lockedClub->id)->where('user_id', $request->user()->id)->lockForUpdate()->firstOrFail();
            abort_if($member->role === 'owner' && ClubMember::where('club_id', $lockedClub->id)->count() > 1, 422, 'انقل الملكية قبل مغادرة النادي.');
            if ($member->role === 'owner') {
                $lockedClub->delete();
                return true;
            }
            $this->log($lockedClub, $request, 'member.left', 'غادر '.$request->user()->username.' النادي.');
            $member->delete();
            return false;
        });

        return response()->json(['ok' => true, 'message' => $closed
            ? 'تم إغلاق النادي لعدم وجود أعضاء آخرين.'
            : 'تمت مغادرة النادي.']);
    }

    public function announce(Request $request, Club $club)
    {
        AuthenticatedActor::resolve($request);
        $this->assertEnabled();
        abort_unless($this->can($club, $request, 'create_announcements'), 403, 'لا تملك صلاحية النشر.');
        $data = $request->validate(['title' => 'required|string|max:140', 'body' => 'required|string|max:2000', 'pinned' => 'nullable|boolean']);
        $announcement = ClubAnnouncement::create([
            'club_id' => $club->id, 'author_id' => $request->user()->id,
            'title' => trim($data['title']), 'body' => trim(strip_tags($data['body'])), 'pinned' => $request->boolean('pinned'),
        ]);
        SocialActivity::create([
            'actor_id' => $request->user()->id, 'club_id' => $club->id, 'type' => 'club_update', 'audience' => 'club',
            'payload' => ['text' => $announcement->title, 'announcement_id' => $announcement->id], 'published_at' => now(),
        ]);
        $this->log($club, $request, 'announcement.created', 'تم نشر إعلان: '.$announcement->title);
        return response()->json(['ok' => true, 'message' => 'تم نشر إعلان النادي.', 'announcement_id' => $announcement->id], 201);
    }

    public function respond(Request $request, ClubJoinRequest $joinRequest)
    {
        AuthenticatedActor::resolve($request);
        $this->assertEnabled();
        $club = $joinRequest->club;
        abort_unless($this->can($club, $request, 'accept_members'), 403);
        $data = $request->validate(['status' => 'required|in:accepted,rejected']);
        $recipientId = DB::transaction(function () use ($request, $joinRequest, $data) {
            User::whereKey($joinRequest->user_id)->lockForUpdate()->firstOrFail();
            $lockedClub = Club::whereKey($joinRequest->club_id)->lockForUpdate()->firstOrFail();
            $lockedRequest = ClubJoinRequest::whereKey($joinRequest->id)->lockForUpdate()->firstOrFail();
            abort_unless($lockedRequest->status === 'pending', 409, 'تمت معالجة هذا الطلب مسبقًا.');
            abort_unless($this->can($lockedClub, $request, 'accept_members'), 403);

            if ($data['status'] === 'accepted') {
                abort_if(ClubMember::where('club_id', $lockedClub->id)->count() >= $this->cap($lockedClub), 409, 'النادي مكتمل العدد.');
                abort_if(ClubMember::where('user_id', $lockedRequest->user_id)->where('club_id', '!=', $lockedClub->id)->exists(), 409, 'اللاعب انضم إلى نادٍ آخر.');
                ClubMember::firstOrCreate(['club_id' => $lockedClub->id, 'user_id' => $lockedRequest->user_id], ['role' => 'member', 'permissions' => [], 'last_active_at' => now()]);
            }
            $lockedRequest->update(['status' => $data['status']]);
            return (int) $lockedRequest->user_id;
        });
        Notification::create([
            'user_id' => $recipientId, 'type' => 'club_join_response',
            'title' => ['ar' => 'تحديث طلب النادي', 'en' => 'Club request updated'],
            'body' => ['ar' => $data['status'] === 'accepted' ? 'تم قبولك في '.$club->name : 'لم تتم الموافقة على طلبك في '.$club->name, 'en' => 'Your club request was updated.'],
            'meta' => ['club_id' => $club->id, 'status' => $data['status']],
        ]);
        return response()->json(['ok' => true, 'message' => 'تم تحديث الطلب.']);
    }

    /** @return array<string,mixed> */
    private function clubPayload(Club $club, Request $request, bool $full = false): array
    {
        $club->loadMissing(['owner.profile', 'members.user.profile']);
        $membership = $club->members->firstWhere('user_id', $request->user()->id);
        $visibleMembers = $club->members->filter(fn (ClubMember $member) => $member->user && (
            $request->user()->is_admin
            || (int) $member->user_id === (int) $request->user()->id
            || $this->policy->canViewProfile($request->user(), $member->user)
        ));
        $members = $full ? $visibleMembers->sortByDesc('weekly_points')->map(fn (ClubMember $member) => [
            'id' => $member->user_id, 'name' => $member->user?->profile?->display_name ?: $member->user?->username,
            'avatar' => $member->user?->profile?->avatar, 'role' => $member->role,
            'weekly_points' => (int) $member->weekly_points, 'total_points' => (int) $member->total_points,
            'online' => $member->user && $this->policy->canSeePresence($request->user(), $member->user)
                ? ($member->user->last_seen_at?->gt(now()->subMinutes(3)) ?? false) : null,
        ])->values()->all() : null;

        return [
            'id' => $club->id, 'name' => $club->name, 'description' => $club->description, 'logo' => $club->logo,
            'visibility' => $club->visibility, 'level' => (int) $club->level,
            'league' => self::LEAGUES[min(6, max(1, (int) $club->level))],
            'weekly_points' => (int) $club->weekly_points, 'total_points' => (int) ($club->total_points ?? 0),
            'members_count' => $club->members->count(), 'capacity' => $this->cap($club),
            'owner' => $club->owner && ($request->user()->is_admin || (int) $club->owner_id === (int) $request->user()->id || $this->policy->canViewProfile($request->user(), $club->owner))
                ? ($club->owner->profile?->display_name ?: $club->owner->username) : null,
            'membership' => $membership ? ['role' => $membership->role, 'permissions' => $membership->permissions ?: []] : null,
            'members' => $members,
        ];
    }

    private function can(Club $club, Request $request, string $permission): bool
    {
        if ($request->user()->is_admin || (int) $club->owner_id === (int) $request->user()->id) return true;
        $member = $club->members()->where('user_id', $request->user()->id)->first();
        if (!$member || $member->role !== 'moderator') return false;
        $permissions = $member->permissions ?: [];
        return !empty($permissions['all']) || !empty($permissions[$permission]);
    }

    private function cap(Club $club): int
    {
        return self::CAPS[min(6, max(1, (int) $club->level))] ?? 20;
    }

    private function log(Club $club, Request $request, string $type, string $description): void
    {
        ClubActivityLog::create(['club_id' => $club->id, 'actor_id' => $request->user()->id, 'event_type' => $type, 'description' => $description, 'meta' => ['release' => 'R11']]);
    }

    private function assertEnabled(): void
    {
        abort_unless(filter_var(\App\Models\SiteSetting::getValue('clubs_enabled', true), FILTER_VALIDATE_BOOLEAN), 503, 'الأندية متوقفة مؤقتًا.');
    }
}
