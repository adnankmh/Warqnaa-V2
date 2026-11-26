@extends('layouts.app')
@section('title','Warqnaa | Visual Studio')
@section('content')
@php
$ar=app()->getLocale()==='ar';
$tr=fn($a,$b)=>$ar?$a:$b;
@endphp
<style>
.ws{color:#eaf4ff;background:#071a36;border:1px solid #315b87;border-radius:22px;padding:clamp(12px,3vw,28px);font:inherit}
.ws a{color:#a8ddff!important}.ws h1,.ws h2{color:#fff}.ws p{color:#bdd3ed}.ws-grid{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr);gap:18px;align-items:start}
.ws-panel{background:#102c50;border:1px solid #315b87;border-radius:16px;padding:16px;min-width:0}.ws-fields{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,155px),1fr));gap:12px}
.ws label{display:grid;gap:6px;min-width:0;color:#eaf4ff}.ws input[type=color]{width:100%;height:44px;padding:4px;background:#173c66;border:1px solid #7ba9d6;border-radius:8px}.ws input[type=range]{width:100%;accent-color:#60baff}
.ws select{color:#fff;background:#173c66;border:1px solid #7ba9d6;padding:8px;border-radius:8px}.ws-actions{display:flex;flex-wrap:wrap;gap:8px;margin-block:12px}
.ws button{background:#155495!important;color:#fff!important;border:1px solid #80bfff!important;min-height:44px!important;padding:8px 14px!important;border-radius:10px!important}
.ws button:focus-visible,.ws input:focus-visible,.ws select:focus-visible,.ws a:focus-visible{outline:3px solid #a5e1ff;outline-offset:3px}
.ws-preview{box-sizing:border-box;max-width:100%;margin:auto;overflow:hidden;background:linear-gradient(140deg,var(--ui_site_bg1),var(--ui_site_bg2));padding:var(--ui_page_padding);border-radius:18px;min-height:290px;color:white}
.ws-demo-nav{background:var(--ui_nav_bg);padding:12px;border-radius:10px;overflow-wrap:anywhere}.ws-demo-panel{background:var(--ui_panel_bg);padding:10px;margin-block:12px;border-radius:var(--ui_card_radius)}.ws-demo-cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,108px),1fr));gap:var(--ui_card_gap)}
.ws-demo-card{background:var(--ui_card_bg);padding:var(--ui_card_padding);border-radius:var(--ui_card_radius);overflow-wrap:anywhere}.ws-demo-button{display:grid;place-items:center;background:var(--ui_button_bg);color:var(--ui_button_text);min-height:var(--ui_button_height);border-radius:var(--ui_button_radius);font-size:var(--ui_button_font);text-align:center;margin-block-start:8px;padding:4px}.ws-demo-primary{background:linear-gradient(135deg,var(--ui_primary_bg),var(--ui_primary_bg2))}
.ws-history{margin-block-start:18px;overflow-wrap:anywhere}.ws-history li{margin-block:6px}.ws output{font-variant-numeric:tabular-nums;color:#a8ddff}
@media(max-width:760px){.ws-grid{grid-template-columns:minmax(0,1fr)}}@media(prefers-reduced-motion:reduce){.ws *{scroll-behavior:auto!important;transition:none!important;animation:none!important}}
</style>
<section class="ws" dir="{{$ar?'rtl':'ltr'}}">
<a href="{{route('admin')}}">{{$tr('← لوحة الإدارة','Back to admin')}}</a>
<h1>{{$tr('استوديو ورقنا المرئي','Warqnaa Visual Studio')}}</h1>
<p>{{$tr('عدّل عناصر التصميم وشاهد نموذجًا مباشرًا قبل النشر. لا يتم حفظ أي تعديل حتى تضغط نشر.','Edit design tokens and preview a sample before publishing. Nothing is saved until you publish.')}}</p>
@if(session('ok'))<p role="status">{{$tr('تم حفظ العملية.','Operation saved.')}}</p>@endif
@if($errors->any())<div role="alert"><ul>@foreach($errors->all() as $error)<li>{{$error}}</li>@endforeach</ul></div>@endif
<form method="post" action="{{route('admin.visual-studio.publish')}}" id="ws-form">@csrf
<input type="hidden" name="revision" value="{{$revision}}">
<div class="ws-grid">
<div class="ws-panel">
<h2>{{$tr('الألوان والأبعاد','Colors and dimensions')}}</h2>
<div class="ws-fields">
@foreach($fields as $key=>$field)
<label for="ws-{{$key}}">{{$field[$ar?0:1]}}
@if(isset($field[3]))
<input id="ws-{{$key}}" data-token="{{$key}}" type="range" name="values[{{$key}}]" min="{{$field[3]}}" max="{{$field[4]}}" value="{{max($field[3],min($field[4],(int)old('values.'.$key,$values[$key])))}}">
<output for="ws-{{$key}}"></output>
@else
<input id="ws-{{$key}}" data-token="{{$key}}" type="color" name="values[{{$key}}]" value="{{$values[$key]}}">
@endif
</label>
@endforeach
</div>
<div class="ws-actions">
<button type="button" id="ws-blue">{{$tr('الهوية الزرقاء','Blue preset')}}</button>
<button type="reset">{{$tr('إلغاء التعديلات','Discard changes')}}</button>
<button type="submit">{{$tr('نشر التصميم','Publish design')}}</button>
</div>
</div>
<div class="ws-panel">
<h2>{{$tr('معاينة النموذج','Sample preview')}}</h2>
<div class="ws-actions">
<label>{{$tr('عرض الجهاز','Device width')}}<select id="ws-width"><option value="320">320 px</option><option value="390" selected>390 px</option><option value="768">768 px</option></select></label>
<label>{{$tr('الاتجاه','Direction')}}<select id="ws-dir"><option value="rtl" @selected($ar)>RTL</option><option value="ltr" @selected(!$ar)>LTR</option></select></label>
</div>
<div id="ws-preview" class="ws-preview">
<div class="ws-demo-nav">WARQNAA • <span id="ws-nav-copy">{{$tr('الردهة','Lobby')}}</span></div>
<div class="ws-demo-panel">
<div class="ws-demo-cards">
@foreach([['الهاند','Hand'],['البناكل','Banakil'],['المتجر','Store'],['الغرف','Rooms']] as $pair)
<div class="ws-demo-card"><strong data-ar="{{$pair[0]}}" data-en="{{$pair[1]}}">{{$pair[$ar?0:1]}}</strong><span class="ws-demo-button" data-ar="فتح" data-en="Open">{{$tr('فتح','Open')}}</span></div>
@endforeach
</div><span class="ws-demo-button ws-demo-primary" data-ar="إنشاء غرفة" data-en="Create room">{{$tr('إنشاء غرفة','Create room')}}</span>
</div>
</div>
<p id="ws-contrast" role="status"></p>
</div>
</div>
</form>
<div class="ws-panel ws-history">
<h2>{{$tr('سجل النشر والاستعادة','Publication and restore history')}}</h2>
@if($history->isNotEmpty())
<form method="post" action="{{route('admin.visual-studio.restore')}}">@csrf
<input type="hidden" name="revision" value="{{$revision}}"><input type="hidden" name="entry" value="{{$history->first()->id}}">
<button type="submit">{{$tr('عكس آخر عملية نشر أو استعادة','Reverse last publish or restore')}}</button>
</form>
@endif
<ul>@forelse($history as $entry)<li>#{{$entry->id}} · {{$entry->action}} · {{$entry->created_at}} · {{$tr('مدير','Admin')}} {{$entry->admin_id}}</li>@empty<li>{{$tr('لا توجد عمليات منشورة بعد.','No published operations yet.')}}</li>@endforelse</ul>
</div>
</section>
<script>
(() => {
 const form=document.getElementById('ws-form'), preview=document.getElementById('ws-preview'), width=document.getElementById('ws-width'), dir=document.getElementById('ws-dir');
 const inputs=[...form.querySelectorAll('[data-token]')], status=document.getElementById('ws-contrast');
 const preset={ui_site_bg1:'#103b70',ui_site_bg2:'#06152e',ui_panel_bg:'#102e52',ui_card_bg:'#174578',ui_nav_bg:'#09264a',ui_button_bg:'#155495',ui_button_text:'#ffffff',ui_primary_bg:'#14519a',ui_primary_bg2:'#123b76'};
 const luminance=h=>{const v=h.slice(1).match(/../g).map(s=>parseInt(s,16)/255).map(c=>c<=.04045?c/12.92:((c+.055)/1.055)**2.4);return .2126*v[0]+.7152*v[1]+.0722*v[2];};
 const refresh=()=>{for(const el of inputs){preview.style.setProperty('--'+el.dataset.token,el.value+(el.type==='range'?'px':''));if(el.type==='range')el.nextElementSibling.textContent=el.value+' px';}
 preview.style.width=width.value+'px';preview.dir=dir.value;
 for(const el of preview.querySelectorAll('[data-ar]'))el.textContent=dir.value==='rtl'?el.dataset.ar:el.dataset.en;
 const a=luminance(form.elements['values[ui_button_bg]'].value),b=luminance(form.elements['values[ui_button_text]'].value),ratio=(Math.max(a,b)+.05)/(Math.min(a,b)+.05);
 status.textContent=(@json($ar)?'تباين الزر النموذجي: ':'Sample button contrast: ')+ratio.toFixed(2)+':1 '+(ratio<4.5?(@json($ar)?'— يوصى برفع التباين':'— increase contrast'):'');
 };
 form.addEventListener('input',refresh);form.addEventListener('reset',()=>requestAnimationFrame(refresh));width.addEventListener('change',refresh);dir.addEventListener('change',refresh);
 document.getElementById('ws-blue').addEventListener('click',()=>{for(const el of inputs)if(preset[el.dataset.token])el.value=preset[el.dataset.token];refresh();});
 refresh();
})();
</script>
@endsection
