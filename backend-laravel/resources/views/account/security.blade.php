@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'مركز أمان الحساب' : 'Account Security Center')
@section('content')
@php $ar=app()->isLocale('ar'); @endphp
<section class="profile-edit-page luxury-form-page" dir="{{$ar?'rtl':'ltr'}}">
 <div class="profile-edit-card">
  <h1>{{$ar?'مركز أمان الحساب':'Account Security Center'}}</h1>
  <p class="muted">{{$ar?'غيّر اسم المستخدم أو البريد الإلكتروني أو كلمة المرور بعد تأكيد كلمة المرور الحالية. تغيير كلمة المرور يغلق الجلسات الأخرى تلقائيًا.':'Change your username, email address or password after confirming your current password. Changing the password automatically signs out other sessions.'}}</p>
  <form method="post" action="{{route('account.security.update')}}" class="profile-edit-form">
   @csrf
   @method('PATCH')
   <label>{{$ar?'اسم المستخدم':'Username'}}</label>
   <input name="username" type="text" value="{{old('username',$user->username)}}" required minlength="3" maxlength="30" autocomplete="username">
   <label>{{$ar?'البريد الإلكتروني الجديد':'New email address'}}</label>
   <input name="email" type="email" value="{{old('email',$user->email)}}" required autocomplete="email">
   <label>{{$ar?'كلمة المرور الحالية':'Current password'}}</label>
   <input name="current_password" type="password" required autocomplete="current-password">
   <div class="two-cols">
    <div><label>{{$ar?'كلمة المرور الجديدة (اختياري)':'New password (optional)'}}</label><input name="password" type="password" minlength="10" autocomplete="new-password"></div>
    <div><label>{{$ar?'تأكيد كلمة المرور الجديدة':'Confirm new password'}}</label><input name="password_confirmation" type="password" minlength="10" autocomplete="new-password"></div>
   </div>
   <small>{{$ar?'عند تغيير البريد سيحتاج البريد الجديد إلى التحقق. كلمة المرور الجديدة يجب أن تضم 10 أحرف على الأقل وحرفًا كبيرًا وصغيرًا ورقمًا.':'A changed email address must be verified. A new password must contain at least 10 characters, uppercase and lowercase letters, and a number.'}}</small>
   <button class="btn primary big-save" type="submit">{{$ar?'حفظ تغييرات الأمان':'Save security changes'}}</button>
  </form>
 </div>
</section>
@endsection
