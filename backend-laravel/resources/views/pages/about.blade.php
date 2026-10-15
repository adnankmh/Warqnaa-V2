@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'حول ورقنا' : 'About Warqna')
@section('content')
@php $ar=app()->isLocale('ar'); @endphp
<section class="about-page" dir="{{$ar?'rtl':'ltr'}}">
 <div class="pro-card">
  <h1>{{$ar?'حول ورقنا':'About Warqna'}}</h1>
  <p>{{$ar?'ورقنا منصة ألعاب ورق عربية متعددة اللاعبين، تجمع الغرف والنوادي والمسابقات والمتجر والدردشة ونظام المستويات في تجربة حديثة.':'Warqna is a multiplayer Arabic card-game platform that brings rooms, clubs, competitions, the store, chat and progression together in one modern experience.'}}</p>
  <p class="muted">{{$ar?'صُممت الواجهة لدعم العربية من اليمين إلى اليسار والإنجليزية من اليسار إلى اليمين عبر الويب والتطبيق.':'The experience supports Arabic right-to-left and English left-to-right across Web and the app.'}}</p>
  <a class="btn primary" href="{{route('games')}}">{{$ar?'استعراض الألعاب':'Browse games'}}</a>
  <a class="btn" href="{{route('contact')}}">{{$ar?'التواصل مع الدعم':'Contact support'}}</a>
 </div>
</section>
@endsection
