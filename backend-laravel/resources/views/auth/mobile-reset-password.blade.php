@php
  $ar = app()->isLocale('ar');
  $title = $ar ? 'إعادة تعيين كلمة المرور' : 'Reset password';
@endphp
<!doctype html>
<html lang="{{ $ar ? 'ar' : 'en' }}" dir="{{ $ar ? 'rtl' : 'ltr' }}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>{{ $title }} | Warqna</title>
  <style>
    *{box-sizing:border-box}
    body{margin:0;min-height:100vh;display:grid;place-items:center;background:radial-gradient(circle at 80% 0,#18385a,#071421 55%,#02070d);font-family:Arial,sans-serif;color:#f8fafc;padding:18px}
    .card{width:min(460px,100%);background:rgba(12,29,45,.96);border:1px solid rgba(255,255,255,.12);border-radius:28px;padding:26px;box-shadow:0 30px 90px rgba(0,0,0,.45)}
    h1{margin:0 0 8px;font-size:clamp(26px,6vw,32px)}
    .sub{color:#b4c4d4;line-height:1.7;margin-bottom:20px}
    label{display:block;font-weight:800;margin:14px 0 7px}
    input{width:100%;height:52px;border-radius:15px;border:1px solid #47647f;background:#0b1d2e;color:white;padding:0 14px;font-size:16px;outline:none}
    input:focus{border-color:#f9c85c;box-shadow:0 0 0 3px rgba(249,200,92,.12)}
    button{width:100%;min-height:54px;margin-top:20px;border:0;border-radius:16px;background:linear-gradient(135deg,#ffd36d,#e7a633);font-size:17px;font-weight:900;color:#15100a;cursor:pointer;padding:12px}
    .msg{padding:12px;border-radius:14px;margin-bottom:14px;line-height:1.6}
    .ok{background:rgba(34,197,94,.14);border:1px solid rgba(34,197,94,.35)}
    .bad{background:rgba(239,68,68,.14);border:1px solid rgba(239,68,68,.35)}
    .brand{text-align:center;color:#f9c85c;font-weight:900;letter-spacing:3px;margin-bottom:18px}
    .back{display:block;text-align:center;margin-top:18px;color:#91e8ff;font-weight:800;text-decoration:none}
    .back:focus-visible{outline:3px solid #f9c85c;outline-offset:4px;border-radius:6px}
    @media (max-height:540px) and (orientation:landscape){body{place-items:start center}.card{padding:20px 24px}h1{font-size:25px}.sub{margin-bottom:12px}label{margin-top:9px}input{height:46px}button{margin-top:14px}}
  </style>
</head>
<body>
  <main class="card">
    <div class="brand" aria-label="Warqna">WARQNA</div>
    <h1>{{ $title }}</h1>
    <p class="sub">{{ $ar
      ? 'أدخل كلمة مرور جديدة قوية لحسابك. بعد نجاح العملية ستُغلق رموز الدخول القديمة لحماية الحساب.'
      : 'Choose a strong new password. After a successful reset, existing access tokens will be revoked to protect your account.' }}</p>
    @if(session('success'))<div class="msg ok" role="status">{{ session('success') }}</div>@endif
    @if(session('error'))<div class="msg bad" role="alert">{{ session('error') }}</div>@endif
    @if($errors->any())<div class="msg bad" role="alert">{{ $errors->first() }}</div>@endif
    <form method="post" action="{{ route('password.reset.web') }}">
      @csrf
      <input type="hidden" name="token" value="{{ $token }}">
      <label for="reset-email">{{ $ar ? 'البريد الإلكتروني' : 'Email address' }}</label>
      <input id="reset-email" type="email" name="email" value="{{ old('email',$email) }}" required autocomplete="email" inputmode="email" dir="ltr">
      <label for="reset-password">{{ $ar ? 'كلمة المرور الجديدة' : 'New password' }}</label>
      <input id="reset-password" type="password" name="password" required minlength="8" maxlength="120" autocomplete="new-password">
      <label for="reset-password-confirmation">{{ $ar ? 'تأكيد كلمة المرور' : 'Confirm new password' }}</label>
      <input id="reset-password-confirmation" type="password" name="password_confirmation" required minlength="8" maxlength="120" autocomplete="new-password">
      <button type="submit">{{ $ar ? 'حفظ كلمة المرور الجديدة' : 'Save new password' }}</button>
    </form>
    <a class="back" href="{{ route('login') }}">{{ $ar ? 'العودة إلى تسجيل الدخول' : 'Back to sign in' }}</a>
  </main>
</body>
</html>
