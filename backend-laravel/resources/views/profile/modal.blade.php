@php
$ar=app()->getLocale()==='ar';
$locale=$ar?'ar':'en';
$fallbackLocale=$ar?'en':'ar';
$profile=$user->profile; $wallet=$user->wallet; $mine=$user->id===auth()->id();
$xp=(int)($profile?->xp ?? 0); $level=(int)($profile?->level ?? 1); $next=app(\App\Services\Leveling\XpService::class)->requiredXp($level); $need=max(0,$next-$xp); $percent=$next?min(100,round(($xp/$next)*100)):0;
$code=safe_country_code($profile?->country_code ?? 'PS');
$relation=$relation ?? null;
$favoriteGame=\App\Models\Game::where('key',$profile?->favorite_game_key)->first();
$favoriteNames=$favoriteGame?->name ?? [];
$favoriteName=is_array($favoriteNames)
    ? ($favoriteNames[$locale] ?? $favoriteNames[$fallbackLocale] ?? ($profile?->favorite_game_key ?: ($ar?'غير محددة':'Not selected')))
    : ($profile?->favorite_game_key ?: ($ar?'غير محددة':'Not selected'));
$profileGradient=[];
if($profile?->active_profile_color && !($profile?->profile_color_expires_at && $profile->profile_color_expires_at->isPast())){
 $candidate=array_values(array_filter(explode('|',(string)$profile->active_profile_color),fn($c)=>preg_match('/^#[0-9a-fA-F]{6}$/',$c)));
 if(count($candidate)>=2) $profileGradient=array_slice($candidate,0,2);
}
$profileGradientStyle=count($profileGradient)>=2 ? '--profile-bg1:'.$profileGradient[0].';--profile-bg2:'.$profileGradient[1].';' : '';
@endphp
<div class="profile-modal-card compact-profile-card {{$mine ? 'profile-self-card' : 'profile-other-card'}} {{count($profileGradient)>=2 ? 'has-profile-gradient' : ''}}" style="{{$profileGradientStyle}}" dir="{{$ar?'rtl':'ltr'}}">
 <button type="button" class="modal-x" aria-label="{{$ar?'إغلاق الملف الشخصي':'Close profile'}}" onclick="document.getElementById('profileModal').classList.add('hidden')">×</button>
 <div class="profile-head">
  <img loading="lazy" decoding="async" class="avatar-lg" src="{{$profile?->avatar ?: '/assets/avatars/default.svg'}}" alt="{{$ar?'الصورة الشخصية':'Profile photo'}}">
  <div>
   <h2 style="color:{{$profile?->name_color ?: '#facc15'}}">{{$profile?->display_name ?: $user->username}}</h2>
   <div class="country-line">{!! flag_img($code,'flag-img flag-small') !!} <b>{{country_name($code)}}</b><a class="btn store-inventory-profile-link" href="{{ route('store') }}#inventory">🎒 {{$ar?'مشترياتي':'My purchases'}}</a></div>
   <small>{{$mine ? ($ar?'بروفايلك الشخصي':'Your profile') : ($ar?'لاعب في Warqna':'Player on Warqna')}}</small><div class="favorite-game-line-v112">🎮 {{$ar?'اللعبة المفضلة':'Favorite game'}}: <b>{{$favoriteName}}</b></div>
  </div>
 </div>
 <div class="profile-mini-grid"><div><b>{{$level}}</b><span>{{$ar?'المستوى':'Level'}}</span></div><div><b>{{number_format($profile?->wins ?? 0)}}</b><span>{{$ar?'فوز':'Wins'}}</span></div><div><b>{{number_format($profile?->games_played ?? 0)}}</b><span>{{$ar?'لعبة':'Games'}}</span></div><div><b>{{token_display($user)}}</b><span>{{$ar?'توكنز':'Tokens'}}</span></div></div>
 <div class="xp-box"><div class="xp-text">{{$ar?'يحتاج اللاعب':'Player needs'}} <b>{{number_format($need)}}</b> {{$ar?'نقطة XP للصعود للمستوى التالي':'XP to reach the next level'}}</div><div class="progress"><span style="width:{{$percent}}%"></span></div></div>
 <div class="profile-points-grid-v161">
  <div><b>{{number_format($profile?->round_points ?? 0)}}</b><span>{{$ar?'نقاط الجولات':'Round points'}}</span></div>
  <div><b>{{number_format($profile?->tournament_points ?? 0)}}</b><span>{{$ar?'نقاط المسابقات':'Tournament points'}}</span></div>
  <div><b>{{number_format($profile?->club_points ?? 0)}}</b><span>{{$ar?'نقاط النادي':'Club points'}}</span></div>
  <div><b>×{{($profile?->pasha_days ?? 0)>0?'2':'1'}}</b><span>{{$ar?'مضاعف الباشا':'Pasha multiplier'}}</span></div>
 </div>
 @if($mine)<div class="profile-self-details"><div><b>{{ number_format($profile?->xp ?? 0) }}</b><span>{{$ar?'XP الحالي':'Current XP'}}</span></div><div><b>{{ number_format($profile?->losses ?? 0) }}</b><span>{{$ar?'خسارة':'Losses'}}</span></div><div class="profile-pasha-days-v134"><img loading="lazy" decoding="async" src="/assets/store/basha1.png?v=36-luxury" alt="{{$ar?'باشا':'Pasha'}}"><b>{{ number_format($profile?->pasha_days ?? 0) }}</b><span>{{$ar?'أيام الباشا':'Pasha days'}}</span></div><div><b>{{ token_display($user) }}</b><span>{{$ar?'الرصيد':'Balance'}}</span></div></div>@endif
 <div class="active-items"><b>{{$ar?'المقتنيات المفعلة':'Active items'}}</b><div class="active-chip-row">@foreach($user->inventoryItems->where('active',true)->take($mine?12:6) as $inv)@php $itemNames=$inv->storeItem?->name ?? []; $itemName=is_array($itemNames)?($itemNames[$locale]??$itemNames[$fallbackLocale]??($ar?'مقتنى':'Item')):($ar?'مقتنى':'Item'); @endphp<span class="active-chip">{{$inv->storeItem?->payload['preview_icon'] ?? '✨'}} {{$itemName}}</span>@endforeach @if($user->inventoryItems->where('active',true)->count()===0)<span class="muted">{{$ar?'لا توجد مقتنيات مفعلة.':'No active items.'}}</span>@endif</div></div>
 <div class="profile-actions">
  @if($mine)
   <a class="btn primary" href="{{route('profile.show',$user)}}">{{$ar?'تعديل البروفايل':'Edit profile'}}</a><a class="btn" href="{{route('store')}}#inventory">{{$ar?'مشترياتي':'My purchases'}}</a><a class="btn" href="{{route('tokens')}}">{{$ar?'التوكنز':'Tokens'}}</a>
  @else
   @if($relation && $relation->status==='accepted')
    <button class="btn primary" onclick="setChatMode('friends');openChatThread({{$user->id}})">{{$ar?'رسالة':'Message'}}</button>
   @elseif($relation && $relation->status==='pending')
    <button class="btn" disabled>{{$ar?'تم إرسال الطلب':'Request sent'}}</button>
   @elseif($relation && $relation->status==='blocked')
    <button class="btn danger" disabled>{{$ar?'محظور':'Blocked'}}</button>
   @else
    <form method="post" action="{{route('friends.request',$user)}}" data-ajax-profile-action="1">@csrf<button class="btn primary" type="submit">{{$ar?'طلب صداقة':'Add friend'}}</button></form>
   @endif
   <form method="post" action="{{route('friends.block',$user)}}" data-confirm="{{$ar?'هل تريد حظر هذا اللاعب؟':'Block this player?'}}">@csrf<button class="btn danger" type="submit">{{$ar?'حظر':'Block'}}</button></form>
   <form class="inline-transfer" method="post" action="{{route('wallet.transfer')}}" data-confirm="{{$ar?'هل أنت متأكد من إرسال التوكنز؟ سيتم خصم عمولة 10%.':'Send these tokens? A 10% fee will be deducted.'}}">@csrf<input type="hidden" name="receiver" value="{{$user->username}}"><input name="amount" type="number" min="1" placeholder="{{$ar?'توكنز':'Tokens'}}"><button class="btn" type="submit">{{$ar?'إرسال توكنز':'Send tokens'}}</button></form>
  @endif
 </div>
</div>
