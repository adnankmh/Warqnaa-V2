@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'الساحة التنافسية | ورقنا' : 'Competitive Arena | Warqnaa')
@section('content')
@php
 $ar=app()->getLocale()==='ar';
 $season=data_get($competitive,'season'); $rating=data_get($competitive,'rating',[]); $tier=data_get($rating,'tier',[]); $queue=data_get($competitive,'queue');
 $local=fn($v)=>is_array($v)?($v[app()->getLocale()]??$v['ar']??$v['en']??reset($v)):$v;
 $rows=data_get($leaderboard,'rows',[]); $tournaments=data_get($competitive,'tournaments',[]); $rewards=data_get($competitive,'rewards',[]);
 $seatsFor=fn($key)=>match($key){'banakil'=>[2,4],'hand','saudi_hand'=>[2,3,4],'basra'=>[2],default=>[4]};
 $queueStatusLabels=['waiting'=>$ar?'قيد الانتظار':'Waiting','matching'=>$ar?'جارٍ البحث':'Matching','matched'=>$ar?'تم العثور على مباراة':'Matched'];
 $regionLabels=['levant'=>$ar?'بلاد الشام':'Levant','mena'=>$ar?'الشرق الأوسط وشمال أفريقيا':'MENA','gcc'=>$ar?'الخليج العربي':'GCC','global'=>$ar?'عالمي':'Global'];
 $scopeLabels=['global'=>$ar?'عالمية':'Global','country'=>$ar?'الدولة':'Country','club'=>$ar?'النادي':'Club'];
 $formatLabels=['cup'=>$ar?'كأس':'Cup','league'=>$ar?'دوري':'League','knockout'=>$ar?'إقصائية':'Knockout'];
 $tierLabels=['bronze'=>$ar?'برونزي':'Bronze','silver'=>$ar?'فضي':'Silver','gold'=>$ar?'ذهبي':'Gold','platinum'=>$ar?'بلاتيني':'Platinum','diamond'=>$ar?'ماسي':'Diamond','master'=>$ar?'أستاذ':'Master','grandmaster'=>$ar?'أستاذ كبير':'Grandmaster'];
 $queueStatusLabel=$queueStatusLabels[data_get($queue,'status')] ?? ucfirst(str_replace('_',' ',(string)data_get($queue,'status','waiting')));
 $queueRegionLabel=$regionLabels[data_get($queue,'region')] ?? strtoupper((string)data_get($queue,'region'));
 $queueGame=$games->firstWhere('key',data_get($queue,'game'));
 $queueGameLabel=$queueGame ? $local($queueGame->name) : data_get($queue,'game');
@endphp
<div class="r12-arena" data-r12-arena data-queue-token="{{data_get($queue,'token')}}">
 <header class="r12-hero">
  <div class="r12-hero-copy">
   <span class="r12-live"><i></i> {{$ar?'منافسات موثقة • لعب عادل':'VERIFIED COMPETITION • FAIR PLAY'}}</span>
   <h1>{{$ar?'اصنع اسمك بين أساطير ورقنا':'Earn your place among Warqnaa legends'}}</h1>
   <p>{{$ar?'تصنيف MMR موسمي، مباريات عادلة من الخادم، بطولات أندية ودول، وجوائز تُصرف بعد اعتماد النتيجة.':'Seasonal MMR, server-authoritative fair play, club and country championships, with rewards released only after verified results.'}}</p>
   <div class="r12-trust"><span>🛡️ {{$ar?'الخادم هو المرجع':'Server authoritative'}}</span><span>◎ {{$ar?'مراجعة مكافحة الغش':'Anti-cheat review'}}</span><span>↻ {{$ar?'تصنيف محمي من التكرار':'Idempotent rating'}}</span></div>
  </div>
  <div class="r12-rank-orbit" style="--tier:{{data_get($tier,'color','#F4C85A')}}">
   <div class="r12-rank-core"><small>{{$local($tier) ?: ($ar?'برونزي':'Bronze')}}</small><b>{{number_format((int)data_get($rating,'rating',1000))}}</b><span>MMR</span></div>
   <span class="r12-rank-icon">{{data_get($tier,'icon','◆')}}</span>
   <em>#{{number_format((int)data_get($rating,'rank',1))}}</em>
  </div>
 </header>

 @if(!$season)
  <section class="r12-empty"><b>◷ {{$ar?'لا يوجد موسم نشط الآن':'No active season right now'}}</b><p>{{$ar?'ستعود الساحة عند انطلاق الموسم القادم.':'The arena will reopen with the next season.'}}</p></section>
 @else
 <section class="r12-season-strip">
  <div><small>{{$ar?'الموسم الحالي':'Current season'}}</small><b>{{$local(data_get($season,'name',$ar?'موسم ورقنا':'Warqnaa Season'))}}</b></div>
  <div><small>{{$ar?'المباريات':'Matches'}}</small><b>{{number_format((int)data_get($rating,'games',0))}}</b></div>
  <div><small>{{$ar?'الانتصارات':'Wins'}}</small><b>{{number_format((int)data_get($rating,'wins',0))}}</b></div>
  <div><small>{{$ar?'أعلى تصنيف':'Peak'}}</small><b>{{number_format((int)data_get($rating,'peak',1000))}}</b></div>
  <div class="r12-season-time"><small>{{$ar?'ينتهي':'Ends'}}</small><b>{{\Illuminate\Support\Carbon::parse(data_get($season,'ends_at'))->diffForHumans()}}</b></div>
 </section>

 <div class="r12-layout">
  <main>
   <section class="r12-matchmaker">
    <div class="r12-section-head"><div><span>{{$ar?'البحث المصنف':'RANKED MATCHMAKING'}}</span><h2>{{$ar?'ادخل المواجهة':'Enter the arena'}}</h2></div><b class="r12-signal">● {{$ar?'الخادم جاهز':'Server ready'}}</b></div>
    @if($queue && in_array(data_get($queue,'status'),['waiting','matching','matched']))
     <div class="r12-queue-live">
      <div class="r12-search-radar"><i></i><i></i><i></i><b>W</b></div>
      <div><span>{{$queueStatusLabel}}</span><h3>{{data_get($queue,'status')==='matched'?($ar?'وجدنا منافستك!':'Match found!'):($ar?'نبحث عن منافسين مناسبين…':'Finding worthy opponents…')}}</h3><p>{{$queueGameLabel}} · {{$queueRegionLabel}} · ±{{number_format((int)data_get($queue,'search_window',100))}} MMR</p></div>
      @if(data_get($queue,'room_code'))<a class="r12-primary" href="{{route('rooms.show',data_get($queue,'room_code'))}}">{{$ar?'ادخل الغرفة':'Enter room'}} ←</a>@else<form method="post" action="{{route('competitive.queue.cancel')}}">@csrf @method('delete')<input type="hidden" name="token" value="{{data_get($queue,'token')}}"><button class="r12-ghost">{{$ar?'إلغاء البحث':'Cancel'}}</button></form>@endif
     </div>
    @else
     <form class="r12-queue-form" method="post" action="{{route('competitive.queue')}}">@csrf
      <label><span>{{$ar?'اللعبة':'Game'}}</span><select id="r12-game" name="game" required>@foreach($games as $game)<option value="{{$game->key}}" data-seats="{{implode(',',$seatsFor($game->key))}}">{{$local($game->name)}} · {{$game->key}}</option>@endforeach</select></label>
      <label><span>{{$ar?'عدد اللاعبين':'Players'}}</span><select id="r12-seats" name="preferred_seats" required></select></label>
      <label><span>{{$ar?'المنطقة':'Region'}}</span><select name="region">@foreach(['levant','mena','gcc','global'] as $value)<option value="{{$value}}" @selected($value==='mena')>{{$regionLabels[$value]}}</option>@endforeach</select></label>
      <button class="r12-primary" type="submit"><span>⚔</span>{{$ar?'ابدأ البحث المصنف':'Start Ranked search'}}</button>
     </form>
    @endif
   </section>

   <section class="r12-block">
    <div class="r12-section-head"><div><span>{{$ar?'الدوريات والكؤوس':'LEAGUES & CUPS'}}</span><h2>{{$ar?'بطولات العالم والأندية':'World & club championships'}}</h2></div><a href="{{route('tournaments')}}">{{$ar?'كل البطولات':'All tournaments'}} ←</a></div>
    <div class="r12-tournament-grid">
     @forelse($tournaments as $t)
      <article class="r12-cup-card"><div class="r12-cup-top"><span>{{$scopeLabels[data_get($t,'scope','global')] ?? ucfirst(str_replace('_',' ',(string)data_get($t,'scope','global')))}}</span><b>{{$formatLabels[data_get($t,'format','cup')] ?? ucfirst(str_replace('_',' ',(string)data_get($t,'format','cup')))}}</b></div><div class="r12-cup">♜</div>
       <h3>{{$local(data_get($t,'name',data_get($t,'key','Warqnaa Cup')))}}</h3><p>{{data_get($t,'game')}} · {{data_get($t,'players',0)}}/{{data_get($t,'max_players',0)}} {{$ar?'لاعب':'players'}}</p>
       <div class="r12-prize"><small>{{$ar?'الجوائز':'Prize pool'}}</small><strong>🪙 {{number_format((int)data_get($t,'prize_pool',0))}}</strong></div>
       <a href="{{route('tournaments')}}">{{$ar?'عرض وتسجيل':'View & register'}}</a>
      </article>
     @empty<div class="r12-empty">{{$ar?'لا توجد بطولة مفتوحة الآن.':'No open tournament right now.'}}</div>@endforelse
    </div>
   </section>

   <section class="r12-block">
    <div class="r12-section-head"><div><span>{{$ar?'التصنيف العالمي':'GLOBAL LADDER'}}</span><h2>{{$ar?'صالة المتصدرين':'Hall of contenders'}}</h2></div><span>{{$local(data_get($season,'name'))}}</span></div>
    <div class="r12-leaderboard"><table><thead><tr><th>#</th><th>{{$ar?'اللاعب':'Player'}}</th><th>{{$ar?'الفئة':'Tier'}}</th><th>MMR</th><th>{{$ar?'ف/خ':'W/L'}}</th><th>{{$ar?'السلسلة':'Streak'}}</th></tr></thead><tbody>
     @forelse($rows as $row)<tr class="{{data_get($row,'user_id')===auth()->id()?'is-me':''}}"><td><b>{{data_get($row,'rank')}}</b></td><td><div class="r12-player"><img src="{{data_get($row,'avatar') ?: '/assets/avatars/default.svg'}}" alt=""><span><b>{{data_get($row,'display_name') ?: data_get($row,'username')}}</b><small>{{data_get($row,'country_code')}} · {{data_get($row,'club') ?: 'Warqnaa'}}</small></span></div></td><td><span class="r12-tier" style="--c:{{data_get($row,'tier.color','#F4C85A')}}">{{data_get($row,'tier.icon')}} {{$local(data_get($row,'tier'))}}</span></td><td><strong>{{number_format((int)data_get($row,'rating'))}}</strong></td><td>{{data_get($row,'wins')}} / {{data_get($row,'losses')}}</td><td>{{data_get($row,'streak')}}</td></tr>
     @empty<tr><td colspan="6">{{$ar?'ابدأ أول مباراة لتظهر القائمة.':'Play the first match to seed the ladder.'}}</td></tr>@endforelse
    </tbody></table></div>
   </section>
  </main>

  <aside class="r12-aside">
   <section class="r12-card"><span class="r12-card-kicker">{{$ar?'فئتك':'YOUR DIVISION'}}</span><div class="r12-emblem" style="--tier:{{data_get($tier,'color','#F4C85A')}}">{{data_get($tier,'icon','◆')}}</div><h2>{{$local($tier)}}</h2><b>{{number_format((int)data_get($rating,'rating',1000))}} MMR</b><div class="r12-progress"><i style="width:{{min(100,max(5,((int)data_get($rating,'rating',1000)%200)/2))}}%"></i></div><small>{{data_get($rating,'placement_complete')?($ar?'تم تثبيت التصنيف':'Rank established'):($ar?'مباريات التثبيت '.data_get($rating,'placements_played',0).'/'.data_get($season,'placement_games',10):'Placements '.data_get($rating,'placements_played',0).'/'.data_get($season,'placement_games',10))}}</small></section>
   <section class="r12-card"><span class="r12-card-kicker">{{$ar?'جوائز الموسم':'SEASON REWARDS'}}</span><h3>{{$ar?'خزنة الجوائز':'Reward vault'}}</h3>@forelse($rewards as $reward)<div class="r12-reward"><span>✦</span><div><b>{{$tierLabels[data_get($reward,'tier')] ?? ucfirst((string)data_get($reward,'tier'))}}</b><small>🪙 {{number_format((int)data_get($reward,'tokens'))}} · {{number_format((int)data_get($reward,'xp'))}} XP</small></div>@if(data_get($reward,'status')==='pending')<form method="post" action="{{route('competitive.rewards.claim',data_get($reward,'id'))}}">@csrf<button>{{$ar?'استلام':'Claim'}}</button></form>@else<em>✓</em>@endif</div>@empty<p>{{$ar?'تُفتح الجوائز عند إغلاق الموسم.':'Rewards unlock when the season closes.'}}</p>@endforelse</section>
   <section class="r12-card r12-fair"><span>🛡️</span><h3>{{$ar?'ميثاق اللعب العادل':'Fair-play contract'}}</h3><p>{{$ar?'لا يثق التصنيف بنتيجة العميل. كل تغيير MMR له حدث موثق، والمباريات المشبوهة تتوقف للمراجعة.':'Client results are never trusted. Every MMR change is auditable and suspicious matches are held for review.'}}</p></section>
  </aside>
 </div>
 @endif
</div>
<script>
(()=>{const game=document.getElementById('r12-game'),seats=document.getElementById('r12-seats');if(!game||!seats)return;const sync=()=>{const values=(game.selectedOptions[0]?.dataset.seats||'4').split(',');seats.replaceChildren(...values.map(value=>{const option=document.createElement('option');option.value=value;option.textContent=value;return option;}));};game.addEventListener('change',sync);sync();})();
</script>
@if($queue && in_array(data_get($queue,'status'),['waiting','matching']))
<script>setInterval(async()=>{try{const r=await fetch('/api/mobile/v1/competitive/queue?token={{data_get($queue,'token')}}',{credentials:'same-origin',headers:{Accept:'application/json'}});const j=await r.json();const code=j?.queue?.room_code;if(code)location.href='/room/'+code;}catch(e){}},5000);</script>
@endif
@endsection
