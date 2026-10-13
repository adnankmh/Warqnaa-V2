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
 <section class="w36-grand-hero w36-illustrated-hero" aria-labelledby="w36ChampTitle">
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


 @if($isAuthed && auth()->user()->isPrimaryAdmin())
  <section id="w36-live-progress" class="w36-progress-center" aria-labelledby="w36-progress-heading">
    <div class="w36-progress-heading">
      <div>
        <span class="w36-progress-eyebrow">WARQNAA DEVELOPMENT • GITHUB LIVE</span>
        <h2 id="w36-progress-heading">📈 {{ $ar?'مركز متابعة التطوير':'Development progress center' }}</h2>
        <p>{{ $ar?'حالة بناء الإصدار والاختبارات الخمسة مباشرة من GitHub. هذه النسبة تخص اجتياز الاختبارات فقط، وليست نسبة اكتمال اللعبة.':'Live GitHub build and five quality gates. This percentage measures passing checks, not overall game completion.' }}</p>
      </div>
      <a class="w36-progress-pr" href="https://github.com/adnankmh/Warqnaa-V2/pull/29" target="_blank" rel="noopener noreferrer">R36 · PR #29 ↗</a>
    </div>
    <div class="w36-progress-overview">
      <div class="w36-progress-count">
        <strong id="w36-progress-passed">— / 5</strong>
        <small>{{ $ar?'اختبارات ناجحة':'Passing workflows' }}</small>
      </div>
      <div class="w36-progress-track-group">
        <div class="w36-progress-track" role="progressbar" aria-valuemin="0" aria-valuemax="5" aria-valuenow="0" aria-label="{{ $ar?'اجتياز بوابات الجودة':'Passing quality gates' }}" id="w36-progress-track">
          <span id="w36-progress-fill"></span>
        </div>
        <div id="w36-progress-note" role="status" aria-live="polite">{{ $ar?'جار التحقق من GitHub…':'Checking GitHub…' }}</div>
      </div>
    </div>
    <div class="w36-progress-grid">
      @foreach([
        'Backend CI and Security Foundation'=>['🛡️','Laravel / Security','backend-ci.yml'],
        'Build Android APK and AAB'=>['📱','Android APK / AAB','flutter-android.yml'],
        'Build and deploy Flutter Web'=>['🌐','Flutter Web','flutter-web-pages.yml'],
        'Production Release Gate'=>['🏆','Production / Economy','production-release-check.yml'],
        'R7 isolated runtime and visual review'=>['🎨','UX / Game / Design','r7-runtime-verification.yml'],
      ] as $workflow=>$config)
        <a class="w36-progress-gate" data-w36-workflow="{{ $workflow }}" href="https://github.com/adnankmh/Warqnaa-V2/actions/workflows/{{ $config[2] }}" target="_blank" rel="noopener noreferrer">
          <span class="w36-progress-gate-icon" aria-hidden="true">{{ $config[0] }}</span>
          <span class="w36-progress-gate-title">{{ $config[1] }}</span>
          <span class="w36-progress-gate-state">{{ $ar?'قيد التحقق':'Checking' }}</span>
        </a>
      @endforeach
    </div>
    <div class="w36-commit-center" aria-labelledby="w36-commit-heading">
      <div class="w36-commit-heading">
        <div><h3 id="w36-commit-heading">🧩 {{ $ar?'التعديلات البرمجية الأخيرة':'Latest verified code changes' }}</h3>
          <small id="w36-commit-summary">{{ $ar?'جار تحميل سجل GitHub…':'Loading GitHub history…' }}</small></div>
        <a href="https://github.com/adnankmh/Warqnaa-V2/pull/29/commits" target="_blank" rel="noopener noreferrer">{{ $ar?'جميع التعديلات':'All commits' }} ↗</a>
      </div>
      <ol id="w36-commit-list" class="w36-commit-list" aria-live="polite" aria-label="{{ $ar?'آخر تعديلات المشروع':'Latest project changes' }}">
        <li>{{ $ar?'يتم التحقق من سجل GitHub مباشرة…':'Checking the live GitHub history…' }}</li>
      </ol>
    </div>
    <div class="w36-progress-footer">
      <span id="w36-progress-version">{{ $ar?'آخر إصدار: جارٍ التحقق':'Latest revision: checking' }}</span>
      <span>{{ $ar?'مشروع قيد التطوير • الدمج يتطلب اجتياز جميع الفحوصات والمراجعة':'In development • merge requires all checks and review' }}</span>
      <a href="https://github.com/adnankmh/Warqnaa-V2/actions" target="_blank" rel="noopener noreferrer">{{ $ar?'عرض سجل GitHub Actions':'Open GitHub Actions' }} ↗</a>
    </div>
  </section>
  <script>
  (() => {
    'use strict';
    const root = document.getElementById('w36-live-progress');
    if (!root || typeof window.fetch !== 'function') return;
    const ar = document.documentElement.lang === 'ar';
    const base = 'https://api.github.com/repos/adnankmh/Warqnaa-V2';
    const expected = [...root.querySelectorAll('[data-w36-workflow]')];
    const note = document.getElementById('w36-progress-note');
    const count = document.getElementById('w36-progress-passed');
    const fill = document.getElementById('w36-progress-fill');
    const track = document.getElementById('w36-progress-track');
    const version = document.getElementById('w36-progress-version');
    const commitList = document.getElementById('w36-commit-list');
    const commitSummary = document.getElementById('w36-commit-summary');
    let previousCommitSha = '';
    let lastCommitUpdate = 0;
    let displayedHead = '';
    function clearWorkflowStatus() {
      expected.forEach(node => {
        node.dataset.status = 'unknown';
        node.querySelector('.w36-progress-gate-state').textContent = ar ? 'غير متاح' : 'Unavailable';
        node.href = 'https://github.com/adnankmh/Warqnaa-V2/actions';
      });
      count.textContent = '— / ' + expected.length;
      fill.style.width = '0%';
      track.setAttribute('aria-valuenow', '0');
      track.setAttribute('aria-valuetext', ar ? 'حالة الفحوص غير متاحة' : 'Workflow status unavailable');
    }
    async function refreshCommits(sha, reportedCount) {
      if (previousCommitSha === sha && Date.now() - lastCommitUpdate < 600000) return;
      try {
        const commits = await request('/commits?sha=' + encodeURIComponent(sha) + '&per_page=8');
        if (!Array.isArray(commits)) throw new Error('Invalid commit history');
        const fragment = document.createDocumentFragment();
        commits.forEach(commit => {
          if (!commit || typeof commit.sha !== 'string' || !/^[a-f0-9]{40}$/.test(commit.sha)) return;
          const item = document.createElement('li');
          const link = document.createElement('a');
          const title = document.createElement('strong');
          const meta = document.createElement('small');
          const message = commit.commit && typeof commit.commit.message === 'string' ? commit.commit.message : '';
          const date = commit.commit && commit.commit.author ? commit.commit.author.date : null;
          link.href = 'https://github.com/adnankmh/Warqnaa-V2/commit/' + commit.sha;
          link.target = '_blank';
          link.rel = 'noopener noreferrer';
          title.textContent = message.split('\n', 1)[0].slice(0, 160) || (ar ? 'تعديل برمجي' : 'Code change');
          const dateLabel = date && !Number.isNaN(new Date(date).getTime())
            ? new Date(date).toLocaleString(ar ? 'ar-PS' : 'en-US', {day:'numeric',month:'short',hour:'2-digit',minute:'2-digit'})
            : '';
          meta.textContent = commit.sha.slice(0, 8) + (dateLabel ? ' · ' + dateLabel : '');
          link.append(title, meta);
          item.appendChild(link);
          fragment.appendChild(item);
        });
        commitList.replaceChildren(fragment);
        previousCommitSha = sha;
        lastCommitUpdate = Date.now();
        commitSummary.textContent = (ar ? 'التعديلات في R36: ' : 'R36 commits: ') +
          (Number.isSafeInteger(reportedCount) ? reportedCount.toLocaleString(ar ? 'ar-PS' : 'en-US') : '—') +
          (ar ? ' · المصدر GitHub' : ' · sourced from GitHub');
      } catch (_) {
        commitSummary.textContent = ar
          ? 'سجل التعديلات غير متاح حاليًا؛ راجعه عبر GitHub.'
          : 'Commit history temporarily unavailable. Open GitHub.';
      }
    }
    const request = async path => {
      const response = await fetch(base + path, {
        method: 'GET', cache: 'no-store',
        headers: { Accept: 'application/vnd.github+json' }
      });
      if (!response.ok) throw new Error('GitHub unavailable');
      return response.json();
    };
    async function refresh() {
      try {
        const pr = await request('/pulls/29');
        const sha = pr.head && pr.head.sha;
        if (typeof sha !== 'string' || !/^[a-f0-9]{40}$/.test(sha)) throw new Error('Invalid SHA');
        if (displayedHead !== sha) {
          clearWorkflowStatus();
          displayedHead = sha;
        }
        version.textContent = (ar ? 'الإصدار الحالي: ' : 'Current revision: ') +
          sha.slice(0, 8) + (pr.draft ? ' · Draft' : pr.merged ? ' · Merged' : ' · Open');
        // History is supplemental: a GitHub rate limit must not hide CI status.
        void refreshCommits(sha, pr.commits);
        const builds = await request('/actions/runs?head_sha=' + encodeURIComponent(sha) + '&event=pull_request&per_page=100');
        const runs = Array.isArray(builds.workflow_runs) ? builds.workflow_runs : [];
        let passed = 0, pending = 0, failed = 0, unknown = 0;
        expected.forEach(node => {
          const workflow = node.getAttribute('data-w36-workflow');
          const candidates = runs.filter(run => run.name === workflow && run.head_sha === sha);
          candidates.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
          const run = candidates[0];
          const state = node.querySelector('.w36-progress-gate-state');
          let label = ar ? 'غير متاح' : 'Unavailable';
          let mode = 'unknown';
          if (run && run.status === 'completed' && run.conclusion === 'success') {
            passed++; mode = 'success'; label = ar ? 'ناجح' : 'Passed';
          } else if (run && run.status === 'completed') {
            failed++; mode = 'failed'; label = ar ? 'يتطلب مراجعة' : 'Needs review';
          } else if (run) {
            pending++; mode = 'pending'; label = ar ? 'قيد التشغيل' : 'In progress';
          } else { unknown++; }
          node.dataset.status = mode;
          state.textContent = label;
          if (run && typeof run.html_url === 'string' && run.html_url.startsWith('https://github.com/')) node.href = run.html_url;
        });
        count.textContent = passed + ' / ' + expected.length;
        fill.style.width = (passed / expected.length * 100) + '%';
        track.setAttribute('aria-valuenow', String(passed));
        track.setAttribute('aria-valuetext', passed + ' / ' + expected.length);
        note.textContent = (ar ? 'آخر تحديث من GitHub: ' : 'Last checked: ') +
          new Date().toLocaleTimeString(ar ? 'ar-PS' : 'en-US', {hour:'2-digit', minute:'2-digit'}) +
          (pending ? (ar ? ' • قيد التنفيذ: ' : ' • Running: ') + pending : '') +
          (failed ? (ar ? ' • تحتاج مراجعة: ' : ' • Needs review: ') + failed : '') +
          (unknown ? (ar ? ' • غير متاح: ' : ' • Unavailable: ') + unknown : '');
      } catch (_) {
        clearWorkflowStatus();
        note.textContent = ar
          ? 'تعذر التحديث المباشر. افتح GitHub Actions لمشاهدة الحالة الموثّقة.'
          : 'Live refresh unavailable. Open GitHub Actions for verified results.';
      }
    }
    refresh();
    window.setInterval(() => { if (!document.hidden) refresh(); }, 300000);
  })();
  </script>
 @endif

 <section class="b304-feature-grid">
  <article><i>🛡️</i><b>{{ $ar?'لعب خادمي آمن':'Server-authoritative play' }}</b><p>{{ $ar?'الحركات والنتائج والمحفظة تُعتمد من الخادم.':'Moves, results and wallet changes are verified server-side.' }}</p></article>
  <article><i>🎨</i><b>{{ $ar?'تخصيص احترافي':'Premium customization' }}</b><p>{{ $ar?'50 طاولة عالية الدقة، ظهر مطابق لكل طاولة، وألوان وثيمات قابلة للتفعيل فورًا.':'50 high-definition tables, one matching back for each table, and instantly activatable colors and themes.' }}</p></article>
  <article><i>🎁</i><b>{{ $ar?'مكافآت افتراضية':'Virtual rewards' }}</b><p>{{ $ar?'صناديق ومسار تحديات ومكافآت افتراضية تُمنح بعد التحقق من الاستحقاق.':'Prize boxes, challenges and virtual rewards granted only after entitlement verification.' }}</p></article>
  <article><i>🏆</i><b>{{ $ar?'منافسات أولاً':'Competition first' }}</b><p>{{ $ar?'بطولات وتذاكر وترتيب وتحديات بدون ازدحام الصفحة الرئيسية.':'Tournaments, tickets, rankings and challenges without a crowded home screen.' }}</p></article>
 </section>
</div>
@endsection
