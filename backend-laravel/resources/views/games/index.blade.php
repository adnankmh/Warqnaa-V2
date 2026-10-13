@extends('layouts.app')
@section('title', app()->getLocale() === 'ar' ? 'صالة الألعاب | ورقنا' : 'Games Hall | Warqnaa')
@section('content')
@php
    $ar = app()->getLocale() === 'ar';
    $featured = ['tarneeb','hand','trix_complex','baloot','domino','ludo','jackaroo','spades'];
    $familyFor = fn($g) => (string) ($g->rules['family'] ?? 'training');
    $familyNames = [
        'training'=>['تدريب','Training'],'classic'=>['كلاسيكية','Classic'],
        'partnership'=>['شراكة','Partnership'],'cards'=>['ألعاب الورق','Cards'],
        'strategy'=>['استراتيجية','Strategy'],'board'=>['ألعاب الطاولة','Board'],
        'trick_taking'=>['لمّات','Trick-taking'],'social'=>['اجتماعية','Social'],
    ];
    $familyLabels = ['all' => $ar ? 'جميع الألعاب' : 'All games'];
    foreach ($games as $game) {
        $family = $familyFor($game);
        if (!array_key_exists($family, $familyLabels)) {
            $familyLabels[$family] = $familyNames[$family][$ar ? 0 : 1] ?? str_replace('_',' ',ucfirst($family));
        }
    }
    $totalGames = $games->count();
    $featuredCount = $games->filter(fn($g) => in_array($g->key, $featured, true))->count();
@endphp

<section class="wz-lobby-v130 w36-premium-games" id="wzLobbyV130" aria-labelledby="w36GamesTitle">
 <header class="wz-lobby-hero-v130 w36-game-hall-hero">
  <div class="hero-copy-v130">
   <span class="w36-hall-eyebrow">♠ WARQNAA GAME HALL ♥</span>
   <h1 id="w36GamesTitle">{{ $ar ? 'كل ألعاب ورقنا في صالة واحدة' : 'Every Warqnaa game, one grand hall' }}</h1>
   <p>{{ $ar ? 'اختر لعبتك وادخل غرف اللعب الفعلية، مع بطاقات فنية واضحة وبحث سريع وقوائم منظمة تناسب الهاتف والكمبيوتر.' : 'Choose a game and enter its real rooms, with illustrated cards, fast search and a clear layout for desktop and mobile.' }}</p>
   <div class="w36-game-hall-stats">
    <span>🃏 <b>{{ number_format($totalGames) }}</b> {{ $ar ? 'لعبة متاحة' : 'available games' }}</span>
    <span>✨ <b>{{ number_format($featuredCount) }}</b> {{ $ar ? 'لعبة مميزة' : 'featured games' }}</span>
   </div>
  </div>
  <div class="w36-game-hero-art" aria-hidden="true">
   <span class="w36-game-hero-sparkle">✦ ✧ ✦</span>
   <span class="w36-game-hero-trophy">🏆</span>
   <span class="w36-game-hero-cards">♥ ♠ ♦ ♣</span>
  </div>
  <div class="hero-actions-v130 w36-game-hero-actions">
   <a class="primary" href="{{ route('store') }}">💎 {{ $ar?'المتجر':'Store' }}</a>
   <a href="{{ route('tournaments') }}">🏆 {{ $ar?'البطولات':'Tournaments' }}</a>
   <a href="{{ route('clubs') }}">🛡️ {{ $ar?'الأندية':'Clubs' }}</a>
  </div>
 </header>

 <div class="w36-games-browser">
  <div class="wz-lobby-toolbar-v130 w36-game-filters">
   <label class="w36-search-label" for="gameSearchV130">{{ $ar?'البحث في الألعاب':'Search games' }}</label>
   <input id="gameSearchV130" type="search" autocomplete="off"
          placeholder="{{ $ar?'ابحث عن طرنيب، تركس، هاند...':'Find Tarneeb, Trix, Hand…' }}"
          aria-controls="w36GamesGrid">
   <button type="button" id="showFeaturedV130" aria-pressed="false">🔥 {{ $ar?'المميزة':'Featured' }}</button>
   <button type="button" id="compactGamesV130" aria-pressed="false">▦ {{ $ar?'عرض مضغوط':'Compact' }}</button>
  </div>
  <nav class="wz-family-tabs-v130 w36-game-families" aria-label="{{ $ar?'تصنيف الألعاب':'Game categories' }}">
   @foreach($familyLabels as $key=>$label)
    <button type="button" data-family-filter-v130="{{ $key }}"
            aria-pressed="{{ $key==='all' ? 'true' : 'false' }}"
            class="{{ $key==='all' ? 'active' : '' }}">{{ $label }}</button>
   @endforeach
  </nav>
  <div class="w36-games-results" id="w36GamesResults" role="status" aria-live="polite">
   {{ $ar?'النتائج:':'Results:' }} {{ $totalGames }} / {{ $totalGames }}
  </div>
  <div class="wz-games-wall-v130 w36-games-wall" id="w36GamesGrid" aria-label="{{ $ar?'ألعاب ورقنا المتاحة':'Available Warqnaa games' }}">
   @foreach($games as $game)
    @php
      $family = $familyFor($game);
      $engine = (string)($game->rules['engine'] ?? 'engine');
      $name = $game->name[$ar?'ar':'en'] ?? $game->name['ar'] ?? $game->key;
      $isFeatured = in_array($game->key,$featured,true);
    @endphp
    <a class="wz-game-card-v130 w36-game-tile {{ $isFeatured ? 'featured' : '' }}"
       data-featured="{{ $isFeatured ? 1 : 0 }}"
       data-family="{{ $family }}"
       data-name="{{ mb_strtolower($game->key.' '.($game->name['ar'] ?? '').' '.($game->name['en'] ?? '').' '.$engine) }}"
       href="{{ route('rooms.index',$game->key) }}"
       aria-label="{{ ($ar?'افتح غرف ':'Open rooms for ').$name }}">
      <div class="w36-game-tile-art r101-game-art">
       <img loading="lazy" decoding="async" src="{{ game_art_url($game->key) }}" alt="{{ $name }}">
       @if($isFeatured)<span class="w36-featured-ribbon">✦ {{ $ar?'مميز':'Featured' }}</span>@endif
      </div>
      <div class="w36-game-tile-info">
       <strong>{{ $name }}</strong>
       <small>👥 {{ $game->min_players }}–{{ $game->max_players }} {{ $ar?'لاعبين':'players' }}</small>
       <small>{{ $game->partnership ? ($ar?'🤝 شراكة':'🤝 Teams') : ($ar?'♠ فردي':'♠ Individual') }}</small>
       <span class="w36-game-play-now">{{ $ar?'العب الآن':'Play now' }} <span aria-hidden="true">←</span></span>
      </div>
    </a>
   @endforeach
  </div>
  <div class="w36-games-empty" id="w36GamesEmpty" hidden>
   <span aria-hidden="true">🔎</span>
   <strong>{{ $ar?'لم نجد لعبة بهذه المواصفات':'No matching games' }}</strong>
   <p>{{ $ar?'غيّر كلمات البحث أو التصنيف لعرض الألعاب المتاحة.':'Try another search or category to see available games.' }}</p>
   <button type="button" id="w36ClearGameFilters">{{ $ar?'عرض جميع الألعاب':'Show all games' }}</button>
  </div>
 </div>
</section>

<script>
(() => {
 const root=document.getElementById('wzLobbyV130');
 if(!root) return;
 const search=root.querySelector('#gameSearchV130');
 const tabs=[...root.querySelectorAll('[data-family-filter-v130]')];
 const compact=root.querySelector('#compactGamesV130');
 const featured=root.querySelector('#showFeaturedV130');
 const cards=[...root.querySelectorAll('.wz-game-card-v130')];
 const results=root.querySelector('#w36GamesResults');
 const empty=root.querySelector('#w36GamesEmpty');
 const clear=root.querySelector('#w36ClearGameFilters');
 const ar=document.documentElement.lang==='ar';
 let onlyFeatured=false;
 const update=()=>{
  const q=(search.value||'').toLocaleLowerCase().trim();
  const family=tabs.find(tab=>tab.classList.contains('active'))?.dataset.familyFilterV130||'all';
  let visible=0;
  for(const card of cards) {
    const match=(family==='all'||card.dataset.family===family)&&
      (!q||(card.dataset.name||'').includes(q))&&
      (!onlyFeatured||card.dataset.featured==='1');
    card.hidden=!match;
    if(match) visible++;
  }
  results.textContent=(ar?'النتائج: ':'Results: ')+visible+' / '+cards.length;
  empty.hidden=visible!==0;
 };
 tabs.forEach(tab=>tab.addEventListener('click',()=>{
  for(const option of tabs) {
    const selected=option===tab;
    option.classList.toggle('active',selected);
    option.setAttribute('aria-pressed',String(selected));
  }
  update();
 }));
 search.addEventListener('input',update);
 compact.addEventListener('click',()=>{
  const active=root.classList.toggle('compact');
  compact.setAttribute('aria-pressed',String(active));
 });
 featured.addEventListener('click',()=>{
  onlyFeatured=!onlyFeatured;
  featured.classList.toggle('active',onlyFeatured);
  featured.setAttribute('aria-pressed',String(onlyFeatured));
  update();
 });
 clear.addEventListener('click',()=>{
  search.value='';
  onlyFeatured=false;
  featured.classList.remove('active');
  featured.setAttribute('aria-pressed','false');
  const first=tabs[0];
  for(const tab of tabs) {
    tab.classList.toggle('active',tab===first);
    tab.setAttribute('aria-pressed',String(tab===first));
  }
  update();
  search.focus();
 });
 update();
})();
</script>
@endsection
