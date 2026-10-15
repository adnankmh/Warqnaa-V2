@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'البحث عن لاعب' : 'Player Search')
@section('content')
@php $ar=app()->isLocale('ar'); @endphp
<section class="player-search-page" dir="{{$ar?'rtl':'ltr'}}">
 <div class="search-hero">
  <h1>🔎 {{$ar?'البحث عن لاعب':'Player Search'}}</h1>
  <p>{{$ar?'اكتب اسم اللاعب أو جزءًا منه للعثور على حسابه، مستواه، دولته، وإرسال طلب صداقة.':'Enter all or part of a player name to find their account, level and country, or send a friend request.'}}</p>
 </div>
 <form class="player-search-form" method="get" action="{{route('players.search')}}">
  <input name="q" value="{{$q}}" placeholder="{{$ar?'مثال: Adnan أو جزء من الاسم':'Example: Adnan or part of a name'}}" aria-label="{{$ar?'اسم اللاعب':'Player name'}}" autofocus>
  <button class="primary">{{$ar?'بحث':'Search'}}</button>
 </form>
 @if($q==='')
  <div class="mini-card">{{$ar?'اكتب اسم اللاعب في مربع البحث بالأعلى.':'Enter a player name in the search field above.'}}</div>
 @else
  <div class="player-results" aria-label="{{$ar?'نتائج البحث':'Search results'}}">
  @forelse($users as $u)
   <div class="player-result-card">
    <div class="name-orbit" style="--orbit:{{$u->profile?->name_color ?? '#facc15'}}">
     <img loading="lazy" decoding="async" src="{{$u->profile?->avatar ?: '/assets/avatars/default.svg'}}" alt="{{$ar?'صورة اللاعب':'Player avatar'}}">
    </div>
    <div class="player-result-main">
     <h3 style="color:{{$u->profile?->name_color ?? '#facc15'}}"><img loading="lazy" decoding="async" class="flag-img" src="/assets/flags/{{strtoupper($u->profile?->country_code ?? 'PS')}}.svg" onerror="this.style.display='none'" alt="{{$ar?'علم الدولة':'Country flag'}}"> {{$u->profile?->display_name ?: $u->username}} @if($u->profile?->badge)<small>{{$u->profile->badge}}</small>@endif</h3>
     <p>{{$ar?'المستوى':'Level'}} {{$u->profile?->level ?? 1}} • XP {{number_format($u->profile?->xp ?? 0)}} • {{$ar?'فوز':'Wins'}} {{number_format($u->profile?->wins ?? 0)}} / {{$ar?'ألعاب':'Games'}} {{number_format($u->profile?->games_played ?? 0)}}</p>
    </div>
    <button type="button" class="btn" onclick="openProfile({{$u->id}})">{{$ar?'عرض الملف الشخصي':'View profile'}}</button>
    @if($u->id!==auth()->id())
     <form method="post" action="{{route('friends.request',$u)}}">@csrf<button>{{$ar?'إضافة صديق':'Add friend'}}</button></form>
     <form method="post" action="{{route('friends.block',$u)}}">@csrf<button class="danger">{{$ar?'حظر':'Block'}}</button></form>
    @endif
   </div>
  @empty
   <div class="mini-card">{{$ar?'لا يوجد لاعب مطابق لهذا البحث.':'No players match this search.'}}</div>
  @endforelse
  </div>
 @endif
</section>
@endsection
