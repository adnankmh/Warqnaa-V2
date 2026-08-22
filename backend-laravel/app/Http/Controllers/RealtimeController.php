<?php
namespace App\Http\Controllers;

use App\Models\{PresenceSession,Room,Message,User};
use App\Services\Social\SocialWorldPolicy;
use Illuminate\Http\Request;

class RealtimeController
{
 public function __construct(private readonly SocialWorldPolicy $socialPolicy) {}

 public function heartbeat(Request $r)
 {
  $data=$r->validate(['scope'=>'nullable|string|max:40','room_code'=>'nullable|string|max:20','meta'=>'nullable|array']);
  $scope=$data['scope'] ?? 'site';
  $roomCode=!empty($data['room_code']) ? strtoupper(trim((string)$data['room_code'])) : null;
  if($roomCode){
   $room=Room::where('code',$roomCode)->first();
   abort_unless($room && $room->players()->where('user_id',$r->user()->id)->where('is_bot',false)->exists(),403,'حضور الغرفة متاح للاعبين فقط.');
  }
  PresenceSession::updateOrCreate(
   ['user_id'=>$r->user()->id,'scope'=>$scope,'room_code'=>$roomCode],
   ['last_seen_at'=>now(),'meta'=>$data['meta'] ?? []]
  );
  return response()->json(['ok'=>true,'online'=>$this->onlinePayload($roomCode, $r->user())]);
 }

 public function room(Room $room)
 {
  $viewer=request()->user();
  abort_unless($viewer && ($viewer->is_admin || $room->players()->where('user_id',$viewer->id)->where('is_bot',false)->exists()),403,'محادثة الغرفة متاحة للاعبين فقط.');
  $online=$this->onlinePayload($room->code, $viewer);
  $messages=Message::with('sender.profile')->where('room_id',$room->id)->latest()->limit(25)->get()->reverse()->values()
   ->filter(fn($m)=>$viewer->is_admin || !$m->sender || (int)$m->sender_id===(int)$viewer->id || !$this->socialPolicy->blocked($viewer->id,$m->sender_id))
   ->map(fn($m)=>[
   'id'=>$m->id,'sender_id'=>$m->sender_id,'name'=>$m->sender?->username,'avatar'=>$m->sender?->profile?->avatar ?: '/assets/avatars/default.svg',
   'body'=>$m->body,'color'=>$m->sender?->profile?->chat_color ?: '#fff','time'=>$m->created_at?->format('H:i')
  ])->values();
  return response()->json(['ok'=>true,'online'=>$online,'messages'=>$messages,'server_time'=>now()->toIso8601String()]);
 }

 private function onlinePayload(?string $roomCode=null, ?User $viewer=null): array
 {
  $q=PresenceSession::with('user.profile')->where('last_seen_at','>=',now()->subMinutes(3));
  if($roomCode){
   $room=Room::where('code',$roomCode)->first();
   $playerIds=$room?->players()->where('is_bot',false)->whereNotNull('user_id')->pluck('user_id')->all() ?? [];
   $q->where('room_code',$roomCode)->whereIn('user_id',$playerIds);
  }
  return $q->latest('last_seen_at')->limit(100)->get()
   ->filter(fn($s)=>$viewer && $s->user ? $this->socialPolicy->canSeePresence($viewer,$s->user) : false)
   ->take(50)->map(function($s) use($viewer,$roomCode){
    $showRoom=$roomCode!==null || (int)$s->user_id===(int)($viewer?->id ?? 0) || (bool)$this->socialPolicy->preferences($s->user)->show_current_room;
    return [
   'id'=>$s->user_id,'name'=>$s->user?->username,'avatar'=>$s->user?->profile?->avatar ?: '/assets/avatars/default.svg',
   'level'=>$s->user?->profile?->level ?? 1,'scope'=>$s->scope,'room_code'=>$showRoom ? $s->room_code : null,'last_seen'=>$s->last_seen_at?->diffForHumans()
   ];
  })->values()->all();
 }
}
