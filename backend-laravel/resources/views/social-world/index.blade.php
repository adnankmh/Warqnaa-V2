@extends('layouts.app')
@section('title', app()->isLocale('ar') ? 'العالم الاجتماعي | ورقنا' : 'Social World | Warqnaa')
@section('content')
@php
  $locale=app()->getLocale();
  $me=auth()->user();
  $followers=\App\Models\SocialFollow::where('followed_id',$me->id)->count();
  $following=\App\Models\SocialFollow::where('follower_id',$me->id)->count();
  $ar=$locale==='ar';
  $activityTypeLabels=[
    'status'=>$ar?'حالة':'Status',
    'looking_for_game'=>$ar?'يبحث عن مباراة':'Looking for game',
    'achievement'=>$ar?'إنجاز':'Achievement',
  ];
  $audienceLabels=[
    'public'=>$ar?'عام':'Public',
    'friends'=>$ar?'الأصدقاء':'Friends',
    'followers'=>$ar?'المتابعون':'Followers',
    'private'=>$ar?'خاص':'Private',
    'everyone'=>$ar?'الجميع':'Everyone',
    'nobody'=>$ar?'لا أحد':'Nobody',
  ];
  $eventStatusLabels=[
    'scheduled'=>$ar?'قادمة':'Scheduled',
    'live'=>$ar?'مباشرة':'Live',
    'finished'=>$ar?'مكتملة':'Finished',
    'cancelled'=>$ar?'ملغاة':'Cancelled',
  ];
  $privacyFieldLabels=[
    'profile_visibility'=>$ar?'الملف الشخصي':'Profile',
    'presence_visibility'=>$ar?'الظهور':'Presence',
    'activity_visibility'=>$ar?'النشاط':'Activity',
    'message_policy'=>$ar?'الرسائل':'Messages',
    'invite_policy'=>$ar?'الدعوات':'Invites',
  ];
  $privacySwitchLabels=[
    'discoverable'=>$ar?'الظهور في البحث':'Appear in search',
    'allow_friend_requests'=>$ar?'طلبات الصداقة':'Friend requests',
    'allow_follows'=>$ar?'المتابعة':'Follows',
    'allow_spectators'=>$ar?'مشاهدة مبارياتي':'Spectate my matches',
    'allow_replay_share'=>$ar?'مشاركة الإعادات':'Share replays',
    'allow_voice'=>$ar?'الصوت':'Voice',
    'show_online_status'=>$ar?'حالة الاتصال':'Online status',
    'show_current_room'=>$ar?'إظهار الغرفة الحالية':'Show current room',
  ];
@endphp
<div class="r11-world" data-r11-social-world>
  <header class="r11-world-hero">
    <div>
      <span class="r11-kicker"><i></i> {{ $ar?'مجتمع اللاعبين • الخصوصية أولًا':'PLAYER COMMUNITY • PRIVACY FIRST' }}</span>
      <h1>{{ $locale==='ar' ? 'عالم ورقنا الاجتماعي' : 'Warqnaa Social World' }}</h1>
      <p>{{ $locale==='ar' ? 'مجلس حي يجمع اللاعبين والفعاليات والمدرجات والإعادات — بخصوصية صممت أولًا.' : 'A living majlis for players, events, spectator stands and replays — built privacy-first.' }}</p>
      <div class="r11-hero-actions">
        <button type="button" class="r11-primary" data-r11-open="composer">✦ {{ $locale==='ar'?'انشر لحظتك':'Share a moment' }}</button>
        <button type="button" data-r11-open="privacy">🛡️ {{ $locale==='ar'?'الخصوصية':'Privacy' }}</button>
      </div>
    </div>
    <div class="r11-orbit" aria-hidden="true"><span>♠</span><span>♥</span><span>♦</span><span>♣</span><b>W</b></div>
  </header>

  <section class="r11-stats">
    <article><b>{{number_format($followers)}}</b><span>{{ $locale==='ar'?'متابع':'Followers' }}</span></article>
    <article><b>{{number_format($following)}}</b><span>{{ $locale==='ar'?'أتابع':'Following' }}</span></article>
    <article><b>{{number_format($liveRooms->count())}}</b><span>{{ $locale==='ar'?'مدرج مباشر':'Live stands' }}</span></article>
    <article><b>{{number_format($events->count())}}</b><span>{{ $locale==='ar'?'فعالية':'Events' }}</span></article>
  </section>

  <nav class="r11-tabs" aria-label="{{ $ar?'أقسام العالم الاجتماعي':'Social World sections' }}">
    <button class="active" data-r11-tab="feed">◉ {{ $locale==='ar'?'الموجز':'Feed' }}</button>
    <button data-r11-tab="live">🏟️ {{ $locale==='ar'?'مباشر':'Live' }}</button>
    <button data-r11-tab="events">✦ {{ $locale==='ar'?'الفعاليات':'Events' }}</button>
    <button data-r11-tab="replays">↻ {{ $locale==='ar'?'الإعادات':'Replays' }}</button>
  </nav>

  <div class="r11-world-grid">
    <main>
      <section class="r11-pane active" data-r11-pane="feed">
        @forelse($activities as $activity)
          @php $actor=$activity->actor; $text=(string)data_get($activity->payload,'text',''); @endphp
          <article class="r11-feed-card">
            <div class="r11-userline">
              <img src="{{$actor?->profile?->avatar ?: '/assets/avatars/default.svg'}}" alt="">
              <div><b>{{$actor?->profile?->display_name ?: $actor?->username}}</b><small>{{$activityTypeLabels[$activity->type] ?? str_replace('_',' ',(string)$activity->type)}} • {{$activity->published_at?->diffForHumans()}}</small></div>
              <span class="r11-audience">{{$audienceLabels[$activity->audience] ?? $activity->audience}}</span>
            </div>
            <p>{{$text}}</p>
            @if($activity->room)<a class="r11-room-chip" href="{{route('rooms.show',$activity->room->code)}}">🎮 {{$activity->room->code}}</a>@endif
            @if($activity->club)<a class="r11-room-chip" href="{{route('clubs.show',$activity->club)}}">🛡️ {{$activity->club->name}}</a>@endif
            @if($activity->gifts->where('visible',true)->isNotEmpty())
              <div class="r11-gift-trail">@foreach($activity->gifts->where('visible',true)->take(8) as $gift)<span title="{{$gift->sender?->username}}">{{data_get($gift->meta,'icon','✨')}}</span>@endforeach</div>
            @endif
          </article>
        @empty
          <div class="r11-empty"><b>✦ {{ $locale==='ar'?'كن أول من يضيء المجلس':'Light up the majlis' }}</b><p>{{ $locale==='ar'?'انشر حالة أو ابحث عن رفاق مباراة.':'Share a status or find players for a match.' }}</p></div>
        @endforelse
      </section>

      <section class="r11-pane" data-r11-pane="live">
        <div class="r11-card-grid">
          @forelse($liveRooms as $room)
            <article class="r11-live-card">
              <div class="r11-live-label"><i></i> {{ $ar?'مباشر':'LIVE' }}</div>
              <h3>{{data_get($room->state,'room_name',$room->game?->key)}}</h3>
              <p>{{$room->game?->name[$locale] ?? $room->game?->name['ar'] ?? $room->game?->key}} • {{$room->players->where('is_bot',false)->count()}} {{ $locale==='ar'?'لاعبين':'players' }}</p>
              <div class="r11-avatars">@foreach($room->players->where('is_bot',false)->take(5) as $player)<img src="{{$player->user?->profile?->avatar ?: '/assets/avatars/default.svg'}}" title="{{$player->user?->username}}" alt="">@endforeach</div>
              <form method="post" action="{{route('social-world.spectate',$room->code)}}">@csrf<button class="r11-primary" type="submit">🏟️ {{ $locale==='ar'?'ادخل المدرجات':'Watch live' }}</button></form>
              <small>🔒 {{ $locale==='ar'?'الأوراق والصوت غير مرئيين':'Hands and voice stay private' }}</small>
            </article>
          @empty<div class="r11-empty">{{ $locale==='ar'?'لا توجد مدرجات مفتوحة الآن.':'No open stands right now.' }}</div>@endforelse
        </div>
      </section>

      <section class="r11-pane" data-r11-pane="events">
        <div class="r11-card-grid">
          @forelse($events as $event)
            @php $isGoing=$event->attendees->where('user_id',$me->id)->where('status','going')->isNotEmpty(); @endphp
            <article class="r11-event-card {{$event->featured?'featured':''}}">
              <span>{{$event->featured?($ar?'✦ مميزة':'✦ FEATURED'):($eventStatusLabels[$event->status] ?? ucfirst(str_replace('_',' ',(string)$event->status)))}}</span>
              <h3>{{$event->title[$locale] ?? $event->title['ar'] ?? ($ar?'فعالية ورقنا':'Warqnaa Event')}}</h3>
              <p>{{$event->description[$locale] ?? $event->description['ar'] ?? ''}}</p>
              <div class="r11-event-meta"><b>◷ {{$event->starts_at?->format('Y-m-d H:i')}}</b><b>◎ {{$event->attendees->where('status','going')->count()}}</b></div>
              <form method="post" action="{{$isGoing?route('social-world.events.cancel',$event):route('social-world.events.attend',$event)}}">@csrf @if($isGoing)@method('delete')@endif<button type="submit">{{ $isGoing?($locale==='ar'?'إلغاء الحضور':'Cancel attendance'):($locale==='ar'?'سأحضر':'I’m going') }}</button></form>
            </article>
          @empty<div class="r11-empty">{{ $locale==='ar'?'اصنع أول فعالية في عالمك.':'Create the first event in your world.' }}</div>@endforelse
        </div>
      </section>

      <section class="r11-pane" data-r11-pane="replays">
        <div class="r11-card-grid">
          @forelse($replays as $replay)
            <a class="r11-replay-card" href="{{route('social-world.replay',$replay)}}">
              <div class="r11-replay-cover"><span>▶</span><b>{{$replay->game?->key}}</b></div>
              <h3>{{$replay->room?->code}} • {{$replay->frames_count}} {{ $locale==='ar'?'لقطة':'frames' }}</h3>
              <p>{{$replay->owner?->profile?->display_name ?: $replay->owner?->username}} · {{gmdate('i:s',(int)$replay->duration_seconds)}} · {{$replay->views}} {{ $ar?'مشاهدة':'views' }}</p>
              <small>🛡️ {{ $ar?'إعادة آمنة تحمي الخصوصية':'Privacy-safe replay' }}</small>
            </a>
          @empty<div class="r11-empty">{{ $locale==='ar'?'ستظهر الإعادات الآمنة بعد اكتمال المباريات.':'Privacy-safe replays appear after matches finish.' }}</div>@endforelse
        </div>
      </section>
    </main>

    <aside class="r11-sidebar">
      <section>
        <div class="r11-section-head"><h2>{{ $locale==='ar'?'لاعبون قد تعرفهم':'People to discover' }}</h2></div>
        @forelse($suggestions as $person)
          <div class="r11-person"><img src="{{$person->profile?->avatar ?: '/assets/avatars/default.svg'}}" alt=""><div><b>{{$person->profile?->display_name ?: $person->username}}</b><small>{{ $ar?'المستوى':'Lv.' }} {{$person->profile?->level ?? 1}}</small></div>
          @if(in_array((int)$person->id,$followingIds,true))<form method="post" action="{{route('social-world.unfollow',$person)}}">@csrf @method('delete')<button>✓</button></form>@else<form method="post" action="{{route('social-world.follow',$person)}}">@csrf<button>＋</button></form>@endif</div>
        @empty<p class="muted">—</p>@endforelse
      </section>
      <section>
        <div class="r11-section-head"><h2>{{ $locale==='ar'?'هدايا المجلس':'Majlis gifts' }}</h2><span>{{ $ar?'متحركة':'Animated' }}</span></div>
        <div class="r11-gifts">@foreach($giftCatalog as $key=>$gift)<button type="button" data-r11-gift="{{$key}}" title="{{$gift[$locale] ?? $gift['ar']}} • {{$gift['cost']}}">{{$gift['icon']}}<small>{{$gift['cost']}}</small></button>@endforeach</div>
        <p class="r11-fair-note">⚖️ {{ $locale==='ar'?'الهدايا اجتماعية فقط ولا تمنح أي أفضلية تنافسية.':'Gifts are social-only and never affect competitive play.' }}</p>
      </section>
      <section>
        <div class="r11-section-head"><h2>{{ $locale==='ar'?'أنشئ فعالية':'Create event' }}</h2></div>
        <form class="r11-stack" method="post" action="{{route('social-world.events.create')}}">@csrf
          <input name="title" maxlength="140" required placeholder="{{ $locale==='ar'?'اسم الفعالية':'Event name' }}">
          <input name="starts_at" type="datetime-local" required>
          <select name="visibility">@foreach(['public','friends','private'] as $value)<option value="{{$value}}">{{$audienceLabels[$value]}}</option>@endforeach</select>
          <button type="submit">✦ {{ $locale==='ar'?'إنشاء':'Create' }}</button>
        </form>
      </section>
    </aside>
  </div>
</div>

<dialog class="r11-dialog" id="r11Composer"><form method="dialog"><button class="r11-close" aria-label="{{ $ar?'إغلاق':'Close' }}">×</button></form><h2>✦ {{ $locale==='ar'?'شارك لحظتك':'Share your moment' }}</h2><form method="post" action="{{route('social-world.publish')}}" class="r11-stack">@csrf<textarea name="text" maxlength="500" required placeholder="{{ $locale==='ar'?'ماذا يحدث في مجلسك؟':'What’s happening in your majlis?' }}"></textarea><div class="r11-form-row"><select name="type" aria-label="{{ $ar?'نوع المنشور':'Post type' }}">@foreach($activityTypeLabels as $value=>$label)<option value="{{$value}}">{{$label}}</option>@endforeach</select><select name="audience" aria-label="{{ $ar?'جمهور المنشور':'Post audience' }}">@foreach(['public','friends','followers','private'] as $value)<option value="{{$value}}">{{$audienceLabels[$value]}}</option>@endforeach</select></div><button class="r11-primary" type="submit">{{ $locale==='ar'?'نشر':'Publish' }}</button></form></dialog>

<dialog class="r11-dialog" id="r11Privacy"><form method="dialog"><button class="r11-close" aria-label="{{ $ar?'إغلاق':'Close' }}">×</button></form><h2>🛡️ {{ $locale==='ar'?'مركز الخصوصية':'Privacy center' }}</h2><form method="post" action="{{route('social-world.privacy')}}" class="r11-stack">@csrf @method('patch')
  @foreach(['profile_visibility','presence_visibility','activity_visibility'] as $key)<label>{{$privacyFieldLabels[$key]}}<select name="{{$key}}">@foreach(['public','friends','private'] as $value)<option value="{{$value}}" @selected($preferences->$key===$value)>{{$audienceLabels[$value]}}</option>@endforeach</select></label>@endforeach
  @foreach(['message_policy','invite_policy'] as $key)<label>{{$privacyFieldLabels[$key]}}<select name="{{$key}}">@foreach(['everyone','friends','nobody'] as $value)<option value="{{$value}}" @selected($preferences->$key===$value)>{{$audienceLabels[$value]}}</option>@endforeach</select></label>@endforeach
  <div class="r11-switches">@foreach($privacySwitchLabels as $key=>$label)<label><input type="checkbox" name="{{$key}}" value="1" @checked($preferences->$key)> <span>{{$label}}</span></label>@endforeach</div>
  <button class="r11-primary" type="submit">{{ $locale==='ar'?'حفظ الخصوصية':'Save privacy' }}</button></form></dialog>

<dialog class="r11-dialog" id="r11Gift"><form method="dialog"><button class="r11-close" aria-label="{{ $ar?'إغلاق':'Close' }}">×</button></form><h2>✨ {{ $locale==='ar'?'أرسل هدية متحركة':'Send an animated gift' }}</h2><form method="post" action="{{route('social-world.gifts.send')}}" class="r11-stack">@csrf<input type="hidden" name="gift_key" id="r11GiftKey"><select name="recipient_id" required><option value="">{{ $locale==='ar'?'اختر اللاعب':'Choose player' }}</option>@foreach($suggestions as $person)<option value="{{$person->id}}">{{$person->profile?->display_name ?: $person->username}}</option>@endforeach</select><input name="message" maxlength="240" placeholder="{{ $locale==='ar'?'رسالة اختيارية':'Optional message' }}"><button class="r11-primary" type="submit">{{ $locale==='ar'?'إرسال الهدية':'Send gift' }}</button></form></dialog>

<script>
document.addEventListener('DOMContentLoaded',()=>{
 const tabs=[...document.querySelectorAll('[data-r11-tab]')], panes=[...document.querySelectorAll('[data-r11-pane]')];
 tabs.forEach(tab=>tab.addEventListener('click',()=>{tabs.forEach(x=>x.classList.remove('active'));panes.forEach(x=>x.classList.remove('active'));tab.classList.add('active');document.querySelector(`[data-r11-pane="${tab.dataset.r11Tab}"]`)?.classList.add('active')}));
 document.querySelector('[data-r11-open="composer"]')?.addEventListener('click',()=>document.getElementById('r11Composer')?.showModal());
 document.querySelector('[data-r11-open="privacy"]')?.addEventListener('click',()=>document.getElementById('r11Privacy')?.showModal());
 document.querySelectorAll('[data-r11-gift]').forEach(btn=>btn.addEventListener('click',()=>{document.getElementById('r11GiftKey').value=btn.dataset.r11Gift;document.getElementById('r11Gift')?.showModal()}));
});
</script>
@endsection
