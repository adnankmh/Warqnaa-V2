@extends('layouts.app')
@section('title','Warqnaa | العب، نافس، وتصدر')
@section('content')
@php
  $isAuthed = auth()->check();
  $games = class_exists('\App\Models\Game') ? \App\Models\Game::where('active',true)->orderBy('id')->take(7)->get() : collect();
  $openRooms = $isAuthed && class_exists('\App\Models\Room') ? \App\Models\Room::whereIn('status',['waiting','bidding','playing'])->count() : 0;
  $friendsOnline = 0;
  $activeTournaments = class_exists('\App\Models\Tournament') ? \App\Models\Tournament::whereIn('status',['open','running'])->count() : 0;
@endphp
<div class="r9-home">
  <section class="r9-hero">
    <div class="r9-hero-content">
      <span class="r9-eyebrow"><span class="r9-live-dot"></span> Warqnaa R9 • تجربة لعب اجتماعية جديدة</span>
      <h1>{{ app()->getLocale()==='ar' ? 'الورق كما يجب أن يكون.' : 'Cards, the way they should feel.' }}</h1>
      <p>{{ app()->getLocale()==='ar' ? 'طرنيب، هاند، بناكل وألعاب اجتماعية بمحركات خادمية، طاولات اتجاهية، منافسات، أندية ومتجر بهوية أصلية هادئة وفخمة.' : 'Tarneeb, Hand, Banakil and social games with server-authoritative engines, directional tables, competitions, clubs and a refined original identity.' }}</p>
      <div class="r9-actions">
        @if($isAuthed)
          <a class="primary" href="{{route('games.index')}}">▶ {{ app()->getLocale()==='ar' ? 'العب الآن' : 'Play now' }}</a>
          <a href="{{route('tournaments')}}">🏆 {{ app()->getLocale()==='ar' ? 'المنافسات' : 'Competitions' }}</a>
          <a href="{{route('store')}}">✨ {{ app()->getLocale()==='ar' ? 'المتجر' : 'Store' }}</a>
        @else
          <a class="primary" href="{{route('register')}}">{{ app()->getLocale()==='ar' ? 'إنشاء حساب' : 'Create account' }}</a>
          <a href="{{route('login')}}">{{ app()->getLocale()==='ar' ? 'تسجيل الدخول' : 'Sign in' }}</a>
        @endif
      </div>
    </div>
  </section>

  <section class="r9-grid">
    <article class="r9-panel wide">
      <h2>{{ app()->getLocale()==='ar' ? 'ألعابك في مكان واحد' : 'Your games, one lobby' }}</h2>
      <p>{{ app()->getLocale()==='ar' ? 'دخول سريع، غرف عامة وخاصة، وبوتات واضحة الهوية عند الحاجة.' : 'Fast entry, public/private rooms and clearly identified bots when needed.' }}</p>
      <div class="r9-game-chips">
        @forelse($games as $game)
          <a href="{{ $isAuthed ? route('rooms.index',$game->key) : route('login') }}">{{ $game->rules['icon'] ?? game_icon($game->key) }} {{ $game->name[app()->getLocale()] ?? $game->name['en'] ?? $game->key }}</a>
        @empty
          <span class="muted">Warqnaa</span>
        @endforelse
      </div>
    </article>
    <article class="r9-panel">
      <h3>{{ app()->getLocale()==='ar' ? 'مباشر الآن' : 'Live now' }}</h3>
      <div class="r9-kpis">
        <div class="r9-kpi"><b>{{$openRooms}}</b><small>{{ app()->getLocale()==='ar' ? 'غرفة' : 'rooms' }}</small></div>
        <div class="r9-kpi"><b>{{$activeTournaments}}</b><small>{{ app()->getLocale()==='ar' ? 'منافسة' : 'events' }}</small></div>
        <div class="r9-kpi"><b>18</b><small>{{ app()->getLocale()==='ar' ? 'محرك' : 'engines' }}</small></div>
        <div class="r9-kpi"><b>12h</b><small>{{ app()->getLocale()==='ar' ? 'مكافآت' : 'rewards' }}</small></div>
      </div>
    </article>
    <article class="r9-panel">
      <h3>🎯 {{ app()->getLocale()==='ar' ? 'مهمتك التالية' : 'Your next goal' }}</h3>
      <p>{{ app()->getLocale()==='ar' ? 'العب مباراة، أكمل مهمة يومية، أو ادخل منافسة لرفع تقدمك.' : 'Play a match, complete a daily mission, or join a competition.' }}</p>
    </article>
    <article class="r9-panel">
      <h3>👑 {{ app()->getLocale()==='ar' ? 'تجربة الباشا' : 'Pasha experience' }}</h3>
      <p>{{ app()->getLocale()==='ar' ? 'هوية مميزة ومزايا اجتماعية وXP إضافي بدون التلاعب بعدالة توزيع الورق.' : 'Status, social perks and XP benefits without altering fair card deals.' }}</p>
    </article>
    <article class="r9-panel">
      <h3>🛡️ {{ app()->getLocale()==='ar' ? 'لعب عادل' : 'Fair play' }}</h3>
      <p>{{ app()->getLocale()==='ar' ? 'الخادم هو الحكم للحركة والدور والنتيجة، وليس جهاز اللاعب.' : 'The server validates turns, actions and results—not the client device.' }}</p>
    </article>
  </section>
</div>
@endsection
