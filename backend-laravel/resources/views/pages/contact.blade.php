@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'التواصل والدعم' : 'Contact & Support')
@section('content')
@php $ar=app()->isLocale('ar'); @endphp
<section class="contact-page" dir="{{$ar?'rtl':'ltr'}}">
 <div class="search-hero">
  <h1>💬 {{$ar?'التواصل والدعم':'Contact & Support'}}</h1>
  <p>{{$ar?'أرسل تفاصيل المشكلة أو الاقتراح بوضوح، وسيصل الطلب إلى فريق الإدارة داخل المنصة.':'Describe your issue or suggestion clearly. Your request will be delivered to the platform administration team.'}}</p>
 </div>
 <form class="pro-card" method="post" action="{{route('contact.send')}}">
  @csrf
  <label for="contact-subject">{{$ar?'عنوان الرسالة':'Subject'}}</label>
  <input id="contact-subject" name="subject" value="{{old('subject')}}" maxlength="120" placeholder="{{$ar?'مثال: مشكلة في الغرفة أو الحساب':'Example: Room or account issue'}}" required>
  <label for="contact-message">{{$ar?'تفاصيل الرسالة':'Message details'}}</label>
  <textarea id="contact-message" name="message" maxlength="2000" placeholder="{{$ar?'اكتب رسالتك للدعم مع التفاصيل اللازمة':'Write your support message with the necessary details'}}" required>{{old('message')}}</textarea>
  <small>{{$ar?'لا ترسل كلمة المرور أو أي رموز سرية.':'Never include your password or any secret codes.'}}</small>
  <button class="primary">{{$ar?'إرسال للدعم':'Send to support'}}</button>
 </form>
</section>
@endsection
