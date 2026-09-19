<?php

namespace App\Http\Controllers;

use App\Models\{Friendship, Notification, Party, PartyMember, User};
use Illuminate\Http\Request;
use App\Support\AuthenticatedActor;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MobilePartyController extends Controller
{
    private function payload(Party $party): Party
    {
        // Only public identity fields; never serialize email, IP or account metadata.
        return $party->load('members.user:id,username');
    }

    private function current(int $userId)
    {
        return Party::where('status', 'open')->whereHas('members', fn ($q) =>
            $q->where('user_id', $userId)->where('status', 'joined'));
    }

    public function mine(Request $request)
    {
        $actor = AuthenticatedActor::resolve($request);
        abort_if($actor->is_banned, 403);
        $party = $this->current($request->user()->id)->latest()->first();
        return response()->json(['ok' => true, 'party' => $party ? $this->payload($party) : null]);
    }

    public function create(Request $request)
    {
        $actor = AuthenticatedActor::resolve($request);
        abort_if($actor->is_banned, 403);
        $data = $request->validate(['game_key'=>'nullable|string|max:80', 'max_members'=>'nullable|integer|min:2|max:6']);
        $party = DB::transaction(function () use ($request, $data) {
            // Serialize create/join for one account, including across different parties.
            User::whereKey($request->user()->id)->lockForUpdate()->firstOrFail();
            $existing = $this->current($request->user()->id)->first();
            if ($existing) return $existing;
            do { $code = strtoupper(Str::random(7)); } while (Party::where('code', $code)->exists());
            $party = Party::create(['owner_id'=>$request->user()->id, 'code'=>$code, 'status'=>'open', 'max_members'=>$data['max_members'] ?? 4, 'game_key'=>$data['game_key'] ?? null, 'settings'=>['voice'=>true, 'invite_only'=>true]]);
            PartyMember::create(['party_id'=>$party->id, 'user_id'=>$request->user()->id, 'role'=>'owner', 'status'=>'joined', 'joined_at'=>now(), 'last_seen_at'=>now()]);
            return $party;
        }, 3);
        return response()->json(['ok'=>true, 'party'=>$this->payload($party)], 201);
    }

    public function invite(Request $request, Party $party, User $user)
    {
        $actor = AuthenticatedActor::resolve($request);
        abort_if($actor->is_banned, 403);
        DB::transaction(function () use ($request, $party, $user) {
            $party = Party::whereKey($party->id)->lockForUpdate()->firstOrFail();
            $this->guardOwner($request, $party);
            abort_unless($party->status === 'open', 422, 'المجموعة مغلقة.');
            abort_if($user->id === $request->user()->id || $user->is_banned, 422);
            abort_unless($this->friends($request->user()->id, $user->id), 403, 'يمكن دعوة الأصدقاء فقط.');
            $member = $party->members()->where('user_id', $user->id)->first();
            if ($member && in_array($member->status, ['joined', 'invited'], true)) return;
            abort_if($party->members()->where('status', 'joined')->count() >= $party->max_members, 422, 'المجموعة ممتلئة.');
            PartyMember::updateOrCreate(['party_id'=>$party->id, 'user_id'=>$user->id], ['role'=>'member', 'status'=>'invited', 'last_seen_at'=>now()]);
            Notification::create(['user_id'=>$user->id, 'type'=>'party_invite', 'title'=>['ar'=>'دعوة مجموعة', 'en'=>'Party invite'], 'body'=>['ar'=>$request->user()->username.' دعاك للعب معًا', 'en'=>$request->user()->username.' invited you to play together'], 'url'=>'/party/'.$party->code, 'meta'=>['party_id'=>$party->id, 'party_code'=>$party->code]]);
        }, 3);
        return response()->json(['ok'=>true]);
    }

    public function join(Request $request, string $code)
    {
        $actor = AuthenticatedActor::resolve($request);
        abort_if($actor->is_banned, 403);
        $party = DB::transaction(function () use ($request, $code) {
            User::whereKey($request->user()->id)->lockForUpdate()->firstOrFail();
            $party = Party::where('code', strtoupper($code))->where('status', 'open')->lockForUpdate()->firstOrFail();
            $member = $party->members()->where('user_id', $request->user()->id)->first();
            abort_unless($member && in_array($member->status, ['invited', 'joined'], true), 403, 'تحتاج دعوة صالحة للانضمام.');
            if ($member->status === 'joined') return $party;
            abort_if($this->current($request->user()->id)->where('id', '!=', $party->id)->exists(), 422, 'غادر مجموعتك الحالية أولًا.');
            abort_if($party->members()->where('status', 'joined')->count() >= $party->max_members, 422, 'المجموعة ممتلئة.');
            $member->update(['status'=>'joined', 'joined_at'=>now(), 'last_seen_at'=>now()]);
            return $party;
        }, 3);
        return response()->json(['ok'=>true, 'party'=>$this->payload($party)]);
    }

    public function leave(Request $request, Party $party)
    {
        $actor = AuthenticatedActor::resolve($request);
        abort_if($actor->is_banned, 403);
        DB::transaction(function () use ($request, $party) {
            User::whereKey($request->user()->id)->lockForUpdate()->firstOrFail();
            $party = Party::whereKey($party->id)->lockForUpdate()->firstOrFail();
            $member = $party->members()->where('user_id', $request->user()->id)->firstOrFail();
            $member->update(['status'=>'left', 'role'=>'member', 'last_seen_at'=>now()]);
            if ($party->owner_id === $request->user()->id) {
                $next = $party->members()->where('status', 'joined')->oldest('joined_at')->first();
                if ($next) {
                    $next->update(['role'=>'owner']);
                    $party->update(['owner_id'=>$next->user_id]);
                } else {
                    $party->update(['status'=>'closed']);
                }
            }
        }, 3);
        return response()->json(['ok'=>true]);
    }

    public function configure(Request $request, Party $party)
    {
        $actor = AuthenticatedActor::resolve($request);
        abort_if($actor->is_banned, 403);
        $data = $request->validate(['game_key'=>'nullable|string|max:80', 'max_members'=>'sometimes|integer|min:2|max:6']);
        $party = DB::transaction(function () use ($request, $party, $data) {
            $party = Party::whereKey($party->id)->lockForUpdate()->firstOrFail();
            $this->guardOwner($request, $party);
            abort_unless($party->status === 'open', 422);
            abort_if(isset($data['max_members']) && $data['max_members'] < $party->members()->where('status', 'joined')->count(), 422, 'السعة أقل من عدد الأعضاء.');
            $party->update($data);
            return $party;
        }, 3);
        return response()->json(['ok'=>true, 'party'=>$this->payload($party)]);
    }

    private function guardOwner(Request $request, Party $party): void
    {
        abort_unless((int) $party->owner_id === (int) $request->user()->id, 403);
    }

    private function friends(int $a, int $b): bool
    {
        return Friendship::where('status', 'accepted')->where(fn ($q) =>
            $q->where(fn ($x) => $x->where('requester_id', $a)->where('addressee_id', $b))
              ->orWhere(fn ($x) => $x->where('requester_id', $b)->where('addressee_id', $a)))->exists();
    }
}
