@extends('layouts.app')
@section('title','Warqnaa | عالم اللعب العربي')
@section('content')
@php
  $isAuthed = auth()->check();
  $locale = app()->getLocale();
  $ar = $locale === 'ar';
  $publicKeys = array_keys(\App\Services\Games\GameCatalog::all());
  $games = class_exists('\App\Models\Game') ? \App\Models\Game::where('active',true)->whereIn('key',$publicKeys)->orderBy('id')->take(8)->get() : collect();
  $openRooms = $isAuthed && class_exists('\App\Models\Room') ? \App\Models\Room::whereIn('status',['waiting','bidding','playing'])->count() : 0;
  $activeTournaments = $isAuthed && class_exists('\App\Models\Tournament') ? \App\Models\Tournament::whereIn('status',['open','running'])->count() : 0;
  $gamesUrl = $isAuthed ? route('games') : route('login');
  $socialUrl = $isAuthed ? route('social-world') : route('login');
  $competitiveUrl = $isAuthed ? route('competitive') : route('login');
@endphp
<div class="r141-home">
  <section class="r141-hero" aria-labelledby="r141HeroTitle">
    <div class="r141-hero-glow one"></div><div class="r141-hero-glow two"></div>
    <div class="r141-hero-copy">
      <span class="r141-kicker"><i></i>{{ $ar ? 'الإصدار العالمي • R14.1' : 'GLOBAL EXPERIENCE • R14.1' }}</span>
      <h1 id="r141HeroTitle">{!! $ar ? 'كل طاولة.<br><em>عالمٌ كامل.</em>' : 'Every table.<br><em>A whole world.</em>' !!}</h1>
      <p>{{ $ar ? 'ألعاب الورق العربية التي تحبها، بمحركات عادلة وخادمية، مجتمع حيّ، منافسات موسمية وهوية بصرية صُممت لتشعر بالفخامة من أول ضغطة.' : 'The Arab card games you love, powered by fair server engines, a living social world, seasonal competition and a premium identity from the first tap.' }}</p>
      <div class="r141-hero-actions">
        <a class="r141-btn r141-btn-primary" href="{{ $gamesUrl }}"><span>▶</span>{{ $ar ? 'ابدأ اللعب الآن' : 'Play now' }}<i>←</i></a>
        <a class="r141-btn r141-btn-glass" href="{{ $competitiveUrl }}"><span>♛</span>{{ $ar ? 'ادخل الساحة' : 'Enter arena' }}</a>
        @unless($isAuthed)<a class="r141-btn r141-btn-quiet" href="{{ route('register') }}">{{ $ar ? 'أنشئ حسابك مجانًا' : 'Create free account' }}</a>@endunless
      </div>
      <div class="r141-trust-row">
        <span>✓ {{ $ar ? '20 محركًا معتمدًا' : '20 certified engines' }}</span>
        <span>✓ {{ $ar ? 'عربي وإنجليزي' : 'Arabic & English' }}</span>
        <span>✓ {{ $ar ? 'ويب وAndroid وiOS' : 'Web, Android & iOS' }}</span>
      </div>
    </div>
    <div class="r141-hero-stage" aria-hidden="true">
      <div class="r141-stage-ring ring-one"></div><div class="r141-stage-ring ring-two"></div>
      <div class="r141-card-fan">
        <span class="r141-playing-card card-a"><b>A</b><i>♠</i></span>
        <span class="r141-playing-card card-k"><b>K</b><i>♥</i></span>
        <span class="r141-playing-card card-q"><b>Q</b><i>♦</i></span>
      </div>
      <div class="r141-stage-seal"><small>WARQNAA</small><strong>W</strong><span>EST. 2026</span></div>
      <div class="r141-stage-chip chip-live"><i></i>{{ $ar ? 'اللعب مباشر' : 'LIVE PLAY' }}</div>
      <div class="r141-stage-chip chip-fair">🛡️ {{ $ar ? 'عدالة خادمية' : 'SERVER FAIR' }}</div>
    </div>
  </section>

  <section class="r141-livebar" aria-label="live platform statistics">
    <div><span>◉</span><small>{{ $ar ? 'الحالة' : 'Status' }}</small><b>{{ $ar ? 'متصل وجاهز' : 'Online & ready' }}</b></div>
    <div><small>{{ $ar ? 'الألعاب الجاهزة' : 'Ready games' }}</small><b>{{ max($games->count(), count($publicKeys)) }}</b></div>
    <div><small>{{ $ar ? 'الغرف النشطة' : 'Active rooms' }}</small><b>{{ number_format($openRooms) }}</b></div>
    <div><small>{{ $ar ? 'المنافسات' : 'Competitions' }}</small><b>{{ number_format($activeTournaments) }}</b></div>
    <div><small>{{ $ar ? 'محركات اللعب' : 'Game engines' }}</small><b>20</b></div>
  </section>

  <section class="r141-section r141-games-section">
    <header class="r141-section-head">
      <div><span>{{ $ar ? 'اختر طاولتك' : 'CHOOSE YOUR TABLE' }}</span><h2>{{ $ar ? 'ألعاب بهوية لا تُنسى' : 'Games with a memorable identity' }}</h2></div>
      <a class="r141-text-link" href="{{ $gamesUrl }}">{{ $ar ? 'استكشف كل الألعاب' : 'Explore all games' }} <i>←</i></a>
    </header>
    <div class="r141-game-shelf">
      @forelse($games as $index => $game)
        @php $name=$game->name[$locale] ?? $game->name['ar'] ?? $game->key; @endphp
        <a class="r141-home-game {{ $index === 0 ? 'is-featured' : '' }}" href="{{ $isAuthed ? route('rooms.index',$game->key) : route('login') }}">
          <img loading="lazy" decoding="async" src="{{ game_art_url($game->key) }}" alt="{{ $name }}">
          <span class="r141-game-shade"></span>
          <span class="r141-game-top"><b>{{ $index < 3 ? ($ar ? 'مميزة' : 'FEATURED') : ($ar ? 'جاهزة' : 'READY') }}</b><i>{{ $game->rules['icon'] ?? game_icon($game->key) }}</i></span>
          <span class="r141-game-copy"><small>{{ $game->partnership ? ($ar ? 'فريقان' : 'Teams') : ($ar ? 'فردي' : 'Solo') }} • {{ $game->min_players }}–{{ $game->max_players }}</small><strong>{{ $name }}</strong><em>{{ $ar ? 'ادخل الطاولة' : 'Enter table' }} ←</em></span>
        </a>
      @empty
        <div class="r141-empty">{{ $ar ? 'ستظهر الألعاب فور جاهزية قاعدة البيانات.' : 'Games appear as soon as the database is ready.' }}</div>
      @endforelse
    </div>
  </section>

  <section class="r141-world-grid">
    <a class="r141-world-card social" href="{{ $socialUrl }}"><span class="r141-world-icon">◎</span><small>SOCIAL WORLD</small><h3>{{ $ar ? 'مجتمع يلعب معك' : 'A world that plays with you' }}</h3><p>{{ $ar ? 'تابع اللاعبين، شاهد المباريات، شارك الإعادات، نظّم الأحداث وأرسل الهدايا ضمن خصوصية كاملة.' : 'Follow players, spectate, share replays, organize events and send gifts with complete privacy.' }}</p><b>{{ $ar ? 'اكتشف العالم الاجتماعي' : 'Discover Social World' }} ←</b></a>
    <a class="r141-world-card arena" href="{{ $competitiveUrl }}"><span class="r141-world-icon">♛</span><small>COMPETITIVE ARENA</small><h3>{{ $ar ? 'مكانك بين الأساطير' : 'Your place among legends' }}</h3><p>{{ $ar ? 'تصنيف MMR، مواسم، مستويات، طوابير عادلة وبطولات عالمية ومحلية وجوائز موثقة.' : 'MMR ranking, seasons, tiers, fair queues, global tournaments and auditable rewards.' }}</p><b>{{ $ar ? 'ابدأ مسيرتك التنافسية' : 'Start your competitive run' }} ←</b></a>
    <a class="r141-world-card rewards" href="{{ $isAuthed ? route('rewards') : route('login') }}"><span class="r141-world-icon">✦</span><small>REWARDS & STYLE</small><h3>{{ $ar ? 'هوية خاصة بك' : 'An identity of your own' }}</h3><p>{{ $ar ? 'مكافآت يومية، صناديق، طريق هدايا، طاولات وثيمات ومقتنيات تجميلية لا تؤثر على عدالة اللعب.' : 'Daily rewards, boxes, a gift road, tables, themes and cosmetics that never affect fair play.' }}</p><b>{{ $ar ? 'افتح المكافآت' : 'Open rewards' }} ←</b></a>
  </section>

  <section class="r141-quality">
    <div class="r141-quality-copy"><span>{{ $ar ? 'الجودة في قلب التجربة' : 'QUALITY AT THE CORE' }}</span><h2>{{ $ar ? 'قوي في الداخل. راقٍ في الخارج.' : 'Powerful inside. Refined outside.' }}</h2><p>{{ $ar ? 'كل نقلة ونتيجة تمر عبر محرك خادمي موثوق، بينما تتكيف الواجهة مع الهاتف واللوحي والكمبيوتر دون التضحية بالوضوح أو السرعة.' : 'Every move and result passes through an authoritative engine while the interface adapts across phone, tablet and desktop without losing clarity or speed.' }}</p></div>
    <div class="r141-quality-list">
      <div><i>01</i><span><b>{{ $ar ? 'لعب عادل' : 'Fair play' }}</b><small>{{ $ar ? 'توزيع آمن وتحقق من الدور والحركة' : 'Secure deals and turn validation' }}</small></span></div>
      <div><i>02</i><span><b>{{ $ar ? 'عالم متصل' : 'Connected world' }}</b><small>{{ $ar ? 'أصدقاء وأندية ومشاهدة وإعادات' : 'Friends, clubs, spectators and replays' }}</small></span></div>
      <div><i>03</i><span><b>{{ $ar ? 'جاهز عالميًا' : 'Global ready' }}</b><small>{{ $ar ? 'أربع قنوات ونظام إصدار قابل للتدقيق' : 'Four channels and auditable releases' }}</small></span></div>
    </div>
  </section>

  <section class="r141-final-cta"><span>♠</span><div><small>WARQNAA R14.1</small><h2>{{ $ar ? 'طاولتك تنتظرك.' : 'Your table is waiting.' }}</h2></div><a class="r141-btn r141-btn-primary" href="{{ $gamesUrl }}">{{ $ar ? 'ادخل ورقنا' : 'Enter Warqnaa' }} ←</a><span>♥</span></section>
</div>
@endsection
