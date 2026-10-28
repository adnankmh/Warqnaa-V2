@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'المنافسات | ورقنا' : 'Competitions | Warqnaa')
@section('content')
@php
$ar=app()->isLocale('ar');
$statusLabels=[
 'open'=>$ar?'مفتوحة':'Open',
 'running'=>$ar?'جارية':'Running',
 'completed'=>$ar?'مكتملة':'Completed',
 'cancelled'=>$ar?'ملغاة':'Cancelled',
];
@endphp
<div class="tournaments-page" dir="{{$ar?'rtl':'ltr'}}">
<div class="tournament-hero premium-module-hero">
    <h1>🏆 {{$ar?'المنافسات':'Competitions'}}</h1>
    <p>{{$ar?'أنشئ منافسة واضحة بمراحل محددة. المقعدين = نهائي/نصف/ربع/ثمن، والأربع مقاعد بنفس المنطق مع 4 لاعبين في كل مباراة.':'Create a clear competition with defined stages. Two-seat and four-seat games follow the same final, semi-final, quarter-final and round-of-16 structure.'}}</p>
</div>
<div class="tournament-system-panel pro-card v105-system-panel">
 <h2>⚔️ {{$ar?'نظام المنافسات المعتمد':'Competition format'}}</h2>
 <div class="system-grid">
  <span>{{$ar?'1 مرحلة = نهائي فقط':'1 stage = final only'}}</span><span>{{$ar?'2 مراحل = نصف نهائي ثم نهائي':'2 stages = semi-final then final'}}</span><span>{{$ar?'3 مراحل = ربع نهائي ثم نصف ثم نهائي':'3 stages = quarter-final, semi-final, final'}}</span><span>{{$ar?'4 مراحل = ثمن نهائي ثم ربع ثم نصف ثم نهائي':'4 stages = round of 16, quarter-final, semi-final, final'}}</span>
  <span>{{$ar?'ألعاب المقعدين: 2 / 4 / 8 / 16 لاعب':'Two-seat games: 2 / 4 / 8 / 16 players'}}</span><span>{{$ar?'ألعاب 4 مقاعد: 4 / 8 / 16 / 32 لاعب':'Four-seat games: 4 / 8 / 16 / 32 players'}}</span><span>{{$ar?'رسوم دخول + صندوق جوائز':'Entry fee + prize pool'}}</span><span>{{$ar?'XP ونقاط صدارة حسب المرحلة':'XP and leaderboard points by stage'}}</span>
 </div>
</div>

<form class="inline-card tournament-create-grid mega-tournament-form" method="post" action="{{ route('tournaments.store') }}">
    @csrf
    <label>
        {{$ar?'اللعبة':'Game'}}
        <select name="game_id" id="tourGameSelect" class="tour-select-glow">
            @foreach($games as $g)
                <option value="{{ $g->id }}" data-min="{{ $g->min_players }}" data-max="{{ $g->max_players }}" data-partner="{{ $g->partnership ? 1 : 0 }}">
                    {{ game_icon($g->key) }} {{ $g->name[$ar?'ar':'en'] ?? $g->name['ar'] ?? $g->key }}
                </option>
            @endforeach
        </select>
        <small>{{$ar?'اختر اللعبة التي ستُفتح لها غرف المنافسة تلقائيًا.':'Choose the game whose competition rooms will open automatically.'}}</small>
    </label>

    <label>
        {{$ar?'عدد المراحل':'Stages'}}
        <select name="stages" id="tourStages" class="tour-select-glow">
            <option value="1">{{$ar?'1 — نهائي فقط':'1 — Final only'}}</option>
            <option value="2">{{$ar?'2 — نصف نهائي ثم نهائي':'2 — Semi-final then final'}}</option>
            <option value="3">{{$ar?'3 — ربع نهائي ثم نصف ثم نهائي':'3 — Quarter-final, semi-final, final'}}</option>
            <option value="4">{{$ar?'4 — ثمن نهائي ثم ربع ثم نصف ثم نهائي':'4 — Round of 16, quarter-final, semi-final, final'}}</option>
        </select>
        <small>{{$ar?'أقصى شيء 4 مراحل.':'Up to four stages.'}}</small>
    </label>

    <label>
        {{$ar?'مقاعد كل مباراة':'Seats per match'}}
        <select name="seats_per_match" id="tourSeats" class="tour-select-glow">
            <option value="2">{{$ar?'2 لاعبين':'2 players'}}</option>
            <option value="3">{{$ar?'3 لاعبين':'3 players'}}</option>
            <option value="4" selected>{{$ar?'4 لاعبين':'4 players'}}</option>
            <option value="6">{{$ar?'6 لاعبين':'6 players'}}</option>
        </select>
        <small>{{$ar?'يتم ضبط الخيارات حسب اللعبة.':'Options are adjusted for the selected game.'}}</small>
    </label>

    <label>
        {{$ar?'رسوم الدخول':'Entry fee'}}
        <input name="entry_fee" value="100">
        <small>{{$ar?'إذا لم يملك اللاعب توكنز كافية تظهر له رسالة واضحة.':'Players without enough tokens receive a clear message.'}}</small>
    </label>

    <label>
        {{$ar?'الجائزة الأساسية':'Base prize'}}
        <input name="prize_pool" value="1000">
        <small>{{$ar?'في ألعاب الشراكة تُقسم الجائزة على الفريق الفائز.':'In partnership games, the prize is shared by the winning team.'}}</small>
    </label>

    <div id="tourCostBox" class="tour-cost-box">{{$ar?'سيظهر هنا كم سيتم خصمه من صاحب المنافسة وكم يمكن أن تكون الجائزة قبل الإنشاء.':'The organizer cost and estimated prize will appear here before creation.'}}</div>
    <small class="pasha-create-note">👑 {{$ar?'إنشاء المنافسات متاح للباشا عند توفر التوكنز.':'Competition creation is available to Pasha members with enough tokens.'}}</small><button class="primary tournament-main-btn">🏆 {{$ar?'إنشاء منافسة':'Create competition'}}</button>
</form>

<div class="module-grid tournament-grid-horizontal">
    @forelse($tournaments as $t)
        @php
            $needed = max(1, $t->seats_per_match * (2 ** max(0, ($t->stages ?? 1) - 1)));
            $count = $t->entries->count();
            $pct = min(100, round(($count / $needed) * 100));
            $match = $t->bracket['matches'][0] ?? null;
            $dist=$t->prize_distribution ?: ($t->bracket['distribution'] ?? []);
            $lb=$t->leaderboard_points ?: ($t->bracket['leaderboard_points'] ?? []);
            $gameName=$t->game->name[$ar?'ar':'en'] ?? $t->game->name['ar'] ?? $t->game->key;
            $prizeNote=$ar
                ? ($dist['note'] ?? ($t->seats_per_match>=4?'تقسيم للفريق/المراكز':'الفائز يأخذ الجائزة كاملة'))
                : ($t->seats_per_match>=4?'Team / placement split':'Winner takes the full prize');
        @endphp
        <div class="pro-card tournament-card tournament-card-wide">
            <h3>{{ game_icon($t->game->key) }} {{ $gameName }} #{{ $t->id }}</h3>
            <span class="pill">{{ $statusLabels[$t->status] ?? $t->status }}</span>
            <span class="pill">{{ $t->stages }} {{$ar?'مراحل':'stages'}}</span>
            <span class="pill">{{ $t->seats_per_match }} {{$ar?'مقاعد لكل مباراة':'seats per match'}}</span>
            <p>{{$ar?'المنشئ':'Organizer'}}: {{ $t->creator->username }}</p>
            <p>{{$ar?'رسوم الدخول':'Entry fee'}}: 🪙 {{ number_format($t->entry_fee) }} — {{$ar?'الجائزة':'Prize'}}: 🪙 {{ number_format($t->prize_pool) }}</p>
            <div class="tournament-prize-line"><span>{{$ar?'نظام الجائزة':'Prize format'}}: {{ $prizeNote }}</span><span>🏆 {{$ar?'الأول':'First'}}: {{ $lb['first'] ?? 1000 }} {{$ar?'نقطة صدارة':'leaderboard points'}}</span><span>🥈 {{$ar?'الثاني':'Second'}}: {{ $lb['second'] ?? 600 }}</span></div>
            <div class="tournament-progress"><span style="width:{{ $pct }}%"></span></div>
            <p>{{$ar?'المسجلون':'Registered'}}: {{ $count }} / {{ $needed }}</p><div class="tournament-bracket-record big-record"><b>📼 {{$ar?'تسجيل المنافسة وسجل المراحل':'Competition recording and stage log'}}</b><p class="muted">{{$ar?'بعد اكتمال المنافسة سيظهر هنا سجل واضح لكل المراحل والنتائج. وعند تفعيل التسجيل داخل غرفة المنافسة يتم حفظ لقطات الورق والحركات كسجل إعادة مشاهدة، مع إظهار أوراق جميع اللاعبين بعد انتهاء المنافسة.':'After completion, this area shows the stages and results. When room recording is enabled, card and action snapshots are preserved for replay, with final hands revealed only after the competition ends.'}}</p><div>@foreach(($t->bracket['messages'] ?? []) as $rec)<p>{{ $rec }}</p>@endforeach @if(empty($t->bracket['messages'] ?? []))<p class="muted">{{$ar?'سيظهر هنا سجل مراحل المنافسة والنتائج بعد التشغيل.':'The stage and results log will appear here after launch.'}}</p>@endif</div></div>

            @if($match && !empty($match['room_code']))
                <a class="btn success" href="{{ route('rooms.show', $match['room_code']) }}">{{$ar?'دخول غرفة المنافسة':'Enter competition room'}} {{ $match['room_code'] }}</a>
                <a class="btn replay-btn" href="{{ route('tournaments.replay', $t) }}">📼 {{$ar?'مشاهدة/توليد تسجيل الفيديو':'View / generate replay'}}</a>
            @else
                <form method="post" action="{{ route('tournaments.join', $t) }}">
                    @csrf
                    <button>{{$ar?'دخول المنافسة':'Join competition'}}</button>
                </form>

                @if($t->creator_id === auth()->id() || auth()->user()->is_admin)
                    <form method="post" action="{{ route('tournaments.launch', $t) }}">
                        @csrf
                        <button class="primary">{{$ar?'تشغيل عند اكتمال العدد':'Launch when full'}}</button>
                    </form>
                @endif
            @endif

            <h4>{{$ar?'اللاعبون':'Players'}}</h4>
            @forelse($t->entries as $e)
                <span class="pill">{{ $e->user->username }}</span>
            @empty
                <p class="muted">{{$ar?'لا يوجد مسجلون بعد.':'No registered players yet.'}}</p>
            @endforelse
        </div>
    @empty
        <div class="mini-card">{{$ar?'لا توجد مسابقات بعد.':'No competitions yet.'}}</div>
    @endforelse
</div>
</div>

<script>
const tourUi=@json($ar ? [
 'seatUnit'=>'مقعد/لاعب','final'=>'نهائي فقط','semi'=>'نصف نهائي ثم نهائي','quarter'=>'ربع نهائي ثم نصف نهائي ثم نهائي','sixteen'=>'ثمن نهائي ثم ربع نهائي ثم نصف نهائي ثم نهائي',
 'create'=>'سيتم إنشاء منافسة من','deduct'=>'سيخصم من صاحب المنافسة','creationFee'=>'رسوم إنشاء','basePrize'=>'جائزة أساسية','tokens'=>'توكنز','required'=>'عدد المقاعد المطلوب','estimated'=>'الجائزة المتوقعة بعد امتلاء التسجيل','distribution'=>'توزيع تقديري','first'=>'الأول','second'=>'الثاني','semifinal'=>'المربع','winnerAll'=>'الفائز يأخذها كاملة','leaderboard'=>'XP/صدارة: الأول 1000، الثاني 600، نصف النهائي 350، ربع النهائي 150'
] : [
 'seatUnit'=>'seat/player','final'=>'Final only','semi'=>'Semi-final then final','quarter'=>'Quarter-final, semi-final, final','sixteen'=>'Round of 16, quarter-final, semi-final, final',
 'create'=>'Competition size','deduct'=>'Organizer deduction','creationFee'=>'creation fee','basePrize'=>'base prize','tokens'=>'tokens','required'=>'Required seats','estimated'=>'Estimated prize after registration fills','distribution'=>'Estimated distribution','first'=>'first','second'=>'second','semifinal'=>'semi-finalists','winnerAll'=>'winner takes all','leaderboard'=>'XP / leaderboard: first 1000, second 600, semi-final 350, quarter-final 150'
]);
function updateTourSeats(){
    const option = document.querySelector('#tourGameSelect')?.selectedOptions?.[0];
    const max = Number(option?.dataset.max || 4);
    const min = Number(option?.dataset.min || 2);
    const select = document.querySelector('#tourSeats');
    if(!select) return;
    [...select.options].forEach(opt => {
        const value = Number(opt.value);
        opt.disabled = value < min || value > max;
    });
    const preferred = [...select.options].find(opt => !opt.disabled && Number(opt.value) === max) || [...select.options].find(opt => !opt.disabled);
    if(preferred) select.value = preferred.value;
}
document.getElementById('tourGameSelect')?.addEventListener('change', updateTourSeats);
updateTourSeats();
function updateTourHint(){const st=Number(document.getElementById('tourStages')?.value||1), seats=Number(document.getElementById('tourSeats')?.value||2), entry=Number(document.querySelector('[name="entry_fee"]')?.value||0), prize=Number(document.querySelector('[name="prize_pool"]')?.value||0); const total=seats*Math.pow(2,st-1), creationFee=1000, expectedPrize=prize+Math.floor(total*entry*.90); let box=document.getElementById('tourHint'); if(!box){box=document.createElement('div'); box.id='tourHint'; box.className='tour-hint'; document.querySelector('.mega-tournament-form')?.appendChild(box);} const stage=st===1?tourUi.final:st===2?tourUi.semi:st===3?tourUi.quarter:tourUi.sixteen; box.innerHTML=tourUi.create+' <b>'+total+'</b> '+tourUi.seatUnit+' — '+stage; const cost=document.getElementById('tourCostBox'); if(cost){ const partner=seats>=4; const first=partner?Math.floor(expectedPrize*.55):expectedPrize; const second=partner?Math.floor(expectedPrize*.30):0; const semi=partner?Math.floor(expectedPrize*.10):0; cost.innerHTML='<span>'+tourUi.deduct+': <b>1000</b> '+tourUi.creationFee+' + <b>'+prize.toLocaleString()+ '</b> '+tourUi.basePrize+' = <b>'+(creationFee+prize).toLocaleString()+'</b> '+tourUi.tokens+'</span><span>'+tourUi.required+': <b>'+total+'</b></span><span>'+tourUi.estimated+': <b>'+expectedPrize.toLocaleString()+'</b></span><span>'+tourUi.distribution+': '+tourUi.first+' <b>'+first.toLocaleString()+'</b>'+(second?'، '+tourUi.second+' <b>'+second.toLocaleString()+'</b>، '+tourUi.semifinal+' <b>'+semi.toLocaleString()+'</b>':'، '+tourUi.winnerAll)+'</span><span>'+tourUi.leaderboard+'</span>'; }}
document.getElementById('tourStages')?.addEventListener('change',updateTourHint);document.getElementById('tourSeats')?.addEventListener('change',updateTourHint);document.querySelector('[name="entry_fee"]')?.addEventListener('input',updateTourHint);document.querySelector('[name="prize_pool"]')?.addEventListener('input',updateTourHint);updateTourHint();
</script>
@endsection
