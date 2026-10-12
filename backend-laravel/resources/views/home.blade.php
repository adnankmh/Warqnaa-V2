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

 @php
   // Real preview data only; never invent tournaments, prizes, club members or shop prices.
   $worldTournaments=\App\Models\Tournament::query()->with('game')->withCount('entries')
     ->whereIn('status',['open','running'])->orderByDesc('featured')->orderBy('starts_at')->limit(3)->get();
   $worldClubs=\App\Models\Club::query()->withCount('members')->orderByDesc('weekly_points')->limit(4)->get();
   $worldProducts=\App\Models\StoreItem::query()->where('active',true)
     ->whereIn('category',['card_back','profile_cover','xp_booster','name_color'])
     ->orderBy('id')->limit(5)->get();
   $worldProfile=auth()->user()?->profile;
 @endphp
 <section class="w36-grand-hero" aria-labelledby="w36ChampTitle">
  <div class="w36-grand-copy">
   <span class="w36-eyebrow">🏆 WARQNAA CHAMPIONSHIPS</span>
   <h2 id="w36ChampTitle">{{ $ar?'بطولات ورقنا الكبرى':'Warqnaa Grand Championships' }}</h2>
   <p>{{ $ar?'ألعاب ورق، منافسات حقيقية، وأندية تتحدى بعضها على صدارة الموسم. المكافآت الافتراضية تحددها قواعد كل بطولة.':'Card games, genuine competitions and clubs racing for seasonal glory. Virtual rewards follow each event’s rules.' }}</p>
   <div class="w36-hero-actions">
    <a href="{{ $isAuthed?route('tournaments'):route('login') }}" class="w36-gold-cta">🏆 {{ $ar?'استكشف البطولات':'Explore tournaments' }}</a>
    <a href="{{ $isAuthed?route('games'):route('register') }}" class="w36-blue-cta">🃏 {{ $ar?'ابدأ اللعب':'Start playing' }}</a>
   </div>
  </div>
  <div class="w36-cup-illustration" aria-hidden="true"><span class="w36-cup-rays">✦ ✦ ✦</span><span class="w36-big-cup">🏆</span><span class="w36-cup-deck">🂡 ♥ ♠ ♦ ♣</span></div>
 </section>
 <section class="w36-world-grid" aria-label="{{ $ar?'عالم ورقنا':'Warqnaa World' }}">
   <article class="w36-panel w36-tournaments">
    <header class="w36-panel-head"><h2>🏆 {{ $ar?'البطولات':'Tournaments' }}</h2><a href="{{ $isAuthed?route('tournaments'):route('login') }}">{{ $ar?'عرض الكل':'View all' }} ←</a></header>
    <div class="w36-mini-tabs" aria-label="{{ $ar?'فئات البطولات':'Tournament categories' }}"><span>{{ $ar?'اليومية':'Daily' }}</span><span>{{ $ar?'الأسبوعية':'Weekly' }}</span><span>{{ $ar?'الموسمية':'Seasonal' }}</span></div>
    @forelse($worldTournaments as $event)
     <a class="w36-tournament-item" href="{{ $isAuthed?route('tournaments'):route('login') }}">
       <span class="w36-tournament-medal" aria-hidden="true">🏆</span>
       <span class="w36-tournament-info"><strong>{{ data_get($event->name,$ar?'ar':'en') ?: ($event->game?->name[$ar?'ar':'en'] ?? ($ar?'بطولة ورقنا':'Warqnaa tournament')) }}</strong><small>{{ $event->entries_count }} {{ $ar?'مسجل':'registered' }} · {{ $event->status==='running'?($ar?'جارية':'Live'):($ar?'التسجيل متاح':'Registration open') }}</small></span>
       <span class="w36-tournament-prize">🪙 {{ number_format((int)$event->prize_pool) }}</span>
     </a>
    @empty
     <div class="w36-empty">{{ $ar?'لا توجد بطولات مفتوحة الآن. استعرض صفحة المنافسات لمعرفة الجديد.':'No open tournaments yet. Browse competitions for updates.' }}</div>
    @endforelse
   </article>
   <article class="w36-panel w36-clubs">
     <header class="w36-panel-head"><h2>🛡️ {{ $ar?'الأندية':'Clubs' }}</h2><a href="{{ $isAuthed?route('clubs'):route('login') }}">{{ $ar?'استكشف':'Explore' }} ←</a></header>
     @forelse($worldClubs as $club)
       <a class="w36-club-item" href="{{ $isAuthed?route('clubs.show',$club):route('login') }}">
        <span class="w36-club-crest" aria-hidden="true">@if($club->logo && preg_match('#^(https?://|/)#i',(string)$club->logo))<img src="{{ $club->logo }}" loading="lazy" decoding="async" alt="">@else{{ $club->logo ?: '♛' }}@endif</span>
        <span><strong>{{ $club->name }}</strong><small>{{ $club->members_count }} {{ $ar?'عضو':'members' }} · {{ $ar?'المستوى':'Level' }} {{ $club->level }}</small></span>
        <span class="w36-join-label">{{ $ar?'فتح':'Open' }}</span>
       </a>
     @empty
       <div class="w36-empty">{{ $ar?'كن من مؤسسي أول نادٍ في ورقنا.':'Be among the first to create a club.' }}</div>
     @endforelse
   </article>
   <article class="w36-panel w36-profile">
     <header class="w36-panel-head"><h2>✨ {{ $ar?'تخصيص الملف الشخصي':'Profile studio' }}</h2><a href="{{ $isAuthed?route('profile.show',$currentUser):route('register') }}">{{ $ar?'التخصيص':'Customize' }} ←</a></header>
     <div class="w36-profile-scene">
       <div class="w36-profile-avatar"><img src="{{ $worldProfile?->avatar ?: '/assets/avatars/default.svg' }}" alt="{{ $ar?'الصورة الشخصية':'Avatar' }}" loading="lazy" decoding="async"></div>
       <div class="w36-profile-tag"><strong>{{ auth()->user()?->username ?? ($ar?'انضم إلى ورقنا':'Join Warqnaa') }}</strong><small>👑 {{ $ar?'المستوى':'Level' }} {{ $worldProfile?->level ?? 1 }}</small></div>
     </div>
     <div class="w36-color-dots" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i><i></i><i></i></div>
     <a class="w36-studio-link" href="{{ $isAuthed?route('profile.show',$currentUser):route('register') }}">🎨 {{ $ar?'الصورة الدائرية • الإطار • الغلاف • الألوان':'Avatar • frame • cover • colors' }}</a>
   </article>
   <article class="w36-panel w36-store-preview">
     <header class="w36-panel-head"><h2>🎁 {{ $ar?'المتجر الفاخر':'Premium store' }}</h2><a href="{{ $isAuthed?route('store'):route('login') }}">{{ $ar?'المتجر':'Store' }} ←</a></header>
     <div class="w36-store-items">
      @forelse($worldProducts as $item)
       <a href="{{ $isAuthed?route('store'):route('login') }}" class="w36-store-item">
        @php $w36ItemArt=$item->payload['asset_url'] ?? $item->payload['table_image'] ?? $item->payload['card_back_image'] ?? null; @endphp
        <span class="w36-shop-icon" aria-hidden="true">@if($w36ItemArt && preg_match('#^(https?://|/)#i',(string)$w36ItemArt))<img src="{{ $w36ItemArt }}" loading="lazy" decoding="async" alt="">@else{{ $item->payload['preview_icon'] ?? '🎁' }}@endif</span>
        <strong>{{ $item->name[$ar?'ar':'en'] ?? $item->key }}</strong>
        <small>🪙 {{ number_format((int)$item->price) }}</small>
       </a>
      @empty
       <div class="w36-empty">{{ $ar?'العناصر الجديدة ستظهر من المتجر مباشرة.':'New items appear from the store catalog.' }}</div>
      @endforelse
     </div>
   </article>
   <article class="w36-panel w36-reactions">
    <header class="w36-panel-head"><h2>😍 {{ $ar?'الإيموجي وردود الفعل':'Emojis & reactions' }}</h2><a href="{{ $isAuthed?route('store'):route('login') }}">{{ $ar?'الباقات':'Packs' }} ←</a></header>
    <div class="w36-emoji-preview" aria-label="{{ $ar?'معاينة ردود الفعل':'Reactions preview' }}"><span>😂</span><span>😍</span><span>🥳</span><span>😭</span><span>😎</span><span>👍</span><span>💙</span><span>🔥</span><span>👏</span><span>🏆</span><span>💎</span><span>👑</span></div>
    <a class="w36-blue-cta w36-panel-button" href="{{ $isAuthed?route('store'):route('login') }}">{{ $ar?'تصفح باقات الإيموجي':'Browse emoji packs' }}</a>
   </article>
   <article class="w36-panel w36-bots">
    <header class="w36-panel-head"><h2>🤖 {{ $ar?'التدريب والروبوتات':'Practice & bots' }}</h2><a href="{{ $isAuthed?route('games'):route('login') }}">{{ $ar?'ابدأ':'Start' }} ←</a></header>
    <div class="w36-bot-badges" aria-hidden="true"><span>♠</span><span>♥</span><span>♦</span><span>♣</span><span>★</span></div>
    <p>{{ $ar?'تدرّب على الألعاب المدعومة بالروبوتات عبر غرف اللعب الحقيقية.':'Practice supported games against bots in real game rooms.' }}</p>
    <a class="w36-gold-cta w36-panel-button" href="{{ $isAuthed?route('games'):route('login') }}">{{ $ar?'اختر لعبة':'Choose a game' }}</a>
   </article>
 </section>

 <section class="b304-feature-grid">
  <article><i>🛡️</i><b>{{ $ar?'لعب خادمي آمن':'Server-authoritative play' }}</b><p>{{ $ar?'الحركات والنتائج والمحفظة تُعتمد من الخادم.':'Moves, results and wallet changes are verified server-side.' }}</p></article>
  <article><i>🎨</i><b>{{ $ar?'تخصيص احترافي':'Premium customization' }}</b><p>{{ $ar?'50 طاولة عالية الدقة، ظهر مطابق لكل طاولة، وألوان وثيمات قابلة للتفعيل فورًا.':'50 high-definition tables, one matching back for each table, and instantly activatable colors and themes.' }}</p></article>
  <article><i>🎁</i><b>{{ $ar?'جوائز حقيقية':'Real rewards' }}</b><p>{{ $ar?'صناديق ودولاب وإعلانات مكافِئة ومسار تحديات متدرج.':'Prize boxes, wheel, rewarded ads and a staged challenge road.' }}</p></article>
  <article><i>🏆</i><b>{{ $ar?'منافسات أولاً':'Competition first' }}</b><p>{{ $ar?'بطولات وتذاكر وترتيب وتحديات بدون ازدحام الصفحة الرئيسية.':'Tournaments, tickets, rankings and challenges without a crowded home screen.' }}</p></article>
 </section>
</div>
@endsection
