@extends('layouts.app')
@section('title', $club->name.' | '.(app()->isLocale('ar') ? 'ورقنا' : 'Warqnaa'))
@section('content')
@php
 $ar=app()->getLocale()==='ar';
 $online=$club->members->filter(fn($m)=>$m->user?->last_seen_at && $m->user->last_seen_at->gt(now()->subMinutes(5)));
 $leagueLabels=[1=>'Bronze',2=>'Silver',3=>'Gold',4=>'Platinum',5=>'Diamond',6=>'Legendary'];
 $roleLabels=['owner'=>($ar?'مالك':'Owner'),'moderator'=>($ar?'مشرف':'Moderator'),'member'=>($ar?'عضو':'Member')];
@endphp
<div class="club-page-shell">
 <section class="club-profile-hero pro-card">
  <div class="club-emblem big">{{$club->logo ?: '👥'}}</div>
  <div><h1>{{$club->name}}</h1><p>{{$ar?'المالك:':'Owner:'}} <b>{{$club->owner?->username}}</b> • {{$ar?'تاريخ الإنشاء:':'Created:'}} {{$club->created_at?->format('Y-m-d')}}</p><div class="club-meta-row"><span class="club-league-badge">{{$ar?($clubLeagues[min(6,max(1,$club->level))] ?? 'برونزي'):($leagueLabels[min(6,max(1,$club->level))] ?? 'Bronze')}}</span><span class="pill">{{$ar?'المستوى':'Level'}} {{$club->level}}</span><span class="pill">{{$club->members->count()}}/{{$clubCaps[min(6,max(1,$club->level))] ?? 50}}</span><span class="pill online-pill">🟢 {{$online->count()}} {{$ar?'متصل':'Online'}}</span><span class="pill">🪙 {{number_format($club->treasury)}}</span></div></div>
  @if($club->owner_id===auth()->id() || auth()->user()->is_admin)
  <form method="post" action="{{route('clubs.delete',$club)}}" data-confirm="{{$ar?'هل تريد حذف المجموعة نهائيًا؟ سيتم حذف الأعضاء والطلبات الخاصة بها.':'Delete this club permanently? Its members and requests will also be deleted.'}}">@csrf<button class="danger">{{$ar?'حذف المجموعة نهائيًا':'Delete club permanently'}}</button></form>
  @endif
 </section>
 @if($canManageClub)
 <section class="pro-card"><h2>🎨 {{$ar?'هوية وإعدادات النادي':'Club identity and settings'}}</h2><form method="post" action="{{route('clubs.settings.update',$club)}}" class="system-grid">@csrf<input name="name" value="{{$club->name}}" required maxlength="120" aria-label="{{$ar?'اسم المجموعة':'Club name'}}"><input name="logo" value="{{$club->logo}}" maxlength="500" placeholder="{{$ar?'شعار Emoji أو رابط صورة':'Emoji emblem or image URL'}}" aria-label="{{$ar?'شعار المجموعة':'Club emblem'}}"><textarea name="description" maxlength="1000" placeholder="{{$ar?'وصف النادي':'Club description'}}" aria-label="{{$ar?'وصف النادي':'Club description'}}">{{$club->description}}</textarea><select name="visibility" aria-label="{{$ar?'خصوصية المجموعة':'Club visibility'}}"><option value="public" {{$club->visibility==='public'?'selected':''}}>{{$ar?'عام':'Public'}}</option><option value="request" {{$club->visibility==='request'?'selected':''}}>{{$ar?'بطلب انضمام':'Approval required'}}</option><option value="private" {{$club->visibility==='private'?'selected':''}}>{{$ar?'خاص':'Private'}}</option></select><button class="primary">{{$ar?'حفظ الهوية':'Save identity'}}</button></form></section>
 @endif
 <section class="pro-card v105-club-economy"><h2>📊 {{$ar?'نظام المجموعة':'Club system'}}</h2><div class="system-grid"><span>{{$ar?'الدوري الحالي:':'Current league:'}} {{$ar?($clubLeagues[min(6,max(1,$club->level))] ?? 'برونزي'):($leagueLabels[min(6,max(1,$club->level))] ?? 'Bronze')}}</span><span>{{$ar?'السعة:':'Capacity:'}} {{$clubCaps[min(6,max(1,$club->level))] ?? 20}}</span><span>{{$ar?'نقاط أسبوعية:':'Weekly points:'}} {{$club->weekly_points}}</span><span>{{$ar?'الخزينة:':'Treasury:'}} 🪙 {{number_format($club->treasury)}}</span><span>{{$ar?'اللعب الجماعي يعطي مكافأة ×2':'Team play awards a ×2 bonus'}}</span><span>{{$ar?'يوزع المالك أو المشرف الخزينة حسب الصلاحيات':'The owner or an authorized moderator distributes the treasury'}}</span></div></section>
 <section class="pro-card"><h2>{{$ar?'اللاعبون الموجودون الآن':'Players online now'}}</h2><div class="club-online-list">@forelse($online as $m)<button type="button" onclick="openProfile({{$m->user_id}})"><img loading="lazy" decoding="async" src="{{$m->user?->profile?->avatar ?: '/assets/avatars/default.svg'}}">{{$m->user?->username}}</button>@empty<p class="muted">{{$ar?'لا يوجد أعضاء متصلون حاليًا.':'No members are online right now.'}}</p>@endforelse</div></section>
 <section class="pro-card"><h2>{{$ar?'أعضاء المجموعة':'Club members'}}</h2><div class="club-member-table">@foreach($club->members as $m)<div class="club-member-row"><button type="button" class="user-chip" onclick="openProfile({{$m->user_id}})"><img loading="lazy" decoding="async" class="avatar-xs" src="{{$m->user?->profile?->avatar ?: '/assets/avatars/default.svg'}}">{{$m->user?->username}}</button><span class="pill">{{$roleLabels[$m->role] ?? $m->role}}</span><span>{{$ar?'نقاط:':'Points:'}} {{$m->weekly_points}}</span><small>{{($m->user?->last_seen_at && $m->user->last_seen_at->gt(now()->subMinutes(5)))?($ar?'متصل':'Online'):($ar?'غير متصل':'Offline')}}</small>@if(($club->owner_id===auth()->id() || auth()->user()->is_admin) && $m->role!=='owner')<form class="club-permission-form" method="post" action="{{route('clubs.memberAction',[$club,$m])}}">@csrf<input type="hidden" name="action" value="moderator"><label><input type="checkbox" name="accept_members" {{$m->permissions['accept_members']??false?'checked':''}}> {{$ar?'قبول الأعضاء':'Accept members'}}</label><label><input type="checkbox" name="kick_members" {{$m->permissions['kick_members']??false?'checked':''}}> {{$ar?'طرد الأعضاء':'Remove members'}}</label><label><input type="checkbox" name="create_tournaments" {{$m->permissions['create_tournaments']??false?'checked':''}}> {{$ar?'المسابقات':'Tournaments'}}</label><label><input type="checkbox" name="manage_chat" {{$m->permissions['manage_chat']??false?'checked':''}}> {{$ar?'الدردشة':'Chat'}}</label><label><input type="checkbox" name="create_announcements" {{$m->permissions['create_announcements']??false?'checked':''}}> {{$ar?'الإعلانات':'Announcements'}}</label><label><input type="checkbox" name="manage_club" {{$m->permissions['manage_club']??false?'checked':''}}> {{$ar?'هوية النادي':'Club identity'}}</label><button>{{$ar?'جعله مشرفًا':'Make moderator'}}</button></form><form method="post" action="{{route('clubs.memberAction',[$club,$m])}}" data-confirm="{{$ar?'هل تريد طرد هذا اللاعب؟':'Remove this player from the club?'}}">@csrf<input type="hidden" name="action" value="kick"><button class="danger">{{$ar?'طرد':'Remove'}}</button></form>@endif</div>@endforeach</div></section>
 @if($canAccept)
 <section class="pro-card"><h2>{{$ar?'طلبات الانضمام':'Join requests'}}</h2>@forelse($club->joinRequests->where('status','pending') as $req)<form class="inline-card" method="post" action="{{route('clubs.respond',$req)}}">@csrf<b>{{$req->user->username}}</b><button class="success" name="status" value="accepted">{{$ar?'قبول':'Accept'}}</button><button class="danger" name="status" value="rejected">{{$ar?'رفض':'Reject'}}</button></form>@empty<p class="muted">{{$ar?'لا توجد طلبات معلقة.':'There are no pending requests.'}}</p>@endforelse</section>
 @endif

 <section class="pro-card club-announcements-v161"><h2>📣 {{$ar?'إعلانات النادي':'Club announcements'}}</h2>
  @if($canAnnounce)
  <form method="post" action="{{route('clubs.announcements.store',$club)}}" class="club-announcement-form">@csrf
   <input name="title" required maxlength="140" placeholder="{{$ar?'عنوان الإعلان':'Announcement title'}}" aria-label="{{$ar?'عنوان الإعلان':'Announcement title'}}">
   <textarea name="body" required maxlength="2000" placeholder="{{$ar?'نص الإعلان للأعضاء':'Announcement for club members'}}" aria-label="{{$ar?'نص الإعلان':'Announcement body'}}"></textarea>
   <label><input type="checkbox" name="pinned" value="1"> {{$ar?'تثبيت الإعلان':'Pin announcement'}}</label>
   <button class="primary">{{$ar?'نشر الإعلان':'Publish announcement'}}</button>
  </form>
  @endif
  <div class="club-announcement-list">
  @forelse($club->announcements as $announcement)
   <article class="mini-card {{$announcement->pinned?'pinned':''}}"><header><b>{{$announcement->pinned?'📌 ':''}}{{$announcement->title}}</b><small>{{$announcement->author?->username}} • {{$announcement->created_at?->diffForHumans()}}</small></header><p>{!! nl2br(e($announcement->body)) !!}</p>
   @if($club->owner_id===auth()->id() || auth()->user()->is_admin || $announcement->author_id===auth()->id())<form method="post" action="{{route('clubs.announcements.delete',[$club,$announcement])}}">@csrf<button class="danger small">{{$ar?'حذف':'Delete'}}</button></form>@endif</article>
  @empty<p class="muted">{{$ar?'لا توجد إعلانات بعد.':'No announcements yet.'}}</p>@endforelse
  </div>
 </section>
 @if($canTournament)
 <section class="pro-card club-tournament-builder-v161"><h2>🏆 {{$ar?'إنشاء مسابقة للنادي':'Create a club tournament'}}</h2><p class="muted">{{$ar?'يسمح بها للمالك أو المشرف الذي منحه المالك صلاحية المسابقات.':'Available to the owner or a moderator authorized to create tournaments.'}}</p>
  <form method="post" action="{{route('clubs.tournaments.store',$club)}}" class="system-grid">@csrf
   <select name="game_id" required aria-label="{{$ar?'اللعبة':'Game'}}">@foreach(\App\Models\Game::where('active',true)->get() as $game)<option value="{{$game->id}}">{{$game->name}}</option>@endforeach</select>
   <select name="stages" aria-label="{{$ar?'مراحل المسابقة':'Tournament stages'}}"><option value="1">{{$ar?'مرحلة واحدة — النهائي':'One stage — final'}}</option><option value="2">{{$ar?'مرحلتان — نصف نهائي ونهائي':'Two stages — semifinal and final'}}</option><option value="3">{{$ar?'3 مراحل — ربع/نصف/نهائي':'Three stages — quarterfinal/semifinal/final'}}</option><option value="4">{{$ar?'4 مراحل — ثمن/ربع/نصف/نهائي':'Four stages — round of 16/quarterfinal/semifinal/final'}}</option></select>
   <select name="seats_per_match" aria-label="{{$ar?'المقاعد لكل مباراة':'Seats per match'}}"><option value="2">{{$ar?'مقعدان':'2 seats'}}</option><option value="4" selected>{{$ar?'4 مقاعد':'4 seats'}}</option><option value="6">{{$ar?'6 مقاعد':'6 seats'}}</option></select>
   <input type="number" name="entry_fee" value="0" min="0" placeholder="{{$ar?'رسوم الدخول':'Entry fee'}}" aria-label="{{$ar?'رسوم الدخول':'Entry fee'}}">
   <input type="number" name="prize_pool" value="10000" min="0" placeholder="{{$ar?'صندوق الجوائز':'Prize pool'}}" aria-label="{{$ar?'صندوق الجوائز':'Prize pool'}}">
   <button class="primary">{{$ar?'إنشاء مسابقة النادي':'Create club tournament'}}</button>
  </form>
 </section>
 @endif
 <section class="pro-card"><h2>📜 {{$ar?'سجل النادي':'Club activity log'}}</h2><div class="club-announcement-list">@forelse($club->activityLogs->take(50) as $log)<article class="mini-card"><header><b>{{$log->description}}</b><small>{{$log->actor?->username ?? ($ar?'النظام':'System')}} • {{$log->created_at?->diffForHumans()}}</small></header></article>@empty<p class="muted">{{$ar?'لا توجد أحداث مسجلة بعد.':'No activity has been recorded yet.'}}</p>@endforelse</div></section>
 <div class="club-actions-row"><a class="btn" href="{{route('clubs')}}">{{$ar?'العودة للمجموعات':'Back to clubs'}}</a>@if($club->members->where('user_id',auth()->id())->count())<form method="post" action="{{route('clubs.leave',$club)}}" data-confirm="{{$ar?'هل تريد مغادرة المجموعة؟':'Leave this club?'}}">@csrf<button class="danger">{{$ar?'مغادرة المجموعة':'Leave club'}}</button></form>@else<form method="post" action="{{route('clubs.join',$club)}}">@csrf<button>{{$ar?'طلب انضمام':'Request to join'}}</button></form>@endif</div>
</div>
@endsection
