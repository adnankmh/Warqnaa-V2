@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'مكتبة الألعاب | ورقنا' : 'Game Library | Warqnaa')
@section('content')
@php
$locale = app()->getLocale();
$ar = $locale === 'ar';
$difficultyLabels = [
 'medium' => $ar ? 'متوسط' : 'Medium',
 'advanced' => $ar ? 'متقدم' : 'Advanced',
 'expert' => $ar ? 'خبير' : 'Expert',
];
@endphp
<div class="game-library-pro-page" dir="{{ $ar ? 'rtl' : 'ltr' }}">
<section class="pro-hero-v118">
 <div>
  <h1>🎮 {{ $ar ? 'مكتبة ألعاب Warqnaa الاحترافية' : 'Warqnaa professional game library' }}</h1>
  <p>{{ $ar ? 'منصة ألعاب ورق ورقعة اجتماعية، مبنية بمحركات عائلات: اللمّات، التجميع، العقود، الرقعة والنرد.' : 'A social card and board-game platform organized around trick-taking, melding, contract, board and dice engines.' }}</p>
 </div>
 <a class="btn primary" href="{{ route('games') }}">{{ $ar ? 'فتح كل الألعاب' : 'Open all games' }}</a>
</section>

@foreach($matrix['families'] as $familyKey=>$family)
<section class="pro-card family-section-v118">
 <h2>{{ $family[$locale] ?? $family['ar'] ?? $familyKey }}</h2>
 <div class="game-family-grid-v118">
  @foreach($family['games'] as $gk)
   @php
    $g = $matrix['supported'][$gk] ?? null;
    $gameName = $g ? ($g[$locale] ?? $g['ar'] ?? $gk) : $gk;
   @endphp
   @if($g)
    <article class="game-pro-card-v118 difficulty-{{ $g['difficulty'] }}">
     <div class="game-pro-icon-v118">🃏</div>
     <h3>{{ $gameName }}</h3>
     <p>{{ $ar ? 'المحرك' : 'Engine' }}: <b>{{ $g['engine'] }}</b></p>
     <p>{{ $ar ? 'عدد اللاعبين' : 'Players' }}: {{ $g['players'] }}</p>
     <span class="difficulty-pill">{{ $difficultyLabels[$g['difficulty']] ?? $g['difficulty'] }}</span>
     <a class="btn" href="{{ route('rooms.index',$gk) }}">{{ $ar ? 'دخول اللعبة' : 'Enter game' }}</a>
    </article>
   @endif
  @endforeach
 </div>
</section>
@endforeach

<section class="pro-card">
 <h2>🛡️ {{ $ar ? 'مبادئ الحماية' : 'Protection principles' }}</h2>
 <ul class="core-rule-list">
  @if($ar)
   <li>السيرفر هو الحكم الوحيد للحركات والنتائج.</li>
   <li>لا يتم إرسال أوراق الخصوم إلى اللاعب.</li>
   <li>يتم رفض الحركة غير القانونية وتسجيلها في مراقبة الغش.</li>
   <li>دعم لعب النظام مؤقتًا عند انقطاع اللاعب حتى 3 لفات.</li>
  @else
   <li>The server is the sole authority for actions and results.</li>
   <li>Opponents’ hidden cards are never sent to the player.</li>
   <li>Illegal actions are rejected and recorded for anti-cheat monitoring.</li>
   <li>Temporary system play may cover a disconnected player for up to three turns.</li>
  @endif
 </ul>
</section>
</div>
@endsection
