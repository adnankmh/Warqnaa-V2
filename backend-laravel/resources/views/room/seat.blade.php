@php
$p = $player ?? null;
$english = app()->getLocale() === 'en';
$t = fn(string $ar, string $en) => $english ? $en : $ar;
$key = $p ? ($p->is_bot ? 'bot:'.$p->id : 'user:'.$p->user_id) : 'empty';
$isTurn = $p && (($room->state['turn'] ?? null) === $key);
$color = $p?->user?->profile?->name_color ?: ($p?->is_bot ? '#38bdf8' : '#facc15');
$avatar = $p ? ($p->is_bot ? bot_avatar_url($p->bot_key, (int)($p->id ?? 1)) : ($p->user?->profile?->avatar ?: '/assets/avatars/default.svg')) : bot_avatar_url('معتصم', 1);
$frame = $p?->user?->profile?->active_name_frame ?: ($p?->is_bot ? 'glow-ocean' : 'glow-gold');
$countryCode = $p?->user?->profile?->country_code ?? 'PS';
$isSeatedInRoom = $room->players->where('user_id',auth()->id())->count() > 0;
$seatState = (array)($room->state ?? []);
$lastPlayed = (array)($seatState['last_played_by_player'] ?? []);
$seatTricksMap = (array)($seatState['seat_tricks'] ?? []);
$lastRoundDeltaMap = (array)($seatState['last_round_score_delta'] ?? []);
$playerRoundDeltaMap = (array)($seatState['player_round_score_delta'] ?? []);
$playerTricks = (int)($seatTricksMap[$key] ?? 0);
$teamKey = in_array($p?->seat,['south','west'],true) ? 'teamA' : 'teamB';
$playerRoundDelta = (int)($playerRoundDeltaMap[$key] ?? $lastRoundDeltaMap[$teamKey] ?? 0);
$playerRoundDeltaLabel = ($playerRoundDelta > 0 ? '+' : '').$playerRoundDelta;
$lastCardCode = (string)($lastPlayed[$key] ?? '');
$prettyLastCard = $lastCardCode ? str_replace(['hearts','diamonds','spades','clubs','-'],['♥','♦','♠','♣',' '],$lastCardCode) : '—';
@endphp
@if($p)
 <div class="seat-box {{$p->is_bot ? 'bot-box' : 'human-box'}}">
  <button type="button" class="seat-profile player-glow {{$frame}} {{$p->is_bot ? 'bot-seat' : 'human-seat'}} {{$isTurn ? 'is-turn' : ''}}" data-player-key="{{$key}}" style="--player-color:{{$color}}" @if(!$p->is_bot && $p->user_id) onclick="openProfile({{$p->user_id}})" @endif>
   <span class="player-ring"><img loading="lazy" decoding="async" src="{{$avatar}}" alt="{{ $t('صورة اللاعب','Player avatar') }}"></span>
   <span class="player-name" style="color:{{$color}}">{{$p->user?->username ?: $p->bot_key}}</span>
   <small>@if($p->user){!! flag_img($countryCode) !!} {{country_name($countryCode)}} @else {{ $t('🤖 بوت جاهز','🤖 Bot ready') }} @endif • {{$seatName ?? $p->seat}} @if(!$p->connected) • {{ $t('منقطع','Disconnected') }} @endif</small>
  </button>
  @if($p->is_bot && !$room->players->where('user_id',auth()->id())->count())
   
  @endif
  @if($p->user_id && $p->user_id !== auth()->id() && (($room->owner_id === auth()->id() && (auth()->user()->profile?->pasha_days ?? 0) > 0) || auth()->user()->is_admin))
   <details class="pasha-seat-control pasha-seat-dropdown-v136"><summary>👑 {{ $t('خيارات الباشا','Pasha options') }}</summary><form method="post" action="{{route('rooms.replacePlayer', [$room->code, $p->id])}}" data-confirm="{{ $t('استبدال هذا اللاعب ببوت؟','Replace this player with a bot?') }}">@csrf<button type="submit">{{ $t('استبدال اللاعب ببوت','Replace player with bot') }}</button></form></details>
  @endif

  @if(!empty(($room->state['voice_room'] ?? false)) && !$p->is_bot)
   <div class="voice-seat-icons" title="{{ $t('تحكم صوت هذا اللاعب','Voice controls for this player') }}">
    @if($p->user_id===auth()->id())
     <button type="button" title="{{ $t('تشغيل المايك','Start microphone') }}" onclick="WarqnaVoice?.start()">🎙️</button>
     <button type="button" title="{{ $t('كتم/تشغيل نفسي','Mute or unmute myself') }}" onclick="WarqnaVoice?.mute()">🔇</button>
     <button type="button" title="{{ $t('إيقاف المايك','Stop microphone') }}" onclick="WarqnaVoice?.stop()">⏹️</button>
    @else
     <button type="button" title="{{ $t('كتم هذا اللاعب عندي فقط','Mute this player for me only') }}" onclick="WarqnaVoice?.mutePeer?.('{{$key}}')">🔇</button>
    @endif
   </div>
  @endif
  <div class="r91-seat-round-stats"><span>{{ $t('لمات اللاعب','Player tricks') }} <b>{{$playerTricks}}</b></span><span>{{ $t('نقاط الجولة','Round points') }} <b>{{$playerRoundDeltaLabel}}</b></span></div>
  <div class="r91-last-card"><small>{{ $t('آخر كرت لعبه','Last card played') }}</small><b>{{$prettyLastCard}}</b></div>
  <div class="seat-played-card" data-player-key="{{$key}}"></div>
 </div>
@else
 <div class="empty-seat bot-placeholder">
  <span class="player-ring"><img loading="lazy" decoding="async" src="{{ bot_avatar_url('معتصم',1) }}" alt="{{ $t('صورة المقعد الافتراضية','Default seat avatar') }}"></span><b>{{ $t('مقعد فارغ','Empty seat') }}</b><small>{{$seatName ?? ''}}</small>
  @unless($isSeatedInRoom)<form method="post" action="{{route('rooms.join',$room->code)}}">@csrf<input type="hidden" name="seat" value="{{$seat ?? ''}}"><button type="submit">{{ $t('اجلس هنا','Sit here') }}</button></form>@else<small class="seat-locked-v136">{{ $t('تم اختيار مقعدك، لا يمكن تغيير المكان داخل نفس اللعبة.','Your seat is selected and cannot be changed during this game.') }}</small>@endunless
 </div>
@endif
