@extends('layouts.app')
@section('content')
@php($ar=app()->getLocale()==='ar')
<style>
.r52-rewards{background:linear-gradient(145deg,#12659d,#082b51);color:#fff;border:1px solid #63e3fa;border-radius:22px;padding:clamp(16px,3vw,30px);margin:16px 0;box-shadow:0 10px 30px #06234444}
.r52-rewards h2{color:#ffe6a7;font-size:clamp(22px,3vw,30px)}.r52-prizes{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:12px}.r52-prize{border:1px solid #7cceec;border-radius:16px;background:#124e7a;padding:16px;text-align:center}.r52-prize strong{display:block;font-size:17px;line-height:1.5}.r52-prize small{display:block;color:#d7efff}.r52-icon{display:block;font-size:34px;margin-bottom:8px}.r52-rewards button{min-height:48px;font-size:16px;padding:10px 20px;margin:8px 4px;border-radius:14px}.r52-reward-result{animation:r52-reveal .5s ease-out;border:2px solid #ffd365}.r52-error{background:#651c30;padding:12px;border-radius:12px}.r52-rewards form{display:inline-block}@keyframes r52-reveal{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}@media(prefers-reduced-motion:reduce){.r52-reward-result{animation:none}}
</style>
@if(session('r52_reward'))
 <section class="r52-rewards r52-reward-result" role="status" aria-live="polite">
  <span class="r52-icon">{{ session('r52_reward.icon','🎁') }}</span>
  <h2>{{ $ar?'تمت إضافة جائزتك':'Your reward has been added' }}</h2>
  <p>{{ session('r52_reward.'.($ar?'label_ar':'label_en')) }}</p>
  @if(session('r52_reward.expires_at'))<small>{{ $ar?'صالحة حتى':'Valid until' }} {{ session('r52_reward.expires_at') }}</small>@endif
 </section>
@endif
<section class="r52-rewards" data-testid="r52-web-wheel">
 <h2>🎡 {{ $ar?'دولاب الحظ':'Lucky wheel' }}</h2>
 <p>{{ $ar?'12 خانة و8 أنواع من الجوائز داخل اللعبة. تدويرة مجانية كل 12 ساعة.':'12 segments and 8 types of in-game rewards. One free spin every 12 hours.' }}</p>
 @error('reward')<p class="r52-error" role="alert">{{ $message }}</p>@enderror
 <div class="r52-prizes">
 @foreach($wheel['segments'] as $segment)
  <div class="r52-prize"><span class="r52-icon">{{ $segment['icon'] }}</span><strong>{{ $segment[$ar?'label_ar':'label_en'] }}</strong><small>{{ $segment['reward']['duration_hours']?:($ar?'دائمة':'Permanent') }} {{ $segment['reward']['duration_hours']?($ar?'ساعة':'hours'):'' }}</small></div>
 @endforeach
 </div>
 <form method="post" action="{{ route('rewards.wheel') }}">@csrf<input type="hidden" name="source" value="free"><button class="primary" @disabled(!$wheel['free_available'])>{{ $ar?'تدوير مجاني':'Free spin' }}</button></form>
 <form method="post" action="{{ route('rewards.wheel') }}">@csrf<input type="hidden" name="source" value="tokens"><button @disabled($wheel['token_spins_remaining']===0)>{{ $ar?'تدوير مقابل 100 توكن':'Spin for 100 tokens' }} • {{ $wheel['token_spins_remaining'] }}/5</button></form>
 @unless($wheel['free_available'])<p>{{ $ar?'التدويرة المجانية التالية':'Next free spin' }}: <time datetime="{{ $wheel['next_free_at'] }}">{{ $wheel['next_free_at'] }}</time></p>@endunless
</section>
<section class="r52-rewards" data-testid="r52-web-boxes">
 <h2>🎁 {{ $ar?'صناديقي':'My prize boxes' }}</h2>
 <div class="r52-prizes">
 @forelse($boxes['boxes'] as $box)
  <div class="r52-prize"><span class="r52-icon">🎁</span><strong>{{ $box['box_key'] }}</strong>
   @if(empty($box['opened_at']))<form method="post" action="{{ route('rewards.box.open',$box['id']) }}">@csrf<button class="primary">{{ $ar?'افتح الصندوق':'Open box' }}</button></form>
   @else<small>{{ $ar?'تم فتحه':'Opened' }}</small>@endif
  </div>
 @empty<p>{{ $ar?'أكمل مباراة للحصول على صندوق مكافأة.':'Complete a match to earn a reward box.' }}</p>@endforelse
 </div>
</section>
<section class="rewards-hero-v118 pro-card">
 <h1>🎁 المكافآت اليومية</h1>
 <p>ادخل يوميًا للحصول على توكنز ومكافآت خاصة، وكلما زادت السلسلة زادت قيمة المكافأة.</p>
 @if($today)
  <div class="reward-claimed-v118">✅ استلمت مكافأة اليوم: {{ number_format($today->coins) }} توكنز</div>
 @else
  <form method="post" action="{{ route('rewards.claim') }}">@csrf<button class="primary big-btn">استلام مكافأة اليوم</button></form>
 @endif
</section>

<section class="pro-card">
 <h2>آخر المكافآت</h2>
 <div class="reward-grid-v118">
 @forelse($claims as $claim)
  <div class="reward-card-v118">
   <b>اليوم {{ $claim->streak }}</b>
   <span>🪙 {{ number_format($claim->coins) }}</span>
   <small>{{ $claim->claim_date?->format('Y-m-d') }}</small>
  </div>
 @empty
  <p class="muted">لا توجد مكافآت بعد.</p>
 @endforelse
 </div>
</section>
@endsection
