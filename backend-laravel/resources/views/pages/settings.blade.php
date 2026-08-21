@extends('layouts.app')
@section('content')
<div class="settings-page"><h1>⚙️ الإعدادات</h1>
@php($countriesV134=config('countries',[]))
<div class="pro-card settings-avatar-upload-v108">
 <h3>{{ app()->getLocale()==='ar' ? 'الصورة الشخصية' : 'Profile photo' }}</h3>
 <div class="r101-avatar-editor">
  <div>
   <div class="r101-avatar-stage"><img id="r101AvatarPreview" class="settings-avatar-preview" src="{{ auth()->user()->profile?->avatar ?: '/assets/avatars/default.svg' }}" alt="avatar"></div>
   <p class="r101-preview-note">{{ app()->getLocale()==='ar' ? 'معاينة فورية قبل الحفظ' : 'Live preview before saving' }}</p>
  </div>
  <form method="post" action="{{ route('profile.update') }}" enctype="multipart/form-data">@csrf
   <p>{{ app()->getLocale()==='ar' ? 'اختر صورة، عاينها فورًا بشكل دائري، ثم احفظها عند رضاك عن النتيجة.' : 'Choose an image, preview it instantly in the circular frame, then save when you are satisfied.' }}</p>
   <label class="avatar-file-label">{{ app()->getLocale()==='ar' ? 'اختيار صورة جديدة' : 'Choose a new photo' }}
    <input id="r101AvatarInput" type="file" name="avatar" accept="image/*">
   </label>
   <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:10px">
    <button class="primary avatar-save-btn hidden" type="submit">{{ app()->getLocale()==='ar' ? 'حفظ الصورة' : 'Save photo' }}</button>
    <button id="r101AvatarReset" type="button">{{ app()->getLocale()==='ar' ? 'إلغاء المعاينة' : 'Cancel preview' }}</button>
   </div>
  </form>
 </div>
</div>
<form class="pro-card" method="post" action="{{route('settings.save')}}">@csrf
<label>الاسم المعروض</label><input name="display_name" value="{{auth()->user()->profile?->display_name}}">
<label>الدولة</label>
<select name="country_code" class="country-select-v134">
 @foreach($countriesV134 as $code=>$c)
  <option value="{{$code}}" {{(auth()->user()->profile?->country_code ?? 'PS')===$code?'selected':''}}>{{$c['flag']}} {{$c['ar']}} — {{$c['en']}}</option>
 @endforeach
</select>
<label class="check-row"><input type="hidden" name="sound_enabled" value="0"><input type="checkbox" name="sound_enabled" value="1" {{auth()->user()->profile?->sound_enabled!==false?'checked':''}}> تشغيل أصوات اللعبة والإشعارات والرسائل</label>
<label>ثيم الموقع</label>
<select name="active_site_theme" onchange="window.setSiteTheme?.(this.value);fetch(window.PREF_URL,{method:'POST',headers:{'X-CSRF-TOKEN':window.CSRF,'Accept':'application/json','Content-Type':'application/json','X-Requested-With':'XMLHttpRequest'},body:JSON.stringify({theme:this.value})}).catch(()=>{});WarqnaSound?.ui()">
 @foreach(['dark'=>(app()->getLocale()==='ar'?'ليلي':'Midnight'),'light'=>(app()->getLocale()==='ar'?'عاجي':'Ivory'),'green'=>(app()->getLocale()==='ar'?'زمردي':'Emerald'),'gold'=>(app()->getLocale()==='ar'?'ذهبي ملكي':'Royal Gold'),'purple'=>(app()->getLocale()==='ar'?'مخملي':'Velvet'),'classic'=>(app()->getLocale()==='ar'?'مجلس كلاسيكي':'Classic Majlis')] as $key=>$label)
  <option value="{{$key}}" {{(auth()->user()->profile?->active_site_theme ?? 'dark')===$key?'selected':''}}>{{$label}}</option>
 @endforeach
</select>
<div class="r101-theme-swatches">
 @foreach(['dark'=>['#07111e','#37b9cf'],'light'=>['#fffdf8','#a7782c'],'green'=>['#09271b','#48d597'],'gold'=>['#2c1c07','#ffd36b'],'purple'=>['#2b153a','#d39bff'],'classic'=>['#2a2116','#d6aa61']] as $themeKey=>$swatch)
 <button type="button" class="r101-theme-chip" onclick="window.setSiteTheme?.('{{$themeKey}}');document.querySelector('select[name=active_site_theme]').value='{{$themeKey}}'"><i style="background:linear-gradient(135deg,{{$swatch[0]}},{{$swatch[1]}})"></i>{{$themeKey}}</button>
 @endforeach
</div>
<button class="primary">حفظ</button></form>
<div class="pro-card"><h3>تكبير الخط</h3><p>تحكم سريع ومريح بحجم الخط في كل الموقع.</p><button onclick="changeFont(1);WarqnaSound?.ui()">تكبير قوي</button><button onclick="changeFont(-1);WarqnaSound?.ui()">تصغير</button></div>
<div class="pro-card"><h3>الأصوات</h3><p>تحكم كامل بالصوت من 0 إلى 100. استخدم الماوس أو أسهم الكيبورد ↑ ↓.</p><label class="sound-settings-range">مستوى الصوت <input id="settingsSoundRange" type="range" min="0" max="100" step="1" value="80"></label><div class="sound-test-row"><button type="button" onclick="WarqnaSound?.toggleMute()">كتم/تشغيل</button><button type="button" onclick="WarqnaSound?.play('win')">تجربة صوت الفوز</button><button type="button" onclick="WarqnaSound?.play('message')">تجربة صوت رسالة</button></div></div>
</div>
<script>
(()=>{const input=document.getElementById('r101AvatarInput'),preview=document.getElementById('r101AvatarPreview'),reset=document.getElementById('r101AvatarReset');if(!input||!preview)return;const original=preview.src;let temp=null;input.addEventListener('change',()=>{const file=input.files?.[0];if(!file)return;if(temp)URL.revokeObjectURL(temp);temp=URL.createObjectURL(file);preview.src=temp;input.closest('form')?.querySelector('.avatar-save-btn')?.classList.remove('hidden');});reset?.addEventListener('click',()=>{input.value='';preview.src=original;if(temp){URL.revokeObjectURL(temp);temp=null;}input.closest('form')?.querySelector('.avatar-save-btn')?.classList.add('hidden');});})();
</script>
@endsection
