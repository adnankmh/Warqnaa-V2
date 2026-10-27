@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'العروض والشراء | ورقنا' : 'Offers & checkout | Warqnaa')
@section('content')
@php
    $catalog=$commerceCatalog ?? [];
    $packages=collect($catalog['packages'] ?? []);
    $offers=collect($catalog['offers'] ?? []);
    $selectedKey=request('package');
    $ar=app()->isLocale('ar');
    $locale=$ar ? 'ar' : 'en';
@endphp
<section class="b307-shop" data-b307-shop>
    <div class="b307-shop-hero">
        <div>
            <span class="b307-offer-badge">WARQNAA SHOP</span>
            <h1>{{ $ar ? 'العروض والشراء الآمن' : 'Offers & secure checkout' }}</h1>
            <p>{{ $ar
                ? 'حزم توكنز وعروض مميزة بواجهة بسيطة ومباشرة. يتم الدفع النهائي عبر مزود دفع موثوق، ولا يقوم ورقنا بتخزين بيانات البطاقة الخام.'
                : 'Token packs and featured offers in a simple, direct experience. Final payment is handled by a trusted provider, and Warqnaa never stores raw card details.' }}</p>
        </div>
        <div class="b307-shop-mark" aria-hidden="true">🛍️</div>
    </div>

    <div class="b307-shop-toolbar">
        <label>{{ $ar ? 'الدولة' : 'Country' }}
            <select id="b307Country" aria-label="{{ $ar ? 'دولة الدفع' : 'Billing country' }}">
                <option value="PS">{{ $ar ? 'فلسطين' : 'Palestine' }}</option>
                <option value="JO">{{ $ar ? 'الأردن' : 'Jordan' }}</option>
                <option value="SA">{{ $ar ? 'السعودية' : 'Saudi Arabia' }}</option>
                <option value="AE">{{ $ar ? 'الإمارات' : 'United Arab Emirates' }}</option>
                <option value="IQ">{{ $ar ? 'العراق' : 'Iraq' }}</option>
                <option value="KW">{{ $ar ? 'الكويت' : 'Kuwait' }}</option>
                <option value="QA">{{ $ar ? 'قطر' : 'Qatar' }}</option>
                <option value="OM">{{ $ar ? 'عُمان' : 'Oman' }}</option>
                <option value="BH">{{ $ar ? 'البحرين' : 'Bahrain' }}</option>
                <option value="OTHER">{{ $ar ? 'بقية العالم' : 'Rest of world' }}</option>
            </select>
        </label>
        <label>{{ $ar ? 'الحساب' : 'Account' }}
            <input id="b307Player" value="{{ auth()->user()->username }}" readonly aria-label="{{ $ar ? 'حساب اللاعب' : 'Player account' }}">
        </label>
    </div>

    <div class="b307-shop-tabs" role="tablist" aria-label="{{ $ar ? 'تصفية عروض المتجر' : 'Store offer filters' }}">
        <button type="button" class="b307-shop-tab active" data-filter="all">{{ $ar ? 'الكل' : 'All' }}</button>
        <button type="button" class="b307-shop-tab" data-filter="featured">{{ $ar ? 'العروض المميزة' : 'Featured offers' }}</button>
        <button type="button" class="b307-shop-tab" data-filter="weekly">{{ $ar ? 'عروض الأسبوع' : 'Weekly offers' }}</button>
        <button type="button" class="b307-shop-tab" data-filter="tokens">{{ $ar ? 'توكنز' : 'Tokens' }}</button>
    </div>

    @if(empty($catalog['enabled']))
        <div class="b307-checkout-panel">{{ $ar ? 'المتجر النقدي متوقف مؤقتًا من الإدارة.' : 'The cash store is temporarily disabled by administration.' }}</div>
    @else
        <div class="b307-offer-grid" id="b307OfferGrid">
            @foreach($packages as $package)
                @php
                    $key=$package['key'] ?? '';
                    $minor=(int)($package['price_minor'] ?? 0);
                    $price=number_format($minor/100,2);
                    $tokens=(int)($package['tokens'] ?? 0);
                    $badge=(string)($package['badge'] ?? '');
                    $categories=(array)($package['categories'] ?? ['tokens']);
                    $type=implode(' ', $categories);
                @endphp
                <article class="b307-offer-card" data-offer-type="{{ $type }}" data-package-key="{{ $key }}">
                    @if($badge)<span class="b307-offer-badge">{{ $badge }}</span>@endif
                    <div class="b307-offer-icon" aria-hidden="true">{{ $package['icon'] ?? '🪙' }}</div>
                    <h3>{{ number_format($tokens) }} {{ $ar ? 'توكنز' : 'tokens' }}</h3>
                    <div class="b307-offer-price">{{ $package['currency'] ?? 'USD' }} {{ $price }}</div>
                    <button type="button" onclick="selectB307Offer(@js($key),@js(number_format($tokens)),@js(($package['currency'] ?? 'USD').' '.$price))">{{ $ar ? 'اختيار العرض' : 'Select offer' }}</button>
                </article>
            @endforeach
        </div>

        @if($offers->isNotEmpty())
            <div class="b307-checkout-panel">
                <h2 style="margin-top:0">{{ $ar ? 'العروض النشطة' : 'Active offers' }}</h2>
                @foreach($offers as $offer)
                    <div style="padding:9px 0;border-bottom:1px solid rgba(255,255,255,.06)">
                        <b>{{ data_get($offer,"title.$locale") ?? data_get($offer,'title.ar') ?? data_get($offer,'title.en') ?? ($offer['key'] ?? '') }}</b>
                        <div class="b307-checkout-note">{{ data_get($offer,"description.$locale") ?? data_get($offer,'description.ar') ?? data_get($offer,'description.en') ?? '' }}</div>
                    </div>
                @endforeach
            </div>
        @endif

        <div class="b307-checkout-panel" id="b307Checkout">
            <h2 style="margin-top:0">{{ $ar ? 'إتمام الشراء' : 'Complete purchase' }}</h2>
            <div id="b307SelectedOffer" class="b307-checkout-note">{{ $ar ? 'اختر عرضًا من الأعلى.' : 'Select an offer above.' }}</div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:10px">
                <label>{{ $ar ? 'العملة' : 'Currency' }}<input id="b307Currency" value="USD" readonly></label>
                <label>{{ $ar ? 'المبلغ' : 'Amount' }}<input id="b307Amount" value="—" readonly></label>
            </div>
            <button type="button" class="primary" id="b307CheckoutButton" disabled onclick="b307BeginCheckout()">{{ $ar ? 'متابعة إلى مزود الدفع' : 'Continue to payment provider' }}</button>
            <p class="b307-checkout-note">{{ $ar
                ? 'لأسباب أمنية لا يتم إدخال بيانات البطاقة داخل ورقنا مباشرة. يجب ربط هذه الخطوة بمزود الدفع أو متجر التطبيقات المعتمد؛ وبعد الدفع يتم التحقق من الإيصال خادميًا قبل إضافة التوكنز.'
                : 'For security, card details are never entered directly in Warqnaa. This step must be connected to the approved payment provider or app store; after payment, the receipt is verified server-side before tokens are credited.' }}</p>
        </div>
    @endif
</section>
<script>
(function(){
 let selected=null;
 const tokenLabel=@json($ar ? 'توكنز' : 'tokens');
 const sandboxMessage=@json($ar
    ? 'وضع Sandbox مفعّل. اربط مزود الدفع الفعلي من إعدادات الإدارة قبل استقبال دفعات حقيقية.'
    : 'Sandbox mode is enabled. Connect the real payment provider in administration settings before accepting real payments.');
 const providerMessage=@json($ar
    ? 'اختر مزود الدفع الموثوق من تطبيق ورقنا لإتمام العملية، ثم سيتم التحقق من الإيصال خادميًا.'
    : 'Choose the trusted payment provider in the Warqnaa app to complete the purchase; the receipt will then be verified server-side.');
 const tabs=[...document.querySelectorAll('.b307-shop-tab')];
 tabs.forEach(btn=>btn.addEventListener('click',()=>{
   tabs.forEach(x=>x.classList.remove('active'));btn.classList.add('active');
   const f=btn.dataset.filter;
   document.querySelectorAll('.b307-offer-card').forEach(card=>card.style.display=(f==='all'||(card.dataset.offerType||'').split(' ').includes(f))?'':'none');
 }));
 window.selectB307Offer=(key,tokens,price)=>{
   selected={key,tokens,price};
   document.getElementById('b307SelectedOffer').textContent=`${tokens} ${tokenLabel} — ${price}`;
   document.getElementById('b307Amount').value=price;
   document.getElementById('b307CheckoutButton').disabled=false;
 };
 window.b307BeginCheckout=()=>{
   if(!selected)return;
   const sandbox=@json((bool)($catalog['sandbox'] ?? false));
   const msg=sandbox ? sandboxMessage : providerMessage;
   if(window.showNotice) window.showNotice(msg); else alert(msg);
 };
 @if($selectedKey)
 const preset=[...document.querySelectorAll('.b307-offer-card')].find(x=>x.dataset.packageKey===@js($selectedKey));
 preset?.querySelector('button')?.click();preset?.scrollIntoView({behavior:'smooth',block:'center'});
 @endif
})();
</script>
@endsection
