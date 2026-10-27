@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'المواسم والاقتصاد | ورقنا' : 'Seasons & Economy | Warqnaa')
@section('content')
@php
$locale=in_array(app()->getLocale(),['ar','en'],true)?app()->getLocale():'en';
$ar=$locale==='ar';
$fallbackLocale=$ar?'en':'ar';
$ui=$ar ? [
 'hero_title'=>'المواسم والعروض النادرة',
 'hero_body'=>'مركز اقتصاد ورقنا: مواسم، فعاليات، عروض، مقتنيات نادرة، ومعززات نقاط.',
 'open_store'=>'فتح المتجر',
 'current_season'=>'الموسم الحالي',
 'from'=>'من',
 'to'=>'إلى',
 'open'=>'مفتوح',
 'no_season'=>'لا يوجد موسم مفعّل حاليًا.',
 'active_offers'=>'العروض النشطة',
 'no_offers'=>'لا توجد عروض نشطة الآن.',
 'rare_collectibles'=>'مقتنيات نادرة',
 'no_rares'=>'لا توجد مقتنيات نادرة مفعّلة الآن.',
 'claimed'=>'تم اقتناء',
 'featured'=>'عناصر مميزة',
 'preview'=>'معاينة',
 'item_preview'=>'معاينة العنصر',
] : [
 'hero_title'=>'Seasons and rare offers',
 'hero_body'=>'Warqnaa economy hub: seasons, events, offers, rare collectibles, and XP boosters.',
 'open_store'=>'Open store',
 'current_season'=>'Current season',
 'from'=>'From',
 'to'=>'to',
 'open'=>'Open',
 'no_season'=>'There is no active season right now.',
 'active_offers'=>'Active offers',
 'no_offers'=>'There are no active offers right now.',
 'rare_collectibles'=>'Rare collectibles',
 'no_rares'=>'There are no active rare collectibles right now.',
 'claimed'=>'Claimed',
 'featured'=>'Featured items',
 'preview'=>'Preview',
 'item_preview'=>'Preview item',
];
$localized=function($value,$fallback='') use ($locale,$fallbackLocale) {
 $primary=data_get($value,$locale);
 if(filled($primary)) return $primary;
 $secondary=data_get($value,$fallbackLocale);
 return filled($secondary)?$secondary:$fallback;
};
$rarityLabels=[
 'common'=>$ar?'شائع':'Common',
 'uncommon'=>$ar?'غير شائع':'Uncommon',
 'rare'=>$ar?'نادر':'Rare',
 'epic'=>$ar?'ملحمي':'Epic',
 'legendary'=>$ar?'أسطوري':'Legendary',
 'mythic'=>$ar?'خرافي':'Mythic',
];
@endphp
<section class="economy-page" dir="{{$ar?'rtl':'ltr'}}">
 <div class="economy-hero pro-card">
  <h1><span aria-hidden="true">🚀</span> {{$ui['hero_title']}}</h1>
  <p>{{$ui['hero_body']}}</p>
  <a class="btn primary" href="{{ route('store') }}">{{$ui['open_store']}}</a>
 </div>
 <div class="economy-grid">
  <section class="pro-card" data-testid="current-economy-season">
   <h2><span aria-hidden="true">🏆</span> {{$ui['current_season']}}</h2>
   @if($season)
    <h3>{{ $localized($season->name,$season->key) }}</h3>
    <p>{{$ui['from']}} {{ optional($season->starts_at)->format('Y-m-d') ?: $ui['open'] }} {{$ui['to']}} {{ optional($season->ends_at)->format('Y-m-d') ?: $ui['open'] }}</p>
    <pre class="json-mini">{{ json_encode($season->rewards, JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT) }}</pre>
   @else
    <p class="muted">{{$ui['no_season']}}</p>
   @endif
  </section>
  <section class="pro-card" data-testid="active-economy-offers">
   <h2><span aria-hidden="true">🔥</span> {{$ui['active_offers']}}</h2>
   @forelse($offers as $offer)
    <div class="offer-card"><b>{{ $localized($offer->title,$offer->key) }}</b><span>{{ $offer->discount_percent }}%</span><p>{{ $localized($offer->description) }}</p></div>
   @empty <p class="muted">{{$ui['no_offers']}}</p> @endforelse
  </section>
  <section class="pro-card" data-testid="rare-economy-collectibles">
   <h2><span aria-hidden="true">💎</span> {{$ui['rare_collectibles']}}</h2>
   @forelse($rares as $rare)
    <div class="rare-card rarity-{{ $rare->rarity }}"><b>{{ $localized($rare->name,$rare->key) }}</b><span>{{ $rarityLabels[$rare->rarity] ?? str_replace('_',' ',ucfirst($rare->rarity)) }}</span><small>{{$ui['claimed']}}: {{ $rare->claimed }}/{{ $rare->supply ?? '∞' }}</small></div>
   @empty <p class="muted">{{$ui['no_rares']}}</p> @endforelse
  </section>
 </div>
 <section class="pro-card" data-testid="featured-economy-items">
  <h2><span aria-hidden="true">🎁</span> {{$ui['featured']}}</h2>
  <div class="store-grid refined">
   @foreach($featured as $item)
    <article class="store-card deluxe" data-category="{{ $item->category }}" data-item-key="{{ $item->key }}">
     <div class="shop-icon" aria-hidden="true">{{ $item->payload['preview_icon'] ?? '🎁' }}</div>
     <h3>{{ $localized($item->name,$item->key) }}</h3>
     <p class="price"><span aria-hidden="true">🪙</span> {{ number_format($item->price) }}</p>
     <button type="button" aria-label="{{$ui['item_preview']}}: {{ $localized($item->name,$item->key) }}" onclick="previewStoreItem(this)">{{$ui['preview']}}</button>
    </article>
   @endforeach
  </div>
 </section>
</section>
@endsection
