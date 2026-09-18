@extends('layouts.app')
@section('title','Warqnaa | العروض والشراء')
@section('content')
@php
    $catalog=$commerceCatalog ?? [];
    $packages=collect($catalog['packages'] ?? []);
    $offers=collect($catalog['offers'] ?? []);
    $selectedKey=request('package');
@endphp
<section class="b307-shop" data-b307-shop>
    <div class="b307-shop-hero">
        <div>
            <span class="b307-offer-badge">WARQNAA SHOP</span>
            <h1>العروض والشراء الآمن</h1>
            <p>حزم توكنز وعروض مميزة بواجهة بسيطة ومباشرة. يتم الدفع النهائي عبر مزود دفع موثوق، ولا يقوم Warqnaa بتخزين بيانات البطاقة الخام.</p>
        </div>
        <div class="b307-shop-mark">🛍️</div>
    </div>

    <div class="b307-shop-toolbar">
        <label>الدولة
            <select id="b307Country">
                <option value="PS">فلسطين</option><option value="JO">الأردن</option><option value="SA">السعودية</option><option value="AE">الإمارات</option><option value="IQ">العراق</option><option value="KW">الكويت</option><option value="QA">قطر</option><option value="OM">عُمان</option><option value="BH">البحرين</option><option value="OTHER">بقية العالم</option>
            </select>
        </label>
        <label>الحساب
            <input id="b307Player" value="{{ auth()->user()->username }}" readonly aria-label="حساب اللاعب">
        </label>
    </div>

    <div class="b307-shop-tabs" role="tablist">
        <button type="button" class="b307-shop-tab active" data-filter="all">الكل</button>
        <button type="button" class="b307-shop-tab" data-filter="featured">العروض المميزة</button>
        <button type="button" class="b307-shop-tab" data-filter="weekly">عروض الأسبوع</button>
        <button type="button" class="b307-shop-tab" data-filter="tokens">توكنز</button>
    </div>

    @if(empty($catalog['enabled']))
        <div class="b307-checkout-panel">المتجر النقدي متوقف مؤقتًا من الإدارة.</div>
    @else
        <div class="b307-offer-grid" id="b307OfferGrid">
            @foreach($packages as $package)
                @php
                    $key=$package['key'] ?? '';
                    $minor=(int)($package['price_minor'] ?? 0);
                    $price=number_format($minor/100,2);
                    $tokens=(int)($package['tokens'] ?? 0);
                    $badge=(string)($package['badge'] ?? '');
                    $type=str_contains(strtolower($badge),'week') ? 'weekly' : ($loop->index<2 ? 'featured' : 'tokens');
                @endphp
                <article class="b307-offer-card" data-offer-type="{{ $type }}" data-package-key="{{ $key }}">
                    @if($badge)<span class="b307-offer-badge">{{ $badge }}</span>@endif
                    <div class="b307-offer-icon">{{ $package['icon'] ?? '🪙' }}</div>
                    <h3>{{ number_format($tokens) }} توكنز</h3>
                    <div class="b307-offer-price">{{ $package['currency'] ?? 'USD' }} {{ $price }}</div>
                    <button type="button" onclick="selectB307Offer(@js($key),@js(number_format($tokens)),@js(($package['currency'] ?? 'USD').' '.$price))">اختيار العرض</button>
                </article>
            @endforeach
        </div>

        @if($offers->isNotEmpty())
            <div class="b307-checkout-panel">
                <h2 style="margin-top:0">العروض النشطة</h2>
                @foreach($offers as $offer)
                    <div style="padding:9px 0;border-bottom:1px solid rgba(255,255,255,.06)">
                        <b>{{ data_get($offer,'title.ar') ?? data_get($offer,'title.en') ?? ($offer['key'] ?? '') }}</b>
                        <div class="b307-checkout-note">{{ data_get($offer,'description.ar') ?? data_get($offer,'description.en') ?? '' }}</div>
                    </div>
                @endforeach
            </div>
        @endif

        <div class="b307-checkout-panel" id="b307Checkout">
            <h2 style="margin-top:0">إتمام الشراء</h2>
            <div id="b307SelectedOffer" class="b307-checkout-note">اختر عرضًا من الأعلى.</div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:10px">
                <label>العملة<input id="b307Currency" value="USD" readonly></label>
                <label>المبلغ<input id="b307Amount" value="—" readonly></label>
            </div>
            <button type="button" class="primary" id="b307CheckoutButton" disabled onclick="b307BeginCheckout()">متابعة إلى مزود الدفع</button>
            <p class="b307-checkout-note">لأسباب أمنية لا يتم إدخال بيانات البطاقة داخل Warqnaa مباشرة. يجب ربط هذه الخطوة بمزود الدفع/متجر التطبيقات المعتمد؛ وبعد الدفع يتم التحقق من الإيصال خادميًا قبل إضافة التوكنز.</p>
        </div>
    @endif
</section>
<script>
(function(){
 let selected=null;
 const tabs=[...document.querySelectorAll('.b307-shop-tab')];
 tabs.forEach(btn=>btn.addEventListener('click',()=>{
   tabs.forEach(x=>x.classList.remove('active'));btn.classList.add('active');
   const f=btn.dataset.filter;
   document.querySelectorAll('.b307-offer-card').forEach(card=>card.style.display=(f==='all'||card.dataset.offerType===f)?'':'none');
 }));
 window.selectB307Offer=(key,tokens,price)=>{
   selected={key,tokens,price};
   document.getElementById('b307SelectedOffer').textContent=`${tokens} توكنز — ${price}`;
   document.getElementById('b307Amount').value=price;
   document.getElementById('b307CheckoutButton').disabled=false;
 };
 window.b307BeginCheckout=()=>{
   if(!selected)return;
   const sandbox=@json((bool)($catalog['sandbox'] ?? false));
   const msg=sandbox
      ? 'وضع Sandbox مفعّل. اربط مزود الدفع الفعلي من إعدادات الإدارة قبل استقبال دفعات حقيقية.'
      : 'اختر مزود الدفع الموثوق من تطبيق Warqnaa لإتمام العملية، ثم سيتم التحقق من الإيصال خادميًا.';
   if(window.showNotice) window.showNotice(msg); else alert(msg);
 };
 @if($selectedKey)
 const preset=[...document.querySelectorAll('.b307-offer-card')].find(x=>x.dataset.packageKey===@js($selectedKey));
 preset?.querySelector('button')?.click();preset?.scrollIntoView({behavior:'smooth',block:'center'});
 @endif
})();
</script>
@endsection
