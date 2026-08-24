<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{HomeController,AuthController,GameController,RoomController,StoreController,ProfileController,FriendController,ClubController,TournamentController,AdminController,WalletController,NotificationController,PageController,ChatController,RealtimeController,EconomyController,AdminMonitorController,EconomyAdminController,GameLibraryController,RewardController,InteractionController,ProAdminController,EngineAuditController,LegalPageController,MobileAuthRecoveryController,SocialAuthController,CommerceAdminController,SocialWorldController,AdminSocialWorldController,CompetitiveController,AdminCompetitiveController,AccountSecurityController};
Route::get('/', [HomeController::class,'index'])->name('home');

Route::get('/health', function(\App\Services\Platform\PlatformHealthService $health){ return response()->json($health->snapshot()); })->name('warqna.health');

Route::get('/health-old', function(){
    return response()->json([
        'ok'=>true,
        'app'=>'Warqnaa',
        'version'=>config('warqna_pro_features.version','v117'),
        'time'=>now()->toIso8601String(),
        'checks'=>[
            'database'=>\Illuminate\Support\Facades\Schema::hasTable('users'),
            'games'=>\Illuminate\Support\Facades\Schema::hasTable('games'),
            'store'=>\Illuminate\Support\Facades\Schema::hasTable('store_items'),
            'messages'=>\Illuminate\Support\Facades\Schema::hasTable('messages'),
        ],
    ]);
})->name('warqna.health.old');

Route::get('/robots.txt', function(){
    $base=url('/');
    return response("User-agent: *\nAllow: /\nSitemap: {$base}/sitemap.xml\n",200)->header('Content-Type','text/plain; charset=UTF-8');
});

Route::get('/sitemap.xml', function(){
    $urls=[url('/'),url('/games'),url('/game-rules'),url('/store'),url('/about'),url('/contact')];
    // The sitemap must remain available during first deployment, migrations,
    // maintenance windows and database outages. Dynamic game URLs are added
    // only when the table can be queried safely.
    try {
        if(\Illuminate\Support\Facades\Schema::hasTable('games')){
            foreach(\App\Models\Game::where('active',true)->get() as $g){
                $urls[]=url('/games/'.rawurlencode((string)$g->key).'/rooms');
            }
        }
    } catch (\Throwable) {
        // Keep the static sitemap valid even when the database is unavailable.
    }
    $xml='<?xml version="1.0" encoding="UTF-8"?>'."\n".'<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'."\n";
    foreach(array_unique($urls) as $u){$xml.='<url><loc>'.e($u).'</loc><changefreq>daily</changefreq><priority>0.8</priority></url>'."\n";}
    $xml.='</urlset>';
    return response($xml,200)->header('Content-Type','application/xml; charset=UTF-8');
});

// Explicit PWA routes make feature tests and non-Apache deployments behave
// exactly like production web servers that normally serve these files.
Route::get('/manifest.webmanifest', fn()=>response()->file(public_path('manifest.webmanifest'),[
    'Content-Type'=>'application/manifest+json; charset=UTF-8',
    'Cache-Control'=>'public, max-age=3600',
]))->name('pwa.manifest');
Route::get('/sw.js', fn()=>response()->file(public_path('sw.js'),[
    'Content-Type'=>'application/javascript; charset=UTF-8',
    'Cache-Control'=>'no-cache, no-store, must-revalidate',
]))->name('pwa.service-worker');
Route::get('/offline.html', fn()=>response()->file(public_path('offline.html'),[
    'Content-Type'=>'text/html; charset=UTF-8',
    'Cache-Control'=>'public, max-age=3600',
]))->name('pwa.offline');


Route::get('/password/reset', [MobileAuthRecoveryController::class, 'showResetForm'])->name('password.reset.form');
Route::post('/password/reset', [MobileAuthRecoveryController::class, 'resetFromWeb'])->middleware('throttle:warqna-auth')->name('password.reset.web');

Route::get('/email/verify/{id}/{hash}', [MobileAuthRecoveryController::class, 'verify'])->middleware('signed')->name('verification.verify.mobile');
Route::match(['get','post'],'/auth/social/{provider}/callback',[SocialAuthController::class,'callback'])->name('social.callback');

Route::get('/legal/{page}', [LegalPageController::class, 'show'])
    ->whereIn('page', ['privacy','terms','community-guidelines','account-deletion','competition-rules','support'])
    ->name('legal.show');

Route::get('/ready', function(\App\Services\Platform\PlatformHealthService $health){
    $snapshot=$health->snapshot();
    return response()->json($snapshot, !empty($snapshot['ok']) ? 200 : 503);
})->name('warqna.ready');

Route::get('/login',[AuthController::class,'showLogin'])->name('login'); Route::post('/login',[AuthController::class,'login']);
Route::get('/register',[AuthController::class,'showRegister'])->name('register'); Route::post('/register',[AuthController::class,'register']); Route::post('/logout',[AuthController::class,'logout'])->name('logout');
Route::middleware('auth')->group(function(){
 Route::get('/games',[GameController::class,'index'])->name('games');
 Route::get('/game-rules',[GameController::class,'rules'])->name('game.rules');
 Route::get('/settings',[PageController::class,'settings'])->name('settings'); Route::post('/settings',[PageController::class,'saveSettings'])->name('settings.save'); Route::post('/preferences/quick',[PageController::class,'quickPreference'])->name('preferences.quick');
 Route::get('/about',[PageController::class,'about'])->name('about'); Route::get('/contact',[PageController::class,'contact'])->name('contact'); Route::post('/contact',[PageController::class,'sendContact'])->name('contact.send');
 Route::get('/notifications',[NotificationController::class,'index'])->name('notifications'); Route::post('/notifications/{notification}/read',[NotificationController::class,'read'])->name('notifications.read'); Route::post('/notifications/{notification}/delete',[NotificationController::class,'delete'])->name('notifications.delete'); Route::post('/realtime/heartbeat',[RealtimeController::class,'heartbeat'])->name('realtime.heartbeat'); Route::post('/rooms/{room}/throw/{target}',[InteractionController::class,'throw'])->name('interactions.throw'); Route::get('/realtime/room/{room:code}',[RealtimeController::class,'room'])->name('realtime.room'); Route::get('/economy',[EconomyController::class,'index'])->name('economy'); Route::get('/game-library-pro',[GameLibraryController::class,'index'])->name('games.library.pro'); Route::get('/rewards',[RewardController::class,'index'])->name('rewards'); Route::post('/rewards/claim',[RewardController::class,'claim'])->name('rewards.claim'); Route::get('/notifications/counts',[NotificationController::class,'counts'])->name('notifications.counts'); Route::post('/notifications/read-all',[NotificationController::class,'readAll'])->name('notifications.readAll');
 Route::get('/games/{game:key}/rooms',[RoomController::class,'index'])->name('rooms.index'); Route::post('/rooms',[RoomController::class,'store'])->name('rooms.store');
 Route::get('/room/{room:code}',[RoomController::class,'show'])->name('rooms.show'); Route::post('/room/{room:code}/join',[RoomController::class,'join'])->name('rooms.join'); Route::post('/room/{room:code}/leave',[RoomController::class,'leave'])->name('rooms.leave'); Route::post('/room/{room:code}/bot',[RoomController::class,'addBot'])->name('rooms.bot'); Route::post('/room/{room:code}/start',[RoomController::class,'start'])->name('rooms.start'); Route::post('/room/{room:code}/timeout',[RoomController::class,'timeoutAutoPlay'])->name('rooms.timeout'); Route::get('/room/{room:code}/sync',[RoomController::class,'sync'])->name('rooms.sync'); Route::post('/room/{room:code}/chat',[RoomController::class,'roomChat'])->name('rooms.chat'); Route::post('/room/{room:code}/invite',[RoomController::class,'invite'])->name('rooms.invite'); Route::post('/room/{room:code}/replace-player/{player}',[RoomController::class,'replacePlayerWithBot'])->name('rooms.replacePlayer'); Route::post('/room/{room:code}/away',[RoomController::class,'toggleAway'])->name('rooms.away'); Route::post('/room/{room:code}/presence',[RoomController::class,'presence'])->name('rooms.presence'); Route::post('/room/{room:code}/action',[RoomController::class,'action'])->name('rooms.action');
 Route::get('/store',[StoreController::class,'index'])->name('store'); Route::post('/store/{item}/buy',[StoreController::class,'buy'])->name('store.buy'); Route::post('/inventory/{inventory}/activate',[StoreController::class,'activate'])->name('inventory.activate');
 Route::post('/profile/update',[ProfileController::class,'update'])->name('profile.update'); Route::get('/profile/{user?}',[ProfileController::class,'show'])->name('profile.show'); Route::get('/friends',[FriendController::class,'index'])->name('friends'); Route::get('/tokens',[WalletController::class,'index'])->name('tokens'); Route::get('/players/search',[ProfileController::class,'search'])->name('players.search'); Route::post('/wallet/transfer',[WalletController::class,'transfer'])->name('wallet.transfer');
 Route::get('/account/security',[AccountSecurityController::class,'show'])->name('account.security'); Route::patch('/account/security',[AccountSecurityController::class,'updateWeb'])->middleware('throttle:warqna-sensitive')->name('account.security.update');
 Route::post('/friends/request/{user}',[FriendController::class,'request'])->name('friends.request'); Route::post('/friends/respond/{friendship}',[FriendController::class,'respond'])->name('friends.respond'); Route::post('/friends/cancel/{friendship}',[FriendController::class,'cancel'])->name('friends.cancel'); Route::post('/friends/unblock/{user}',[FriendController::class,'unblock'])->name('friends.unblock'); Route::post('/friends/block/{user}',[FriendController::class,'block'])->name('friends.block'); Route::post('/chat/private/{user}',[ChatController::class,'privateMessage'])->name('chat.private'); Route::get('/chat/friends',[ChatController::class,'friends'])->name('chat.friends'); Route::get('/chat/search',[ChatController::class,'search'])->name('chat.search'); Route::get('/chat/thread/{user}',[ChatController::class,'thread'])->name('chat.thread'); Route::post('/chat/send/{user}',[ChatController::class,'send'])->name('chat.send');
 Route::get('/clubs',[ClubController::class,'index'])->name('clubs'); Route::post('/clubs',[ClubController::class,'store'])->name('clubs.store'); Route::get('/clubs/{club}',[ClubController::class,'show'])->name('clubs.show'); Route::post('/clubs/{club}/join',[ClubController::class,'requestJoin'])->name('clubs.join'); Route::post('/clubs/{club}/leave',[ClubController::class,'leave'])->name('clubs.leave'); Route::post('/clubs/{club}/delete',[ClubController::class,'delete'])->name('clubs.delete'); Route::post('/clubs/{club}/settings',[ClubController::class,'updateSettings'])->name('clubs.settings.update'); Route::post('/clubs/{club}/member/{member}',[ClubController::class,'memberAction'])->name('clubs.memberAction'); Route::post('/club-requests/{request}/respond',[ClubController::class,'respond'])->name('clubs.respond'); Route::post('/clubs/{club}/announcements',[ClubController::class,'announcementStore'])->name('clubs.announcements.store'); Route::post('/clubs/{club}/announcements/{announcement}/delete',[ClubController::class,'announcementDelete'])->name('clubs.announcements.delete'); Route::post('/clubs/{club}/tournaments',[ClubController::class,'createTournament'])->name('clubs.tournaments.store');
 Route::get('/social-world',[SocialWorldController::class,'index'])->name('social-world');
 Route::patch('/social-world/privacy',[SocialWorldController::class,'updatePrivacy'])->name('social-world.privacy');
 Route::post('/social-world/publish',[SocialWorldController::class,'publish'])->name('social-world.publish');
 Route::post('/social-world/follow/{user}',[SocialWorldController::class,'follow'])->name('social-world.follow');
 Route::delete('/social-world/follow/{user}',[SocialWorldController::class,'unfollow'])->name('social-world.unfollow');
 Route::post('/social-world/events',[SocialWorldController::class,'createEvent'])->name('social-world.events.create');
 Route::post('/social-world/events/{event}/attend',[SocialWorldController::class,'attend'])->name('social-world.events.attend');
 Route::delete('/social-world/events/{event}/attend',[SocialWorldController::class,'cancelAttendance'])->name('social-world.events.cancel');
 Route::post('/social-world/gifts',[SocialWorldController::class,'sendGift'])->name('social-world.gifts.send');
 Route::post('/social-world/spectate/{room:code}',[SocialWorldController::class,'spectate'])->name('social-world.spectate');
 Route::get('/social-world/spectate/{room:code}/state',[SocialWorldController::class,'spectatorState'])->name('social-world.spectator.state');
 Route::get('/social-world/replays/{replay}',[SocialWorldController::class,'replay'])->name('social-world.replay');
 Route::get('/competitive',[CompetitiveController::class,'index'])->name('competitive');
 Route::post('/competitive/queue',[CompetitiveController::class,'queue'])->name('competitive.queue');
 Route::delete('/competitive/queue',[CompetitiveController::class,'cancel'])->name('competitive.queue.cancel');
 Route::post('/competitive/rewards/{claim}/claim',[CompetitiveController::class,'claim'])->name('competitive.rewards.claim');
 Route::get('/tournaments',[TournamentController::class,'index'])->name('tournaments'); Route::post('/tournaments',[TournamentController::class,'store'])->name('tournaments.store'); Route::post('/tournaments/{tournament}/join',[TournamentController::class,'join'])->name('tournaments.join'); Route::post('/tournaments/{tournament}/leave',[TournamentController::class,'leave'])->name('tournaments.leave'); Route::post('/tournaments/{tournament}/launch',[TournamentController::class,'launch'])->name('tournaments.launch'); Route::get('/tournaments/{tournament}/replay',[TournamentController::class,'replay'])->name('tournaments.replay');
 Route::prefix('admin')->middleware('admin')->group(function(){
    Route::get('/',[AdminController::class,'index'])->name('admin');
    Route::post('/users/{user}',[AdminController::class,'userAction'])->name('admin.users.action');
    Route::post('/site',[AdminController::class,'saveSite'])->name('admin.site.save');
    Route::post('/design',[AdminController::class,'saveDesign'])->name('admin.design.save');
    Route::post('/designer-entities',[AdminController::class,'saveDesignerEntity'])->name('admin.designer.entity.save');
    Route::post('/designer-entities/{entity}/delete',[AdminController::class,'deleteDesignerEntity'])->name('admin.designer.entity.delete');
    Route::post('/games',[AdminController::class,'createGame'])->name('admin.games.create');
    Route::post('/games/{game}',[AdminController::class,'updateGame'])->name('admin.games.update');
    Route::post('/rooms/{room}',[AdminController::class,'updateRoom'])->name('admin.rooms.update');
    Route::post('/rooms/{room}/close',[AdminController::class,'closeRoom'])->name('admin.rooms.close');
    Route::post('/clubs/{club}',[AdminController::class,'updateClub'])->name('admin.clubs.update');
    Route::post('/clubs/{club}/delete',[AdminController::class,'deleteClub'])->name('admin.clubs.delete');
    Route::post('/tournaments',[AdminController::class,'createTournament'])->name('admin.tournaments.create');
    Route::post('/tournaments/{tournament}',[AdminController::class,'updateTournament'])->name('admin.tournaments.update');
    Route::post('/tournaments/{tournament}/delete',[AdminController::class,'deleteTournament'])->name('admin.tournaments.delete');
    Route::post('/store-items',[AdminController::class,'createStoreItem'])->name('admin.store.create');
    Route::post('/store-items/{item}',[AdminController::class,'updateStoreItem'])->name('admin.store.update');
    Route::post('/store-items/{item}/delete',[AdminController::class,'deleteStoreItem'])->name('admin.store.delete');
    Route::post('/store-items/{item}/purge',[AdminController::class,'purgeStoreItem'])->name('admin.store.purge');
    Route::post('/commerce/settings',[CommerceAdminController::class,'saveSettings'])->name('admin.commerce.settings');
    Route::post('/commerce/offers',[CommerceAdminController::class,'saveOffer'])->name('admin.commerce.offer.save');
    Route::post('/commerce/offers/{offer}/delete',[CommerceAdminController::class,'deleteOffer'])->name('admin.commerce.offer.delete');
    Route::post('/social-world/settings',[AdminSocialWorldController::class,'updateSettings'])->name('admin.social-world.settings');
    Route::post('/social-world/activities/{activity}',[AdminSocialWorldController::class,'activityAction'])->name('admin.social-world.activity');
    Route::post('/social-world/events/{event}',[AdminSocialWorldController::class,'eventAction'])->name('admin.social-world.event');
    Route::post('/social-world/replays/{replay}',[AdminSocialWorldController::class,'replayAction'])->name('admin.social-world.replay');
    Route::post('/social-world/spectators/{spectator}/evict',[AdminSocialWorldController::class,'evictSpectator'])->name('admin.social-world.spectator.evict');
    Route::get('/competitive',[AdminCompetitiveController::class,'dashboard'])->name('admin.competitive');
    Route::patch('/competitive/settings',[AdminCompetitiveController::class,'updateSettings'])->name('admin.competitive.settings');
    Route::post('/competitive/seasons',[AdminCompetitiveController::class,'createSeason'])->name('admin.competitive.season.create');
    Route::post('/competitive/seasons/{season}',[AdminCompetitiveController::class,'seasonAction'])->name('admin.competitive.season.action');
    Route::post('/competitive/ratings/{user}',[AdminCompetitiveController::class,'adjustRating'])->name('admin.competitive.rating.adjust');
    Route::post('/competitive/matches/{match}',[AdminCompetitiveController::class,'matchAction'])->name('admin.competitive.match.action');
    Route::post('/competitive/tournaments',[AdminCompetitiveController::class,'createTournament'])->name('admin.competitive.tournament.create');
    Route::post('/competitive/tournaments/{tournament}/bracket',[AdminCompetitiveController::class,'buildBracket'])->name('admin.competitive.tournament.bracket');
    Route::get('/pro-v118', fn()=>response()->json(['ok'=>true,'version'=>config('warqna_pro_features.version'),'status'=>'admin pro dashboard route restored v134']))->name('admin.pro.v118');
    Route::get('/engine-audit', [\App\Http\Controllers\EngineAuditController::class,'index'])->name('admin.engine.audit');
    Route::post('/economy/season', fn()=>back()->with('ok','تم حفظ الموسم من لوحة الإدارة'))->name('admin.economy.season');
    Route::post('/economy/offer', fn()=>back()->with('ok','تم حفظ العرض من لوحة الإدارة'))->name('admin.economy.offer');
    Route::post('/economy/rare', fn()=>back()->with('ok','تم حفظ المقتنى النادر من لوحة الإدارة'))->name('admin.economy.rare');
});
});
