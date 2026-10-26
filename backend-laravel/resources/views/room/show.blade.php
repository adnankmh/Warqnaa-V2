@extends('layouts.app')
@section('content')
@php
$state = $room->state ?: [];
$english = app()->getLocale() === 'en';
$t = fn(string $ar, string $en) => $english ? $en : $ar;
$gameName = $room->game->name[$english ? 'en' : 'ar'] ?? $room->game->name['ar'] ?? $room->game->key;
$phase = $state['phase'] ?? 'waiting';
$phaseLabel = match($phase) {
 'waiting' => $t('بانتظار اللاعبين','Waiting for players'),
 'bidding' => $t('مرحلة الطلب','Bidding'),
 'choose_trump' => $t('اختيار الطرنيب','Choose trump'),
 'finished' => $t('انتهت الجولة','Round finished'),
 default => $t('اللعب جارٍ','In progress'),
};
$fixedTimeout = max(5, min(10, (int)($state['turn_timeout_seconds'] ?? 7)));
$speedLabel = ($state['speed'] ?? 'medium')==='fast' ? $t('سريعة','Fast') : ((($state['speed'] ?? 'medium')==='slow') ? $t('بطيئة','Slow') : $t('متوسطة','Medium'));
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
$lastActionText = $state['messages'][count($state['messages'] ?? [])-1] ?? ($state['last_action']['action'] ?? $t('لم تبدأ الحركة بعد','No action yet'));
$gameKey = $room->game->key;
$handLike = in_array($gameKey,['hand','hand_partner','saudi_hand','banakil','pinochle','solitaire_multiplayer'],true);
$needsBid = in_array($gameKey,['tarneeb','tarneeb_400','tarneeb_41','estimation','hokm','kout4','kout6'],true);
$needsTrump = in_array($gameKey,['tarneeb','tarneeb_400','tarneeb_41','hokm','kout4','kout6','baloot'],true);
$seatClasses = ['south'=>'seat-south','north'=>'seat-north','west'=>'seat-west','east'=>'seat-east','south_west'=>'seat-south-west','south_east'=>'seat-south-east'];
$seatNames = ['south'=>$t('أنت / الجنوب','You / South'),'north'=>$t('الشريك / الشمال','Partner / North'),'west'=>$t('الغرب','West'),'east'=>$t('الشرق','East'),'south_west'=>$t('جنوب غرب','South West'),'south_east'=>$t('جنوب شرق','South East')];
$suitNames=['clubs'=>$t('♣ سنك','♣ Clubs'),'diamonds'=>$t('♦ ديناري','♦ Diamonds'),'spades'=>$t('♠ بستوني','♠ Spades'),'hearts'=>$t('♥ كبة','♥ Hearts')];

$teamAName = collect($seatPlayers)->filter(fn($p)=>in_array($p->seat,['south','west'],true))->map(fn($p)=>$p->user?->username ?: $p->bot_key)->filter()->implode(' + ') ?: $t('اللاعبون','Players');
$teamBName = collect($seatPlayers)->filter(fn($p)=>in_array($p->seat,['north','east'],true))->map(fn($p)=>$p->user?->username ?: $p->bot_key)->filter()->implode(' + ') ?: $t('المنافسون','Opponents');
$bidderName = $t('لم يُحسم بعد','Not decided yet');
if ($bidPlayerKey) {
 foreach (collect($seatPlayers)->filter() as $seatPlayer) {
  $playerStateKey = $seatPlayer->is_bot ? 'bot:'.$seatPlayer->id : 'user:'.$seatPlayer->user_id;
  if ($playerStateKey === $bidPlayerKey) { $bidderName = $seatPlayer->user?->username ?: $seatPlayer->bot_key ?: $t('لاعب','Player'); break; }
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
  <h3>{{ $t('غرفة','Room') }} {{$room->code}}</h3>
  <p><b>{{ $t('اللعبة:','Game:') }}</b> {{$gameName}}</p>
  <p><b>{{ $t('الحالة:','Status:') }}</b> <span class="status-pill">{{$phaseLabel}}</span></p>
  <p><b>{{ $t('اللاعبون:','Players:') }}</b> {{$room->players->where('is_bot',false)->count()}}/{{$room->max_players}}</p>
  <p class="speed-clean-v108"><b>{{ $t('سرعة الدور:','Turn timer:') }}</b> <b id="turnTimer">{{$fixedTimeout}}</b> {{ $t('ثوانٍ','seconds') }}</p>
  
   <div class="room-friend-invite-v132">
    <button type="button" onclick="document.getElementById('friendInviteBoxV132')?.classList.toggle('hidden')">📨 {{ $t('دعوة صديق','Invite friend') }}</button>
    <div id="friendInviteBoxV132" class="friend-invite-box-v132 hidden">
     <b>{{ $t('اختر صديقًا لدعوته لهذه اللعبة','Choose a friend to invite to this game') }}</b>
     @forelse($acceptedFriendsV132 as $fr)
      <form method="post" action="{{ route('rooms.invite',$room->code) }}">@csrf<input type="hidden" name="user_id" value="{{$fr->id}}"><button type="submit"><img loading="lazy" decoding="async" src="{{$fr->profile?->avatar ?: '/assets/avatars/default.svg'}}"> {{$fr->username}}</button></form>
     @empty
      <p class="muted">{{ $t('لا يوجد أصدقاء بعد. أرسل طلبات صداقة من صفحة اللاعبين.','No friends yet. Send friend requests from the players page.') }}</p>
     @endforelse
    </div>
   </div>

  <div class="score-card">
   <h4>{{ $t('النتيجة','Score') }}</h4>
   <div class="score-row"><span id="teamAName">{{$teamAName}}</span><b id="scoreA">{{$score['teamA'] ?? 0}}</b><small>{{ $t('لمات الجولة:','Round tricks:') }} <span id="tricksA">{{$roundTricks['teamA'] ?? 0}}</span> • {{ $t('نقاط الجولة:','Round points:') }} <strong>{{$roundDeltaALabel}}</strong></small></div>
   <div class="score-row"><span id="teamBName">{{$teamBName}}</span><b id="scoreB">{{$score['teamB'] ?? 0}}</b><small>{{ $t('لمات الجولة:','Round tricks:') }} <span id="tricksB">{{$roundTricks['teamB'] ?? 0}}</span> • {{ $t('نقاط الجولة:','Round points:') }} <strong>{{$roundDeltaBLabel}}</strong></small></div>
   @if($needsBid)
    <div class="score-meta request-only tarneeb-request-meta-r91"><span>{{ $t('الطلب الحالي','Current bid') }}</span><b id="currentBid">{{$bid ? ($bid['value'] ?? '—') : $t('لا يوجد','None')}}</b><small>{{ $t('صاحب الطلب:','Bidder:') }} <strong id="currentBidder">{{$bidderName}}</strong></small></div>
   @endif
   @if($needsTrump)
    <div class="score-meta trump-only">{{ $t('الطرنيب:','Trump:') }} <b id="currentTrump">{{$trump ? ($suitNames[$trump] ?? $trump) : $t('لم يحدد','Not set')}}</b></div>
   @endif
   <div class="score-meta">{{ $t('نمط المباراة:','Match mode:') }} <b>{{ $singleRound ? $t('جولة واحدة','Single round') : $t('متعددة الجولات','Multiple rounds') }}</b></div>
   <div class="score-meta">{{ $t('آخر حركة:','Last action:') }} <b id="lastActionMeta">{{$lastActionText}}</b></div>
  </div>
  @if((auth()->user()->profile?->pasha_days ?? 0)>0)
   @php $isAway = !empty(($state['away_players'] ?? [])[$myKey]); @endphp
   <div class="away-status {{$isAway ? 'active' : ''}}">{{$isAway ? $t('🟡 أنت الآن في وضع الغائب، الكمبيوتر يلعب بدلك.','🟡 Away mode is active; the computer is playing for you.') : $t('🟢 أنت حاضر وتلعب بنفسك.','🟢 You are present and playing.') }}</div>
   <form method="post" action="{{route('rooms.away',$room->code)}}" data-confirm="{{ $t('تفعيل/إلغاء وضع الغائب؟ الكمبيوتر سيلعب بدلًا عنك مؤقتًا.','Toggle away mode? The computer will play for you temporarily.') }}">@csrf<button type="submit" class="btn big-action away-btn">{{$isAway ? $t('✅ العودة للعب بنفسي','✅ Return to playing') : $t('🕒 تفعيل وضع الغائب','🕒 Enable away mode')}}</button></form>
  @endif
  <form method="post" action="{{route('rooms.leave',$room->code)}}" data-confirm="{{ $t('هل تريد الخروج من اللعبة؟ إذا خرجت 5 مرات يدويًا من هذه الغرفة نفسها فلن تستطيع العودة إلى هذه الغرفة فقط.','Leave this game? After five manual exits from this room, you cannot return to this room.') }}">@csrf<button class="danger big-action">🚪 {{ $t('خروج والعودة لغرف','Leave and return to') }} {{$gameName}}</button></form>
  <a class="btn big-action" href="{{route('rooms.index',$room->game->key)}}">{{ $t('العودة للغرف','Back to rooms') }}</a>
 </aside>
 <section class="table-wrap">
  <div class="game-table premium-table responsive-table seats-{{$room->max_players}} {{$handLike ? 'hand-like-table' : 'single-row-table'}} {{$activeTableSkin}} {{auth()->user()->profile?->active_effect}} {{!empty($activeTableImage) ? 'has-table-art' : ''}}" data-player-name="{{ auth()->user()->profile?->display_name ?? auth()->user()->username }}" @if(!empty($activeTableImage)) style="--r101-table-art:url('{{$activeTableImage}}');" @endif>
   @if($approvedTableDesign = \App\Support\R48TableArtwork::design($activeTableSkin))
    <picture class="r48-table-art" aria-hidden="true">
     <source media="(orientation: portrait) and (max-width: 900px)" srcset="{{ \App\Support\R48TableArtwork::url($activeTableSkin, true) }}">
     <img src="{{ \App\Support\R48TableArtwork::url($activeTableSkin) }}" alt="" draggable="false">
    </picture>
   @elseif(!empty($activeTableImage))
    <picture class="r48-table-art r52-catalog-table-art" data-showcase="{{ str_contains((string)$activeTableSkin,'showcase')?'true':'false' }}" aria-hidden="true">
     <img src="{{ $activeTableImage }}" alt="" draggable="false">
    </picture>
   @endif
   <div class="table-aura"></div>
   <div class="deck-stack"><span></span><span></span><span></span></div>
   @if(($room->owner_id===auth()->id() || auth()->user()->is_admin) && $phase==='waiting')
    <form id="centerStartForm" class="center-start-form" method="post" action="{{route('rooms.start',$room->code)}}" data-ajax-start="1">@csrf<button class="primary start-game-orb" type="submit">▶️ {{ $t('بدء اللعبة','Start game') }}</button></form>
   @endif
   @foreach($seats as $seat)
    <div class="player-seat {{$seatClasses[$seat] ?? ''}}" data-seat="{{$seat}}">
     @include('room.seat',['player'=>$seatPlayers[$seat] ?? null,'seatName'=>$seatNames[$seat] ?? $seat,'seat'=>$seat])
    </div>
   @endforeach
   <div class="center-board">
    <div class="phase-title" id="phaseTitle">{{$phaseLabel}}</div>
    <div class="last-trick" id="lastAction">{{$lastActionText}}</div>
    <div class="center-status-grid r91-tarneeb-clarity-grid">
      @if($needsBid)<div class="r91-status-hot"><small>{{ $t('الطلب','Bid') }}</small><b id="centerBidValue">{{$bid['value'] ?? '—'}}</b></div>@endif
      @if($needsBid)<div class="r91-status-hot"><small>{{ $t('صاحب الطلب','Bidder') }}</small><b id="centerBidderName">{{$bidderName}}</b></div>@endif
      <div class="r91-status-hot"><small>{{ $t('الطرنيب','Trump') }}</small><b>{{ $trump ? ($suitNames[$trump] ?? $trump) : $t('بانتظار الاختيار','Waiting for selection') }}</b></div>
      <div><small>{{ $t('لمات الجولة','Round tricks') }}</small><b>{{(int)($roundTricks['teamA'] ?? 0)}} — {{(int)($roundTricks['teamB'] ?? 0)}}</b></div>
      <div><small>{{ $t('نقاط آخر جولة','Last round points') }}</small><b>{{$roundDeltaALabel}} — {{$roundDeltaBLabel}}</b></div>
      <div><small>{{ $t('نمط الغرفة','Room mode') }}</small><b>{{ $singleRound ? $t('جولة واحدة','Single round') : $t('متعددة الجولات','Multiple rounds') }}</b></div>
      <div><small>{{ $t('السرعة','Speed') }}</small><b>{{$fixedTimeout}} {{ $t('ثوانٍ','seconds') }}</b></div>
      <div><small>{{ $t('آخر حركة','Last action') }}</small><b id="lastActionCenter">{{$lastActionText}}</b></div>
    </div>
    <div id="tableTrick" class="table-trick"></div>
     @if($handLike)
      <section id="r44OwnerMelds" class="r44-owner-zone" aria-label="{{ $t('مجموعات الورق المنزلة','Melded card groups') }}" hidden></section>
      <section id="r44RoomPiles" class="r44-room-piles" aria-label="{{ $t('حزمتا السحب والرمي','Stock and discard piles') }}"></section>
     @endif
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

    <div id="lastTrickMini" class="last-trick-mini hidden"><b>{{ $t('اللفة السابقة','Previous trick') }}</b><div></div></div>
   </div>
   <div class="bid-panel action-panel game-action-panel action-panel-{{$room->game->key}} {{$handLike ? 'hand-controls-panel' : ''}}" id="actionPanel">
     <div class="tarneeb-request-panel">
      <div class="tarneeb-request-title">{{ $t('مرحلة الطلب','Bidding') }}</div>
      <button data-action="pass" class="pass-btn tarneeb-pass">{{ $t('تمرير','Pass') }}</button>
      <div class="tarneeb-bid-grid">
       @for($i=7;$i<=13;$i++) <button data-action="bid" data-value="{{$i}}" class="tarneeb-bid pro-bid-btn" title="{{ $t('اعتماد طلب','Bid') }} {{$i}}"><span>{{$i}}</span></button> @endfor
      </div>
      <div class="estimation-bid-grid">
       @for($i=0;$i<=6;$i++) <button data-action="bid" data-value="{{$i}}" class="estimation-bid">{{$i}}</button> @endfor
      </div>
     </div>
     <div class="trump-chooser-panel">
      <div class="trump-title">{{ $t('اختر نوع الطرنيب بعد تأكيد الطلب','Choose trump after confirming the bid') }}</div>
      <button data-action="choose_trump" data-suit="hearts" class="trump-card red-suit"><b>♥</b><span>{{ $t('كبة','Hearts') }}</span></button>
      <button data-action="choose_trump" data-suit="diamonds" class="trump-card red-suit"><b>♦</b><span>{{ $t('ديناري','Diamonds') }}</span></button>
      <button data-action="choose_trump" data-suit="spades" class="trump-card black-suit"><b>♠</b><span>{{ $t('بستوني','Spades') }}</span></button>
      <button data-action="choose_trump" data-suit="clubs" class="trump-card black-suit"><b>♣</b><span>{{ $t('سباتي','Clubs') }}</span></button>
     </div>
     <button data-action="draw_deck" class="hand-btn">{{ $t('اسحب من الرزمة','Draw stock') }}</button><button data-action="draw_discard" class="hand-btn">{{ $t('اسحب من الرمي','Draw discard') }}</button><button type="button" class="meld-btn hand-btn" onclick="meldSelectedCards()">{{ $t('تجميع المحدد','Group selected') }}</button><button type="button" class="meld-btn hand-btn" onclick="arrangeMelds()">{{ $t('اعتماد ترتيب المجموعات','Confirm groups') }}</button><button type="button" class="sort-btn hand-btn" onclick="sortHandVisual()">{{ $t('ترتيب الورق','Sort cards') }}</button>
     <button data-action="roll" class="backgammon-btn">🎲 {{ $t('رمي النرد','Roll dice') }}</button><button data-action="draw" class="domino-btn">{{ $t('اسحب دومينو','Draw domino') }}</button>
    </div>
    @if($handLike)
    <div class="meld-zone" id="meldZone"><b>{{ $t('مجموعاتك الجاهزة للنزول','Groups ready to meld') }}</b><small>{{ $t('اسحب الورق هنا أو حدده ثم اضغط نزّل مجموعة. يسمح بإعادة ترتيب المجموعات حسب القانون.','Drag cards here or select them, then meld the group. Groups remain reorderable within the rules.') }}</small><div id="myMelds"><div class="meld-slot" data-cards="[]">{{ $t('ضع المجموعة هنا','Place group here') }}</div><div class="meld-slot" data-cards="[]">{{ $t('مجموعة أخرى','Another group') }}</div><div class="meld-slot" data-cards="[]">{{ $t('مجموعة ثالثة','Third group') }}</div></div></div>
   @endif
   <div class="hand-label">{{ $t('أوراقك','Your cards') }}</div>
   <div class="hand-row pro-hand" id="myHand"></div>
   @if($handLike)<div class="hand-quick-controls"><button type="button" data-action="draw_deck">{{ $t('اسحب من الرزمة','Draw stock') }}</button><button type="button" data-action="draw_discard">{{ $t('اسحب من الرمي','Draw discard') }}</button><button type="button" onclick="sortHandVisual()">{{ $t('رتّب الورق','Sort cards') }}</button><button type="button" onclick="meldSelectedCards()">{{ $t('نزّل مجموعة','Meld group') }}</button></div>@endif
   <div class="game-log" id="gameLog"></div>
</div>
  </div>
 </section>

 @if(!empty(($state['voice_room'] ?? false)))
 <aside id="voiceRoomPanel" class="voice-room-panel pro-panel">
  <div class="voice-head"><b>🎙️ {{ $t('اللعبة الصوتية','Voice game') }}</b><small>{{ $t('تم خصم 100 توكنز من كل لاعب ينضم لهذه الغرفة الصوتية.','100 tokens are deducted from every player who joins this voice room.') }}</small></div>
  <div class="voice-status" id="voiceStatus">{{ $t('اضغط تشغيل المايك للسماح بالصوت.','Start the microphone to enable voice.') }}</div>
  <div class="voice-controls">
   <button type="button" class="primary voice-icon-only" title="{{ $t('تشغيل المايك','Start microphone') }}" onclick="WarqnaVoice?.start()">🎙️</button>
   <button type="button" class="voice-icon-only" title="{{ $t('كتم/تشغيل','Mute or unmute') }}" onclick="WarqnaVoice?.mute()">🔇</button>
   <button type="button" class="danger voice-icon-only" title="{{ $t('إيقاف','Stop') }}" onclick="WarqnaVoice?.stop()">⏹️</button>
  </div>
  <div id="voicePeers" class="voice-peers"><small>{{ $t('يمكنك كتم أي لاعب من الأيقونات أمام اسمه على الطاولة.','You can mute any player using the icon beside their name.') }}</small></div><div class="voice-note">{{ $t('ملاحظة تقنية: اسمح للمايك من المتصفح. للصوت بين الأجهزة شغّل سيرفر Socket/WebRTC من ملفات المشروع.','Technical note: allow microphone access in the browser. Cross-device voice requires the project Socket/WebRTC server.') }}</div>
 </aside>
 @endif
 <aside id="gameRoomChat" class="game-room-chat pro-panel">
  <div class="game-room-chat-head"><b>💬 {{ $t('دردشة اللعبة','Game chat') }}</b><small>{{ $t('ظاهرة فقط للاعبين داخل هذه الغرفة','Visible only to players in this room') }}</small></div>
  <div id="gameRoomChatBody" class="game-room-chat-body"><p class="muted">{{ $t('اكتب رسالتك وسيشاهدها كل لاعبي الغرفة.','Write a message for everyone in the room.') }}</p></div>
  <form id="gameRoomChatForm" class="game-room-chat-form" onsubmit="sendEmbeddedRoomChat(event)">
   <input id="gameRoomChatInput" maxlength="500" placeholder="{{ $t('اكتب رسالة داخل اللعبة...','Write a game message...') }}">
   <button type="submit">{{ $t('إرسال','Send') }}</button>
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
@if($handLike)
<script src="{{ asset('assets/js/r44-room-rummy.js') }}?v=85" defer></script>
@endif
@endsection
