@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'تعديل الملف الشخصي' : 'Edit profile')
@section('content')
@php
$profile=$user->profile; $mine=$user->id===auth()->id(); $countries=config('countries'); $games=\App\Models\Game::where('active',true)->orderBy('id')->get(); $code=safe_country_code($profile?->country_code ?? 'PS');
$ar=app()->isLocale('ar'); $locale=$ar?'ar':'en'; $fallbackLocale=$ar?'en':'ar';
$profileGradient=[];
if($profile?->active_profile_color && !($profile?->profile_color_expires_at && $profile->profile_color_expires_at->isPast())){
 $candidate=array_values(array_filter(explode('|',(string)$profile->active_profile_color),fn($c)=>preg_match('/^#[0-9a-fA-F]{6}$/',$c)));
 if(count($candidate)>=2) $profileGradient=array_slice($candidate,0,2);
}
$profileGradientStyle=count($profileGradient)>=2 ? '--profile-bg1:'.$profileGradient[0].';--profile-bg2:'.$profileGradient[1].';' : '';
@endphp
<section class="profile-edit-page luxury-form-page" dir="{{$ar?'rtl':'ltr'}}">
 <div class="profile-edit-card {{count($profileGradient)>=2 ? 'has-profile-gradient' : ''}}" style="{{$profileGradientStyle}}">
  <h1>{{$ar?'تعديل الملف الشخصي':'Edit profile'}}</h1>
  <div class="profile-edit-preview">
   <img loading="lazy" decoding="async" class="avatar-lg" src="{{$profile?->avatar ?: '/assets/avatars/default.svg'}}" alt="{{$ar?'الصورة الشخصية':'Profile photo'}}">
   <div><h2>{{$profile?->display_name ?: $user->username}}</h2><div id="countryPreviewBig">{!! flag_img($code,'flag-img flag-small') !!} <b>{{country_name($code)}}</b></div></div>
  </div>
  @php $xp=(int)($profile?->xp ?? 0); $level=(int)($profile?->level ?? 1); $next=app(\App\Services\Leveling\XpService::class)->requiredXp($level); $need=max(0,$next-$xp); $percent=$next?min(100,round(($xp/$next)*100)):0; @endphp
  <div class="profile-progress-v161">
   <div class="xp-text"><b>{{$ar?'المستوى':'Level'}} {{$level}}</b><span>{{$xp}} / {{$next}} XP</span></div>
   <div class="progress"><span style="width:{{$percent}}%"></span></div>
   <small>{{$ar ? 'متبقٍ '.number_format($need).' XP للمستوى التالي • الباشا يضاعف نقاط الجولات ×2' : number_format($need).' XP remaining to the next level • Pasha doubles round points ×2'}}</small>
   <div class="profile-points-grid-v161"><div><b>{{number_format($profile?->round_points ?? 0)}}</b><span>{{$ar?'الجولات':'Rounds'}}</span></div><div><b>{{number_format($profile?->tournament_points ?? 0)}}</b><span>{{$ar?'المسابقات':'Tournaments'}}</span></div><div><b>{{number_format($profile?->club_points ?? 0)}}</b><span>{{$ar?'النادي':'Club'}}</span></div><div><b>{{number_format($profile?->pasha_days ?? 0)}}</b><span>{{$ar?'أيام الباشا':'Pasha days'}}</span></div></div>
  </div>

  <div class="profile-theme-box-v131">
   <h2>🎨 {{$ar?'الثيمات السريعة':'Quick themes'}}</h2>
   <p>{{$ar?'اختر الثيم ويتفعل مباشرة على الموقع.':'Choose a theme and apply it instantly across the website.'}}</p>
   <div class="profile-theme-grid-v131">
    <button type="button" data-theme-pick="royal">👑 {{$ar?'ملكي':'Royal'}}</button>
    <button type="button" data-theme-pick="midnight">🌙 {{$ar?'ليلي':'Midnight'}}</button>
    <button type="button" data-theme-pick="emerald">💎 {{$ar?'زمردي':'Emerald'}}</button>
    <button type="button" data-theme-pick="desert">🏜️ {{$ar?'صحراوي':'Desert'}}</button>
    <button type="button" data-theme-pick="galaxy">🌌 {{$ar?'مجرة':'Galaxy'}}</button>
    <button type="button" data-theme-pick="crimson">❤️ {{$ar?'قرمزي':'Crimson'}}</button>
    <button type="button" data-theme-pick="ocean">🌊 {{$ar?'محيطي':'Ocean'}}</button>
   </div>
  </div>

  @if($mine)
  <form method="post" action="{{route('profile.update')}}" enctype="multipart/form-data" class="profile-edit-form">@csrf
   <label>{{$ar?'الاسم الظاهر':'Display name'}}</label><input name="display_name" value="{{$profile?->display_name}}" placeholder="{{$ar?'اسمك داخل الموقع':'Your name across Warqnaa'}}">
   <label>{{$ar?'الدولة والعلم':'Country & flag'}}</label><select name="country_code" onchange="updateCountryPreview(this)">@foreach($countries as $cc=>$country)@php $countryName=is_array($country)?($country[$locale] ?? $country[$fallbackLocale] ?? $cc):$country; @endphp<option value="{{$cc}}" {{$cc===$code?'selected':''}} data-flag="{{flag_url($cc)}}" data-name="{{$countryName}}">{{$countryName}}</option>@endforeach</select><div class="country-preview" data-country-preview>{!! flag_img($code,'flag-img flag-small') !!} <b>{{country_name($code)}}</b></div>
   <label>{{$ar?'اللعبة المفضلة':'Favorite game'}}</label><select name="favorite_game_key"><option value="">{{$ar?'اختر لعبة':'Choose a game'}}</option>@foreach($games as $g)@php $gameName=$g->name[$locale] ?? $g->name[$fallbackLocale] ?? $g->key; @endphp<option value="{{$g->key}}" {{$profile?->favorite_game_key===$g->key?'selected':''}}>{{$gameName}}</option>@endforeach</select>
   <label>{{$ar?'الصورة الشخصية':'Profile photo'}}</label><input type="file" name="avatar" accept="image/*">
   <button class="btn primary big-save" type="submit">{{$ar?'حفظ التعديلات':'Save changes'}}</button>
  </form>
  <a class="btn" href="{{route('account.security')}}">🔐 {{$ar?'تغيير البريد وكلمة المرور من مركز الأمان':'Change email and password in the Security Center'}}</a>
  @endif
 </div>
</section>
@endsection

<script>
document.addEventListener('DOMContentLoaded',()=>{
 const input=document.querySelector('input[type=file][name=avatar],input[type=file][name=avatar_file]');
 const img=document.querySelector('.profile-edit-preview .avatar-lg,.profile-head .avatar-lg');
 if(input&&img) input.addEventListener('change',()=>{const f=input.files?.[0];if(!f)return;const u=URL.createObjectURL(f);img.src=u;img.id='warqnaAvatarPreview201';});
});
</script>
