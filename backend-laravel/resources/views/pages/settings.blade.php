@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'الإعدادات' : 'Settings')
@section('content')
@php
$isAr=app()->getLocale()==='ar';
$countriesV134=config('countries',[]);
$ui=$isAr ? [
 'title'=>'الإعدادات','profile_photo'=>'الصورة الشخصية','avatar_alt'=>'الصورة الشخصية',
 'live_preview'=>'معاينة فورية قبل الحفظ','photo_help'=>'اختر صورة، عاينها فورًا بشكل دائري، ثم احفظها عند رضاك عن النتيجة.',
 'choose_photo'=>'اختيار صورة جديدة','save_photo'=>'حفظ الصورة','cancel_preview'=>'إلغاء المعاينة',
 'display_name'=>'الاسم المعروض','country'=>'الدولة','sound_enabled'=>'تشغيل أصوات اللعبة والإشعارات والرسائل',
 'site_theme'=>'ثيم الموقع','save'=>'حفظ الإعدادات','typography'=>'حجم الخط',
 'theme_locked'=>'الثيم مفروض من الإدارة ويظهر موحدًا لجميع اللاعبين.','theme_saving'=>'جارٍ حفظ الثيم…','theme_saved'=>'تم حفظ الثيم وتطبيقه على جميع الشاشات.','theme_error'=>'تعذر حفظ الثيم؛ تمت استعادة الاختيار السابق.',
 'typography_help'=>'تحكم سريع ومريح بحجم الخط في كل الموقع.','increase_font'=>'تكبير قوي','decrease_font'=>'تصغير',
 'audio'=>'الأصوات','audio_help'=>'تحكم كامل بالصوت من 0 إلى 100. استخدم الماوس أو أسهم لوحة المفاتيح.',
 'volume'=>'مستوى الصوت','mute_toggle'=>'كتم/تشغيل','test_win'=>'تجربة صوت الفوز','test_message'=>'تجربة صوت رسالة',
] : [
 'title'=>'Settings','profile_photo'=>'Profile photo','avatar_alt'=>'Profile photo',
 'live_preview'=>'Live preview before saving','photo_help'=>'Choose an image, preview it instantly in the circular frame, then save when you are satisfied.',
 'choose_photo'=>'Choose a new photo','save_photo'=>'Save photo','cancel_preview'=>'Cancel preview',
 'display_name'=>'Display name','country'=>'Country','sound_enabled'=>'Play game, notification and message sounds',
 'site_theme'=>'Site theme','save'=>'Save settings','typography'=>'Typography',
 'theme_locked'=>'The administrator has locked one theme for every player.','theme_saving'=>'Saving theme…','theme_saved'=>'Theme saved and applied across every screen.','theme_error'=>'The theme could not be saved; the previous choice was restored.',
 'typography_help'=>'Quickly adjust the text size across the entire website.','increase_font'=>'Increase text','decrease_font'=>'Decrease text',
 'audio'=>'Audio','audio_help'=>'Set volume from 0 to 100 using the pointer or keyboard arrow keys.',
 'volume'=>'Volume','mute_toggle'=>'Mute / unmute','test_win'=>'Test victory sound','test_message'=>'Test message sound',
];
$themes=[
 'dark'=>['label'=>$isAr?'ليلي':'Midnight','colors'=>['#07111e','#37b9cf']],
 'light'=>['label'=>$isAr?'عاجي':'Ivory','colors'=>['#fffdf8','#a7782c']],
 'green'=>['label'=>$isAr?'زمردي':'Emerald','colors'=>['#09271b','#48d597']],
 'gold'=>['label'=>$isAr?'ذهبي ملكي':'Royal Gold','colors'=>['#2c1c07','#ffd36b']],
 'purple'=>['label'=>$isAr?'مخملي':'Velvet','colors'=>['#2b153a','#d39bff']],
 'classic'=>['label'=>$isAr?'مجلس كلاسيكي':'Classic Majlis','colors'=>['#2a2116','#d6aa61']],
];
$globalTheme=class_exists('\\App\\Models\\SiteSetting') ? \App\Models\SiteSetting::getValue('default_theme','dark') : 'dark';
$forceGlobalTheme=class_exists('\\App\\Models\\SiteSetting') ? (bool) \App\Models\SiteSetting::getValue('force_global_theme',false) : false;
$profileTheme=auth()->user()->profile?->active_site_theme ?? 'dark';
$activeTheme=$forceGlobalTheme ? $globalTheme : $profileTheme;
@endphp
<div class="settings-page" dir="{{$isAr?'rtl':'ltr'}}">
 <h1>⚙️ {{ $ui['title'] }}</h1>
 @if($forceGlobalTheme)<p class="pro-card muted" role="status">🔒 {{ $ui['theme_locked'] }}</p>@endif
 <div class="pro-card settings-avatar-upload-v108">
  <h3>{{ $ui['profile_photo'] }}</h3>
  <div class="r101-avatar-editor">
   <div>
    <div class="r101-avatar-stage"><img id="r101AvatarPreview" class="settings-avatar-preview" src="{{ auth()->user()->profile?->avatar ?: '/assets/avatars/default.svg' }}" alt="{{ $ui['avatar_alt'] }}"></div>
    <p class="r101-preview-note">{{ $ui['live_preview'] }}</p>
   </div>
   <form method="post" action="{{ route('profile.update') }}" enctype="multipart/form-data">@csrf
    <p>{{ $ui['photo_help'] }}</p>
    <label class="avatar-file-label" for="r101AvatarInput">{{ $ui['choose_photo'] }}
     <input id="r101AvatarInput" type="file" name="avatar" accept="image/*">
    </label>
    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:10px">
     <button class="primary avatar-save-btn hidden" type="submit">{{ $ui['save_photo'] }}</button>
     <button id="r101AvatarReset" type="button">{{ $ui['cancel_preview'] }}</button>
    </div>
   </form>
  </div>
 </div>

 <form class="pro-card" method="post" action="{{route('settings.save')}}">@csrf
  <label for="settingsDisplayName">{{ $ui['display_name'] }}</label>
  <input id="settingsDisplayName" name="display_name" value="{{auth()->user()->profile?->display_name}}">
  <label for="settingsCountry">{{ $ui['country'] }}</label>
  <select id="settingsCountry" name="country_code" class="country-select-v134">
   @foreach($countriesV134 as $code=>$c)
    <option value="{{$code}}" {{(auth()->user()->profile?->country_code ?? 'PS')===$code?'selected':''}}>{{$c['flag']}} {{$isAr?$c['ar']:$c['en']}}</option>
   @endforeach
  </select>
  <label class="check-row"><input type="hidden" name="sound_enabled" value="0"><input type="checkbox" name="sound_enabled" value="1" {{auth()->user()->profile?->sound_enabled!==false?'checked':''}}> {{ $ui['sound_enabled'] }}</label>
  <label for="settingsSiteTheme">{{ $ui['site_theme'] }}</label>
  <select id="settingsSiteTheme" name="active_site_theme" {{$forceGlobalTheme?'disabled':''}} onchange="window.saveThemePreference?.(this.value)">
   @foreach($themes as $key=>$theme)
    <option value="{{$key}}" {{$activeTheme===$key?'selected':''}}>{{$theme['label']}}</option>
   @endforeach
  </select>
  <div class="r101-theme-swatches">
   @foreach($themes as $themeKey=>$theme)
    <button type="button" class="r101-theme-chip" data-theme-choice="{{$themeKey}}" aria-pressed="{{$activeTheme===$themeKey?'true':'false'}}" {{$forceGlobalTheme?'disabled':''}} onclick="window.saveThemePreference?.('{{$themeKey}}')"><i style="background:linear-gradient(135deg,{{$theme['colors'][0]}},{{$theme['colors'][1]}})"></i>{{$theme['label']}}</button>
   @endforeach
  </div>
  <p id="themePreferenceStatus" class="muted" role="status" aria-live="polite"></p>
  <button class="primary" type="submit">{{ $ui['save'] }}</button>
 </form>

 <div class="pro-card">
  <h3>{{ $ui['typography'] }}</h3>
  <p>{{ $ui['typography_help'] }}</p>
  <button type="button" onclick="changeFont(1);WarqnaSound?.ui()">{{ $ui['increase_font'] }}</button>
  <button type="button" onclick="changeFont(-1);WarqnaSound?.ui()">{{ $ui['decrease_font'] }}</button>
 </div>
 <div class="pro-card">
  <h3>{{ $ui['audio'] }}</h3>
  <p>{{ $ui['audio_help'] }}</p>
  <label class="sound-settings-range" for="settingsSoundRange">{{ $ui['volume'] }} <input id="settingsSoundRange" type="range" min="0" max="100" step="1" value="80"></label>
  <div class="sound-test-row">
   <button type="button" onclick="WarqnaSound?.toggleMute()">{{ $ui['mute_toggle'] }}</button>
   <button type="button" onclick="WarqnaSound?.play('win')">{{ $ui['test_win'] }}</button>
   <button type="button" onclick="WarqnaSound?.play('message')">{{ $ui['test_message'] }}</button>
  </div>
 </div>
</div>
<script>
(()=>{
 const themeUi=@json(['saving'=>$ui['theme_saving'],'saved'=>$ui['theme_saved'],'error'=>$ui['theme_error'],'locked'=>$ui['theme_locked']]);
 const syncThemeControls=(theme)=>{const select=document.getElementById('settingsSiteTheme');if(select&&!select.disabled)select.value=theme;document.querySelectorAll('[data-theme-choice]').forEach(button=>button.setAttribute('aria-pressed',button.dataset.themeChoice===theme?'true':'false'));};
 window.saveThemePreference=async(theme)=>{
  const status=document.getElementById('themePreferenceStatus'),previous=document.body?.dataset?.theme||'dark';
  if(!window.setSiteTheme?.(theme)){if(status)status.textContent=themeUi.locked;syncThemeControls(previous);return false;}
  syncThemeControls(theme);if(status)status.textContent=themeUi.saving;
  try{
   const response=await fetch(window.PREF_URL,{method:'POST',headers:{'X-CSRF-TOKEN':window.CSRF,'Accept':'application/json','Content-Type':'application/json','X-Requested-With':'XMLHttpRequest'},body:JSON.stringify({theme})});
   const payload=await response.json().catch(()=>({}));
   if(!response.ok||payload.ok===false)throw new Error('theme preference rejected');
   if(status)status.textContent=payload.message||themeUi.saved;
   return true;
  }catch(error){
   window.setSiteTheme?.(previous);syncThemeControls(previous);if(status)status.textContent=themeUi.error;return false;
  }
 };
 syncThemeControls(document.body?.dataset?.theme||'{{$activeTheme}}');
})();
(()=>{const input=document.getElementById('r101AvatarInput'),preview=document.getElementById('r101AvatarPreview'),reset=document.getElementById('r101AvatarReset');if(!input||!preview)return;const original=preview.src;let temp=null;input.addEventListener('change',()=>{const file=input.files?.[0];if(!file)return;if(temp)URL.revokeObjectURL(temp);temp=URL.createObjectURL(file);preview.src=temp;input.closest('form')?.querySelector('.avatar-save-btn')?.classList.remove('hidden');});reset?.addEventListener('click',()=>{input.value='';preview.src=original;if(temp){URL.revokeObjectURL(temp);temp=null;}input.closest('form')?.querySelector('.avatar-save-btn')?.classList.add('hidden');});})();
</script>
@endsection
