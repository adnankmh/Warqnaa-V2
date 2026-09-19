@extends('layouts.app')
@section('title', 'Operations | Warqnaa')
@section('content')
@php
$ar = app()->getLocale() === 'ar';
$labels = $ar ? ['database'=>'قاعدة البيانات','cache'=>'التخزين المؤقت','schema'=>'الجداول الأساسية','scheduler'=>'جدولة المهام','release_config'=>'تطابق الإصدار','https'=>'اتصال HTTPS','debug_disabled'=>'إيقاف عرض أخطاء التطوير'] : ['database'=>'Database','cache'=>'Cache','schema'=>'Core tables','scheduler'=>'Scheduler','release_config'=>'Release configuration','https'=>'HTTPS','debug_disabled'=>'Debug disabled'];
$metrics = $ar ? ['active_rooms'=>'الغرف النشطة','ranked_waiting'=>'بانتظار المنافسة','open_reports'=>'البلاغات المفتوحة','economy_reviews'=>'مراجعات الاقتصاد'] : ['active_rooms'=>'Active rooms','ranked_waiting'=>'Ranked waiting','open_reports'=>'Open reports','economy_reviews'=>'Economy reviews'];
@endphp
<style>
.ops{max-width:1200px;margin:auto;padding:20px}.ops-hero{padding:28px;border:1px solid #cbaa6544;border-radius:24px;background:linear-gradient(120deg,#163b2e,#171c24)}.ops-hero h1{margin:8px 0;color:#f3d28a}.ops-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:12px;margin:18px 0}.ops-card{padding:20px;border:1px solid #ffffff22;border-radius:18px;background:#17231e}.ops-card b{display:block;font-size:30px;margin-top:8px}.ops-state{display:flex;justify-content:space-between;gap:16px;align-items:center}.ops-pass{color:#86efac}.ops-warn{color:#fcd34d}.ops-note{padding:16px;border-inline-start:3px solid #d8ad3f;line-height:1.8}.ops a:focus-visible{outline:3px solid #fcd34d;outline-offset:4px}
</style>
<div class="ops" dir="{{ $ar ? 'rtl' : 'ltr' }}">
<header class="ops-hero"><small>WARQNAA · {{ $report['release'] }}</small><h1>{{ $ar ? 'مركز التشغيل والجاهزية' : 'Operations & readiness' }}</h1><p>{{ $ar ? 'حالة فعلية من الخادم، مع تمييز الفحوص التي تحتاج متابعة.' : 'Live server status with checks that need attention.' }}</p><a href="{{ route('admin.operations') }}">{{ $ar ? 'تحديث الحالة' : 'Refresh status' }}</a> · <a href="{{ route('admin') }}">{{ $ar ? 'لوحة الإدارة' : 'Admin dashboard' }}</a></header>
<div class="ops-grid">@foreach($metrics as $key=>$label)<section class="ops-card"><span>{{ $label }}</span><b>{{ $report['counts'][$key] ?? '—' }}</b></section>@endforeach</div>
<div class="ops-grid">@foreach($labels as $key=>$label)<section class="ops-card ops-state"><span>{{ $label }}</span><strong class="{{ $report['checks'][$key] ? 'ops-pass' : 'ops-warn' }}">{{ $report['checks'][$key] ? ($ar ? 'سليم' : 'OK') : ($ar ? 'يحتاج متابعة' : 'Check needed') }}</strong></section>@endforeach</div>
<p class="ops-note">{{ $ar ? 'في التشغيل المحلي يكون HTTP ووضع التطوير طبيعيين. قبل النشر العام يلزم HTTPS وإيقاف وضع التطوير. تظهر الجدولة سليمة فقط بعد تسجيل تشغيل فعلي خلال آخر ثلاث دقائق.' : 'HTTP and debug mode are expected locally. Public deployment requires HTTPS and debug disabled. Scheduler health requires a recorded run within the last three minutes.' }}</p>
<p>{{ $ar ? 'آخر تحديث:' : 'Updated:' }} <time>{{ $report['generated_at'] }}</time></p>
</div>
@endsection
