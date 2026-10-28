@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'قوانين الألعاب | ورقنا' : 'Game Rules | Warqnaa')
@section('content')
@php
$locale = app()->getLocale();
$ar = $locale === 'ar';
@endphp
<div class="game-rules-page" dir="{{ $ar ? 'rtl' : 'ltr' }}">
 <div class="rules-hero">
  <h1>📜 {{ $ar ? 'قوانين الألعاب' : 'Game rules' }}</h1>
  <p>{{ $ar ? 'صفحة مستقلة لكل قواعد الألعاب؛ لم تعد القوانين تظهر داخل الغرفة حتى تبقى الطاولة نظيفة ومركزة على اللعب.' : 'A dedicated rules page keeps every table clean and focused on play while the full guides remain easy to reach.' }}</p>
 </div>
 <div class="rules-list">
 @foreach($games as $game)
  @php
   $gameName = $game->name[$locale] ?? $game->name['ar'] ?? $game->key;
   $guide = $ruleGuide[$game->key] ?? $ruleGuide[str_replace(['_partner','_400','_41'],['','',''],$game->key)] ?? null;
   $rawSummary = $game->rules['text'] ?? $game->rules['summary'] ?? null;
   $fallbackSummary = is_array($rawSummary) ? ($rawSummary[$locale] ?? $rawSummary['ar'] ?? null) : $rawSummary;
   $summary = $guide ? ($ar ? $guide['summary'] : ($guide['summary_en'] ?? $guide['summary'])) : ($fallbackSummary ?? ($ar ? 'قواعد قابلة للتوسعة.' : 'Professional game rules.'));
   $coreRules = $guide ? ($ar ? ($guide['core'] ?? []) : ($guide['core_en'] ?? $guide['core'] ?? [])) : [];
  @endphp
  <article class="rule-card" id="game-{{$game->key}}">
   <h2>{{ $gameName }} <small>{{ $ar ? ($game->name['en'] ?? '') : ($game->name['ar'] ?? '') }}</small></h2>
   <div class="rule-meta">
    <span>{{$game->min_players}}-{{$game->max_players}} {{ $ar ? 'لاعبين' : 'players' }}</span>
    <span>{{ $game->partnership ? ($ar ? 'شراكة' : 'Partnership') : ($ar ? 'فردي' : 'Individual') }}</span>
   </div>
   <p>{{ $summary }}</p>
   @if($guide)
    <div class="rule-card-collapsed-v136"><ul class="core-rule-list">@foreach($coreRules as $r)<li>{{$r}}</li>@endforeach</ul></div>
    <details class="rule-readmore-v136"><summary>{{ $ar ? 'اقرأ المزيد عن قوانين' : 'Read more about' }} {{ $gameName }}</summary><ul class="core-rule-list expanded">@foreach($coreRules as $r)<li>{{$r}}</li>@endforeach</ul></details>
   @endif
   @if(!empty($game->rules['translations']))
    <details class="rule-translations"><summary>{{ $ar ? 'الترجمات المتاحة' : 'Available translations' }}</summary>@foreach($game->rules['translations'] as $lang=>$txt)<div><b>{{strtoupper($lang)}}:</b> {{$txt}}</div>@endforeach</details>
   @endif
   <a class="btn primary" href="{{route('rooms.index',$game->key)}}">{{ $ar ? 'دخول غرف اللعبة' : 'Enter game rooms' }}</a>
  </article>
 @endforeach
 </div>
</div>
@endsection
