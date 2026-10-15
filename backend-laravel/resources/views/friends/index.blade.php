@extends('layouts.app')
@section('content')
@php
$isAr=app()->getLocale()==='ar';
$ui=$isAr ? [
 'title'=>'الأصدقاء وطلبات الصداقة',
 'description'=>'إدارة طلبات الصداقة والرسائل الخاصة من نفس الصفحة. لا يمكن إرسال طلب أكثر من مرة لنفس اللاعب.',
 'incoming'=>'طلبات واردة','outgoing'=>'طلبات مرسلة','friends'=>'الأصدقاء','blocked'=>'المحظورون',
 'accept'=>'قبول','reject'=>'رفض','block'=>'حظر','block_confirm'=>'هل تريد حظر هذا اللاعب؟',
 'sent'=>'تم إرسال الطلب','cancel'=>'إلغاء الطلب','message'=>'رسالة','blocked_badge'=>'محظور','unblock'=>'إلغاء الحظر',
 'empty_incoming'=>'لا توجد طلبات واردة.','empty_outgoing'=>'لا توجد طلبات مرسلة.','empty_friends'=>'لا يوجد أصدقاء بعد.','empty_blocked'=>'لا يوجد لاعبون محظورون.',
 'avatar'=>'الصورة الشخصية للاعب',
] : [
 'title'=>'Friends & Requests',
 'description'=>'Manage friend requests and private messages from one place. A request cannot be sent more than once to the same player.',
 'incoming'=>'Incoming requests','outgoing'=>'Sent requests','friends'=>'Friends','blocked'=>'Blocked players',
 'accept'=>'Accept','reject'=>'Decline','block'=>'Block','block_confirm'=>'Block this player?',
 'sent'=>'Request sent','cancel'=>'Cancel request','message'=>'Message','blocked_badge'=>'Blocked','unblock'=>'Unblock',
 'empty_incoming'=>'No incoming requests.','empty_outgoing'=>'No sent requests.','empty_friends'=>'No friends yet.','empty_blocked'=>'No blocked players.',
 'avatar'=>'Player avatar',
];
@endphp
<h1>{{ $ui['title'] }}</h1>
<p class="muted">{{ $ui['description'] }}</p>
<div class="friends-dashboard">
 <section class="pro-card friend-section"><h2>{{ $ui['incoming'] }}</h2>
  @forelse($incoming as $f) @php $u=$f->requester; @endphp
   <div class="friend-row"><button type="button" class="user-chip" onclick="openProfile({{$u->id}})"><img loading="lazy" decoding="async" class="avatar-xs" src="{{$u->profile?->avatar ?: '/assets/avatars/default.svg'}}" alt="{{ $ui['avatar'] }}"> {!! flag_img($u->profile?->country_code) !!} {{$u->username}}</button><div class="friend-actions"><form method="post" action="{{route('friends.respond',$f)}}" data-ajax-soft="1">@csrf<input type="hidden" name="status" value="accepted"><button class="primary" type="submit">{{ $ui['accept'] }}</button></form><form method="post" action="{{route('friends.respond',$f)}}" data-ajax-soft="1">@csrf<input type="hidden" name="status" value="rejected"><button type="submit">{{ $ui['reject'] }}</button></form><form method="post" action="{{route('friends.block',$u)}}" data-confirm="{{ $ui['block_confirm'] }}">@csrf<button class="danger" type="submit">{{ $ui['block'] }}</button></form></div></div>
  @empty <div class="mini-card">{{ $ui['empty_incoming'] }}</div> @endforelse
 </section>
 <section class="pro-card friend-section"><h2>{{ $ui['outgoing'] }}</h2>
  @forelse($outgoing as $f) @php $u=$f->addressee; @endphp
   <div class="friend-row"><button type="button" class="user-chip" onclick="openProfile({{$u->id}})"><img loading="lazy" decoding="async" class="avatar-xs" src="{{$u->profile?->avatar ?: '/assets/avatars/default.svg'}}" alt="{{ $ui['avatar'] }}"> {!! flag_img($u->profile?->country_code) !!} {{$u->username}}</button><span class="pill">{{ $ui['sent'] }}</span><form method="post" action="{{route('friends.cancel',$f)}}" data-ajax-soft="1">@csrf<button class="danger" type="submit">{{ $ui['cancel'] }}</button></form></div>
  @empty <div class="mini-card">{{ $ui['empty_outgoing'] }}</div> @endforelse
 </section>
 <section class="pro-card friend-section"><h2>{{ $ui['friends'] }}</h2>
  @forelse($accepted as $f) @php $u=$f->requester_id===auth()->id()?$f->addressee:$f->requester; @endphp
   <div class="friend-row"><button type="button" class="user-chip" onclick="openProfile({{$u->id}})"><img loading="lazy" decoding="async" class="avatar-xs" src="{{$u->profile?->avatar ?: '/assets/avatars/default.svg'}}" alt="{{ $ui['avatar'] }}"> {!! flag_img($u->profile?->country_code) !!} {{$u->username}}</button><div class="friend-actions"><button type="button" onclick="setChatMode('friends');openFriendThread({{$u->id}});document.getElementById('chatDock')?.classList.remove('hidden','chat-minimized')">{{ $ui['message'] }}</button><form method="post" action="{{route('friends.block',$u)}}" data-confirm="{{ $ui['block_confirm'] }}">@csrf<button class="danger" type="submit">{{ $ui['block'] }}</button></form></div></div>
  @empty <div class="mini-card">{{ $ui['empty_friends'] }}</div> @endforelse
 </section>
 <section class="pro-card friend-section"><h2>{{ $ui['blocked'] }}</h2>
  @forelse($blocked as $f) @php $u=$f->requester_id===auth()->id()?$f->addressee:$f->requester; @endphp
   <div class="friend-row"><button type="button" class="user-chip" onclick="openProfile({{$u->id}})"><img loading="lazy" decoding="async" class="avatar-xs" src="{{$u->profile?->avatar ?: '/assets/avatars/default.svg'}}" alt="{{ $ui['avatar'] }}"> {{$u->username}}</button><span class="pill danger">{{ $ui['blocked_badge'] }}</span><form method="post" action="{{route('friends.unblock',$u)}}" data-ajax-soft="1">@csrf<button type="submit">{{ $ui['unblock'] }}</button></form></div>
  @empty <div class="mini-card">{{ $ui['empty_blocked'] }}</div> @endforelse
 </section>
</div>
@endsection
