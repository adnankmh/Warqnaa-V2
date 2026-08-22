@extends('layouts.app')
@section('title','Live Stands '.$room->code.' | Warqnaa')
@section('content')
<div class="r11-viewer" data-room-code="{{$room->code}}" data-state-url="{{route('social-world.spectator.state',$room->code)}}">
  <header><div><span class="r11-live-label"><i></i> LIVE • READ ONLY</span><h1>🏟️ {{data_get($room->state,'room_name',$room->code)}}</h1><p>{{$room->game?->name[app()->getLocale()] ?? $room->game?->key}} • {{$room->code}}</p></div><a href="{{route('social-world')}}">← Social World</a></header>
  <div class="r11-privacy-banner">🛡️ <b>Privacy Shield active</b><span>Hands, deck order, legal actions, player voice and private chat are never sent to spectators.</span></div>
  <section class="r11-score-stage">
    <div class="r11-table-glow"><div id="r11ViewerPhase">{{data_get($safeState,'phase','playing')}}</div><strong id="r11ViewerTurn">{{data_get($safeState,'turn','—')}}</strong><small>Current turn</small></div>
    <div class="r11-viewer-players">
      @foreach($room->players->where('is_bot',false) as $player)
        @php $seatLabel=is_numeric($player->seat)?((int)$player->seat+1):ucwords(str_replace('_',' ',(string)$player->seat)); @endphp
        <article><img src="{{$player->user?->profile?->avatar ?: '/assets/avatars/default.svg'}}" alt=""><b>{{$player->user?->profile?->display_name ?: $player->user?->username}}</b><span>Seat {{$seatLabel}}</span></article>
      @endforeach
    </div>
  </section>
  <details class="r11-safe-state"><summary>Safe public state</summary><pre id="r11ViewerState">{{json_encode($safeState,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES)}}</pre></details>
</div>
<script>document.addEventListener('DOMContentLoaded',()=>{const root=document.querySelector('.r11-viewer'),url=root?.dataset.stateUrl;if(!url)return;const poll=async()=>{try{const r=await fetch(url,{headers:{Accept:'application/json'}});if(!r.ok)return;const d=await r.json(),s=d.state||{};document.getElementById('r11ViewerPhase').textContent=s.phase||'playing';document.getElementById('r11ViewerTurn').textContent=s.turn||'—';document.getElementById('r11ViewerState').textContent=JSON.stringify(s,null,2)}catch(e){}};setInterval(poll,2500)});</script>
@endsection
