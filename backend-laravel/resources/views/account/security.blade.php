@extends('layouts.app')
@section('content')
<section class="r142-security-shell" aria-labelledby="r142-security-title">
 <header class="r142-security-hero">
  <div class="r142-security-emblem" aria-hidden="true">⌾</div>
  <div>
   <span class="r142-eyebrow">R14.2 • SECURE ACCOUNT</span>
   <h1 id="r142-security-title">أمان الحساب وبيانات الدخول</h1>
   <p>غيّر بريدك أو كلمة مرورك بأمان. كل تغيير حساس يحتاج كلمة المرور الحالية ويغلق جلسات التطبيق الأخرى.</p>
  </div>
  <div class="r142-security-state">
   <span class="{{$user->email_verified_at ? 'is-verified' : 'is-pending'}}">{{$user->email_verified_at ? '✓ البريد مؤكّد' : '◷ بانتظار تأكيد البريد'}}</span>
   <small>{{$activeSessions}} جلسة نشطة</small>
  </div>
 </header>

 @if(session('ok'))<div class="r142-security-message success" role="status">{{session('ok')}}</div>@endif
 @if($errors->any())<div class="r142-security-message error" role="alert"><b>لم يتم حفظ التغيير:</b><ul>@foreach($errors->all() as $error)<li>{{$error}}</li>@endforeach</ul></div>@endif

 <div class="r142-security-grid">
  <article class="r142-security-card">
   <div class="r142-security-card-head"><span>✉</span><div><h2>تغيير البريد الإلكتروني</h2><p>البريد الحالي: <b dir="ltr">{{$user->email}}</b></p></div></div>
   <form method="post" action="{{route('account.security.email')}}" class="r142-security-form">@csrf
    <label for="r142-email">البريد الإلكتروني الجديد</label>
    <input id="r142-email" type="email" name="email" value="{{old('email')}}" required autocomplete="email" dir="ltr" placeholder="name@example.com">
    <label for="r142-email-current">كلمة المرور الحالية للتأكيد</label>
    <input id="r142-email-current" type="password" name="current_password" required autocomplete="current-password">
    <p class="r142-security-hint">بعد التغيير يصبح البريد غير مؤكّد حتى تفتح رابط التحقق المرسل إليه.</p>
    <button class="btn primary r142-security-submit" type="submit">حفظ البريد الجديد</button>
   </form>
  </article>

  <article class="r142-security-card">
   <div class="r142-security-card-head"><span>⚿</span><div><h2>تغيير كلمة المرور</h2><p>حماية موحّدة للموقع والتطبيق وحساب المدير.</p></div></div>
   <form method="post" action="{{route('account.security.password')}}" class="r142-security-form">@csrf
    <label for="r142-password-current">كلمة المرور الحالية</label>
    <input id="r142-password-current" type="password" name="current_password" required autocomplete="current-password">
    <label for="r142-password">كلمة المرور الجديدة</label>
    <input id="r142-password" type="password" name="password" required minlength="8" maxlength="120" autocomplete="new-password">
    <label for="r142-password-confirmation">تأكيد كلمة المرور الجديدة</label>
    <input id="r142-password-confirmation" type="password" name="password_confirmation" required minlength="8" maxlength="120" autocomplete="new-password">
    <p class="r142-security-hint">8 أحرف على الأقل، وتشمل حرفًا كبيرًا وصغيرًا ورقمًا. لا تُرسل كلمة المرور في السجلات أو رسائل البريد.</p>
    <button class="btn primary r142-security-submit" type="submit">تغيير كلمة المرور</button>
   </form>
  </article>
 </div>

 @if($user->is_admin)
 <aside class="r142-admin-security-note"><b>حساب مدير محمي:</b> تغيير بيانات الدخول لا يزيل صلاحيات {{ $user->isPrimaryAdmin() ? 'Adnan المدير الرئيسي' : 'Abd المدير المفوّض' }} ولا يعيدها Seeder إلى القيم الافتراضية.</aside>
 @endif
</section>
@endsection
