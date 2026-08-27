<?php

namespace App\Http\Controllers;

use App\Models\{Friendship,Notification,Party,PartyMember,User};
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MobilePartyController extends Controller
{
    public function mine(Request $request)
    {
        $party=Party::whereHas('members',fn($q)=>$q->where('user_id',$request->user()->id)->where('status','joined'))->with('members.user.profile')->latest()->first();
        return response()->json(['ok'=>true,'party'=>$party]);
    }

    public function create(Request $request)
    {
        $data=$request->validate(['game_key'=>'nullable|string|max:80','max_members'=>'nullable|integer|min:2|max:6']);
        $existing=Party::whereHas('members',fn($q)=>$q->where('user_id',$request->user()->id)->where('status','joined'))->where('status','open')->first();
        if($existing) return response()->json(['ok'=>true,'party'=>$existing->load('members.user.profile')]);
        $party=DB::transaction(function() use($request,$data){
            do{$code=strtoupper(Str::random(7));}while(Party::where('code',$code)->exists());
            $party=Party::create(['owner_id'=>$request->user()->id,'code'=>$code,'status'=>'open','max_members'=>$data['max_members'] ?? 4,'game_key'=>$data['game_key'] ?? null,'settings'=>['voice'=>true,'invite_only'=>true]]);
            PartyMember::create(['party_id'=>$party->id,'user_id'=>$request->user()->id,'role'=>'owner','status'=>'joined','joined_at'=>now(),'last_seen_at'=>now()]);
            return $party;
        });
        return response()->json(['ok'=>true,'party'=>$party->load('members.user.profile')],201);
    }

    public function invite(Request $request, Party $party, User $user)
    {
        $this->guardOwner($request,$party);
        abort_if($party->members()->where('status','joined')->count() >= $party->max_members,422,'المجموعة ممتلئة.');
        abort_if($user->id === $request->user()->id,422,'أنت موجود في المجموعة.');
        abort_unless($this->friends($request->user()->id,$user->id),403,'يمكن دعوة الأصدقاء فقط.');
        PartyMember::updateOrCreate(['party_id'=>$party->id,'user_id'=>$user->id],['role'=>'member','status'=>'invited','last_seen_at'=>now()]);
        Notification::create(['user_id'=>$user->id,'type'=>'party_invite','title'=>['ar'=>'دعوة Party','en'=>'Party invite'],'body'=>['ar'=>$request->user()->username.' دعاك للعب معًا','en'=>$request->user()->username.' invited you to play together'],'url'=>'/party/'.$party->code,'meta'=>['party_id'=>$party->id,'party_code'=>$party->code]]);
        return response()->json(['ok'=>true,'message'=>'تم إرسال الدعوة.']);
    }

    public function join(Request $request, string $code)
    {
        $party=Party::where('code',strtoupper($code))->where('status','open')->firstOrFail();
        abort_if($party->members()->where('status','joined')->count() >= $party->max_members,422,'المجموعة ممتلئة.');
        $member=PartyMember::where('party_id',$party->id)->where('user_id',$request->user()->id)->first();
        abort_unless($member && in_array($member->status,['invited','joined'],true),403,'تحتاج دعوة صالحة للانضمام.');
        $member->update(['status'=>'joined','joined_at'=>$member->joined_at ?: now(),'last_seen_at'=>now()]);
        return response()->json(['ok'=>true,'party'=>$party->fresh()->load('members.user.profile')]);
    }

    public function leave(Request $request, Party $party)
    {
        $member=$party->members()->where('user_id',$request->user()->id)->firstOrFail();
        $member->update(['status'=>'left','last_seen_at'=>now()]);
        if($party->owner_id === $request->user()->id){
            $next=$party->members()->where('status','joined')->where('user_id','!=',$request->user()->id)->oldest('joined_at')->first();
            if($next){$next->update(['role'=>'owner']);$party->update(['owner_id'=>$next->user_id]);}else{$party->update(['status'=>'closed']);}
        }
        return response()->json(['ok'=>true]);
    }

    public function configure(Request $request, Party $party)
    {
        $this->guardOwner($request,$party);
        $data=$request->validate(['game_key'=>'nullable|string|max:80','max_members'=>'nullable|integer|min:2|max:6']);
        $party->update($data);
        return response()->json(['ok'=>true,'party'=>$party->fresh()->load('members.user.profile')]);
    }

    private function guardOwner(Request $request, Party $party): void { abort_unless($party->owner_id === $request->user()->id,403,'قائد المجموعة فقط يستطيع تنفيذ هذا الإجراء.'); }
    private function friends(int $a,int $b): bool { return Friendship::where('status','accepted')->where(fn($q)=>$q->where(fn($x)=>$x->where('requester_id',$a)->where('addressee_id',$b))->orWhere(fn($x)=>$x->where('requester_id',$b)->where('addressee_id',$a)))->exists(); }
}
