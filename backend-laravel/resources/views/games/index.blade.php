@extends('layouts.app')
@section('title','صالة ألعاب Warqnaa')
@section('content')
@php
$locale=app()->getLocale(); $ar=$locale==='ar';
$familyLabels=['all'=>$ar?'الكل':'All','tarneeb'=>$ar?'طرنيب':'Tarneeb','meld'=>$ar?'هاند وبناكل':'Meld','trix'=>$ar?'تركس':'Trix','gulf'=>$ar?'خليجية':'Gulf','basra'=>$ar?'باصرة':'Basra'];
$familyFor=fn($g)=>$g->rules['family'] ?? 'training';
$featured=['tarneeb','hand','trix_complex','baloot','banakil','syrian_tarneeb'];
$teamCount=$games->filter(fn($game)=>(bool)$game->partnership)->count();
@endphp

<section class="r141-lobby" id="r141Lobby">
 <header class="r141-lobby-hero">
  <div class="r141-lobby-copy"><span><i></i> WARQNAA GAME HALL</span><h1>{{ $ar ? 'اختر لعبتك. اصنع ليلتك.' : 'Choose your game. Own the night.' }}</h1><p>{{ $ar ? 'صالة واحدة لكل ألعابك الجاهزة، بصور سينمائية ومعلومات واضحة ودخول مباشر إلى الغرف.' : 'One hall for every ready game, with cinematic art, clear information and direct room access.' }}</p></div>
  <div class="r141-lobby-emblem" aria-hidden="true"><span>♠</span><b>W</b><span>♥</span></div>
  <div class="r141-lobby-actions"><a class="r141-btn r141-btn-primary" href="{{ route('competitive') }}">♛ {{ $ar ? 'لعب تنافسي' : 'Ranked play' }}</a><a class="r141-btn r141-btn-glass" href="{{ route('game.rules') }}">☷ {{ $ar ? 'دليل القوانين' : 'Rules guide' }}</a></div>
 </header>

 <div class="r141-lobby-stats"><div><b>{{ $games->count() }}</b><span>{{ $ar ? 'لعبة جاهزة' : 'ready games' }}</span></div><div><b>20</b><span>{{ $ar ? 'محركًا معتمدًا' : 'certified engines' }}</span></div><div><b>{{ $teamCount }}</b><span>{{ $ar ? 'ألعاب شراكة' : 'team games' }}</span></div><div><b>24/7</b><span>{{ $ar ? 'غرف ومجتمع' : 'rooms & community' }}</span></div></div>

 <div class="r141-lobby-toolbar">
  <label class="r141-search"><span>⌕</span><input id="gameSearchR141" type="search" placeholder="{{ $ar ? 'ابحث باسم اللعبة أو المحرك...' : 'Search game or engine...' }}" autocomplete="off"></label>
  <div class="r141-view-actions"><button type="button" id="featuredR141" aria-pressed="false">✦ {{ $ar ? 'المميزة' : 'Featured' }}</button><button type="button" id="compactR141" aria-pressed="false">▦ {{ $ar ? 'عرض مدمج' : 'Compact' }}</button></div>
 </div>

 <nav class="r141-family-tabs" aria-label="{{ $ar ? 'تصنيف الألعاب' : 'Game categories' }}">
  @foreach($familyLabels as $key=>$label)<button type="button" data-family-r141="{{$key}}" class="{{$key==='all'?'active':''}}">{{$label}}</button>@endforeach
 </nav>

 <main class="r141-games-grid" id="r141GamesGrid">
  @foreach($games as $game)
   @php $family=$familyFor($game); $engine=$game->rules['engine'] ?? 'engine'; $isFeatured=in_array($game->key,$featured,true); $name=$game->name[$locale] ?? $game->name['ar'] ?? $game->key; @endphp
   <article class="r141-game-card {{$isFeatured?'is-featured':''}}" data-featured="{{$isFeatured?1:0}}" data-family="{{$family}}" data-name="{{ strtolower($game->key.' '.($game->name['ar'] ?? '').' '.($game->name['en'] ?? '').' '.$engine) }}">
    <a class="r141-game-cover" href="{{ route('rooms.index',$game->key) }}">
      <img loading="lazy" decoding="async" src="{{ game_art_url($game->key) }}" alt="{{ $name }}">
      <span class="r141-game-overlay"></span>
      <span class="r141-game-badges"><b>{{ $isFeatured ? ($ar?'مميزة':'FEATURED') : ($ar?'جاهزة':'READY') }}</b><i>{{ $game->rules['icon'] ?? game_icon($game->key) }}</i></span>
      <span class="r141-game-play"><i>▶</i></span>
    </a>
    <div class="r141-game-info"><div><small>{{ strtoupper(str_replace('_',' ',$engine)) }}</small><h2>{{ $name }}</h2></div><p>{{ $game->rules['summary'] ?? ($ar?'تجربة ورق عربية بمحرك خادمي عادل.':'An Arab card experience with a fair server engine.') }}</p><div class="r141-game-meta"><span>♟ {{ $game->min_players }}–{{ $game->max_players }} {{ $ar?'لاعبين':'players' }}</span><span>{{ $game->partnership ? '◈ '.($ar?'شراكة':'Teams') : '◇ '.($ar?'فردي':'Solo') }}</span></div><a class="r141-game-enter" href="{{ route('rooms.index',$game->key) }}"><span>{{ $ar ? 'دخول الغرف' : 'Enter rooms' }}</span><i>←</i></a></div>
   </article>
  @endforeach
  <div class="r141-no-games" id="r141NoGames" hidden>⌕<b>{{ $ar ? 'لا توجد لعبة مطابقة' : 'No matching game' }}</b><span>{{ $ar ? 'جرّب كلمة أخرى أو اعرض كل التصنيفات.' : 'Try another keyword or show all categories.' }}</span></div>
 </main>
</section>

<script>
(()=>{
 const root=document.getElementById('r141Lobby'),search=document.getElementById('gameSearchR141'),cards=[...document.querySelectorAll('.r141-game-card')],tabs=[...document.querySelectorAll('[data-family-r141]')],featured=document.getElementById('featuredR141'),compact=document.getElementById('compactR141'),empty=document.getElementById('r141NoGames');
 let onlyFeatured=false;
 const apply=()=>{const q=(search?.value||'').toLocaleLowerCase().trim(),family=document.querySelector('[data-family-r141].active')?.dataset.familyR141||'all';let shown=0;cards.forEach(card=>{const visible=(!q||(card.dataset.name||'').includes(q))&&(family==='all'||card.dataset.family===family)&&(!onlyFeatured||card.dataset.featured==='1');card.hidden=!visible;if(visible)shown++;});if(empty)empty.hidden=shown!==0;};
 tabs.forEach(tab=>tab.addEventListener('click',()=>{tabs.forEach(item=>item.classList.toggle('active',item===tab));apply();}));
 search?.addEventListener('input',apply);
 featured?.addEventListener('click',()=>{onlyFeatured=!onlyFeatured;featured.classList.toggle('active',onlyFeatured);featured.setAttribute('aria-pressed',String(onlyFeatured));apply();});
 compact?.addEventListener('click',()=>{const active=root.classList.toggle('is-compact');compact.classList.toggle('active',active);compact.setAttribute('aria-pressed',String(active));});
 apply();
})();
</script>
@endsection
