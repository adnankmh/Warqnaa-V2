@extends('layouts.app')
@section('title','Warqnaa | العب وتواصل بطريقتك')
@section('content')
@php
  $ar=app()->getLocale()==='ar';
  $isAuthed=auth()->check();
  $keys=\App\Services\Games\GameCatalog::customerKeys();
  $games=\App\Models\Game::where('active',true)->whereIn('key',$keys)->orderBy('id')->take(12)->get();
  $rooms=\App\Models\Room::whereIn('status',['waiting','bidding','playing'])->count();
  $events=\App\Models\Tournament::whereIn('status',['open','running'])->count();
@endphp
<div class="b304-home">
 <section class="b304-head">
   <div><span class="b304-kicker">WARQNAA WORLD • R6.1</span><h1>{{ $ar?'العب. تواصل. اصنع مجلسك.':'Play. Connect. Make it yours.' }}</h1><p>{{ $ar?'ألعاب ورق اجتماعية، ملف شخصي حي، مجتمع متكامل، وكتالوج طاولات وظهور ورق متطابقة للهاتف والويب.':'Social card games, a living profile, a connected community, and matching table/card-back collections for mobile and web.' }}</p></div>
   <div class="b304-statbar"><span><b>{{ $rooms }}</b>{{ $ar?'غرفة نشطة':'live rooms' }}</span><span><b>{{ $events }}</b>{{ $ar?'منافسة':'competitions' }}</span><span><b>{{ count($keys) }}</b>{{ $ar?'محرك فعّال':'active engines' }}</span></div>
 </section>
 <section class="b304-actions">
  <a class="primary" href="{{ $isAuthed?route('competitive'):route('login') }}">🏆 {{ $ar?'المسابقات':'Competitions' }}</a>
  <a href="{{ $isAuthed?route('store'):route('login') }}">🛍️ {{ $ar?'المتجر':'Store' }}</a>
  <a href="{{ $isAuthed?route('rewards'):route('login') }}">🎁 {{ $ar?'الجوائز':'Rewards' }}</a>
  <a href="{{ $isAuthed?route('games.index'):route('register') }}">▶ {{ $ar?'كل الألعاب':'All games' }}</a>
 </section>
 <section class="b304-section"><div class="b304-title"><h2>{{ $ar?'مركز الألعاب':'Game Hub' }}</h2><span>{{ $ar?'اختر بطاقة اللعبة':'Pick a game card' }}</span></div>
  <div class="b304-grid">
   @foreach($games as $game)
    <a class="b304-game" href="{{ $isAuthed?route('rooms.index',$game->key):route('login') }}">
      <img src="{{ game_art_url($game->key) }}" alt="{{ $game->name[$ar?'ar':'en'] ?? $game->key }}" loading="lazy" decoding="async">
      <div><b>{{ $game->name[$ar?'ar':'en'] ?? $game->key }}</b><small>SERVER • FAIR PLAY</small></div><span>›</span>
    </a>
   @endforeach
  </div>
 </section>
 <section class="b304-feature-grid">
  <article><i>🛡️</i><b>{{ $ar?'لعب خادمي آمن':'Server-authoritative play' }}</b><p>{{ $ar?'الحركات والنتائج والمحفظة تُعتمد من الخادم.':'Moves, results and wallet changes are verified server-side.' }}</p></article>
  <article><i>🎨</i><b>{{ $ar?'تخصيص احترافي':'Premium customization' }}</b><p>{{ $ar?'50 طاولة عالية الدقة، ظهر مطابق لكل طاولة، وألوان وثيمات قابلة للتفعيل فورًا.':'50 high-definition tables, one matching back for each table, and instantly activatable colors and themes.' }}</p></article>
  <article><i>🎁</i><b>{{ $ar?'جوائز حقيقية':'Real rewards' }}</b><p>{{ $ar?'صناديق ودولاب وإعلانات مكافِئة ومسار تحديات متدرج.':'Prize boxes, wheel, rewarded ads and a staged challenge road.' }}</p></article>
  <article><i>🏆</i><b>{{ $ar?'منافسات أولاً':'Competition first' }}</b><p>{{ $ar?'بطولات وتذاكر وترتيب وتحديات بدون ازدحام الصفحة الرئيسية.':'Tournaments, tickets, rankings and challenges without a crowded home screen.' }}</p></article>
 </section>
</div>
@endsection
