@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'المجموعات | ورقنا' : 'Clubs | Warqnaa')
@section('content')
@php
 $ar=app()->getLocale()==='ar';
 $leagueLabels=[1=>'Bronze',2=>'Silver',3=>'Gold',4=>'Platinum',5=>'Diamond',6=>'Legendary'];
@endphp
<div class="club-hero premium-module-hero"><h1>👥 {{$ar?'المجموعات':'Clubs'}}</h1><p>{{$ar?'مجموعات بالعرض مع ملخص سريع. اضغط على أي مجموعة لفتح صفحتها الكاملة والأعضاء والإدارة والصلاحيات.':'Browse clubs at a glance, then open any club to review its members, leadership and permissions.'}}</p><div class="club-levels">@foreach($clubCaps as $level=>$capacity)<span>{{$ar?'المستوى':'Level'}} {{$level}}: {{$capacity}}</span>@endforeach</div></div>
<form class="inline-card club-create-form" method="post" action="{{route('clubs.store')}}">@csrf
 <input name="name" placeholder="{{$ar?'اسم المجموعة الجديدة':'New club name'}}" aria-label="{{$ar?'اسم المجموعة الجديدة':'New club name'}}"><small class="pasha-create-note">👑 {{$ar?'إنشاء المجموعات متاح للباشا عند توفر التوكنز.':'Club creation is available to Pasha members with enough tokens.'}}</small>
 <button class="primary">{{$ar?'إنشاء مجموعة للباشا - 5000 توكنز':'Create Pasha club — 5,000 tokens'}}</button>
</form>
<div class="clubs-horizontal-grid">
@foreach($clubs as $club)
 @php $isMember=$club->members->where('user_id',auth()->id())->count()>0; $online=$club->members->filter(fn($m)=>$m->user?->last_seen_at && $m->user->last_seen_at->gt(now()->subMinutes(5)))->count(); @endphp
 <article class="club-tile pro-card">
  <a class="club-tile-main" href="{{route('clubs.show',$club)}}">
   <div class="club-emblem">👥</div>
   <div><h3>{{$club->name}}</h3><p>{{$ar?'المالك:':'Owner:'}} <b>{{$club->owner?->username}}</b></p><small>{{$ar?'تاريخ الإنشاء:':'Created:'}} {{$club->created_at?->format('Y-m-d')}}</small></div>
  </a>
  <div class="club-meta-row"><span class="club-league-badge">{{$ar?($clubLeagues[min(6,max(1,$club->level))] ?? 'برونزي'):($leagueLabels[min(6,max(1,$club->level))] ?? 'Bronze')}}</span><span class="pill">{{$ar?'المستوى':'Level'}} {{$club->level}}</span><span class="pill">{{$club->members->count()}}/{{$clubCaps[min(6,max(1,$club->level))] ?? 50}}</span><span class="pill online-pill">🟢 {{$online}} {{$ar?'متصل':'Online'}}</span></div>
  <p class="muted club-summary">{{$ar?'نقاط أسبوعية:':'Weekly points:'}} {{$club->weekly_points}} • {{$ar?'نقاط تراكمية:':'Total points:'}} {{number_format($club->total_points ?? 0)}} • {{$ar?'الخزينة:':'Treasury:'}} {{number_format($club->treasury)}} {{$ar?'توكنز':'tokens'}}</p>
  <div class="club-members-preview">@foreach($club->members->take(6) as $m)<button type="button" onclick="openProfile({{$m->user_id}})" title="{{$m->user?->username}}"><img loading="lazy" decoding="async" src="{{$m->user?->profile?->avatar ?: '/assets/avatars/default.svg'}}"><span>{{$m->user?->username}}</span></button>@endforeach</div>
  <div class="club-actions-row">
   <a class="btn" href="{{route('clubs.show',$club)}}">{{$ar?'فتح المجموعة':'Open club'}}</a>
   @if($isMember)<span class="success pill">{{$ar?'عضو':'Member'}}</span>@else<form method="post" action="{{route('clubs.join',$club)}}">@csrf<button>{{$ar?'طلب انضمام':'Request to join'}}</button></form>@endif
  </div>
 </article>
@endforeach
</div>
@endsection
