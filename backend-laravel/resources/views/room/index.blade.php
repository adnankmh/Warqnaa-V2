@extends('layouts.app')
@section('content')
@php
$userLevel = (int)(auth()->user()->profile?->level ?? 1);
$english = app()->getLocale() === 'en';
$t = fn(string $ar, string $en) => $english ? $en : $ar;
$gameName = $game->name[$english ? 'en' : 'ar'] ?? $game->name['ar'] ?? $game->key;
$isTarneeb = in_array($game->key,['tarneeb','tarneeb_400','tarneeb_41'],true);
$targets = $isTarneeb ? [31,41,61] : ((array)($game->rules['targets'] ?? []));
@endphp
<h1>{{ $t('غرف','Rooms for') }} {{ $gameName }}</h1>
<p class="muted">{{ $t('قوانين اللعبة في صفحة القوانين فقط.','Game rules are available on the rules page.') }} <a class="btn" href="{{route('game.rules')}}#game-{{$game->key}}">{{ $t('عرض القوانين','View rules') }}</a></p>
<div class="rooms-layout">
 <section class="leaders"><h3>{{ $t('المتصدرون','Leaders') }}</h3>@foreach($leaders as $u)<div>{!! flag_img($u->profile?->country_code) !!} {{$u->username}} • {{number_format($u->profile?->games_played ?? 0)}} {{ $t('لعبة','games') }}</div>@endforeach</section>
 <section class="rooms-list">
  @forelse($rooms as $room)
   <div class="room-card"><a href="{{route('rooms.show',$room->code)}}"><b>{{ $t('غرفة','Room') }} {{ $room->code }}</b></a><span class="room-status-pill">{{ $room->status==='waiting' ? $t('مفتوحة','Open') : ($room->status==='playing' ? $t('جارية','In progress') : $room->status) }} • {{ $room->players->count() }}/{{$room->max_players}}</span><div>@foreach($room->players as $p)<span class="seat-mini"><img loading="lazy" decoding="async" src="{{$p->user?->profile?->avatar ?: ($p->is_bot?'/assets/bots/player.svg':'/assets/avatars/default.svg')}}" alt=""> {{$p->user?->username ?: $p->bot_key}}</span>@endforeach</div>@unless($room->players->contains('user_id',auth()->id()))<form method="post" action="{{route('rooms.join',$room->code)}}">@csrf @if($room->visibility==='private')<input name="password" placeholder="{{ $t('كلمة السر','Password') }}" aria-label="{{ $t('كلمة سر الغرفة','Room password') }}">@endif<button>{{ $t('دخول','Join') }}</button></form>@endunless</div>
  @empty
   <div class="empty-room"><button class="create-new-room-hero large-empty" type="button" onclick="openCreateRoomModal()">＋ <span>{{ $t('أنشئ لعبة جديدة','Create a new game') }}</span></button><p>{{ $t('لا توجد غرف مفتوحة لهذه اللعبة.','There are no open rooms for this game.') }}</p></div>
  @endforelse
 </section>
 <aside class="create-room compact-create-room" id="createRoomPanel"><button class="create-new-room-hero" type="button" onclick="openCreateRoomModal()">＋ <span>{{ $t('أنشئ لعبة جديدة','Create a new game') }}</span></button><h2>{{ $t('إنشاء لعبة','Create game') }}</h2>
  <form method="post" action="{{route('rooms.store')}}" data-ajax-room="1">@csrf
   <input type="hidden" name="game_id" value="{{$game->id}}">
   <input type="hidden" name="voice_room" id="voiceRoomFlag" value="0">
   <label>{{ $t('نوع اللعبة','Game type') }}</label>
   <select name="room_type" id="roomTypeSelect" onchange="roomTypeChanged(this)"><option value="public">{{ $t('عامة','Public') }}</option><option value="private">{{ $t('خاصة','Private') }}</option><option value="voice">{{ $t('لعبة صوتية - تخصم 100 توكنز من كل لاعب','Voice game — deducts 100 tokens from each player') }}</option></select><small class="voice-fee-hint hidden">{{ $t('اللعبة الصوتية تخصم 100 توكنز عند إنشاء/دخول الغرفة.','A voice game deducts 100 tokens when creating or joining the room.') }}</small>
   <input id="privatePasswordInput" class="hidden" name="password" placeholder="{{ $t('كلمة السر للعبة الخاصة','Private-game password') }}" aria-label="{{ $t('كلمة السر للعبة الخاصة','Private-game password') }}">
   <label>{{ $t('عدد المقاعد','Seats') }}</label>
   @if(count($allowedSeats)===1)
    <select name="max_players"><option value="{{$allowedSeats[0]}}" selected>{{$allowedSeats[0]}} {{ $t('مقاعد','seats') }}</option></select>
   @else
    <select name="max_players">@foreach($allowedSeats as $i)<option value="{{$i}}" {{$i==$game->max_players?'selected':''}}>{{$i}} {{ $t('مقاعد','seats') }}</option>@endforeach</select>
   @endif
   <label>{{ $t('سرعة اللعب','Game speed') }}</label><select name="speed"><option value="slow">{{ $t('بطيئة - 10 ثوانٍ','Slow — 10 seconds') }}</option><option value="medium" selected>{{ $t('متوسطة - 7 ثوانٍ','Medium — 7 seconds') }}</option><option value="fast">{{ $t('سريعة - 5 ثوانٍ','Fast — 5 seconds') }}</option></select>
   <label>{{ $t('إمكانية الطرد لصاحب الغرفة الباشا','Pasha room-owner kick permission') }}</label><select name="allow_owner_kick"><option value="0" selected>{{ $t('معطلة','Disabled') }}</option><option value="1">{{ $t('مفعّلة — للباشا فقط','Enabled — Pasha only') }}</option></select>
   <label>{{ $t('مدرجات Social World','Social World spectators') }}</label><select name="allow_spectators"><option value="1" selected>{{ $t('مفتوحة — بدون كشف الأوراق أو الصوت','Open — cards and voice stay private') }}</option><option value="0">{{ $t('مغلقة','Closed') }}</option></select>
   <label>{{ $t('خصم XP عند الخروج اليدوي','XP penalty for manual exit') }}</label><select name="leave_xp_penalty"><option value="0" selected>{{ $t('بدون خصم','No penalty') }}</option><option value="1">{{ $t('خصم 200 XP إذا خرج اللاعب وحده أثناء اللعبة','Deduct 200 XP when a player leaves alone during the game') }}</option></select>
   <label>{{ $t('أقل مستوى للدخول','Minimum level') }}</label><select name="min_level">@for($lvl=1;$lvl<=min(100,$userLevel);$lvl++)<option value="{{$lvl}}">{{ $t('المستوى','Level') }} {{$lvl}}</option>@endfor</select>
   @if(count($targets))<label>{{ $t('نهاية اللعبة','Target score') }}</label><select name="target_score">@foreach($targets as $target)<option value="{{$target}}">{{$target}}</option>@endforeach</select>@endif
   <button class="btn primary create-room-submit" type="submit">{{ $t('إنشاء الغرفة','Create room') }}</button>
  </form>
 </aside>
</div>
<div id="createRoomModal" class="create-room-modal hidden" onclick="if(event.target===this)this.classList.add('hidden')">
 <div class="create-room-modal-card">
  <button type="button" class="modal-x" aria-label="{{ $t('إغلاق','Close') }}" onclick="document.getElementById('createRoomModal').classList.add('hidden')">×</button>
  <h2>{{ $t('إنشاء لعبة جديدة','Create a new game') }}</h2>
  <p class="muted">{{ $t('اختر نفس خيارات الإنشاء بسرعة من منتصف الصفحة، ثم سيتم فتح الغرفة مباشرة.','Choose the room options here, then the new room will open immediately.') }}</p>
  <div id="createRoomModalBody"></div>
 </div>
</div>
<script>
function roomTypeChanged(sel){const scope=sel.closest('form')||document; const pass=scope.querySelector('[name="password"]'),voice=scope.querySelector('[name="voice_room"]'),hint=scope.querySelector('.voice-fee-hint'); if(pass)pass.classList.toggle('hidden',sel.value!=='private'); if(voice)voice.value=sel.value==='voice'?'1':'0'; if(hint)hint.classList.toggle('hidden',sel.value!=='voice');}
function openCreateRoomModal(){const modal=document.getElementById('createRoomModal'),body=document.getElementById('createRoomModalBody'),form=document.querySelector('#createRoomPanel form'); if(!modal||!body||!form)return; const clone=form.cloneNode(true); clone.removeAttribute('id'); clone.classList.add('modal-create-room-form'); clone.querySelectorAll('[id]').forEach((el,i)=>{el.id=el.id+'Modal'+i}); body.innerHTML=''; body.appendChild(clone); modal.classList.remove('hidden'); clone.querySelector('select')?.focus();}
</script>
@endsection
