<?php
namespace App\Http\Controllers;

use App\Models\{User,Friendship,Notification};
use Illuminate\Http\Request;

class FriendController
{
    private function message(string $ar, string $en): string
    {
        return app()->getLocale()==='ar' ? $ar : $en;
    }

    private function relationWith(User $user): ?Friendship
    {
        return Friendship::where(function($q) use($user){
            $q->where('requester_id',auth()->id())->where('addressee_id',$user->id);
        })->orWhere(function($q) use($user){
            $q->where('requester_id',$user->id)->where('addressee_id',auth()->id());
        })->latest()->first();
    }

    public function index()
    {
        $friendships=Friendship::with(['requester.profile','addressee.profile'])->where(function($q){
            $q->where('requester_id',auth()->id())->orWhere('addressee_id',auth()->id());
        })->latest()->get();
        $incoming=$friendships->where('addressee_id',auth()->id())->where('status','pending');
        $outgoing=$friendships->where('requester_id',auth()->id())->where('status','pending');
        $accepted=$friendships->where('status','accepted');
        $blocked=$friendships->where('status','blocked');
        return view('friends.index',compact('incoming','outgoing','accepted','blocked'));
    }

    public function request(User $user)
    {
        abort_if($user->id===auth()->id(),422,$this->message('لا يمكنك إرسال طلب لنفسك.','You cannot send a friend request to yourself.'));
        $existing=$this->relationWith($user);
        if($existing){
            $msg = match($existing->status){
                'accepted'=>$this->message('هذا اللاعب موجود في قائمة أصدقائك بالفعل.','This player is already in your friends list.'),
                'pending'=>$this->message('تم إرسال الطلب مسبقًا، بانتظار موافقة اللاعب الآخر.','The request was already sent and is awaiting the other player.'),
                'blocked'=>$this->message('لا يمكن إرسال طلب صداقة بسبب الحظر.','A friend request cannot be sent because of a block.'),
                default=>$this->message('يوجد طلب سابق لهذا اللاعب.','A previous request exists for this player.')
            };
            if(request()->expectsJson() || request()->ajax()) return response()->json(['ok'=>$existing->status!=='blocked','message'=>$msg,'status'=>$existing->status]);
            return back()->with($existing->status==='blocked'?'error':'ok',$msg);
        }
        $f=Friendship::create(['requester_id'=>auth()->id(),'addressee_id'=>$user->id,'status'=>'pending']);
        Notification::create([
            'user_id'=>$user->id,
            'type'=>'friend_request',
            'title'=>['ar'=>'طلب صداقة','en'=>'Friend request'],
            'body'=>[
                'ar'=>auth()->user()->username.' أرسل لك طلب صداقة',
                'en'=>auth()->user()->username.' sent you a friend request',
            ],
            'url'=>route('friends'),
            'meta'=>['friendship_id'=>$f->id,'from'=>auth()->id()],
        ]);
        $msg=$this->message('تم إرسال طلب الصداقة','Friend request sent');
        if(request()->expectsJson() || request()->ajax()) return response()->json(['ok'=>true,'message'=>$msg,'status'=>'pending']);
        return back()->with('ok',$msg);
    }

    public function respond(Friendship $friendship, Request $r)
    {
        abort_unless($friendship->addressee_id===auth()->id(),403);
        $status=$r->input('status','accepted');
        abort_unless(in_array($status,['accepted','rejected'],true),422);
        if($status==='accepted') $friendship->update(['status'=>'accepted']);
        else { $friendship->delete(); }
        $accepted=$status==='accepted';
        Notification::create([
            'user_id'=>$friendship->requester_id,
            'type'=>'friend_response',
            'title'=>['ar'=>'رد على طلب الصداقة','en'=>'Friend request response'],
            'body'=>[
                'ar'=>auth()->user()->username.' '.($accepted?'قبل طلب الصداقة':'رفض طلب الصداقة'),
                'en'=>auth()->user()->username.' '.($accepted?'accepted your friend request':'declined your friend request'),
            ],
            'url'=>route('friends'),
        ]);
        $msg=$accepted
            ? $this->message('تم قبول طلب الصداقة','Friend request accepted')
            : $this->message('تم رفض طلب الصداقة','Friend request declined');
        if($r->expectsJson() || $r->ajax()) return response()->json(['ok'=>true,'message'=>$msg,'status'=>$status]);
        return back()->with('ok',$this->message('تم تحديث الطلب','Friend request updated'));
    }

    public function cancel(Friendship $friendship, Request $r)
    {
        abort_unless($friendship->requester_id===auth()->id() && $friendship->status==='pending',403);
        $friendship->delete();
        $msg=$this->message('تم إلغاء طلب الصداقة','Friend request cancelled');
        if($r->expectsJson() || $r->ajax()) return response()->json(['ok'=>true,'message'=>$msg,'status'=>'cancelled']);
        return back()->with('ok',$msg);
    }

    public function unblock(User $user)
    {
        $existing=$this->relationWith($user);
        abort_unless($existing && $existing->status==='blocked' && $existing->requester_id===auth()->id(),403);
        $existing->delete();
        $msg=$this->message('تم إلغاء الحظر','Player unblocked');
        if(request()->expectsJson() || request()->ajax()) return response()->json(['ok'=>true,'message'=>$msg,'status'=>'unblocked']);
        return back()->with('ok',$msg);
    }

    public function block(User $user)
    {
        abort_if($user->id===auth()->id(),422);
        $existing=$this->relationWith($user);
        if($existing) $existing->update(['status'=>'blocked','requester_id'=>auth()->id(),'addressee_id'=>$user->id]);
        else Friendship::create(['requester_id'=>auth()->id(),'addressee_id'=>$user->id,'status'=>'blocked']);
        $msg=$this->message('تم حظر اللاعب','Player blocked');
        if(request()->expectsJson() || request()->ajax()) return response()->json(['ok'=>true,'message'=>$msg,'status'=>'blocked']);
        return back()->with('ok',$msg);
    }
}
