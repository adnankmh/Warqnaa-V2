@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'تسجيل الدخول | ورقنا' : 'Sign in | Warqnaa')
@section('content')
@php $ar=app()->isLocale('ar'); @endphp
<section class="auth-page" dir="{{$ar?'rtl':'ltr'}}">
 <div class="auth-card">
  <h2>{{$ar?'تسجيل الدخول':'Sign in'}}</h2>
  <p class="muted">{{$ar?'استخدم اسم المستخدم أو البريد الإلكتروني للدخول إلى حسابك.':'Use your username or email address to access your account.'}}</p>
  <form method="post" data-testid="login-form">
   @csrf
   <label for="login-identifier">{{$ar?'اسم المستخدم أو البريد الإلكتروني':'Username or email address'}}</label>
   <input id="login-identifier" name="login" value="{{old('login')}}" placeholder="{{$ar?'اسم المستخدم أو البريد الإلكتروني':'Username or email'}}" autocomplete="username" required>
   <div class="auth-hint">{{$ar?'يمكنك الدخول باسم المستخدم أو البريد الإلكتروني. اسم مستخدم الإدارة:':'You can sign in with either identifier. Administration username:'}} <b>Adnan</b></div>
   <label for="login-password">{{$ar?'كلمة المرور':'Password'}}</label>
   <input id="login-password" type="password" name="password" placeholder="{{$ar?'كلمة المرور':'Password'}}" autocomplete="current-password" required>
   <button class="btn primary" type="submit">{{$ar?'دخول':'Sign in'}}</button>
  </form>
  <a href="{{route('register')}}">{{$ar?'إنشاء حساب جديد':'Create a new account'}}</a>
 </div>
</section>
@endsection
