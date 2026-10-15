@extends('layouts.app')
@section('content')
@php
$ar=app()->isLocale('ar');
$typeLabels=[
 'store_buy'=>[$ar?'شراء من المتجر':'Store purchase'],
 'store_sale_income'=>[$ar?'دخل بيع متجر':'Store sale income'],
 'transfer_sent'=>[$ar?'تحويل صادر':'Sent transfer'],
 'transfer_received'=>[$ar?'تحويل وارد':'Received transfer'],
 'transfer_fee'=>[$ar?'عمولة تحويل':'Transfer fee'],
 'admin_silent_gift'=>[$ar?'هدية إدارية':'Administrator gift'],
 'voice_room_entry'=>[$ar?'غرفة صوتية':'Voice room entry'],
 'tournament_create'=>[$ar?'إنشاء مسابقة':'Tournament creation'],
 'tournament_entry'=>[$ar?'اشتراك مسابقة':'Tournament entry'],
 'club_create'=>[$ar?'إنشاء نادي':'Club creation'],
 'daily_reward'=>[$ar?'مكافأة يومية':'Daily reward'],
 'reward_claim'=>[$ar?'مكافأة':'Reward claim'],
];
$metaLabels=[
 'to'=>$ar?'إلى':'To',
 'from'=>$ar?'من':'From',
 'fee'=>$ar?'العمولة':'Fee',
 'buyer_id'=>$ar?'المشتري':'Buyer',
 'primary_admin_unlimited'=>$ar?'حساب المدير الأساسي':'Primary administrator account',
];
$purchaseTypes=['store_buy','voice_room_entry','tournament_entry','tournament_create','club_create'];
$transferTypes=['transfer_sent','transfer_received','transfer_fee','admin_silent_gift'];
$rewardTypes=['daily_reward','reward_claim','store_sale_income'];
$summary=[
 'in'=>$transactions->where('amount','>',0)->sum('amount'),
 'out'=>abs($transactions->where('amount','<',0)->sum('amount')),
 'count'=>$transactions->count(),
];
@endphp
<section class="token-ledger-v136" dir="{{$ar?'rtl':'ltr'}}">
 <header class="token-ledger-hero-v136 pro-card">
  <div>
   <span class="v127-kicker">{{$ar?'دفتر التوكنز':'Token Ledger'}}</span>
   <h1>{{$ar?'سجل التوكنز':'Token history'}}</h1>
   <p>{{$ar?'سجل الشراء والتحويل والإنفاق والمكافآت والعمولات في مكان واحد واضح وسهل القراءة.':'Review purchases, transfers, spending, rewards and fees in one clear place.'}}</p>
  </div>
  <div class="token-balance-pill-v136"><small>{{$ar?'رصيدك الحالي':'Current balance'}}</small><b>🪙 {{token_display($user)}}</b></div>
 </header>
 <div class="token-summary-grid-v136">
  <div class="pro-card"><b>{{number_format($summary['in'])}}</b><span>{{$ar?'إجمالي الداخل':'Total received'}}</span></div>
  <div class="pro-card"><b>{{number_format($summary['out'])}}</b><span>{{$ar?'إجمالي المصروف':'Total spent'}}</span></div>
  <div class="pro-card"><b>{{number_format($summary['count'])}}</b><span>{{$ar?'عدد الحركات':'Transactions'}}</span></div>
 </div>
 <div class="tokens-page token-ledger-layout-v136">
  <section class="pro-card token-transfer token-send-card-v136">
   <h2>{{$ar?'إرسال توكنز للاعب':'Send tokens to a player'}}</h2>
   <form method="post" action="{{route('wallet.transfer')}}" data-confirm="{{$ar?'هل أنت متأكد من إرسال التوكنز؟ سيتم خصم عمولة 10% من حسابك.':'Send these tokens? A 10% fee will be deducted from your account.'}}">@csrf
    <label>{{$ar?'اسم اللاعب أو البريد الإلكتروني':'Username or email'}}</label>
    <input name="receiver" placeholder="{{$ar?'اسم المستخدم أو البريد الإلكتروني':'Username or email'}}" required>
    <label>{{$ar?'المبلغ':'Amount'}}</label>
    <input type="number" name="amount" min="10" max="100000000" required>
    <small>{{$ar?'تُخصم عمولة تحويل بنسبة 10% من المرسل.':'A 10% transfer fee is charged to the sender.'}}</small>
    <button class="primary big-save">{{$ar?'إرسال التوكنز':'Send tokens'}}</button>
   </form>
  </section>
  <section class="pro-card token-history token-ledger-card-v136">
   <div class="token-ledger-head-v136">
    <h2>{{$ar?'كل الحركات الأخيرة':'Recent transactions'}}</h2>
    <div class="token-ledger-tabs-v136" aria-label="{{$ar?'تصفية الحركات':'Filter transactions'}}">
     <button type="button" class="active" data-token-filter="all">{{$ar?'الكل':'All'}}</button>
     <button type="button" data-token-filter="purchase">{{$ar?'شراء وإنفاق':'Purchases & spending'}}</button>
     <button type="button" data-token-filter="transfer">{{$ar?'تحويلات':'Transfers'}}</button>
     <button type="button" data-token-filter="reward">{{$ar?'مكافآت ودخل':'Rewards & income'}}</button>
    </div>
   </div>
   <div class="token-ledger-list-v136">
   @forelse($transactions as $t)
    @php
     $kind=in_array($t->type,$purchaseTypes,true)?'purchase':(in_array($t->type,$transferTypes,true)?'transfer':(in_array($t->type,$rewardTypes,true)?'reward':'other'));
     $meta=$t->meta ?: [];
     $details=collect($meta)->map(function($v,$k) use($metaLabels){
        $value=is_bool($v)?($v?'✓':'—'):(is_array($v)?json_encode($v,JSON_UNESCAPED_UNICODE):$v);
        return ($metaLabels[$k] ?? $k).': '.$value;
     })->implode(' · ');
    @endphp
    <article class="transaction-row token-ledger-row-v136 {{$t->amount>=0?'income':'expense'}}" data-token-kind="{{$kind}}">
     <span class="token-kind-icon-v136" aria-hidden="true">{{$kind==='purchase'?'🛒':($kind==='transfer'?'🔁':($kind==='reward'?'🎁':'🧾'))}}</span>
     <div><b>{{$typeLabels[$t->type][0] ?? $t->type}}</b>@if($details)<small>{{$details}}</small>@endif<small>{{$t->created_at?->format('Y-m-d H:i')}}</small></div>
     <strong class="{{$t->amount>=0?'plus':'minus'}}">{{$t->amount>=0?'+':'-'}}{{number_format(abs($t->amount))}}</strong>
    </article>
   @empty
    <p class="muted">{{$ar?'لا توجد عمليات بعد.':'No transactions yet.'}}</p>
   @endforelse
   </div>
  </section>
 </div>
</section>
<script>
document.addEventListener('click',function(e){const b=e.target.closest('[data-token-filter]');if(!b)return;document.querySelectorAll('[data-token-filter]').forEach(x=>x.classList.toggle('active',x===b));const v=b.dataset.tokenFilter;document.querySelectorAll('[data-token-kind]').forEach(r=>r.hidden=(v!=='all'&&r.dataset.tokenKind!==v));});
</script>
@endsection
