@extends('layouts.app')
@section('content')
@php
$locale=in_array(app()->getLocale(),['ar','en'],true)?app()->getLocale():'en';
$isAr=$locale==='ar';
$fallbackLocale=$isAr?'en':'ar';
$ui=$isAr ? [
 'title'=>'الإشعارات',
 'mark_all'=>'تعليم الكل كمقروء',
 'unread'=>'غير مقروء',
 'empty'=>'لا توجد إشعارات بعد.',
] : [
 'title'=>'Notifications',
 'mark_all'=>'Mark all as read',
 'unread'=>'Unread',
 'empty'=>'No notifications yet.',
];
@endphp
<div class="notifications-page">
 <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap">
  <h1>🔔 {{ $ui['title'] }}</h1>
  <form method="post" action="{{route('notifications.readAll')}}">@csrf<button class="primary" type="submit">{{ $ui['mark_all'] }}</button></form>
 </div>
 @forelse($notifications as $n)
  @php
   $title=data_get($n->title,$locale) ?: data_get($n->title,$fallbackLocale) ?: $n->type;
   $body=data_get($n->body,$locale) ?: data_get($n->body,$fallbackLocale) ?: '';
  @endphp
  <a class="notification-card {{$n->read?'read':'unread'}}" href="{{$n->url ?: '#'}}">
   <b>{{$title}}</b>
   @if($body!=='')<p>{{$body}}</p>@endif
   <small>{{$n->created_at->locale($locale)->diffForHumans()}}</small>
   @unless($n->read)<span class="pill">{{ $ui['unread'] }}</span>@endunless
  </a>
 @empty
  <div class="mini-card">{{ $ui['empty'] }}</div>
 @endforelse
 {{$notifications->links()}}
</div>
@endsection
