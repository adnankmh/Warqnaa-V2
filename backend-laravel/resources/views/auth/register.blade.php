@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'إنشاء حساب | ورقنا' : 'Create account | Warqnaa')
@section('content')
@php
$ar=app()->isLocale('ar');
$countries=config('countries',[]);
unset($countries['IL']);
$selectedCountry=old('country_code','PS');
@endphp
<section class="auth-page" dir="{{$ar?'rtl':'ltr'}}">
 <div class="auth-card">
  <h2>{{$ar?'تسجيل مستخدم جديد':'Create a new account'}}</h2>
  <p class="muted">{{$ar?'أنشئ حسابك باسم مستخدم فريد وبريد إلكتروني صالح.':'Create your account with a unique username and a valid email address.'}}</p>
  <form method="post" data-testid="registration-form">
   @csrf
   <label for="register-username">{{$ar?'اسم المستخدم':'Username'}}</label>
   <input id="register-username" name="username" value="{{old('username')}}" placeholder="{{$ar?'اسم مستخدم فريد':'Unique username'}}" autocomplete="username" required>
   <label for="register-email">{{$ar?'البريد الإلكتروني':'Email address'}}</label>
   <input id="register-email" name="email" type="email" value="{{old('email')}}" placeholder="{{$ar?'بريد إلكتروني صالح':'Valid email address'}}" autocomplete="email" required>
   <label for="register-country">{{$ar?'الدولة':'Country'}}</label>
   <div id="countryPreview" class="country-preview" aria-live="polite"></div>
   <select id="register-country" name="country_code" onchange="updateCountryPreview(this)" autocomplete="country" required>
    @foreach($countries as $code=>$name)
     @php
      $countryName=is_array($name)
       ? ($name[$ar?'ar':'en'] ?? $name[$ar?'en':'ar'] ?? $code)
       : $name;
      $countryLabel=is_array($name) ? trim(($name['flag'] ?? '').' '.$countryName) : $countryName;
     @endphp
     <option value="{{$code}}" data-flag="{{ flag_url($code) }}" {{$selectedCountry===$code?'selected':''}}>{{$countryLabel}} — {{$code}}</option>
    @endforeach
   </select>
   <label for="register-password">{{$ar?'كلمة المرور':'Password'}}</label>
   <input id="register-password" type="password" name="password" placeholder="{{$ar?'كلمة المرور':'Password'}}" autocomplete="new-password" required>
   <label for="register-password-confirmation">{{$ar?'تأكيد كلمة المرور':'Confirm password'}}</label>
   <input id="register-password-confirmation" type="password" name="password_confirmation" placeholder="{{$ar?'تأكيد كلمة المرور':'Confirm password'}}" autocomplete="new-password" required>
   <button class="btn primary" type="submit">{{$ar?'تسجيل':'Create account'}}</button>
  </form>
 </div>
</section>
@endsection
