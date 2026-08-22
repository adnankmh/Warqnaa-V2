@extends('layouts.app')
@section('content')
@php
$state = $room->state ?: [];
$phase = $state['phase'] ?? 'waiting';
$fixedTimeout = max(5, min(10, (int)($state['turn_timeout_seconds'] ?? 7)));
$speedLabel = ($state['speed'] ?? 'medium')==='fast' ? 'سريعة' : ((($state['speed'] ?? 'medium')==='slow') ? 'بطيئة' : 'متوسطة');
$score = $state['score'] ?? ['teamA'=>0,'teamB'=>0];
$roundTricks = $state['round_tricks'] ?? ['teamA'=>0,'teamB'=>0];
$bid = $state['bid'] ?? null;
$bidPlayerKey = is_array($bid) ? ($bid['player'] ?? null) : null;
$lastPlayedByPlayer = (array)($state['last_played_by_player'] ?? []);
$seatTricks = (array)($state['seat_tricks'] ?? []);
$lastRoundScoreDelta = (array)($state['last_round_score_delta'] ?? ['teamA'=>0,'teamB'=>0]);
$trump = $state['trump'] ?? null;
$singleRound = (bool)($state['single_round'] ?? false);
$lastTrick = $state['last_trick'] ?? [];
$lastActionText = $state['messages'][count($state['messages'] ?? [])-1] ?? ($state['last_action']['action'] ?? 'لم تبدأ الحركة بعد');
$gameKey = $room->game->key;
$handLike = in_array($gameKey,['hand','hand_partner','saudi_hand','banakil','pinochle','solitaire_multiplayer'],true);
$needsBid = in_array($gameKey,['tarneeb','tarneeb_400','tarneeb_41','estimation','hokm','kout4','kout6'],true);
$needsTrump = in_array($gameKey,['tarneeb','tarneeb_400','tarneeb_41','hokm','kout4','kout6','baloot'],true);
$seatClasses = ['south'=>'seat-south','north'=>'seat-north','west'=>'seat-west','east'=>'seat-east','south_west'=>'seat-south-west','south_east'=>'seat-south-east'];
$seatNames = ['south'=>'أنت / الجنوب','north'=>'الشريك / الشمال','west'=>'الغرب','east'=>'الشرق','south_west'=>'جنوب غرب','south_east'=>'جنوب شرق'];
$suitNames=['clubs'=>'♣ سنك','diamonds'=>'♦ ديناري','spades'=>'♠ بستوني','hearts'=>'♥ كبة'];

$teamAName = collect($seatPlayers)->filter(fn($p)=>in_array($p->seat,['south','west'],true))->map(fn($p)=>$p->user?->username ?: $p->bot_key)->filter()->implode(' + ') ?: 'اللاعبون';
$teamBName = collect($seatPlayers)->filter(fn($p)=>in_array($p->seat,['north','east'],true))->map(fn($p)=>$p->user?->username ?: $p->bot_key)->filter()->implode(' + ') ?: 'المنافسون';
$bidderName = 'لم يُحسم بعد';
if ($bidPlayerKey) {
 foreach (collect($seatPlayers)->filter() as $seatPlayer) {
  $playerStateKey = $seatPlayer->is_bot ? 'bot:'.$seatPlayer->id : 'user:'.$seatPlayer->user_id;
  if ($playerStateKey === $bidPlayerKey) { $bidderName = $seatPlayer->user?->username ?: $seatPlayer->bot_key ?: 'لاعب'; break; }
 }
}
$roundDeltaA = (int)($lastRoundScoreDelta['teamA'] ?? 0);
$roundDeltaB = (int)($lastRoundScoreDelta['teamB'] ?? 0);
$roundDeltaALabel = ($roundDeltaA > 0 ? '+' : '').$roundDeltaA;
$roundDeltaBLabel = ($roundDeltaB > 0 ? '+' : '').$roundDeltaB;
@endphp

@php
$acceptedFriendsV132=\App\Models\Friendship::with(['requester.profile','addressee.profile'])
 ->where('status','accepted')
 ->where(function($q){$q->where('requester_id',auth()->id())->orWhere('addressee_id',auth()->id());})
 ->get()
 ->map(fn($f)=>$f->requester_id===auth()->id()?$f->addressee:$f->requester)
 ->filter();
@endphp

<div class="room-shell pro-room v108-room-shell room-wide-v131" data-room="{{$room->code}}" data-game="{{$gameKey}}">
 <aside class="room-info pro-panel compact-panel">
  <h3>غرفة {{$room->code}}</h3>
  <p><b>اللعبة:</b> {{$room->game->name['ar'] ?? $room->game->key}}</p>
  <p><b>الحالة:</b> <span class="status-pill">{{$phase}}</span></p>
  <p><b>اللاعبون:</b> {{$room->players->where('is_bot',false)->count()}}/{{$room->max_players}}</p>
  <p class="speed-clean-v108"><b>سرعة الدور:</b> <b id="turnTimer">{{$fixedTimeout}}</b> ثواني فقط</p>
  
   <div class="room-friend-invite-v132">
    <button type="button" onclick="document.getElementById('friendInviteBoxV132')?.classList.toggle('hidden')">📨 دعوة صديق</button>
    <div id="friendInviteBoxV132" class="friend-invite-box-v132 hidden">
     <b>اختر صديقًا لدعوته لهذه اللعبة</b>
     @forelse($acceptedFriendsV132 as $fr)
      <form method="post" action="{{ route('rooms.invite',$room->code) }}">@csrf<input type="hidden" name="user_id" value="{{$fr->id}}"><button type="submit"><img loading="lazy" decoding="async" src="{{$fr->profile?->avatar ?: '/assets/avatars/default.svg'}}"> {{$fr->username}}</button></form>
     @empty
      <p class="muted">لا يوجد أصدقاء بعد. أرسل طلبات صداقة من صفحة اللاعبين.</p>
     @endforelse
    </div>
   </div>

  <div class="score-card">
   <h4>النتيجة</h4>
   <div class="score-row"><span id="teamAName">{{$teamAName}}</span><b id="scoreA">{{$score['teamA'] ?? 0}}</b><small>لمات الجولة: <span id="tricksA">{{$roundTricks['teamA'] ?? 0}}</span> • نقاط الجولة: <strong>{{$roundDeltaALabel}}</strong></small></div>
   <div class="score-row"><span id="teamBName">{{$teamBName}}</span><b id="scoreB">{{$score['teamB'] ?? 0}}</b><small>لمات الجولة: <span id="tricksB">{{$roundTricks['teamB'] ?? 0}}</span> • نقاط الجولة: <strong>{{$roundDeltaBLabel}}</strong></small></div>
   @if($needsBid)
    <div class="score-meta request-only tarneeb-request-meta-r91"><span>الطلب الحالي</span><b id="currentBid">{{$bid ? ($bid['value'] ?? '—') : 'لا يوجد'}}</b><small>صاحب الطلب: <strong id="currentBidder">{{$bidderName}}</strong></small></div>
   @endif
   @if($needsTrump)
    <div class="score-meta trump-only">الطرنيب: <b id="currentTrump">{{$trump ? ($suitNames[$trump] ?? $trump) : 'لم يحدد'}}</b></div>
   @endif
   <div class="score-meta">نمط المباراة: <b>{{ $singleRound ? 'جولة واحدة' : 'متعددة الجولات' }}</b></div>
   <div class="score-meta">آخر حركة: <b id="lastActionMeta">{{$lastActionText}}</b></div>
  </div>
  @if((auth()->user()->profile?->pasha_days ?? 0)>0)
   @php $isAway = !empty(($state['away_players'] ?? [])[$myKey]); @endphp
   <div class="away-status {{$isAway ? 'active' : ''}}">{{$isAway ? '🟡 أنت الآن في وضع الغائب، الكمبيوتر يلعب بدلك.' : '🟢 أنت حاضر وتلعب بنفسك.'}}</div>
   <form method="post" action="{{route('rooms.away',$room->code)}}" data-confirm="تفعيل/إلغاء وضع الغائب؟ الكمبيوتر سيلعب بدلًا عنك مؤقتًا.">@csrf<button type="submit" class="btn big-action away-btn">{{$isAway ? '✅ العودة للعب بنفسي' : '🕒 تفعيل وضع الغائب'}}</button></form>
  @endif
  <form method="post" action="{{route('rooms.leave',$room->code)}}" data-confirm="هل تريد الخروج من اللعبة؟ إذا خرجت 5 مرات يدويًا من هذه الغرفة نفسها فلن تستطيع العودة إلى هذه الغرفة فقط.">@csrf<button class="danger big-action">🚪 خروج والعودة لغرف {{$room->game->name['ar'] ?? $room->game->key}}</button></form>
  <a class="btn big-action" href="{{route('rooms.index',$room->game->key)}}">العودة للغرف</a>
 </aside>
 <section class="table-wrap">
  <div class="game-table premium-table responsive-table seats-{{$room->max_players}} {{$handLike ? 'hand-like-table' : 'single-row-table'}} {{$activeTableSkin}} {{auth()->user()->profile?->active_effect}} {{!empty($activeTableImage) ? 'has-table-art' : ''}}" data-player-name="{{ auth()->user()->profile?->display_name ?? auth()->user()->username }}" @if(!empty($activeTableImage)) style="--r101-table-art:url('{{$activeTableImage}}');" @endif>
   <div class="table-aura"></div>
   <div class="deck-stack"><span></span><span></span><span></span></div>
   @if(($room->owner_id===auth()->id() || auth()->user()->is_admin) && $phase==='waiting')
    <form id="centerStartForm" class="center-start-form" method="post" action="{{route('rooms.start',$room->code)}}" data-ajax-start="1">@csrf<button class="primary start-game-orb" type="submit">▶️ بدء اللعبة</button></form>
   @endif
   @foreach($seats as $seat)
    <div class="player-seat {{$seatClasses[$seat] ?? ''}}" data-seat="{{$seat}}">
     @include('room.seat',['player'=>$seatPlayers[$seat] ?? null,'seatName'=>$seatNames[$seat] ?? $seat,'seat'=>$seat])
    </div>
   @endforeach
   <div class="center-board">
    <div class="phase-title" id="phaseTitle">{{ $phase==='waiting' ? 'بانتظار بدء الجولة' : ($phase==='bidding' ? 'مرحلة الطلب' : ($phase==='choose_trump' ? 'اختيار الطرنيب' : ($phase==='finished' ? 'انتهت الجولة' : 'اللعب جارٍ'))) }}</div>
    <div class="last-trick" id="lastAction">{{$lastActionText}}</div>
    <div class="center-status-grid r91-tarneeb-clarity-grid">
      @if($needsBid)<div class="r91-status-hot"><small>الطلب</small><b id="centerBidValue">{{$bid['value'] ?? '—'}}</b></div>@endif
      @if($needsBid)<div class="r91-status-hot"><small>صاحب الطلب</small><b id="centerBidderName">{{$bidderName}}</b></div>@endif
      <div class="r91-status-hot"><small>الطرنيب</small><b>{{ $trump ? ($suitNames[$trump] ?? $trump) : 'بانتظار الاختيار' }}</b></div>
      <div><small>لمات الجولة</small><b>{{(int)($roundTricks['teamA'] ?? 0)}} — {{(int)($roundTricks['teamB'] ?? 0)}}</b></div>
      <div><small>نقاط آخر جولة</small><b>{{$roundDeltaALabel}} — {{$roundDeltaBLabel}}</b></div>
      <div><small>نمط الغرفة</small><b>{{ $singleRound ? 'جولة واحدة' : 'متعددة الجولات' }}</b></div>
      <div><small>السرعة</small><b>{{$fixedTimeout}} ثوانٍ</b></div>
      <div><small>آخر حركة</small><b id="lastActionCenter">{{$lastActionText}}</b></div>
    </div>
    <div id="tableTrick" class="table-trick"></div>
    <div class="quick-reactions-mini-v132">
     <button type="button" class="reaction-toggle-v132" onclick="document.getElementById('quickReactionsV132')?.classList.toggle('hidden')">⚡</button>
     <div id="quickReactionsV132" class="quick-reactions-box-v132 hidden">
      <button type="button" onclick="sendEmojiChat?.('🔥')">🔥</button>
      <button type="button" onclick="sendEmojiChat?.('😂')">😂</button>
      <button type="button" onclick="sendEmojiChat?.('👑')">👑</button>
      <button type="button" onclick="sendEmojiChat?.('👏')">👏</button>
      <button type="button" onclick="sendEmojiChat?.('😮')">😮</button>
     </div>
    </div>

    <div id="lastTrickMini" class="last-trick-mini hidden"><b>اللفة السابقة</b><div></div></div>
   </div>
   <div class="bid-panel action-panel game-action-panel action-panel-{{$room->game->key}} {{$handLike ? 'hand-controls-panel' : ''}}" id="actionPanel">
     <div class="tarneeb-request-panel">
      <div class="tarneeb-request-title">مرحلة الطلب</div>
      <button data-action="pass" class="pass-btn tarneeb-pass">تمرير</button>
      <div class="tarneeb-bid-grid">
       @for($i=7;$i<=13;$i++) <button data-action="bid" data-value="{{$i}}" class="tarneeb-bid pro-bid-btn" title="اعتماد طلب {{$i}}"><span>{{$i}}</span></button> @endfor
      </div>
      <div class="estimation-bid-grid">
       @for($i=0;$i<=6;$i++) <button data-action="bid" data-value="{{$i}}" class="estimation-bid">{{$i}}</button> @endfor
      </div>
     </div>
     <div class="trump-chooser-panel">
      <div class="trump-title">اختر نوع الطرنيب بعد تأكيد الطلب</div>
      <button data-action="choose_trump" data-suit="hearts" class="trump-card red-suit"><b>♥</b><span>كبة</span></button>
      <button data-action="choose_trump" data-suit="diamonds" class="trump-card red-suit"><b>♦</b><span>ديناري</span></button>
      <button data-action="choose_trump" data-suit="spades" class="trump-card black-suit"><b>♠</b><span>بستوني</span></button>
      <button data-action="choose_trump" data-suit="clubs" class="trump-card black-suit"><b>♣</b><span>سباتي</span></button>
     </div>
     <button data-action="draw_deck" class="hand-btn">اسحب من الدك</button><button data-action="draw_discard" class="hand-btn">اسحب من الرمي</button><button type="button" class="meld-btn hand-btn" onclick="meldSelectedCards()">تجميع المحدد</button><button type="button" class="meld-btn hand-btn" onclick="arrangeMelds()">اعتماد ترتيب المجموعات</button><button type="button" class="sort-btn hand-btn" onclick="sortHandVisual()">ترتيب الورق</button>
     <button data-action="roll" class="backgammon-btn">🎲 رمي النرد</button><button data-action="draw" class="domino-btn">اسحب دومينو</button>
    </div>
    @if($handLike)
    <div class="meld-zone" id="meldZone"><b>مجموعاتك الجاهزة للنزول</b><small>اسحب الورق هنا أو حدده ثم اضغط نزّل مجموعة. يسمح بإعادة ترتيب المجموعات حسب القانون.</small><div id="myMelds"><div class="meld-slot" data-cards="[]">ضع المجموعة هنا</div><div class="meld-slot" data-cards="[]">مجموعة أخرى</div><div class="meld-slot" data-cards="[]">مجموعة ثالثة</div></div></div>
   @endif
   <div class="hand-label">أوراقك</div>
   <div class="hand-row pro-hand" id="myHand"></div>
   @if($handLike)<div class="hand-quick-controls"><button type="button" onclick="roomAction('draw_deck')">اسحب من الدك</button><button type="button" onclick="roomAction('draw_discard')">اسحب من الرمي</button><button type="button" onclick="sortHandVisual()">رتّب الورق</button><button type="button" onclick="meldSelectedCards()">نزّل مجموعة</button></div>@endif
   <div class="game-log" id="gameLog"></div>
</div>
  </div>
 </section>

 @if(!empty(($state['voice_room'] ?? false)))
 <aside id="voiceRoomPanel" class="voice-room-panel pro-panel">
  <div class="voice-head"><b>🎙️ اللعبة الصوتية</b><small>تم خصم 100 توكنز من كل لاعب ينضم لهذه الغرفة الصوتية.</small></div>
  <div class="voice-status" id="voiceStatus">اضغط تشغيل المايك للسماح بالصوت.</div>
  <div class="voice-controls">
   <button type="button" class="primary voice-icon-only" title="تشغيل المايك" onclick="WarqnaVoice?.start()">🎙️</button>
   <button type="button" class="voice-icon-only" title="كتم/تشغيل" onclick="WarqnaVoice?.mute()">🔇</button>
   <button type="button" class="danger voice-icon-only" title="إيقاف" onclick="WarqnaVoice?.stop()">⏹️</button>
  </div>
  <div id="voicePeers" class="voice-peers"><small>يمكنك كتم أي لاعب من الأيقونات أمام اسمه على الطاولة.</small></div><div class="voice-note">ملاحظة تقنية: اسمح للمايك من المتصفح. للصوت بين الأجهزة شغّل سيرفر Socket/WebRTC من ملفات المشروع.</div>
 </aside>
 @endif
 <aside id="gameRoomChat" class="game-room-chat pro-panel">
  <div class="game-room-chat-head"><b>💬 دردشة اللعبة</b><small>ظاهرة فقط للاعبين داخل هذه الغرفة</small></div>
  <div id="gameRoomChatBody" class="game-room-chat-body"><p class="muted">اكتب رسالتك وسيشاهدها كل لاعبي الغرفة.</p></div>
  <form id="gameRoomChatForm" class="game-room-chat-form" onsubmit="sendEmbeddedRoomChat(event)">
   <input id="gameRoomChatInput" maxlength="500" placeholder="اكتب رسالة داخل اللعبة...">
   <button type="submit">إرسال</button>
  </form>
 </aside>

</div>
<script>
window.ROOM_CODE=@json($room->code);
window.ROOM_ACTION_URL=@json(route('rooms.action',$room->code));
window.ROOM_TIMEOUT_URL=@json(route('rooms.timeout',$room->code));
window.ROOM_SYNC_URL=@json(route('rooms.sync',$room->code));
window.ROOM_CHAT_URL=@json(route('rooms.chat',$room->code));
window.ROOM_PRESENCE_URL=@json(route('rooms.presence',$room->code));
window.ROOM_TURN_TIMEOUT={{$fixedTimeout}};
window.CSRF=@json(csrf_token());
window.MY_PLAYER_KEY=@json($myKey);
window.INITIAL_STATE=@json($state);
window.INITIAL_HAND=@json($myHand);
window.MY_CARD_BACK=@json($activeCardBack);
window.MY_CARD_BACK_IMAGE=@json($activeCardBackImage);
window.GAME_KEY=@json($gameKey);
window.HAND_LIKE={{$handLike ? 'true' : 'false'}};
</script>
@endsection
