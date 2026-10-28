@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'تدقيق المحركات | ورقنا' : 'Engine Audit | Warqna')
@section('content')
@php
$ar=app()->isLocale('ar');
$ui=$ar ? [
 'title'=>'Engine Audit v124',
 'description'=>'فحص سريع لكل الألعاب: هل لها محرك؟ هل ترجع حالة لعب صالحة؟',
 'deep'=>'محركات عميقة',
 'fallback'=>'محركات fallback آمنة',
 'not_ready'=>'غير جاهز',
] : [
 'title'=>'Engine Audit v124',
 'description'=>'A fast audit of every game: does it have an engine, and does it return a valid playable state?',
 'deep'=>'Deep engines',
 'fallback'=>'Safe fallback engines',
 'not_ready'=>'Not ready',
];
@endphp
<section class="wz-audit-v124" dir="{{$ar?'rtl':'ltr'}}">
 <header><h1>🛡️ {{$ui['title']}}</h1><p>{{$ui['description']}}</p><p class="muted">{{$ui['deep']}}: {{ $score['deep_engines'] ?? 0 }} — {{$ui['fallback']}}: {{ $score['fallback_engines'] ?? 0 }}</p></header>
 <div class="audit-grid-v124">
 @foreach($rows as $r)
  <article class="audit-card-v124 {{ $r['ok'] ? 'ok' : 'bad' }}">
   <b>{{ $r['name'] }}</b>
   <span>{{ $r['key'] }}</span>
   <small>{{ $r['family'] }} • {{ $r['engine'] }}</small>
   <em>{{ $r['phase'] }} / {{ $r['turn'] }}</em>
   @if(!$r['ok'])<p>{{ $r['error'] ?? $ui['not_ready'] }}</p>@endif
  </article>
 @endforeach
 </div>
</section>
@endsection
