@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'إعادة المسابقة #'.$tournament->id.' | ورقنا' : 'Tournament Replay #'.$tournament->id.' | Warqnaa')
@section('content')
@php
$locale = app()->getLocale();
$ar = $locale === 'ar';
$gameName = $tournament->game->name[$locale] ?? $tournament->game->name['ar'] ?? $tournament->game->key;
$replayTitle = ($ar ? 'مسابقة #' : 'Tournament #').$tournament->id.' — '.$gameName;
@endphp
<div class="replay-page pro-card" dir="{{ $ar ? 'rtl' : 'ltr' }}">
 <h1>📼 {{ $ar ? 'تسجيل المسابقة' : 'Tournament replay' }} #{{ $tournament->id }} — {{ $gameName }}</h1>
 <p class="muted">{{ $ar ? 'هذا تسجيل فيديو داخل المتصفح يتم توليده من سجل حركات المسابقة. بعد الضغط على زر التسجيل سيتم إنتاج فيديو WebM قابل للتشغيل والتحميل، ومع نهاية المباراة تظهر أوراق جميع اللاعبين.' : 'This in-browser video is generated from the tournament action log. Recording produces a playable, downloadable WebM file, and every player’s cards are revealed only after the match has finished.' }}</p>
 <div class="replay-toolbar">
  <a class="btn" href="{{ route('tournaments') }}">{{ $ar ? 'العودة للمسابقات' : 'Back to tournaments' }}</a>
  @if($room)<a class="btn success" href="{{ route('rooms.show',$room->code) }}">{{ $ar ? 'فتح الغرفة' : 'Open room' }} {{ $room->code }}</a>@endif
  <button type="button" class="primary" onclick="playTournamentReplay(false)">{{ $ar ? 'تشغيل العرض' : 'Play replay' }}</button>
  <button type="button" class="primary" onclick="playTournamentReplay(true)">{{ $ar ? 'توليد فيديو التسجيل' : 'Generate replay video' }}</button>
 </div>
 <div class="replay-stage-wrap">
  <canvas id="tournamentReplayCanvas" width="1280" height="720"></canvas>
  <video id="tournamentReplayVideo" controls class="hidden"></video>
 </div>
 <div id="replayStatus" class="mini-card">{{ $ar ? 'جاهز للتشغيل.' : 'Ready to play.' }}</div>
 <section class="replay-log-list">
  <h2>{{ $ar ? 'سجل الحركات' : 'Action log' }}</h2>
  @forelse($frames as $f)
   <div class="replay-log-row"><b>{{ $f['title'] }}</b><span>{{ $f['body'] }}</span><small>{{ $f['at'] }}</small></div>
  @empty <p class="muted">{{ $ar ? 'لا يوجد سجل حتى الآن.' : 'No replay log is available yet.' }}</p>@endforelse
 </section>
</div>
<script>
window.TOURNAMENT_REPLAY_FRAMES = @json($frames, JSON_UNESCAPED_UNICODE);
window.TOURNAMENT_FINAL_HANDS = @json($finalHands, JSON_UNESCAPED_UNICODE);
window.TOURNAMENT_REPLAY_TITLE = @json($replayTitle, JSON_UNESCAPED_UNICODE);
</script>
@endsection
