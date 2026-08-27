<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{
    MobileApiController,
    MobileGameController,
    MobileSocialController,
    MobileAdminController,
    MobileVoiceController,
    MobilePlatformController,
    MobileAccountController,
    MobileSafetyController,
    MobileModerationController,
    MobileAuthRecoveryController,
    SocialAuthController,
    MobilePushController,
    MobileEngagementController,
    MobileAssetController,
    MobileCommerceController,
    MobileSocialWorldController,
    MobileSpectatorController,
    MobileReplayController,
    MobileClubWorldController,
    MobileCompetitiveController,
    AdminSocialWorldController,
    AdminCompetitiveController,
    AccountSecurityController,
    MobileLifecycleController,
    MobilePartyController,
    AdminEconomyAuditController
};

// Backward-compatible public aliases for older Flutter/PWA builds. They
// expose only health, app capability flags and the curated game catalog.
Route::prefix('mobile')->group(function () {
    Route::get('/health', [MobilePlatformController::class, 'legacyHealth']);
    Route::get('/bootstrap', [MobilePlatformController::class, 'legacyBootstrap']);
    Route::get('/games', [MobilePlatformController::class, 'legacyGames']);
});

Route::prefix('mobile/v1')->group(function () {
    Route::get('/health', [MobilePlatformController::class, 'health']);
    Route::get('/app-config', [MobilePlatformController::class, 'config']);
    Route::get('/countries', [MobilePlatformController::class, 'countries']);
    Route::post('/social-auth/start/{provider}', [SocialAuthController::class, 'start'])->middleware('throttle:warqna-auth');
    Route::get('/social-auth/status/{state}', [SocialAuthController::class, 'status'])->middleware('throttle:warqna-auth');
    Route::post('/register', [MobileApiController::class, 'register'])->middleware('throttle:warqna-auth');
    Route::post('/password/forgot', [MobileAuthRecoveryController::class, 'forgot'])->middleware('throttle:warqna-auth');
    Route::post('/password/reset', [MobileAuthRecoveryController::class, 'reset'])->middleware('throttle:warqna-auth');
    Route::post('/login', [MobileApiController::class, 'login'])->middleware('throttle:warqna-auth');
    Route::get('/games/catalog', [MobileGameController::class, 'catalog']);
    Route::get('/games/{gameKey}/rules', [MobileGameController::class, 'rules']);
    Route::get('/assets/manifest', [MobileAssetController::class, 'manifest']);
    Route::get('/commerce/catalog', [MobileCommerceController::class, 'catalog']);

    Route::middleware(['auth:sanctum', 'throttle:warqna-api', 'supported.app', 'maintenance.guard'])->group(function () {
        Route::get('/bootstrap', [MobileApiController::class, 'bootstrap']);
        Route::post('/email/verification-notification', [MobileAuthRecoveryController::class, 'sendVerification'])->middleware('throttle:warqna-sensitive');
        Route::get('/profile', [MobileApiController::class, 'profile']);
        Route::patch('/profile', [MobileApiController::class, 'updateProfile']);
        Route::get('/wallet', [MobileApiController::class, 'wallet']);
        Route::post('/store/purchase', [MobileApiController::class, 'purchase'])->middleware('throttle:warqna-sensitive');
        Route::post('/store/activate', [MobileApiController::class, 'activateStoreInventoryV183'])->middleware('throttle:warqna-sensitive');
        Route::post('/commerce/verify-receipt', [MobileCommerceController::class, 'verifyReceipt'])->middleware('throttle:warqna-sensitive');
        Route::get('/commerce/receipts/{receipt}', [MobileCommerceController::class, 'receipt'])->middleware('throttle:warqna-sensitive');
        Route::get('/notifications', [MobileApiController::class, 'notifications']);
        Route::patch('/notifications/{id}/read', [MobileApiController::class, 'markNotification']);
        Route::delete('/notifications/{id}', [MobileApiController::class, 'deleteNotification']);
        Route::post('/push/devices', [MobilePushController::class, 'store']);
        Route::delete('/push/devices', [MobilePushController::class, 'destroy']);
        Route::post('/rewards/daily', [MobileApiController::class, 'claimDaily'])->middleware('throttle:warqna-sensitive');
        Route::post('/rewards/rewarded-ad', [MobileApiController::class, 'claimRewardedAd'])->middleware('throttle:warqna-sensitive');
        Route::get('/engagement/center', [MobileEngagementController::class, 'center']);
        Route::get('/rewards/lucky-wheel', [MobileEngagementController::class, 'luckyWheel']);
        Route::post('/rewards/lucky-wheel/spin', [MobileEngagementController::class, 'spinLuckyWheel'])->middleware('throttle:warqna-sensitive');
        Route::get('/prize-boxes', [MobileEngagementController::class, 'prizeBoxes']);
        Route::post('/prize-boxes/{prizeBox}/open', [MobileEngagementController::class, 'openPrizeBox'])->middleware('throttle:warqna-sensitive');
        Route::post('/packs/daily/open', [MobileEngagementController::class, 'openDailyPack'])->middleware('throttle:warqna-sensitive');
        Route::post('/challenges/{challengeKey}/activate', [MobileEngagementController::class, 'activateChallenge'])->middleware('throttle:warqna-sensitive');
        Route::post('/challenges/{challengeKey}/claim', [MobileEngagementController::class, 'claimChallenge'])->middleware('throttle:warqna-sensitive');
        Route::post('/challenge-road/start', [MobileEngagementController::class, 'startChallengeRoad'])->middleware('throttle:warqna-sensitive');
        Route::post('/challenge-road/matchmake', [MobileEngagementController::class, 'matchmakeChallengeRoad'])->middleware('throttle:warqna-sensitive');
        Route::post('/competitions/{competitionKey}/join', [MobileEngagementController::class, 'joinCompetition'])->middleware('throttle:warqna-sensitive');
        Route::post('/competitions/{competitionKey}/leave', [MobileEngagementController::class, 'leaveCompetition'])->middleware('throttle:warqna-sensitive');

        Route::get('/account/export', [MobileAccountController::class, 'export'])->middleware('throttle:warqna-sensitive');
        Route::patch('/account/security', [AccountSecurityController::class, 'updateMobile'])->middleware('throttle:warqna-sensitive');
        Route::get('/account/sessions', [MobileAccountController::class, 'sessions']);
        Route::delete('/account/sessions/{tokenId}', [MobileAccountController::class, 'revokeSession'])->middleware('throttle:warqna-sensitive');
        Route::post('/account/deletion-request', [MobileAccountController::class, 'requestDeletion'])->middleware('throttle:warqna-sensitive');
        Route::delete('/account/deletion-request', [MobileAccountController::class, 'cancelDeletion'])->middleware('throttle:warqna-sensitive');
        Route::delete('/account', [MobileAccountController::class, 'requestDeletion'])->middleware('throttle:warqna-sensitive');

        Route::post('/safety/reports', [MobileSafetyController::class, 'report'])->middleware('throttle:warqna-report');
        Route::get('/safety/reports', [MobileSafetyController::class, 'mine']);

        Route::get('/games/{gameKey}/rooms', [MobileGameController::class, 'rooms']);
        Route::post('/games/session', [MobileGameController::class, 'create'])->middleware('throttle:warqna-sensitive');
        Route::post('/games/session/{room:code}/join', [MobileGameController::class, 'join']);
        Route::get('/games/session/{room:code}', [MobileGameController::class, 'show']);
        Route::post('/games/session/{room:code}/action', [MobileGameController::class, 'action']);
        Route::post('/games/session/{room:code}/timeout', [MobileGameController::class, 'timeout']);
        Route::post('/games/session/{room:code}/leave', [MobileGameController::class, 'leave']);
        Route::post('/games/session/{room:code}/kick/{user}', [MobileGameController::class, 'kick'])->middleware('throttle:warqna-sensitive');
        Route::get('/games/session/{room:code}/chat', [MobileGameController::class, 'chat']);
        Route::post('/games/session/{room:code}/chat', [MobileGameController::class, 'sendChat']);


        // WORLD EXPERIENCE lifecycle: heartbeat/reconnect/AFK state is server authoritative.
        Route::get('/games/session/{room:code}/lifecycle', [MobileLifecycleController::class, 'status'])->middleware('throttle:warqna-presence');
        Route::post('/games/session/{room:code}/heartbeat', [MobileLifecycleController::class, 'heartbeat'])->middleware('throttle:warqna-presence');
        Route::post('/games/session/{room:code}/disconnect', [MobileLifecycleController::class, 'disconnect'])->middleware('throttle:30,1');
        Route::post('/games/session/{room:code}/reconnect', [MobileLifecycleController::class, 'reconnect'])->middleware('throttle:warqna-presence');

        Route::post('/games/session/{room:code}/voice/join', [MobileVoiceController::class, 'join'])->middleware('throttle:30,1');
        Route::get('/games/session/{room:code}/voice/poll', [MobileVoiceController::class, 'poll'])->middleware('throttle:120,1');
        Route::post('/games/session/{room:code}/voice/signal', [MobileVoiceController::class, 'signal'])->middleware('throttle:240,1');
        Route::patch('/games/session/{room:code}/voice/controls', [MobileVoiceController::class, 'controls'])->middleware('throttle:60,1');
        Route::post('/games/session/{room:code}/voice/leave', [MobileVoiceController::class, 'leave'])->middleware('throttle:30,1');

        Route::get('/social', [MobileSocialController::class, 'index']);
        Route::get('/social/search', [MobileSocialController::class, 'search']);
        Route::get('/social/users/{user}/profile', [MobileSocialController::class, 'profile']);
        Route::post('/social/users/{user}/room-invite', [MobileSocialController::class, 'inviteToRoom']);
        Route::post('/social/room-invite-all', [MobileSocialController::class, 'inviteAllToRoom'])->middleware('throttle:warqna-sensitive');
        Route::post('/social/friends/{user}/request', [MobileSocialController::class, 'request']);
        Route::post('/social/friendships/{friendship}/respond', [MobileSocialController::class, 'respond']);
        Route::delete('/social/friendships/{friendship}', [MobileSocialController::class, 'cancel']);
        Route::post('/social/users/{user}/block', [MobileSocialController::class, 'block']);
        Route::delete('/social/users/{user}/block', [MobileSocialController::class, 'unblock']);
        Route::get('/social/chat/{user}', [MobileSocialController::class, 'thread']);
        Route::post('/social/chat/{user}', [MobileSocialController::class, 'send']);
        Route::post('/social/transfer', [MobileSocialController::class, 'transfer'])->middleware('throttle:warqna-sensitive');

        // Party system — friend-only squads that can move into matchmaking/rooms together.
        Route::get('/parties/mine', [MobilePartyController::class, 'mine']);
        Route::post('/parties', [MobilePartyController::class, 'create'])->middleware('throttle:warqna-sensitive');
        Route::patch('/parties/{party}', [MobilePartyController::class, 'configure'])->middleware('throttle:warqna-sensitive');
        Route::post('/parties/{party}/invite/{user}', [MobilePartyController::class, 'invite'])->middleware('throttle:warqna-sensitive');
        Route::post('/parties/join/{code}', [MobilePartyController::class, 'join'])->middleware('throttle:warqna-sensitive');
        Route::post('/parties/{party}/leave', [MobilePartyController::class, 'leave'])->middleware('throttle:warqna-sensitive');


        // R11 Social World — privacy-first feed, events, following and animated gifts.
        Route::get('/social-world', [MobileSocialWorldController::class, 'dashboard']);
        Route::get('/social-world/privacy', [MobileSocialWorldController::class, 'privacy']);
        Route::patch('/social-world/privacy', [MobileSocialWorldController::class, 'updatePrivacy'])->middleware('throttle:warqna-sensitive');
        Route::post('/social-world/presence', [MobileSocialWorldController::class, 'heartbeat'])->middleware('throttle:120,1');
        Route::post('/social-world/follows/{user}', [MobileSocialWorldController::class, 'follow'])->middleware('throttle:60,1');
        Route::delete('/social-world/follows/{user}', [MobileSocialWorldController::class, 'unfollow'])->middleware('throttle:60,1');
        Route::post('/social-world/activities', [MobileSocialWorldController::class, 'publish'])->middleware('throttle:30,1');
        Route::delete('/social-world/activities/{activity}', [MobileSocialWorldController::class, 'deleteActivity']);
        Route::get('/social-world/events', [MobileSocialWorldController::class, 'events']);
        Route::post('/social-world/events', [MobileSocialWorldController::class, 'createEvent'])->middleware('throttle:warqna-sensitive');
        Route::post('/social-world/events/{event}/attend', [MobileSocialWorldController::class, 'attend'])->middleware('throttle:60,1');
        Route::delete('/social-world/events/{event}/attend', [MobileSocialWorldController::class, 'cancelAttendance'])->middleware('throttle:60,1');
        Route::get('/social-world/gifts', [MobileSocialWorldController::class, 'gifts']);
        Route::post('/social-world/gifts', [MobileSocialWorldController::class, 'sendGift'])->middleware('throttle:warqna-sensitive');

        // Spectators are read-only and isolated from player voice/chat and hidden state.
        Route::get('/spectator/rooms', [MobileSpectatorController::class, 'lobby']);
        Route::post('/spectator/rooms/{room:code}/join', [MobileSpectatorController::class, 'join'])->middleware('throttle:30,1');
        Route::get('/spectator/rooms/{room:code}', [MobileSpectatorController::class, 'show']);
        Route::post('/spectator/rooms/{room:code}/heartbeat', [MobileSpectatorController::class, 'heartbeat'])->middleware('throttle:120,1');
        Route::post('/spectator/rooms/{room:code}/leave', [MobileSpectatorController::class, 'leave']);

        Route::get('/replays', [MobileReplayController::class, 'index']);
        Route::get('/replays/{replay}', [MobileReplayController::class, 'show']);
        Route::patch('/replays/{replay}/visibility', [MobileReplayController::class, 'updateVisibility'])->middleware('throttle:warqna-sensitive');
        Route::delete('/replays/{replay}', [MobileReplayController::class, 'hide'])->middleware('throttle:warqna-sensitive');

        // Clubs 2.0 mobile contract.
        Route::get('/clubs-world', [MobileClubWorldController::class, 'index']);
        Route::get('/clubs-world/{club}', [MobileClubWorldController::class, 'show']);
        Route::post('/clubs-world', [MobileClubWorldController::class, 'create'])->middleware('throttle:warqna-sensitive');
        Route::post('/clubs-world/{club}/join', [MobileClubWorldController::class, 'join'])->middleware('throttle:30,1');
        Route::post('/clubs-world/{club}/leave', [MobileClubWorldController::class, 'leave'])->middleware('throttle:warqna-sensitive');
        Route::post('/clubs-world/{club}/announcements', [MobileClubWorldController::class, 'announce'])->middleware('throttle:warqna-sensitive');
        Route::patch('/clubs-world/join-requests/{joinRequest}', [MobileClubWorldController::class, 'respond'])->middleware('throttle:warqna-sensitive');

        // R12 Competitive Arena — server-authoritative MMR, seasons, cups and rewards.
        Route::get('/competitive', [MobileCompetitiveController::class, 'dashboard']);
        Route::post('/competitive/queue', [MobileCompetitiveController::class, 'joinQueue'])->middleware('throttle:20,1');
        Route::get('/competitive/queue', [MobileCompetitiveController::class, 'queueStatus'])->middleware('throttle:120,1');
        Route::delete('/competitive/queue', [MobileCompetitiveController::class, 'cancelQueue'])->middleware('throttle:30,1');
        Route::get('/competitive/leaderboard', [MobileCompetitiveController::class, 'leaderboard']);
        Route::get('/competitive/history', [MobileCompetitiveController::class, 'history']);
        Route::get('/competitive/tournaments/{tournament}', [MobileCompetitiveController::class, 'tournament']);
        Route::post('/competitive/tournaments/{tournament}/join', [MobileCompetitiveController::class, 'joinTournament'])->middleware('throttle:warqna-sensitive');
        Route::delete('/competitive/tournaments/{tournament}/leave', [MobileCompetitiveController::class, 'leaveTournament'])->middleware('throttle:warqna-sensitive');
        Route::post('/competitive/rewards/{claim}/claim', [MobileCompetitiveController::class, 'claimReward'])->middleware('throttle:warqna-sensitive');

        Route::get('/admin/dashboard', [MobileAdminController::class, 'dashboard']);
        Route::patch('/admin/games/{game}', [MobileAdminController::class, 'updateGame']);
        Route::patch('/admin/store/{item}', [MobileAdminController::class, 'updateStore']);
        Route::delete('/admin/store/{item}', [MobileAdminController::class, 'deleteStore']);
        Route::post('/admin/users/{user}/action', [MobileAdminController::class, 'userAction']);
        Route::patch('/admin/feature-flags/{flag}', [MobileAdminController::class, 'updateFeatureFlag']);
        Route::post('/admin/releases', [MobileAdminController::class, 'createRelease']);
        Route::get('/admin/designer', [MobileAdminController::class, 'designerIndex']);
        Route::patch('/admin/designer/{entityType}/{key}', [MobileAdminController::class, 'upsertDesigner']);
        Route::delete('/admin/designer/{entity}', [MobileAdminController::class, 'deleteDesigner']);
        Route::get('/admin/moderation/reports', [MobileModerationController::class, 'index']);
        Route::patch('/admin/moderation/reports/{report}', [MobileModerationController::class, 'resolve']);
        Route::get('/admin/social-world', [AdminSocialWorldController::class, 'dashboard']);
        Route::patch('/admin/social-world/settings', [AdminSocialWorldController::class, 'updateSettings']);
        Route::post('/admin/social-world/activities/{activity}', [AdminSocialWorldController::class, 'activityAction']);
        Route::post('/admin/social-world/events/{event}', [AdminSocialWorldController::class, 'eventAction']);
        Route::post('/admin/social-world/replays/{replay}', [AdminSocialWorldController::class, 'replayAction']);
        Route::post('/admin/social-world/spectators/{spectator}/evict', [AdminSocialWorldController::class, 'evictSpectator']);
        Route::get('/admin/competitive', [AdminCompetitiveController::class, 'dashboard']);
        Route::patch('/admin/competitive/settings', [AdminCompetitiveController::class, 'updateSettings']);
        Route::post('/admin/competitive/seasons', [AdminCompetitiveController::class, 'createSeason']);
        Route::post('/admin/competitive/seasons/{season}', [AdminCompetitiveController::class, 'seasonAction']);
        Route::post('/admin/competitive/ratings/{user}', [AdminCompetitiveController::class, 'adjustRating']);
        Route::post('/admin/competitive/matches/{match}', [AdminCompetitiveController::class, 'matchAction']);
        Route::post('/admin/competitive/tournaments', [AdminCompetitiveController::class, 'createTournament']);
        Route::post('/admin/competitive/tournaments/{tournament}/bracket', [AdminCompetitiveController::class, 'buildBracket']);

        Route::get('/admin/economy-audit', [AdminEconomyAuditController::class, 'index'])->middleware('throttle:warqna-sensitive');
        Route::patch('/admin/economy-audit/{event}', [AdminEconomyAuditController::class, 'review'])->middleware('throttle:warqna-sensitive');


        Route::post('/logout', [MobileApiController::class, 'logout']);
    });
});
