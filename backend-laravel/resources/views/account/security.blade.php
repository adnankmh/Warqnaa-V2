@extends('layouts.app')
@section('content')
<section class="profile-edit-page luxury-form-page">
 <div class="profile-edit-card">
  <h1>مركز أمان الحساب</h1>
  <p class="muted">غيّر اسم المستخدم أو البريد الإلكتروني أو كلمة المرور بعد تأكيد كلمة المرور الحالية. تغيير كلمة المرور يغلق الجلسات الأخرى تلقائيًا.</p>
  <form method="post" action="{{route('account.security.update')}}" class="profile-edit-form">
   @csrf
   @method('PATCH')
   <label>اسم المستخدم</label>
   <input name="username" type="text" value="{{old('username',$user->username)}}" required minlength="3" maxlength="30" autocomplete="username">
   <label>البريد الإلكتروني الجديد</label>
   <input name="email" type="email" value="{{old('email',$user->email)}}" required autocomplete="email">
   <label>كلمة المرور الحالية</label>
   <input name="current_password" type="password" required autocomplete="current-password">
   <div class="two-cols">
    <div><label>كلمة المرور الجديدة (اختياري)</label><input name="password" type="password" minlength="10" autocomplete="new-password"></div>
    <div><label>تأكيد كلمة المرور الجديدة</label><input name="password_confirmation" type="password" minlength="10" autocomplete="new-password"></div>
   </div>
   <small>عند تغيير البريد سيحتاج البريد الجديد إلى التحقق. كلمة المرور الجديدة يجب أن تضم 10 أحرف على الأقل وحرفًا كبيرًا وصغيرًا ورقمًا.</small>
   <button class="btn primary big-save" type="submit">حفظ تغييرات الأمان</button>
  </form>
 </div>
</section>
@endsection
