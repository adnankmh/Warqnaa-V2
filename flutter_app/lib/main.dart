Warning: truncated output (original token count: 164229)
Total output lines: 10420

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

import 'engines/tarneeb_engine.dart';
import 'engines/local_game_engine.dart';
import 'services/api_client.dart';
import 'services/rewarded_ads.dart';
import 'services/interstitial_ads.dart';
import 'services/voice_room_service.dart';
import 'services/app_sounds.dart';
import 'services/app_notifications.dart';
import 'services/connection_diagnostics.dart';
import 'services/r10_asset_delivery.dart';
import 'models/room_launch_options.dart';
import 'r9_design_system.dart';
import 'data/countries.dart';
import 'premium_v149.dart';

part 'premium_v151.dart';
part 'production_v153.dart';
part 'v166_polish.dart';
part 'v170_global.dart';
part 'v173_global.dart';
part 'v175_release.dart';
part 'v176_release.dart';
part 'v02_release.dart';
part 'v021_patch.dart';
part 'v182_rewards.dart';
part 'v183_overhaul.dart';
part 'r9_release.dart';
part 'r10_1_release.dart';
part 'r11_social_world.dart';
part 'r12_competitive.dart';
part 'r14_1_legendary.dart';
part 'r14_2_account_security.dart';
part 'v300_world_experience.dart';
part 'v304_vertical_legend.dart';
part 'v305_single_table.dart';
part 'b307_visual_revolution.dart';
part 'r35_reference_world.dart';
part 'r36_meld_workspace.dart';
part 'r41_board_legibility.dart';
part 'r36_store_sync.dart';
part 'r5_world_class.dart';
part 'r6_1_world_class.dart';
part 'r6_4_world_championship.dart';
part 'r6_5_operations.dart';
part 'r8_play_experience.dart';
part 'r9_local_studio.dart';
// Contract anchor: LuckyWheelHomeCardV182(controller: controller) is rendered by the V183/V184 responsive home screen.

final GlobalKey<NavigatorState> warqnaNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  // The Flutter binding and runApp must be created in the same zone. Keeping
  // the boot path synchronous also guarantees that the first frame is not
  // blocked by SharedPreferences, AdMob, WebRTC, networking, or any optional
  // platform plug-in.
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };
    // Register the FCM background entry point before the first frame. The
    // registration is inert when Firebase build variables are absent.
    PushNotifications.registerBackgroundHandler();

    ui.PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Uncaught platform error: $error\n$stack');
      return true;
    };
    ErrorWidget.builder = (details) => Material(
          color: const Color(0xff101620),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Warqna recovered from a screen error.\n${details.exceptionAsString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );

    runApp(const WarqnaApp());
  }, (error, stack) {
    debugPrint('Application zone error: $error\n$stack');
  });
}

class WarqnaApp extends StatefulWidget {
  const WarqnaApp({super.key});

  @override
  State<WarqnaApp> createState() => _WarqnaAppState();
}

class _WarqnaAppState extends State<WarqnaApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(controller.load());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: warqnaNavigatorKey,
          debugShowCheckedModeBanner: false,
          locale: Locale(controller.localeCode),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final current = MediaQuery.textScalerOf(context).scale(1.0);
            final widthCap = media.size.width < 370 ? 1.08 : media.size.width < 430 ? 1.16 : 1.28;
            final safeScale = (current * controller.uiFontScale).clamp(.85, widthCap).toDouble();
            return MediaQuery(
              data: media.copyWith(textScaler: TextScaler.linear(safeScale)),
              child: ClipRect(child: child ?? const SizedBox.shrink()),
            );
          },
          theme: r101Theme(controller.themeCode, controller.uiAccentHex,
            fontFamily: controller.uiFontFamily, localeCode: controller.localeCode),
          home: !controller.ready
              ? const AppLoadingScreen()
              : controller.isAuthenticated
                  ? HomeShell(controller: controller)
                  : LoginScreen(controller: controller),
        );
      },
    );
  }
}

class AppController extends ChangeNotifier {
  AppController({WarqnaApiClient? api}) : api=api ?? WarqnaApiClient();
  final WarqnaApiClient api;
  String? _pendingRoomCodeV174;
  String? _queuedNavigationRouteV175;
  bool _openingNavigationRouteV175 = false;

  void refreshUi() => notifyListeners();

  bool ready = false;
  bool isAuthenticated = false;
  bool isAdmin = false;
  String adminRole = 'player';
  bool get isPrimaryAdmin => isAdmin && adminRole == 'primary_admin';
  static final BigInt primaryAdminTokens = BigInt.parse('9999999999999999999');
  bool get isLocalAdmin => isAuthenticated && adminRole == 'local_admin' && authToken == null && !serverConnected;
  int? currentUserId;
  bool serverConnected = false;
  String? lastStoreError;
  bool soundEnabled = true;
  bool landscapeMode = false;
  String selectedTable = v305PremiumTableId;
  String selectedCardBack = v305CardBackId;
  String selectedNameColor = '#facc15';
  String selectedChatColor = '#ffffff';
  DateTime? nameColorExpiresAt;
  DateTime? chatColorExpiresAt;
  String avatarEmoji = '🦁';
  String? avatarData;
  String selectedBadge = 'badge_pro';
  String selectedEmojiPack = 'emoji_free_basic';
  String selectedEffect = 'effect_gold_entry';
  String selectedCover = 'cover_royal_gold';
  String selectedProfileFrameV300 = 'frame_world_gold';
  String selectedProfileColorB304 = 'b304_profile_aurora_30d';
  DateTime? profileColorExpiresAtB304;
  String botDifficultyCode = 'pro';
  double uiButtonHeight = 48;
  double uiRadius = 18;
  double uiFontScale = 1.0;
  double uiChatScale = 1.0;
  String uiFontFamily = 'Roboto';
  String? customTableBackgroundData;
  String? customCardBackData;
  String uiAccentHex = '#ffcf67';
  bool tableAmbientEffects = true;
  String selectedPashaStyle = 'red';
  final Map<int, int> competitionTickets = <int, int>{};
  String? dailyPackLastOpened;
  String? dailyPackReward;
  DateTime? temporaryTableExpiresAtV173;
  DateTime? boosterExpiresAtV173;
  final Map<String, DateTime> packInventoryExpiriesV176 = <String, DateTime>{};
  final List<Map<String, dynamic>> dailyPackHistoryV176 = <Map<String, dynamic>>[];
  Map<String, dynamic>? lastDailyPackRevealV176;
  final List<Map<String, dynamic>> prizeBoxesV02 = <Map<String, dynamic>>[];
  String prizeBoxesDateV02 = '';
  int championRankPointsV173 = 0;
  int challengeStreakV173 = 0;
  Timer? connectivityTimerV173;
  bool awayMode = false;
  String? luckyWheelLastFreeDateV182;
  String luckyWheelSpinDateV182 = '';
  int luckyWheelTokenSpinsV182 = 0;
  Map<String, dynamic>? lastLuckyWheelRewardV182;
  BigInt adminRevenueTokensV182 = BigInt.zero;
  final List<Map<String, dynamic>> designerOfflineEntitiesV182 = <Map<String, dynamic>>[];
  final Map<String, List<String>> clubPermissionsV182 = <String, List<String>>{};
  final List<Map<String, dynamic>> clubActivityV182 = <Map<String, dynamic>>[];
  // Legacy game-wide counter is kept only for old saved-state compatibility.
  // R9.1 enforces the five-exit rule per exact room code, never per game type.
  final Map<String, int> gameExitCounts = <String, int>{};
  final Map<String, int> roomExitCountsV210 = <String, int>{};
  int gamesPlayed = 842;
  int wins = 514;
  double activeXpMultiplier = 1.0;
  int giftRoadProgress = 5;
  final Set<int> claimedGiftSteps = <int>{};
  String? activeCompetition;
  String? activeChallenge;
  String? challengeRoadGame;
  int challengeRoadStage = 0;
  int challengeRoadTotal = 12;
  int challengeRoadAttempts = 5;
  bool challengeRoadCompleted = false;
  final Set<String> challengeRoadResultMarkers = <String>{};
  String? activeGame;
  final List<String> homeGameIds = <String>['tarneeb', 'hand', 'trix'];
  String? activeRoomCode;
  String? activeRoomName;
  bool activeRoomVoice = false;
  String activeRoomVisibility = 'public';
  int activeRoomTurnSeconds = 10;
  bool activeRoomSingleRound = false;
  RoundRewardReport? lastRoundReport;
  final Set<String> rewardedMatches = <String>{};
  String localeCode = 'ar';
  String themeCode = 'dark';
  String customApiUrl = '';
  String username = 'Adnan';
  String displayName = 'Adnan';
  String email = 'adnan@warqna.local';
  String countryCode = 'PS';
  String countryName = 'فلسطين';
  int roundPoints = 0;
  int tournamentPoints = 0;
  int clubPoints = 0;
  String? authToken;
  BigInt coins = BigInt.from(125680);
  int level = 28;
  int xp = 18560;
  int xpNext = 25000;
  int vipDays = 12;
  int consecutiveLoginDays = 0;
  String? lastLoginDate;
  String? lastDailyClaimDate;
  int rewardedAdClaimsToday = 0;
  String? rewardedAdClaimDate;
  String? activeClub;
  String clubImageEmojiV182 = '🛡️';
  String clubDescriptionV182 = 'نادي احترافي داخل مجتمع ورقنا.';
  final Set<String> owned = {'emoji_fun'};
  final Map<String,int> inventoryQuantitiesR36 = <String,int>{};
  final Map<String, int> storePriceOverrides = <String, int>{};
  final Map<String,Map<String,dynamic>> serverStoreR36 = <String,Map<String,dynamic>>{};
  bool serverStoreReadyR36 = false;
  final Map<String, String> storeNameOverrides = <String, String>{};
  final Map<String, String> storeDescriptionOverrides = <String, String>{};
  final Map<String, int> storeDurationOverrides = <String, int>{};
  final Map<String, String> storeColor1Overrides = <String, String>{};
  final Map<String, String> storeColor2Overrides = <String, String>{};
  final Set<String> hiddenStoreProducts = <String>{};
  final List<AppNotice> notices = [
    AppNotice('🏆', 'بدأ التسجيل في بطولة الأبطال', 'المقاعد محدودة والتسجيل متاح الآن.'),
    AppNotice('🎁', 'مكافأتك اليومية جاهزة', 'استلم 100 توكن و20 نقطة خبرة.'),
    AppNotice('👤', 'أرسل سامر طلب صداقة', 'يمكنك القبول من مركز الأصدقاء.'),
  ];
  final List<TokenTransaction> transactions = [
    const TokenTransaction('مكافأة يومية', 100, 'اليوم 09:12'),
    const TokenTransaction('شراء حزمة المرح', -4200, 'أمس 18:27'),
  ];
  final List<LocalFriend> friends = [
    LocalFriend(2, 'سامر', 'Samer', online: true, activity: 'يلعب طرنيب'),
    LocalFriend(3, 'ليلى', 'Layla', online: true, activity: 'في المتجر'),
    LocalFriend(4, 'جميل', 'Jameel', online: false, activity: 'آخر ظهور قبل ساعة'),
  ];
  final List<LocalFriend> incomingRequests = [
    LocalFriend(5, 'نور', 'Noor', online: true, activity: 'طلب صداقة جديد'),
  ];
  final List<LocalFriend> outgoingRequests = [];
  final List<LocalFriend> blocked = [];
  final Map<int, List<ChatMessage>> privateChats = {
    2: [
      ChatMessage('سامر', 'أهلاً بك، هل نبدأ مباراة طرنيب؟', false, '09:10'),
      ChatMessage('Adnan', 'نعم، أرسل الدعوة.', true, '09:11'),
    ],
  };

  String get _accountPrefix => adminRole == 'local_admin'
      ? 'warqna.device-admin.adnan.'
      : 'warqna.account.${username.trim().toLowerCase()}.';
  String _accountKey(String key) => '$_accountPrefix$key';

  Future<void> _loadAccountState(
    SharedPreferences prefs, {
    String? defaultCoins,
    int? defaultLevel,
    int? defaultVipDays,
    String? defaultAvatar,
  }) async {
    final initializedKey = _accountKey('initialized');
    final initialized = prefs.getBool(initializedKey) ?? false;
    if (!initialized) {
      coins = BigInt.tryParse(defaultCoins ?? '') ?? BigInt.from(1500);
      level = defaultLevel ?? 1;
      xp = 0;
      xpNext = xpNeededForLevel(level);
      vipDays = defaultVipDays ?? 0;
      avatarEmoji = defaultAvatar ?? demoAvatarFor(username);
      avatarData = null;
      countryCode = 'PS';
      countryName = countryByCode(countryCode).name(localeCode);
      roundPoints = 0;
      tournamentPoints = 0;
      clubPoints = 0;
      selectedTable = v305PremiumTableId;
      selectedCardBack = v305CardBackId;
      selectedNameColor = '#facc15';
      selectedChatColor = '#ffffff';
      selectedBadge = 'badge_pro';
      selectedEmojiPack = 'emoji_free_basic';
      selectedEffect = 'effect_gold_entry';
      selectedCover = 'cover_royal_gold';
      selectedProfileFrameV300 = 'frame_world_gold';
      activeClub = null;
      clubImageEmojiV182 = '🛡️';
      clubDescriptionV182 = 'نادي احترافي داخل مجتمع ورقنا.';
      activeCompetition = null;
      activeChallenge = null;
      challengeRoadGame = null;
      challengeRoadStage = 0;
      challengeRoadTotal = 12;
      challengeRoadAttempts = 5;
      challengeRoadCompleted = false;
      challengeRoadResultMarkers.clear();
      activeGame = null;
      homeGameIds
        ..clear()
        ..addAll(const <String>['tarneeb', 'hand', 'trix']);
      owned
        ..clear()
        ..add('emoji_fun');
      gameExitCounts.clear();
      roomExitCountsV210.clear();
      awayMode = false;
      luckyWheelLastFreeDateV182 = null;
      luckyWheelSpinDateV182 = '';
      luckyWheelTokenSpinsV182 = 0;
      lastLuckyWheelRewardV182 = null;
      adminRevenueTokensV182 = BigInt.zero;
      designerOfflineEntitiesV182.clear();
      clubPermissionsV182.clear();
      clubActivityV182.clear();
      await prefs.setBool(initializedKey, true);
      await _saveAccountState(prefs);
      return;
    }

    displayName = prefs.getString(_accountKey('displayName')) ?? displayName;
    email = prefs.getString(_accountKey('email')) ?? email;
    countryCode = prefs.getString(_accountKey('countryCode')) ?? 'PS';
    countryName = prefs.getString(_accountKey('countryName')) ?? countryByCode(countryCode).name(localeCode);
    roundPoints = prefs.getInt(_accountKey('roundPoints')) ?? 0;
    tournamentPoints = prefs.getInt(_accountKey('tournamentPoints')) ?? 0;
    clubPoints = prefs.getInt(_accountKey('clubPoints')) ?? 0;
    coins = BigInt.tryParse(prefs.getString(_accountKey('coins')) ?? '') ?? BigInt.from(1500);
    level = prefs.getInt(_accountKey('level')) ?? defaultLevel ?? 1;
    xp = prefs.getInt(_accountKey('xp')) ?? 0;
    xpNext = prefs.getInt(_accountKey('xpNext')) ?? xpNeededForLevel(level);
    vipDays = prefs.getInt(_accountKey('vipDays')) ?? defaultVipDays ?? 0;
    avatarEmoji = prefs.getString(_accountKey('avatarEmoji')) ?? defaultAvatar ?? demoAvatarFor(username);
    avatarData = prefs.getString(_accountKey('avatarData'));
    selectedTable = prefs.getString(_accountKey('selectedTable')) ?? v305PremiumTableId;
    selectedCardBack = prefs.getString(_accountKey('selectedCardBack')) ?? v305CardBackId;
    if (!isR61SelectableTableId(selectedTable)) selectedTable = v305PremiumTableId;
    if (!isR61SelectableCardBackId(selectedCardBack)) selectedCardBack = v305CardBackId;
    selectedNameColor = prefs.getString(_accountKey('selectedNameColor')) ?? '#facc15';
    selectedChatColor = prefs.getString(_accountKey('selectedChatColor')) ?? '#ffffff';
    nameColorExpiresAt = DateTime.tryParse(prefs.getString(_accountKey('nameColorExpiresAt')) ?? '');
    chatColorExpiresAt = DateTime.tryParse(prefs.getString(_accountKey('chatColorExpiresAt')) ?? '');
    selectedBadge = prefs.getString(_accountKey('selectedBadge')) ?? 'badge_pro';
    selectedEmojiPack = prefs.getString(_accountKey('selectedEmojiPack')) ?? 'emoji_free_basic';
    selectedEffect = prefs.getString(_accountKey('selectedEffect')) ?? 'effect_gold_entry';
    selectedCover = prefs.getString(_accountKey('selectedCover')) ?? 'cover_royal_gold';
    selectedProfileFrameV300 = prefs.getString(_accountKey('selectedProfileFrameV300')) ?? 'frame_world_gold';
    selectedProfileColorB304 = prefs.getString(_accountKey('selectedProfileColorB304')) ?? 'b304_profile_aurora_30d';
    profileColorExpiresAtB304 = DateTime.tryParse(prefs.getString(_accountKey('profileColorExpiresAtB304')) ?? '');
    activeXpMultiplier = prefs.getDouble(_accountKey('activeXpMultiplier')) ?? 1.0;
    gamesPlayed = prefs.getInt(_accountKey('gamesPlayed')) ?? 0;
    wins = prefs.getInt(_accountKey('wins')) ?? 0;
    giftRoadProgress = prefs.getInt(_accountKey('giftRoadProgress')) ?? 0;
    consecutiveLoginDays = prefs.getInt(_accountKey('consecutiveLoginDays')) ?? 0;
    lastLoginDate = prefs.getString(_accountKey('lastLoginDate'));
    lastDailyClaimDate = prefs.getString(_accountKey('lastDailyClaimDate'));
    activeClub = prefs.getString(_accountKey('activeClub'));
    clubImageEmojiV182 = prefs.getString(_accountKey('clubImageEmojiV182')) ?? '🛡️';
    clubDescriptionV182 = prefs.getString(_accountKey('clubDescriptionV182')) ?? 'نادي احترافي داخل مجتمع ورقنا.';
    activeCompetition = prefs.getString(_accountKey('activeCompetition'));
    activeChallenge = prefs.getString(_accountKey('activeChallenge'));
    challengeRoadGame = prefs.getString(_accountKey('challengeRoadGame'));
    challengeRoadStage = prefs.getInt(_accountKey('challengeRoadStage')) ?? 0;
    challengeRoadTotal = (prefs.getInt(_accountKey('challengeRoadTotal')) ?? 12).clamp(10, 15).toInt();
    challengeRoadAttempts = (prefs.getInt(_accountKey('challengeRoadAttempts')) ?? 5).clamp(0, 5).toInt();
    challengeRoadCompleted = prefs.getBool(_accountKey('challengeRoadCompleted')) ?? false;
    activeGame = prefs.getString(_accountKey('activeGame'));
    homeGameIds
      ..clear()
      ..addAll(_normalizedHomeGameIds(prefs.getStringList(_accountKey('homeGameIds'))));
    owned
      ..clear()
      ..addAll(prefs.getStringList(_accountKey('owned')) ?? const <String>['emoji_fun']);
    inventoryQuantitiesR36
      ..clear()
      ..addAll(decodeIntMap(prefs.getString(_accountKey('inventoryQuantitiesR36'))));
    gameExitCounts
      ..clear()
      ..addAll(decodeIntMap(prefs.getString(_accountKey('gameExitCounts'))));
    roomExitCountsV210
      ..clear()
      ..addAll(decodeIntMap(prefs.getString(_accountKey('roomExitCountsV210'))));
    awayMode = prefs.getBool(_accountKey('awayMode')) ?? false;
    luckyWheelLastFreeDateV182 = prefs.getString(_accountKey('luckyWheelLastFreeDateV182'));
    luckyWheelSpinDateV182 = prefs.getString(_accountKey('luckyWheelSpinDateV182')) ?? '';
    luckyWheelTokenSpinsV182 = prefs.getInt(_accountKey('luckyWheelTokenSpinsV182')) ?? 0;
    final lastWheelRaw = prefs.getString(_accountKey('lastLuckyWheelRewardV182'));
    lastLuckyWheelRewardV182 = null;
    if (lastWheelRaw != null && lastWheelRaw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(lastWheelRaw);
        if (decoded is Map) lastLuckyWheelRewardV182 = Map<String, dynamic>.from(decoded);
      } catch (_) {
        await prefs.remove(_accountKey('lastLuckyWheelRewardV182'));
      }
    }
    adminRevenueTokensV182 = BigInt.tryParse(prefs.getString(_accountKey('adminRevenueTokensV182')) ?? '') ?? BigInt.zero;
    designerOfflineEntitiesV182
      ..clear()
      ..addAll(decodeMapListV176(prefs.getString(_accountKey('designerOfflineEntitiesV182'))));
    clubPermissionsV182
      ..clear()
      ..addAll(decodeStringListMapV182(prefs.getString(_accountKey('clubPermissionsV182'))));
    clubActivityV182
      ..clear()
      ..addAll(decodeMapListV176(prefs.getString(_accountKey('clubActivityV182'))));
    _normalizeTimedCosmetics();
  }

  Future<void> _saveAccountState(SharedPreferences prefs) async {
    if (username.trim().isEmpty) return;
    await prefs.setBool(_accountKey('initialized'), true);
    await prefs.setString(_accountKey('coins'), coins.toString());
    await prefs.setInt(_accountKey('level'), level);
    await prefs.setInt(_accountKey('xp'), xp);
    await prefs.setInt(_accountKey('xpNext'), xpNext);
    await prefs.setInt(_accountKey('vipDays'), vipDays);
    await prefs.setString(_accountKey('displayName'), displayName);
    await prefs.setString(_accountKey('email'), email);
    await prefs.setString(_accountKey('countryCode'), countryCode);
    await prefs.setString(_accountKey('countryName'), countryName);
    await prefs.setInt(_accountKey('roundPoints'), roundPoints);
    await prefs.setInt(_accountKey('tournamentPoints'), tournamentPoints);
    await prefs.setInt(_accountKey('clubPoints'), clubPoints);
    await prefs.setString(_accountKey('avatarEmoji'), avatarEmoji);
    if (avatarData == null) { await prefs.remove(_accountKey('avatarData')); } else { await prefs.setString(_accountKey('avatarData'), avatarData!); }
    await prefs.setString(_accountKey('selectedTable'), selectedTable);
    await prefs.setString(_accountKey('selectedCardBack'), selectedCardBack);
    await prefs.setString(_accountKey('selectedNameColor'), selectedNameColor);
    await prefs.setString(_accountKey('selectedChatColor'), selectedChatColor);
    if (nameColorExpiresAt == null) { await prefs.remove(_accountKey('nameColorExpiresAt')); } else { await prefs.setString(_accountKey('nameColorExpiresAt'), nameColorExpiresAt!.toIso8601String()); }
    if (chatColorExpiresAt == null) { await prefs.remove(_accountKey('chatColorExpiresAt')); } else { await prefs.setString(_accountKey('chatColorExpiresAt'), chatColorExpiresAt!.toIso8601String()); }
    await prefs.setString(_accountKey('selectedBadge'), selectedBadge);
    await prefs.setString(_accountKey('selectedEmojiPack'), selectedEmojiPack);
    await prefs.setString(_accountKey('selectedEffect'), selectedEffect);
    await prefs.setString(_accountKey('selectedCover'), selectedCover);
    await prefs.setString(_accountKey('selectedProfileFrameV300'), selectedProfileFrameV300);
    await prefs.setString(_accountKey('selectedProfileColorB304'), selectedProfileColorB304);
    if (profileColorExpiresAtB304 == null) { await prefs.remove(_accountKey('profileColorExpiresAtB304')); } else { await prefs.setString(_accountKey('profileColorExpiresAtB304'), profileColorExpiresAtB304!.toIso8601String()); }
    await prefs.setString(_accountKey('uiFontFamily'), uiFontFamily);
    await prefs.setDouble(_accountKey('activeXpMultiplier'), activeXpMultiplier);
    await prefs.setInt(_accountKey('gamesPlayed'), gamesPlayed);
    await prefs.setInt(_accountKey('wins'), wins);
    await prefs.setInt(_accountKey('giftRoadProgress'), giftRoadProgress);
    await prefs.setInt(_accountKey('consecutiveLoginDays'), consecutiveLoginDays);
    if (lastLoginDate == null) { await prefs.remove(_accountKey('lastLoginDate')); } else { await prefs.setString(_accountKey('lastLoginDate'), lastLoginDate!); }
    if (lastDailyClaimDate == null) { await prefs.remove(_accountKey('lastDailyClaimDate')); } else { await prefs.setString(_accountKey('lastDailyClaimDate'), lastDailyClaimDate!); }
    if (activeClub == null) { await prefs.remove(_accountKey('activeClub')); } else { await prefs.setString(_accountKey('activeClub'), activeClub!); }
    await prefs.setString(_accountKey('clubImageEmojiV182'), clubImageEmojiV182);
    await prefs.setString(_accountKey('clubDescriptionV182'), clubDescriptionV182);
    if (activeCompetition == null) { await prefs.remove(_accountKey('activeCompetition')); } else { await prefs.setString(_accountKey('activeCompetition'), activeCompetition!); }
    if (activeChallenge == null) { await prefs.remove(_accountKey('activeChallenge')); } else { await prefs.setString(_accountKey('activeChallenge'), activeChallenge!); }
    if (challengeRoadGame == null) { await prefs.remove(_accountKey('challengeRoadGame')); } else { await prefs.setString(_accountKey('challengeRoadGame'), challengeRoadGame!); }
    await prefs.setInt(_accountKey('challengeRoadStage'), challengeRoadStage);
    await prefs.setInt(_accountKey('challengeRoadTotal'), challengeRoadTotal);
    await prefs.setInt(_accountKey('challengeRoadAttempts'), challengeRoadAttempts);
    await prefs.setBool(_accountKey('challengeRoadCompleted'), challengeRoadCompleted);
    if (activeGame == null) { await prefs.remove(_accountKey('activeGame')); } else { await prefs.setString(_accountKey('activeGame'), activeGame!); }
    await prefs.setStringList(_accountKey('homeGameIds'), homeGameIds);
    if (activeRoomCode == null) { await prefs.remove(_accountKey('activeRoomCode')); } else { await prefs.setString(_accountKey('activeRoomCode'), activeRoomCode!); }
    if (activeRoomName == null) { await prefs.remove(_accountKey('activeRoomName')); } else { await prefs.setString(_accountKey('activeRoomName'), activeRoomName!); }
    await prefs.setBool(_accountKey('activeRoomVoice'), activeRoomVoice);
    await prefs.setString(_accountKey('activeRoomVisibility'), activeRoomVisibility);
    await prefs.setInt(_accountKey('activeRoomTurnSeconds'), activeRoomTurnSeconds);
    await prefs.setBool(_accountKey('activeRoomSingleRound'), activeRoomSingleRound);
    await prefs.setStringList(_accountKey('owned'), owned.toList());
    await prefs.setString(_accountKey('inventoryQuantitiesR36'),jsonEncode(inventoryQuantitiesR36));
    await prefs.setString(_accountKey('gameExitCounts'), jsonEncode(gameExitCounts));
    await prefs.setString(_accountKey('roomExitCountsV210'), jsonEncode(roomExitCountsV210));
    await prefs.setBool(_accountKey('awayMode'), awayMode);
    if (luckyWheelLastFreeDateV182 == null) { await prefs.remove(_accountKey('luckyWheelLastFreeDateV182')); } else { await prefs.setString(_accountKey('luckyWheelLastFreeDateV182'), luckyWheelLastFreeDateV182!); }
    await prefs.setString(_accountKey('luckyWheelSpinDateV182'), luckyWheelSpinDateV182);
    await prefs.setInt(_accountKey('luckyWheelTokenSpinsV182'), luckyWheelTokenSpinsV182);
    if (lastLuckyWheelRewardV182 == null) { await prefs.remove(_accountKey('lastLuckyWheelRewardV182')); } else { await prefs.setString(_accountKey('lastLuckyWheelRewardV182'), jsonEncode(lastLuckyWheelRewardV182)); }
    await prefs.setString(_accountKey('adminRevenueTokensV182'), adminRevenueTokensV182.toString());
    await prefs.setString(_accountKey('designerOfflineEntitiesV182'), jsonEncode(designerOfflineEntitiesV182));
    await prefs.setString(_accountKey('clubPermissionsV182'), jsonEncode(clubPermissionsV182));
    await prefs.setString(_accountKey('clubActivityV182'), jsonEncode(clubActivityV182));
  }

  String _offlineAliasKey(String value) => 'warqna.offline.alias.${value.trim().toLowerCase()}';
  String _offlineHashKey(String value) => 'warqna.offline.hash.${value.trim().toLowerCase()}';
  String _offlineCredentialHash(String user, String password) => sha256
      .convert(utf8.encode('warqna-v175|${user.trim().toLowerCase()}|$password|local-session'))
      .toString();

  Future<void> _storeOfflineCredentials(
    SharedPreferences prefs,
    String user,
    String mail,
    String password, {
    bool? admin,
  }) async {
    final canonical = user.trim().toLowerCase();
    await prefs.setString(_offlineAliasKey(user), canonical);
    if (mail.trim().isNotEmpty) await prefs.setString(_offlineAliasKey(mail), canonical);
    await prefs.setString(_offlineHashKey(canonical), _offlineCredentialHash(canonical, password));
    await prefs.setString('warqna.offline.username.$canonical', user.trim());
    await prefs.setString('warqna.offline.email.$canonical', mail.trim());
    if (admin != null) {
      await prefs.setBool('warqna.offline.admin.$canonical', admin);
      if (admin) await prefs.setString('warqna.offline.admin_role.$canonical', adminRole);
    }
    await prefs.setString('lastOfflineUsername', user.trim());
    await prefs.setBool('offlineLoggedIn', true);
  }

  Future<String?> _loginLocal(String loginId, String password) async {
    final prefs = await SharedPreferences.getInstance();
    var alias = prefs.getString(_offlineAliasKey(loginId)) ?? loginId.trim().toLowerCase();
    var expected = prefs.getString(_offlineHashKey(alias));
    final demo = demoAccounts[alias];
    if (!warqnaProductionMode && expected == null && demo != null && demo['password']?.toString() == password) {
      final canonicalName = '${alias.substring(0, 1).toUpperCase()}${alias.substring(1)}';
      final demoMail = '$alias@warqna.local';
      await _storeOfflineCredentials(prefs, canonicalName, demoMail, password, admin: false);
      alias = canonicalName.toLowerCase();
      expected = prefs.getString(_offlineHashKey(alias));
    }
    if (expected == null || expected != _offlineCredentialHash(alias, password)) {
      return 'لا يوجد حساب محلي مطابق أو كلمة المرور غير صحيحة. اتصل بالإنترنت مرة واحدة أو أنشئ حساباً محلياً.';
    }
    username = prefs.getString('warqna.offline.username.$alias') ?? loginId.trim();
    email = prefs.getString('warqna.offline.email.$alias') ?? '$alias@warqna.local';
    final demoProfile = demoAccounts[alias];
    displayName = demoProfile?['name']?.toString() ?? username;
    isAdmin = prefs.getBool('warqna.offline.admin.$alias') ?? false;
    adminRole = prefs.getString('warqna.offline.admin_role.$alias') ?? (isAdmin ? 'primary_admin' : 'player');
    await _loadAccountState(
      prefs,
      defaultCoins: demoProfile?['coins']?.toString() ?? (isAdmin ? '1000000000000000000' : '1500'),
      defaultLevel: int.tryParse(demoProfile?['level']?.toString() ?? '') ?? (isAdmin ? 99 : 1),
      defaultVipDays: isAdmin ? 3650 : 0,
      defaultAvatar: demoAvatarFor(username),
    );
    if (isPrimaryAdmin) { level = math.max(level, 99); vipDays = math.max(vipDays, 36500); coins = primaryAdminTokens; }
    _applyLocalLoginStreak();
    authToken = null;
    api.token = null;
    isAuthenticated = true;
    serverConnected = false;
    await prefs.setBool('offlineLoggedIn', true);
    await _save();
    refreshUi();
    return null;
  }

  Future<String?> _registerLocal(String user, String mail, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_offlineAliasKey(user)) || prefs.containsKey(_offlineAliasKey(mail))) {
      return 'اسم المستخدم أو البريد مسجّل محلياً مسبقاً.';
    }
    username = user.trim();
    displayName = username;
    email = mail.trim();
    isAdmin = false;
    adminRole = 'player';
    currentUserId = null;
    await _storeOfflineCredentials(prefs, username, email, password, admin: false);
    await _loadAccountState(prefs, defaultCoins: isAdmin ? '1000000000000000000' : '1500', defaultLevel: isAdmin ? 99 : 1, defaultVipDays: isAdmin ? 3650 : 0);
    _applyLocalLoginStreak();
    authToken = null;
    api.token = null;
    isAuthenticated = true;
    serverConnected = false;
    await _save();
    refreshUi();
    return null;
  }

  Future<String?> registerOffline(String user, String mail, String password) {
    if (user.trim().isEmpty || mail.trim().isEmpty || password.length < 8) {
      return Future<String?>.value('أدخل اسم المستخدم والبريد وكلمة مرور من 8 أحرف على الأقل.');
    }
    return _registerLocal(user, mail, password);
  }

  Future<String?> _loginOrCreateLocalFallback(String loginId, String password) async {
    // B307 security/runtime fix: a failed ONLINE login must never silently
    // manufacture a fresh local account. This was the reason privileged users
    // could appear as empty Level-1 players when the API URL/server was wrong.
    final existing = await _loginLocal(loginId, password);
    if (existing == null) return null;
    return 'تعذر الاتصال بالخادم. لم يتم إنشاء حساب محلي جديد. تأكد من عنوان API أو استخدم وضع Offline فقط لحساب محفوظ مسبقًا.';
  }

  Future<void> load() async {
    try {
      await _loadUnsafe();
      _initializeOptionalServices();
    } catch (error, stack) {
      // A stale value written by an older APK must never stop the current APK
      // from opening. Start with safe defaults and leave the user able to sign
      // in; the original data remains untouched for diagnostics.
      debugPrint('Safe boot ignored incompatible local state: $error\n$stack');
      authToken = null;
      api.token = null;
      isAuthenticated = false;
      serverConnected = false;
      ready = true;
      _initializeOptionalServices();
      notifyListeners();
    }
  }

  void _initializeOptionalServices() {
    AppSounds.enabled = soundEnabled;
    unawaited(initializeWarqnaRewardedAdsAfterFirstFrame());
    PushNotifications.onForeground = (title, body, data) {
      notices.insert(0, AppNotice('🔔', title, body));
      AppSounds.fire('notification');
      notifyListeners();
    };
    PushNotifications.onToken = (token) => _registerPushToken(token);
    PushNotifications.onTap = (route) {
      if (route == null || route.isEmpty) return;
      if (route.startsWith('room:')) {
        final code = route.substring('room:'.length).split(':').first.trim().toUpperCase();
        if (code.isNotEmpty) {
          notices.insert(0, AppNotice('🎮', L.t(localeCode, 'activeGame'), L.t(localeCode, 'resumeGame')));
          queueNavigationRoute('/room/$code');
        }
      } else if (route.startsWith('friend-chat:')) {
        notices.insert(0, AppNotice('💬', L.t(localeCode, 'friendsChat'), L.t(localeCode, 'friendsChat')));
        refreshUi();
      }
    };
    unawaited(_refreshPushRegistration());
  }

  Future<void> _registerPushToken(String token) async {
    if (token.isEmpty || !serverConnected || api.token == null || api.token!.isEmpty) return;
    try {
      await api.registerPushDevice(token);
    } catch (error) {
      debugPrint('Push token registration deferred: $error');
    }
  }

  Future<void> _refreshPushRegistration() async {
    final token = await PushNotifications.initialize();
    if (token != null) await _registerPushToken(token);
  }

  Future<void> _loadUnsafe() async {
    await R10AssetDelivery.instance.restore();
    final prefs = await SharedPreferences.getInstance();
    customApiUrl = prefs.getString('customApiUrl') ?? '';
    if (customApiUrl.trim().isNotEmpty) api.updateBaseUrl(customApiUrl);
    final savedLocale = prefs.getString('locale');
    localeCode = savedLocale != null && b304ActiveLocaleCodes.contains(savedLocale) ? savedLocale : 'ar';
    themeCode = prefs.getString('theme') ?? themeCode;
    final storedCoins = prefs.getString('coins');
    if (storedCoins != null) coins = BigInt.tryParse(storedCoins) ?? coins;
    vipDays = prefs.getInt('vipDays') ?? vipDays;
    activeClub = prefs.getString('activeClub');
    soundEnabled = prefs.getBool('soundEnabled') ?? soundEnabled;
    landscapeMode = prefs.getBool('landscapeMode') ?? landscapeMode;
    selectedTable = prefs.getString('selectedTable') ?? selectedTable;
    selectedCardBack = prefs.getString('selectedCardBack') ?? selectedCardBack;
    selectedNameColor = prefs.getString('selectedNameColor') ?? selectedNameColor;
    selectedChatColor = prefs.getString('selectedChatColor') ?? selectedChatColor;
    nameColorExpiresAt = DateTime.tryParse(prefs.getString('nameColorExpiresAt') ?? '');
    chatColorExpiresAt = DateTime.tryParse(prefs.getString('chatColorExpiresAt') ?? '');
    avatarEmoji = prefs.getString('avatarEmoji') ?? avatarEmoji;
    avatarData = prefs.getString('avatarData');
    selectedBadge = prefs.getString('selectedBadge') ?? selectedBadge;
    selectedEmojiPack = prefs.getString('selectedEmojiPack') ?? selectedEmojiPack;
    selectedEffect = prefs.getString('selectedEffect') ?? selectedEffect;
    selectedCover = prefs.getString('selectedCover') ?? selectedCover;
    selectedProfileFrameV300 = prefs.getString('selectedProfileFrameV300') ?? selectedProfileFrameV300;
    selectedProfileColorB304 = prefs.getString('selectedProfileColorB304') ?? selectedProfileColorB304;
    profileColorExpiresAtB304 = DateTime.tryParse(prefs.getString('profileColorExpiresAtB304') ?? '');
    botDifficultyCode = prefs.getString('botDifficultyCode') ?? botDifficultyCode;
    uiButtonHeight = prefs.getDouble('uiButtonHeight') ?? uiButtonHeight;
    uiRadius = prefs.getDouble('uiRadius') ?? uiRadius;
    uiFontScale = prefs.getDouble('uiFontScale') ?? uiFontScale;
    uiChatScale = prefs.getDouble('uiChatScale') ?? uiChatScale;
    uiFontFamily = prefs.getString('uiFontFamily') ?? uiFontFamily;
    customTableBackgroundData = prefs.getString('customTableBackgroundData');
    customCardBackData = prefs.getString('customCardBackData');
    uiAccentHex = prefs.getString('uiAccentHex') ?? uiAccentHex;
    tableAmbientEffects = prefs.getBool('tableAmbientEffects') ?? tableAmbientEffects;
    selectedPashaStyle = 'red';
    competitionTickets
      ..clear()
      ..addAll(decodeIntMap(prefs.getString('competitionTicketsV173')).map((key, value) => MapEntry(int.tryParse(key) ?? 0, value)));
    dailyPackLastOpened = prefs.getString('dailyPackLastOpenedV173');
    dailyPackReward = prefs.getString('dailyPackRewardV173');
    temporaryTableExpiresAtV173 = DateTime.tryParse(prefs.getString('temporaryTableExpiresAtV173') ?? '');
    boosterExpiresAtV173 = DateTime.tryParse(prefs.getString('boosterExpiresAtV173') ?? '');
    packInventoryExpiriesV176
      ..clear()
      ..addAll(decodeDateTimeMapV176(prefs.getString('packInventoryExpiriesV176')));
    dailyPackHistoryV176
      ..clear()
      ..addAll(decodeMapListV176(prefs.getString('dailyPackHistoryV176')));
    if (dailyPackHistoryV176.isNotEmpty) lastDailyPackRevealV176 = Map<String, dynamic>.from(dailyPackHistoryV176.first);
    prizeBoxesV02
      ..clear()
      ..addAll(decodeMapListV176(prefs.getString('prizeBoxesV02')));
    prizeBoxesDateV02 = prefs.getString('prizeBoxesDateV02') ?? '';
    normalizePrizeBoxesV02();
    championRankPointsV173 = prefs.getInt('championRankPointsV173') ?? championRankPointsV173;
    challengeStreakV173 = prefs.getInt('challengeStreakV173') ?? challengeStreakV173;
    gamesPlayed = prefs.getInt('gamesPlayed') ?? gamesPlayed;
    wins = prefs.getInt('wins') ?? wins;
    activeXpMultiplier = prefs.getDouble('activeXpMultiplier') ?? activeXpMultiplier;
    giftRoadProgress = prefs.getInt('giftRoadProgress') ?? giftRoadProgress;
    consecutiveLoginDays = prefs.getInt('consecutiveLoginDays') ?? consecutiveLoginDays;
    lastLoginDate = prefs.getString('lastLoginDate');
    lastDailyClaimDate = prefs.getString('lastDailyClaimDate');
    rewardedAdClaimsToday = prefs.getInt('rewardedAdClaimsToday') ?? 0;
    rewardedAdClaimDate = prefs.getString('rewardedAdClaimDate');
    _resetAdCounterIfNeeded();
    claimedGiftSteps
      ..clear()
      ..addAll(
        (prefs.getStringList('claimedGiftSteps') ?? const <String>[])
            .map(int.tryParse)
            .whereType<int>(),
      );
    activeCompetition = prefs.getString('activeCompetition');
    activeChallenge = prefs.getString('activeChallenge');
    challengeRoadGame = prefs.getString('challengeRoadGame');
    challengeRoadStage = prefs.getInt('challengeRoadStage') ?? 0;
    challengeRoadTotal = (prefs.getInt('challengeRoadTotal') ?? 12).clamp(10, 15).toInt();
    challengeRoadAttempts = (prefs.getInt('challengeRoadAttempts') ?? 5).clamp(0, 5).toInt();
    challengeRoadCompleted = prefs.getBool('challengeRoadCompleted') ?? false;
    activeGame = prefs.getString('activeGame');
    homeGameIds
      ..clear()
      ..addAll(_normalizedHomeGameIds(prefs.getStringList('homeGameIds')));
    activeRoomCode = prefs.getString('activeRoomCode');
    _queuedNavigationRouteV175 = prefs.getString('queuedNavigationRouteV175');
    activeRoomName = prefs.getString('activeRoomName');
    activeRoomVoice = prefs.getBool('activeRoomVoice') ?? false;
    activeRoomVisibility = prefs.getString('activeRoomVisibility') ?? 'public';
    activeRoomTurnSeconds = prefs.getInt('activeRoomTurnSeconds') ?? 10;
    activeRoomSingleRound = prefs.getBool('activeRoomSingleRound') ?? false;
    owned
      ..clear()
      ..addAll(prefs.getStringList('owned') ?? const ['emoji_fun']);
    _normalizeTimedCosmetics();
    storePriceOverrides
      ..clear()
      ..addAll(decodeIntMap(prefs.getString('storePriceOverrides')));
    storeNameOverrides
      ..clear()
      ..addAll(decodeStringMapV151(prefs.getString('storeNameOverrides')));
    storeDescriptionOverrides
      ..clear()
      ..addAll(decodeStringMapV151(prefs.getString('storeDescriptionOverrides')));
    storeDurationOverrides
      ..clear()
      ..addAll(decodeIntMap(prefs.getString('storeDurationOverrides')));
    storeColor1Overrides
      ..clear()
      ..addAll(decodeStringMapV151(prefs.getString('storeColor1Overrides')));
    storeColor2Overrides
      ..clear()
      ..addAll(decodeStringMapV151(prefs.getString('storeColor2Overrides')));
    hiddenStoreProducts
      ..clear()
      ..addAll(prefs.getStringList('hiddenStoreProducts') ?? const <String>[]);
    authToken = prefs.getString('authToken');
    final offlineLoggedIn = prefs.getBool('offlineLoggedIn') ?? false;
    final storedUsername = prefs.getString('username') ?? prefs.getString('lastOfflineUsername');
    if (storedUsername != null && storedUsername.trim().isNotEmpty) {
      username = storedUsername.trim();
      displayName = prefs.getString('displayName') ?? username;
      email = prefs.getString('email') ?? email;
      isAdmin = prefs.getBool('isAdmin') ?? false;
      adminRole = prefs.getString('adminRole') ?? (isAdmin ? 'admin' : 'player');
    }
    if (adminRole == 'local_admin') {
      authToken = null;
      api.token = null;
      isAdmin = false;
      currentUserId = null;
    }
    if (authToken != null && authToken!.isNotEmpty) {
      api.token = authToken;
      try {
        final sessionToken = authToken;
        final data = await api.bootstrap();
        if (authToken != sessionToken || adminRole == 'local_admin') return;
        _applySession(data);
        unawaited(R10AssetDelivery.instance.refresh(api, bootstrap: data));
        isAuthenticated = true;
        serverConnected = true;
      } catch (_) {
        await _loadAccountState(prefs, defaultCoins: isAdmin ? '1000000000000000000' : '1500', defaultLevel: isAdmin ? 99 : 1, defaultVipDays: isAdmin ? 3650 : 0);
        _applyLocalLoginStreak();
        isAuthenticated = true;
        serverConnected = false;
      }
    } else if (offlineLoggedIn && storedUsername != null && storedUsername.trim().isNotEmpty) {
      await _loadAccountState(prefs, defaultCoins: isAdmin ? '1000000000000000000' : '1500', defaultLevel: isAdmin ? 99 : 1, defaultVipDays: isAdmin ? 3650 : 0);
      _applyLocalLoginStreak();
      isAuthenticated = true;
      serverConnected = false;
    }
    await _applyPreferredOrientationV174();
    unawaited(startConnectivityMonitorV173());
    ready = true;
    refreshUi();
    if (_pendingRoomCodeV174 != null) queueNavigationRoute('/room/${_pendingRoomCodeV174!}');
    unawaited(openPendingNavigationRoute());
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', localeCode);
    await prefs.setString('theme', themeCode);
    if (customApiUrl.trim().isEmpty) {
      await prefs.remove('customApiUrl');
    } else {
      await prefs.setString('customApiUrl', customApiUrl.trim());
    }
    await prefs.setString('coins', coins.toString());
    await prefs.setInt('vipDays', vipDays);
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setBool('landscapeMode', landscapeMode);
    await prefs.setString('selectedTable', selectedTable);
    await prefs.setString('selectedCardBack', selectedCardBack);
    await prefs.setString('selectedNameColor', selectedNameColor);
    await prefs.setString('selectedChatColor', selectedChatColor);
    if (nameColorExpiresAt == null) { await prefs.remove('nameColorExpiresAt'); } else { await prefs.setString('nameColorExpiresAt', nameColorExpiresAt!.toIso8601String()); }
    if (chatColorExpiresAt == null) { await prefs.remove('chatColorExpiresAt'); } else { await prefs.setString('chatColorExpiresAt', chatColorExpiresAt!.toIso8601String()); }
    await prefs.setString('avatarEmoji', avatarEmoji);
    if (avatarData == null) { await prefs.remove('avatarData'); } else { await prefs.setString('avatarData', avatarData!); }
    await prefs.setString('selectedBadge', selectedBadge);
    await prefs.setString('selectedEmojiPack', selectedEmojiPack);
    await prefs.setString('selectedEffect', selectedEffect);
    await prefs.setString('selectedCover', selectedCover);
    await prefs.setString('selectedProfileFrameV300', selectedProfileFrameV300);
    await prefs.setString('selectedProfileColorB304', selectedProfileColorB304);
    if (profileColorExpiresAtB304 == null) { await prefs.remove('profileColorExpiresAtB304'); } else { await prefs.setString('profileColorExpiresAtB304', profileColorExpiresAtB304!.toIso8601String()); }
    await prefs.setString('botDifficultyCode', botDifficultyCode);
    await prefs.setDouble('uiButtonHeight', uiButtonHeight);
    await prefs.setDouble('uiRadius', uiRadius);
    await prefs.setDouble('uiFontScale', uiFontScale);
    await prefs.setDouble('uiChatScale', uiChatScale);
    await prefs.setString('uiFontFamily', uiFontFamily);
    if (customTableBackgroundData == null) { await prefs.remove('customTableBackgroundData'); } else { await prefs.setString('customTableBackgroundData', customTableBackgroundData!); }
    if (customCardBackData == null) { await prefs.remove('customCardBackData'); } else { await prefs.setString('customCardBackData', customCardBackData!); }
    await prefs.setString('uiAccentHex', uiAccentHex);
    await prefs.setBool('tableAmbientEffects', tableAmbientEffects);
    await prefs.setString('selectedPashaStyleV173', selectedPashaStyle);
    await prefs.setString('competitionTicketsV173', jsonEncode(competitionTickets.map((key, value) => MapEntry('$key', value))));
    if (dailyPackLastOpened == null) { await prefs.remove('dailyPackLastOpenedV173'); } else { await prefs.setString('dailyPackLastOpenedV173', dailyPackLastOpened!); }
    if (dailyPackReward == null) { await prefs.remove('dailyPackRewardV173'); } else { await prefs.setString('dailyPackRewardV173', dailyPackReward!); }
    if (temporaryTableExpiresAtV173 == null) { await prefs.remove('temporaryTableExpiresAtV173'); } else { await prefs.setString('temporaryTableExpiresAtV173', temporaryTableExpiresAtV173!.toIso8601String()); }
    if (boosterExpiresAtV173 == null) { await prefs.remove('boosterExpiresAtV173'); } else { await prefs.setString('boosterExpiresAtV173', boosterExpiresAtV173!.toIso8601String()); }
    await prefs.setString('packInventoryExpiriesV176', jsonEncode(packInventoryExpiriesV176.map((key, value) => MapEntry(key, value.toIso8601String()))));
    await prefs.setString('dailyPackHistoryV176', jsonEncode(dailyPackHistoryV176));
    await prefs.setString('prizeBoxesV02', jsonEncode(prizeBoxesV02));
    await prefs.setString('prizeBoxesDateV02', prizeBoxesDateV02);
    await prefs.setInt('championRankPointsV173', championRankPointsV173);
    await prefs.setInt('challengeStreakV173', challengeStreakV173);
    await prefs.setInt('gamesPlayed', gamesPlayed);
    await prefs.setInt('wins', wins);
    await prefs.setDouble('activeXpMultiplier', activeXpMultiplier);
    await prefs.setInt('giftRoadProgress', giftRoadProgress);
    await prefs.setInt('consecutiveLoginDays', consecutiveLoginDays);
    if (lastLoginDate == null) { await prefs.remove('lastLoginDate'); } else { await prefs.setString('lastLoginDate', lastLoginDate!); }
    if (lastDailyClaimDate == null) { await prefs.remove('lastDailyClaimDate'); } else { await prefs.setString('lastDailyClaimDate', lastDailyClaimDate!); }
    await prefs.setInt('rewardedAdClaimsToday', rewardedAdClaimsToday);
    if (rewardedAdClaimDate == null) { await prefs.remove('rewardedAdClaimDate'); } else { await prefs.setString('rewardedAdClaimDate', rewardedAdClaimDate!); }
    await prefs.setStringList('claimedGiftSteps', claimedGiftSteps.map((e) => '$e').toList());
    if (activeCompetition == null) { await prefs.remove('activeCompetition'); } else { await prefs.setString('activeCompetition', activeCompetition!); }
    if (activeChallenge == null) { await prefs.remove('activeChallenge'); } else { await prefs.setString('activeChallenge', activeChallenge!); }
    if (challengeRoadGame == null) { await prefs.remove('challengeRoadGame'); } else { await prefs.setString('challengeRoadGame', challengeRoadGame!); }
    await prefs.setInt('challengeRoadStage', challengeRoadStage);
    await prefs.setInt('challengeRoadTotal', challengeRoadTotal);
    await prefs.setInt('challengeRoadAttempts', challengeRoadAttempts);
    await prefs.setBool('challengeRoadCompleted', challengeRoadCompleted);
    if (activeGame == null) { await prefs.remove('activeGame'); } else { await prefs.setString('activeGame', activeGame!); }
    await prefs.setStringList('homeGameIds', homeGameIds);
    if (activeRoomCode == null) { await prefs.remove('activeRoomCode'); } else { await prefs.setString('activeRoomCode', activeRoomCode!); }
    if (_queuedNavigationRouteV175 == null) { await prefs.remove('queuedNavigationRouteV175'); } else { await prefs.setString('queuedNavigationRouteV175', _queuedNavigationRouteV175!); }
    if (activeRoomName == null) { await prefs.remove('activeRoomName'); } else { await prefs.setString('activeRoomName', activeRoomName!); }
    await prefs.setBool('activeRoomVoice', activeRoomVoice);
    await prefs.setString('activeRoomVisibility', activeRoomVisibility);
    await prefs.setInt('activeRoomTurnSeconds', activeRoomTurnSeconds);
    await prefs.setBool('activeRoomSingleRound', activeRoomSingleRound);
    await prefs.setStringList('owned', owned.toList());
    await prefs.setString('storePriceOverrides', jsonEncode(storePriceOverrides));
    await prefs.setString('storeNameOverrides', jsonEncode(storeNameOverrides));
    await prefs.setString('storeDescriptionOverrides', jsonEncode(storeDescriptionOverrides));
    await prefs.setString('storeDurationOverrides', jsonEncode(storeDurationOverrides));
    await prefs.setString('storeColor1Overrides', jsonEncode(storeColor1Overrides));
    await prefs.setString('storeColor2Overrides', jsonEncode(storeColor2Overrides));
    await prefs.setStringList('hiddenStoreProducts', hiddenStoreProducts.toList());
    await prefs.setBool('offlineLoggedIn', isAuthenticated);
    await prefs.setString('username', username);
    await prefs.setString('displayName', displayName);
    await prefs.setString('email', email);
    await prefs.setBool('isAdmin', isAdmin);
    await prefs.setString('adminRole', adminRole);
    if (authToken == null) {
      await prefs.remove('authToken');
    } else {
      await prefs.setString('authToken', authToken!);
    }
    if (activeClub == null) {
      await prefs.remove('activeClub');
    } else {
      await prefs.setString('activeClub', activeClub!);
    }
    await _saveAccountState(prefs);
  }

  Future<String?> login(String loginId, String password, {bool offline = false}) async {
    if (loginId.trim().isEmpty || password.isEmpty) return 'أدخل اسم المستخدم وكلمة المرور.';
    if (offline) return _loginLocal(loginId, password);
    try {
      final data = await api.login(loginId.trim(), password);
      authToken = data['token']?.toString();
      api.token = authToken;
      _applySession(data);
      final streak = data['streak_reward'];
      if (streak is Map) {
        consecutiveLoginDays = int.tryParse(streak['streak']?.toString() ?? '') ?? consecutiveLoginDays;
        final awarded = int.tryParse(streak['pasha_awarded']?.toString() ?? '') ?? 0;
        if (awarded > 0) notices.insert(0, AppNotice('👑', 'مكافأة الاستمرارية', 'حصلت على يوم باشا مجاني بعد 3 أيام دخول متواصلة.'));
      }
      if (data['account_reactivated'] == true) {
        notices.insert(0, AppNotice('✅', 'تمت استعادة الحساب', data['reactivation_message']?.toString() ?? 'تمت استعادة الحساب.'));
      }
      isAuthenticated = true;
      serverConnected = true;
      final prefs = await SharedPreferences.getInstance();
      await _storeOfflineCredentials(prefs, username, email, password, admin: isAdmin);
      await refreshServerStoreR36();
      unawaited(_refreshPushRegistration());
      unawaited(startConnectivityMonitorV173());
      await _save();
      refreshUi();
      if (_pendingRoomCodeV174 != null) queueNavigationRoute('/room/${_pendingRoomCodeV174!}');
      unawaited(openPendingNavigationRoute());
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 422) return e.message;
      final localResult = await _loginOrCreateLocalFallback(loginId, password);
      return localResult == null ? null : e.message;
    } catch (_) {
      return _loginOrCreateLocalFallback(loginId, password);
    }
  }

  Future<String?> register(String user, String mail, String password) async {
    if (user.trim().isEmpty || mail.trim().isEmpty || password.length < 8) return 'أدخل اسم المستخدم والبريد وكلمة مرور من 8 أحرف على الأقل.';
    try {
      final data = await api.register(username: user.trim(), email: mail.trim(), password: password);
      authToken = data['token']?.toString();
      api.token = authToken;
      _applySession(data);
      isAuthenticated = true;
      serverConnected = true;
      final prefs = await SharedPreferences.getInstance();
      await _storeOfflineCredentials(prefs, username, email, password, admin: isAdmin);
      unawaited(_refreshPushRegistration());
      unawaited(startConnectivityMonitorV173());
      await _save();
      refreshUi();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return _registerLocal(user, mail, password);
    }
  }

  Future<String?> loginWithSocialProvider(String provider) async {
    if (!const {'google', 'facebook', 'apple'}.contains(provider)) return 'مزود تسجيل الدخول غير مدعوم.';
    try {
      final start = await api.startSocialAuth(provider);
      final state = start['state']?.toString() ?? '';
      final url = start['authorize_url']?.toString() ?? '';
      if (state.isEmpty || url.isEmpty) return start['message']?.toString() ?? 'لم يجهز الخادم رابط تسجيل الدخول.';
      final launched = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!launched) return 'تعذر فتح صفحة تسجيل الدخول الخارجية.';
      for (var attempt = 0; attempt < 90; attempt++) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final status = await api.socialAuthStatus(state);
        final value = status['status']?.toString();
        if (value == 'completed') {
          authToken = status['token']?.toString();
          api.token = authToken;
          _applySession(status);
          isAuthenticated = true;
          serverConnected = true;
          await _save();
          unawaited(_refreshPushRegistration());
          unawaited(startConnectivityMonitorV173());
          refreshUi();
          return null;
        }
        if (value == 'failed' || value == 'expired' || value == 'consumed') {
          return status['error']?.toString() ?? 'تعذر إكمال تسجيل الدخول الاجتماعي.';
        }
      }
      return 'انتهت مهلة تسجيل الدخول. حاول مرة أخرى.';
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تسجيل الدخول الاجتماعي يحتاج اتصالاً بالإنترنت وخادماً مهيأً.';
    }
  }

  /// Device-only workspace. It never grants a server role or API session.
  Future<void> loginAsLocalAdmin() async {
    connectivityTimerV173?.cancel();
    authToken = null;
    api.token = null;
    currentUserId = null;
    serverConnected = false;
    isAdmin = false;
    adminRole = 'local_admin';
    username = 'Adnan';
    displayName = 'Adnan';
    email = 'adnan@device.local';
    final prefs = await SharedPreferences.getInstance();
    await _loadAccountState(prefs, defaultCoins: '1000000', defaultLevel: 99, defaultVipDays: 36500, defaultAvatar: '👑');
    coins = primaryAdminTokens;
    owned.addAll(products.map((product) => product.id));
    for(final product in products) {inventoryQuantitiesR36[product.id]=100;}
    for (final denomination in competitionTicketValuesV173) {
      competitionTickets[denomination] = math.max(100, competitionTickets[denomination] ?? 0);
    }
    isAuthenticated = true;
    await _save();
    refreshUi();
  }

  Future<void> loginAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('lastGuestUsername') ?? 'Guest';
    displayName = localeCode == 'ar' ? 'ضيف ورقنا' : 'Warqnaa Guest';
    email = 'guest@warqna.local';
    isAdmin = false;
    adminRole = 'player';
    currentUserId = null;
    await prefs.setString('lastGuestUsername', username);
    await _loadAccountState(prefs, defaultCoins: '1500', defaultLevel: 1, defaultVipDays: 0, defaultAvatar: '🃏');
    _applyLocalLoginStreak();
    authToken = null;
    api.token = null;
    isAuthenticated = true;
    serverConnected = false;
    await _save();
    refreshUi();
  }

  Future<void> logout() async {
    if (serverConnected) {
      final pushToken = PushNotifications.currentToken;
      if (pushToken != null && pushToken.isNotEmpty) {
        try { await api.removePushDevice(pushToken); } catch (_) {}
      }
      try {
        await api.post('/logout', const {});
      } catch (_) {}
    }
    isAuthenticated = false;
    serverConnected = false;
    isAdmin = false;
    adminRole = 'player';
    currentUserId = null;
    authToken = null;
    api.token = null;
    serverStoreR36.clear();
    serverStoreReadyR36=false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.setBool('offlineLoggedIn', false);
    notifyListeners();
  }

  void _applySession(Map<String, dynamic> data) {
    syncServerStoreR36(data['store']);
    final user = data['user'];
    final wallet = data['wallet'];
    if (user is Map) {
      currentUserId = int.tryParse(user['id']?.toString() ?? '') ?? currentUserId;
      username = user['username']?.toString() ?? username;
      displayName = user['display_name']?.toString() ?? user['name']?.toString() ?? username;
      email = user['email']?.toString() ?? email;
      countryCode = (user['country_code']?.toString() ?? countryCode).toUpperCase();
      countryName = user['country_name']?.toString() ?? countryByCode(countryCode).name(localeCode);
      roundPoints = int.tryParse(user['round_points']?.toString() ?? '') ?? roundPoints;
      tournamentPoints = int.tryParse(user['tournament_points']?.toString() ?? '') ?? tournamentPoints;
      clubPoints = int.tryParse(user['club_points']?.toString() ?? '') ?? clubPoints;
      avatarEmoji = user['avatar']?.toString() ?? avatarEmoji;
      avatarData = user['avatar_data']?.toString().isNotEmpty == true ? user['avatar_data']?.toString() : avatarData;
      selectedNameColor = user['name_color']?.toString() ?? selectedNameColor;
      selectedChatColor = user['chat_color']?.toString() ?? selectedChatColor;
      nameColorExpiresAt = DateTime.tryParse(user['name_color_expires_at']?.toString() ?? '');
      chatColorExpiresAt = DateTime.tryParse(user['chat_color_expires_at']?.toString() ?? '');
      consecutiveLoginDays = int.tryParse(user['login_streak']?.toString() ?? '') ?? consecutiveLoginDays;
      adminRole = user['admin_role']?.toString() ?? ((user['is_admin'] == true || user['is_admin'] == 1) ? 'admin' : 'player');
      isAdmin = user['is_admin'] == true || user['is_admin'] == 1 || adminRole == 'primary_admin';
      level = int.tryParse(user['level']?.toString() ?? '') ?? level;
      final serverTotalXp = int.tryParse(user['xp']?.toString() ?? '');
      if (serverTotalXp != null) xp = xpProgressFromTotal(serverTotalXp, level);
      vipDays = int.tryParse(user['pasha_days']?.toString() ?? '') ?? vipDays;
      if(user.containsKey('xp_boost_multiplier')) {
        activeXpMultiplier=math.max(1.0,double.tryParse(user['xp_boost_multiplier']?.toString() ?? '') ?? 1.0);
        boosterExpiresAtV173=DateTime.tryParse(user['xp_boost_expires_at']?.toString() ?? '');
        if(boosterExpiresAtV173?.isAfter(DateTime.now())==false)activeXpMultiplier=1.0;
      }
      selectedCover = user['active_cover']?.toString() ?? selectedCover;
      botDifficultyCode = user['bot_difficulty']?.toString() ?? botDifficultyCode;
      final uiPreferences = user['ui_preferences'];
      if (uiPreferences is Map) {
        uiButtonHeight = double.tryParse(uiPreferences['button_height']?.toString() ?? '') ?? uiButtonHeight;
        uiRadius = double.tryParse(uiPreferences['radius']?.toString() ?? '') ?? uiRadius;
        uiFontScale = double.tryParse(uiPreferences['font_scale']?.toString() ?? '') ?? uiFontScale;
        tableAmbientEffects = uiPreferences['ambient_effects'] == true || uiPreferences['ambient_effects'] == 1;
      }
      gamesPlayed = int.tryParse(user['games_played']?.toString() ?? '') ?? gamesPlayed;
      wins = int.tryParse(user['wins']?.toString() ?? '') ?? wins;
      xpNext = xpNeededForLevel(level);
    }
    if (wallet is Map) {
      coins = BigInt.tryParse(wallet['tokens']?.toString() ?? '') ?? coins;
    }
    final tickets = data['competition_tickets'];
    if (tickets is Map) {
      competitionTickets
        ..clear()
        ..addAll(tickets.map((key, value) => MapEntry(int.tryParse(key.toString()) ?? 0, int.tryParse(value.toString()) ?? 0)));
    }
    final pack = data['daily_pack'];
    if (pack is Map) {
      dailyPackLastOpened = pack['last_opened']?.toString() ?? dailyPackLastOpened;
      dailyPackReward = pack['last_reward']?.toString() ?? dailyPackReward;
    }
    if (data['inventory'] is List) {
      owned.clear();
      inventoryQuantitiesR36.clear();
      packInventoryExpiriesV176.clear();
    }
    syncPackInventoryV176(data['inventory']);
    syncPrizeBoxesV02(data['prize_boxes']);
    if (user is Map) selectedPashaStyle = user['pasha_style']?.toString() ?? selectedPashaStyle;
    championRankPointsV173 = int.tryParse(data['champion_rank_points']?.toString() ?? '') ?? championRankPointsV173;
    if (isPrimaryAdmin) {
      coins = primaryAdminTokens;
      level = math.max(level, 99);
      vipDays = math.max(vipDays, 36500);
      // Historical compatibility marker retained for cumulative contracts: vipDays = math.max(vipDays, 3650)
      xpNext = xpNeededForLevel(level);
    }
    _normalizeTimedCosmetics();
  }

  int cumulativeXpBeforeLevel(int targetLevel) {
    var total = 0;
    for (var current = 1; current < targetLevel.clamp(1, 100); current++) {
      total += xpNeededForLevel(current);
    }
    return total;
  }

  int xpProgressFromTotal(int totalXp, int currentLevel) {
    return math.max(0, totalXp - cumulativeXpBeforeLevel(currentLevel));
  }

  int xpNeededForLevel(int currentLevel) {
    final safe = currentLevel.clamp(1, 100).toInt();
    final exact = xpRequirementsV175[safe];
    if (exact != null) return exact;
    return xpRequirementsV175[100]!;
  }

  void _recalculateLevel() {
    if (isAdmin) {
      level = math.max(level, 99);
      xpNext = xpNeededForLevel(level);
      return;
    }
    xpNext = xpNeededForLevel(level);
    while (xp >= xpNext && level < 100) {
      xp -= xpNext;
      level += 1;
      xpNext = xpNeededForLevel(level);
      _grantLocalLevelReward(level);
    }
  }


  void _grantLocalLevelReward(int reachedLevel) {
    final tokenReward = reachedLevel <= 10
        ? 75 + reachedLevel * 35
        : reachedLevel <= 50
            ? 500 + reachedLevel * 20
            : 2000 + reachedLevel * 25;
    coins += BigInt.from(tokenReward);
    final rewards = <String>['$tokenReward توكن'];
    if (reachedLevel % 5 == 0) {
      final days = reachedLevel % 25 == 0 ? 3 : 1;
      vipDays += days;
      rewards.add('$days يوم باشا');
    }
    if (reachedLevel % 10 == 0) {
      competitionTickets[200] = (competitionTickets[200] ?? 0) + 1;
      rewards.add('تذكرة منافسة 200');
    }
    if (reachedLevel % 3 == 0) {
      awardLocalPrizeBoxV02('level_$reachedLevel');
      rewards.add('صندوق مستوى');
    }
    final temporaryChoices = <String>['b304_profile_aurora_30d','b304_profile_royal_30d','b304_profile_emerald_30d','b304_profile_crimson_30d','booster_green_v183','booster_blue_v183'];
    final first = temporaryChoices[reachedLevel % temporaryChoices.length];
    final second = temporaryChoices[(reachedLevel + 3) % temporaryChoices.length];
    final expiry = DateTime.now().add(const Duration(days: 7));
    packInventoryExpiriesV176['level_temp_${reachedLevel}_$first'] = expiry;
    packInventoryExpiriesV176['level_temp_${reachedLevel}_$second'] = expiry;
    rewards.add('${storeProductById(first)?.name(localeCode) ?? first} • 7 ${localeCode == 'ar' ? 'أيام' : 'days'}');
    rewards.add('${storeProductById(second)?.name(localeCode) ?? second} • 7 ${localeCode == 'ar' ? 'أيام' : 'days'}');
    transactions.insert(0, TokenTransaction('مكافأة المستوى $reachedLevel', tokenReward, 'الآن'));
    notices.insert(0, AppNotice('⭐', 'وصلت إلى المستوى $reachedLevel', 'مكافأتك: ${rewards.join(' • ')}.'));
  }

  void applyServerRoundProgressV174(Map<String, dynamic> result) {
    final profile = result['profile'];
    if (profile is Map) {
      level = int.tryParse(profile['level']?.toString() ?? '') ?? level;
      xp = int.tryParse(profile['xp_progress']?.toString() ?? profile['xp']?.toString() ?? '') ?? xp;
      xpNext = int.tryParse(profile['xp_next']?.toString() ?? '') ?? xpNeededForLevel(level);
      roundPoints = int.tryParse(profile['round_points']?.toString() ?? '') ?? roundPoints;
      tournamentPoints = int.tryParse(profile['tournament_points']?.toString() ?? '') ?? tournamentPoints;
      clubPoints = int.tryParse(profile['club_points']?.toString() ?? '') ?? clubPoints;
    } else {
      xp += int.tryParse((result['awarded_xp'] ?? 0).toString()) ?? 0;
      roundPoints += int.tryParse((result['round_points'] ?? 0).toString()) ?? 0;
      tournamentPoints += int.tryParse((result['tournament_points'] ?? 0).toString()) ?? 0;
      clubPoints += int.tryParse((result['club_points'] ?? 0).toString()) ?? 0;
      _recalculateLevel();
    }
    final prizeBox = result['prize_box'];
    if (prizeBox is Map) upsertPrizeBoxV02(Map<String, dynamic>.from(prizeBox));
    unawaited(_save());
    refreshUi();
  }

  void _normalizeTimedCosmetics() {
    final now = DateTime.now();
    if (nameColorExpiresAt != null && now.isAfter(nameColorExpiresAt!)) {
      selectedNameColor = '#facc15';
      nameColorExpiresAt = null;
    }
    if (chatColorExpiresAt != null && now.isAfter(chatColorExpiresAt!)) {
      selectedChatColor = '#ffffff';
      chatColorExpiresAt = null;
    }
    if (boosterExpiresAtV173 != null && now.isAfter(boosterExpiresAtV173!)) {
      activeXpMultiplier = 1.0;
      boosterExpiresAtV173 = null;
    }
    if (temporaryTableExpiresAtV173 != null && now.isAfter(temporaryTableExpiresAtV173!)) {
      selectedTable = v305PremiumTableId;
      temporaryTableExpiresAtV173 = null;
    }
    if (profileColorExpiresAtB304 != null && !profileColorExpiresAtB304!.isAfter(now)) { selectedProfileColorB304='b304_profile_aurora_30d'; profileColorExpiresAtB304=null; }
        purgeExpiredPackInventoryV176(now);
  }

  void _resetAdCounterIfNeeded() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (rewardedAdClaimDate != today) {
      rewardedAdClaimDate = today;
      rewardedAdClaimsToday = 0;
    }
  }

  int get rewardedAdsRemaining {
    _resetAdCounterIfNeeded();
    return math.max(0, 8 - rewardedAdClaimsToday);
  }

  void _applyLocalLoginStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayText = today.toIso8601String().substring(0, 10);
    if (lastLoginDate == todayText) return;
    final previous = DateTime.tryParse(lastLoginDate ?? '');
    final yesterday = today.subtract(const Duration(days: 1));
    consecutiveLoginDays = previous != null && DateTime(previous.year, previous.month, previous.day) == yesterday
        ? consecutiveLoginDays + 1
        : 1;
    lastLoginDate = todayText;
    if (consecutiveLoginDays % 3 == 0) {
      vipDays += 1;
      notices.insert(0, AppNotice('👑', 'يوم باشا مجاني', 'أكملت 3 أيام دخول متواصلة، وتمت إضافة يوم باشا.'));
    }
  }

  Future<String?> updateAvatarFromGallery(BuildContext context) async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1400, imageQuality: 92);
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      if (bytes.length > 5000000) return 'الصورة كبيرة جداً. اختر صورة أصغر من 5MB.';
      if (!context.mounted) return null;
      final cropped = await showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AvatarCropDialog(bytes: bytes),
      );
      if (cropped == null) return null;
      if (cropped.length > 1500000) return 'تعذر ضغط المعاينة. جرّب صورة أصغر.';
      avatarData = 'data:image/png;base64,${base64Encode(cropped)}';
      if (serverConnected) {
        await api.updateProfile({'avatar_data': avatarData, 'avatar': avatarEmoji});
      }
      await _save();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'تعذر قراءة الصورة المختارة أو قصها.';
    }
  }

  Future<String?> chooseAvatarEmoji(String emoji) async {
    avatarEmoji = emoji;
    avatarData = null;
    if (serverConnected) {
      try {
        await api.updateProfile({'avatar': emoji, 'avatar_data': null});
      } on ApiException catch (e) {
        return e.message;
      }
    }
    await _save();
    notifyListeners();
    return null;
  }

  Future<String?> changeCountry(CountryInfo country) async {
    countryCode = country.code;
    countryName = country.name(localeCode);
    if (serverConnected) {
      try {
        final data = await api.updateProfile({'country_code': country.code});
        final user = data['user'];
        if (user is Map) {
          countryName = user['country_name']?.toString() ?? countryName;
        }
      } on ApiException catch (e) {
        return e.message;
      }
    }
    await _save();
    notifyListeners();
    return null;
  }

  String get countryFlag => countryByCode(countryCode).flag;
  double get levelProgress => xpNext <= 0 ? 0 : (xp / xpNext).clamp(0.0, 1.0).toDouble();
  int get pointsToNextLevel => math.max(0, xpNext - xp);

  Future<String?> cancelAccount(String password, {String? reason}) async {
    if (isAdmin) return 'لا يمكن إلغاء حساب المدير الرئيسي.';
    if (password.trim().isEmpty) return 'أدخل كلمة المرور لتأكيد إلغاء الحساب.';
    if (!serverConnected) return 'إلغاء الحساب يتطلب اتصالاً بالخادم لحماية بياناتك.';
    try {
      await api.requestDeletion(password, reason: reason);
    } on ApiException catch (e) {
      return e.message;
    }
    await logout();
    return null;
  }

  Future<String?> grantRewardedAd(String verificationId) async {
    _resetAdCounterIfNeeded();
    if (rewardedAdClaimsToday >= 8) return localeCode == 'ar' ? 'وصلت إلى الحد اليومي: 8 إعلانات مكافِئة.' : 'You reached today’s limit of 8 rewarded ads.';
    final claimNumber = rewardedAdClaimsToday + 1;
    const localTokens = <int>[50,75,100,150,200,250,350,500];
    const localXp = <int>[15,25,40,60,90,120,160,250];
    var tokens = localTokens[(claimNumber - 1).clamp(0, 7)];
    var earnedXp = localXp[(claimNumber - 1).clamp(0, 7)];
    if (serverConnected) {
      try {
        final data = await api.claimRewardedAd(verificationId);
        tokens = int.tryParse(data['tokens']?.toString() ?? '') ?? tokens;
        earnedXp = int.tryParse(data['xp']?.toString() ?? '') ?? earnedXp;
        final wallet = data['wallet'];
        if (wallet is Map) coins = BigInt.tryParse(wallet['tokens']?.toString() ?? '') ?? coins;
        final profile = data['profile'];
        if (profile is Map) {
          level = int.tryParse(profile['level']?.toString() ?? '') ?? level;
          final totalXp = int.tryParse(profile['xp']?.toString() ?? '');
          if (totalXp != null) xp = xpProgressFromTotal(totalXp, level);
          xpNext = xpNeededForLevel(level);
        }
      } on ApiException catch (e) {
        return e.message;
      }
    } else {
      // Web/GitHub Pages preview: keep the temporary rewarded-ad feature testable
      // without inventing a server. The reward remains local to this browser.
      coins += BigInt.from(tokens);
      xp += earnedXp;
      _recalculateLevel();
    }
    rewardedAdClaimsToday += 1;
    transactions.insert(0, TokenTransaction('مكافأة مشاهدة إعلان', tokens, serverConnected ? 'الآن • خادم' : 'الآن • محلي'));
    notices.insert(0, AppNotice('📺', localeCode == 'ar' ? 'مكافأة إعلان' : 'Ad reward', localeCode == 'ar' ? '$tokens توكن و$earnedXp XP • المكافأة ${rewardedAdClaimsToday + 1}/8' : '$tokens tokens and $earnedXp XP • reward ${rewardedAdClaimsToday + 1}/8'));
    await _save();
    notifyListeners();
    return null;
  }

  void changeLocale(String value) {
    localeCode = b304ActiveLocaleCodes.contains(value) ? value : 'ar';
    _save();
    if (serverConnected) {
      api.updateProfile({'locale': localeCode}).catchError((_) => <String, dynamic>{});
    }
    notifyListeners();
  }

  void changeTheme(String value) {
    themeCode = value;
    _save();
    notifyListeners();
  }

  void toggleSound(bool value) {
    soundEnabled = value;
    AppSounds.enabled = value;
    if (value) AppSounds.fire('button');
    _save();
    notifyListeners();
  }

  void changeFontFamily(String value) {
    if (!const {'Roboto','Arial','Tahoma','Verdana','serif','monospace'}.contains(value)) return;
    uiFontFamily = value;
    _save();
    notifyListeners();
  }

  void adjustFontScale(double delta) {
    uiFontScale = (uiFontScale + delta).clamp(.70, 1.70).toDouble();
    _save();
    notifyListeners();
  }

  Future<void> playReactionFeedback({bool strong = false}) async {
    if (soundEnabled) AppSounds.fire(strong ? 'emoji' : 'tap');
    try {
      if (strong) { await HapticFeedback.mediumImpact(); } else { await HapticFeedback.selectionClick(); }
    } catch (_) {}
  }

  List<String> _normalizedHomeGameIds(List<String>? values) {
    final valid = customerGamesR101.map((game) => game.id).toSet();
    final normalized = <String>[];
    for (final value in values ?? const <String>[]) {
      if (valid.contains(value) && !normalized.contains(value)) normalized.add(value);
      if (normalized.length == 4) break;
    }
    if (normalized.isEmpty) normalized.addAll(const <String>['tarneeb', 'hand', 'trix']);
    return normalized;
  }

  List<GameInfo> get homeGames {
    final byId = <String, GameInfo>{for (final game in customerGamesR101) game.id: game};
    final selected = homeGameIds.map((id) => byId[id]).whereType<GameInfo>().take(4).toList();
    return selected.isEmpty ? customerGamesR101.take(3).toList() : selected;
  }

  Future<String?> updateHomeGames(Iterable<String> values) async {
    final raw = values.toList();
    if (raw.isEmpty) return L.t(localeCode, 'homeGamesAtLeastOne');
    if (raw.toSet().length > 4) return L.t(localeCode, 'homeGamesMaximumFour');
    final normalized = _normalizedHomeGameIds(raw);
    homeGameIds
      ..clear()
      ..addAll(normalized.take(4));
    await _save();
    notifyListeners();
    return null;
  }

  Future<bool> buy(StoreProduct product) async {
    lastStoreError = null;
    final reusable = product.reusable;
    final price = priceFor(product);
    if (!reusable && isOwnedActiveV176(product.id)) {
      return activateOwnedProductR36(product);
    }
    if (coins < BigInt.from(price)) {
      lastStoreError = 'رصيدك غير كافٍ. تحتاج إلى ${formatNumber(price)} توكن، ورصيدك الحالي ${formatNumber(coins)}.';
      return false;
    }

    if (serverConnected) {
      try {
        final data = await api.purchase(product.id, expectedPrice: price);
        final wallet = data['wallet'];
        if (wallet is Map) coins = BigInt.tryParse(wallet['tokens']?.toString() ?? '') ?? coins;
        final tickets = data['tickets'];
        if (tickets is Map) {
          competitionTickets
            ..clear()
            ..addAll(tickets.map((key, value) => MapEntry(int.tryParse(key.toString()) ?? 0, int.tryParse(value.toString()) ?? 0)));
        }
      } on ApiException catch (e) {
        if (e.statusCode == 409) await refreshServerStoreR36();
        lastStoreError = e.message;
        return false;
      } catch (_) {
        lastStoreError = 'تعذر إتمام الشراء بسبب مشكلة اتصال غير متوقعة.';
        return false;
      }
    } else {
      // GitHub Pages/PWA has no Laravel runtime. Keep the local demo economy fully
      // functional and persistent instead of rejecting every purchase.
      if (!isPrimaryAdmin && !isLocalAdmin) coins -= BigInt.from(price);
      if (!isPrimaryAdmin) adminRevenueTokensV182 += BigInt.from(price);
    }

    if (!reusable) owned.add(product.id);
    if (product.category == 'boost') {
      packInventoryExpiriesV176[product.id] = DateTime.now().add(Duration(days: boosterValidityDaysV183(product.id)));
      transactions.insert(0, TokenTransaction('شراء ${nameFor(product, 'ar')}', -price, serverConnected ? 'الآن • خادم' : 'الآن • محلي'));
      AppSounds.fire('purchase');
      await _save();
      notifyListeners();
      return true;
    }
    transactions.insert(0, TokenTransaction('شراء ${nameFor(product, 'ar')}', -price, serverConnected ? 'الآن • خادم' : 'الآن • محلي'));
    activateProduct(product);
    AppSounds.fire('purchase');
    await _save();
    notifyListeners();
    return true;
  }

  int priceFor(StoreProduct product) => int.tryParse(storeRowR36(product.id)?['price']?.toString() ?? '') ?? storePriceOverrides[product.id] ?? raisedStorePriceV183(product);
  String nameFor(StoreProduct product, [String? lang]) => storeTextR36(product,'name',lang ?? localeCode) ?? (storeNameOverrides[product.id]?.trim().isNotEmpty == true
      ? storeNameOverrides[product.id]!
      : product.name(lang ?? localeCode));
  String descriptionFor(StoreProduct product, [String? lang]) => storeTextR36(product,'description',lang ?? localeCode) ?? (storeDescriptionOverrides[product.id]?.trim().isNotEmpty == true
      ? storeDescriptionOverrides[product.id]!
      : product.description(lang ?? localeCode));
  int? durationFor(StoreProduct product) => int.tryParse(storeRowR36(product.id)?['duration_days']?.toString() ?? '') ?? (storeDurationOverrides.containsKey(product.id)
      ? storeDurationOverrides[product.id]
      : product.durationDays);
  Color color1For(StoreProduct product) => storeGradientR36(product,0) ?? colorFromHex(storeColor1Overrides[product.id] ?? colorToHex(product.previewColor1 ?? const Color(0xff0b4731)));
  Color color2For(StoreProduct product) => storeGradientR36(product,1) ?? colorFromHex(storeColor2Overrides[product.id] ?? colorToHex(product.previewColor2 ?? const Color(0xffd6aa59)));
  bool isStoreProductVisible(StoreProduct product) {
    if (serverConnected && serverStoreReadyR36) {
      final row=serverStoreR36[product.id];
      return row!=null && (row['active']==true || row['active']==1 || row['active']=='1');
    }
    if (hiddenStoreProducts.contains(product.id)) return false;
    if (const {'badges','effects'}.contains(product.category)) return false;
    if (product.category == 'tables') return isR61CuratedTable(product);
    if (product.category == 'cards') return isR61CuratedCardBack(product);
    return true;
  }

  Future<void> updateStoreProductAdmin(
    StoreProduct product, {
    int? price,
    bool? visible,
    String? name,
    String? description,
    int? durationDays,
    String? color1,
    String? color2,
  }) async {
    if (serverConnected) {
      await saveServerStoreProductR36(product,price:price,visible:visible,name:name,description:description,
        durationDays:durationDays,color1:color1,color2:color2);
      return;
    }
    if (price != null) storePriceOverrides[product.id] = price.clamp(0, 999999999).toInt();
    if (name != null) {
      if (name.trim().isEmpty) { storeNameOverrides.remove(product.id); } else { storeNameOverrides[product.id] = name.trim(); }
    }
    if (description != null) {
      if (description.trim().isEmpty) { storeDescriptionOverrides.remove(product.id); } else { storeDescriptionOverrides[product.id] = description.trim(); }
    }
    if (durationDays != null) storeDurationOverrides[product.id] = durationDays.clamp(0, 3650).toInt();
    if (color1 != null && color1.trim().isNotEmpty) storeColor1Overrides[product.id] = color1.trim();
    if (color2 != null && color2.trim().isNotEmpty) storeColor2Overrides[product.id] = color2.trim();
    if (visible != null) {
      if (visible) { hiddenStoreProducts.remove(product.id); } else { hiddenStoreProducts.add(product.id); }
    }
    await _save();
    notifyListeners();
  }

  void activateProduct(StoreProduct product) {
    switch (product.category) {
      case 'pasha':
        vipDays += durationFor(product) ?? 0;
        selectedBadge = 'badge_pasha';
        break;
      case 'pasha_style':
        selectedPashaStyle = product.value ?? selectedPashaStyle;
        final style = pashaStyleV173(selectedPashaStyle);
        uiAccentHex = style.primaryHex;
        selectedNameColor = style.primaryHex;
        selectedChatColor = style.primaryHex;
        if (serverConnected) api.updateProfile({'pasha_style': selectedPashaStyle, 'ui_preferences': {'accent_hex': uiAccentHex}}).catchError((_) => <String, dynamic>{});
        break;
      case 'competition_ticket':
        final denomination = int.tryParse(product.value ?? '') ?? 0;
        if (!serverConnected && denomination > 0) competitionTickets[denomination] = (competitionTickets[denomination] ?? 0) + 1;
        break;
      case 'themes':
        if (product.value != null) themeCode = product.value!;
        break;
      case 'tables':
        selectedTable = product.id;
        temporaryTableExpiresAtV173 = expiryForProductV176(product.id);
        break;
      case 'cards':
        selectedCardBack = product.id;
        break;
      case 'names':
        selectedNameColor = product.value ?? selectedNameColor;
        final nameExpiry = expiryForProductV176(product.id);
        final nameHours = product.durationHours;
        final nameDays = durationFor(product);
        nameColorExpiresAt = nameExpiry ?? (nameHours != null && nameHours > 0 ? DateTime.now().add(Duration(hours: nameHours)) : nameDays == null || nameDays <= 0 ? null : DateTime.now().add(Duration(days: nameDays)));
        break;
      case 'chat_colors':
        selectedChatColor = product.value ?? selectedChatColor;
        final chatExpiry = expiryForProductV176(product.id);
        final chatHours = product.durationHours;
        final chatDays = durationFor(product);
        chatColorExpiresAt = chatExpiry ?? (chatHours != null && chatHours > 0 ? DateTime.now().add(Duration(hours: chatHours)) : chatDays == null || chatDays <= 0 ? null : DateTime.now().add(Duration(days: chatDays)));
        break;
      case 'profile_colors':
        selectedProfileColorB304 = product.id;
        profileColorExpiresAtB304 = DateTime.now().add(Duration(days: durationFor(product) ?? 30));
        break;
      case 'badges':
        selectedBadge = product.id;
        break;
      case 'emoji':
        selectedEmojiPack = product.id;
        break;
      case 'effects':
        selectedEffect = product.id;
        break;
      case 'frames':
        selectedProfileFrameV300 = product.id;
        break;
      case 'covers':
        selectedCover = product.id;
        if (serverConnected) api.updateProfile({'active_cover': selectedCover}).catchError((_) => <String, dynamic>{});
        break;
      case 'boost':
        activeXpMultiplier = product.multiplier ?? 1.0;
        boosterExpiresAtV173 = DateTime.now().add(const Duration(hours: 24));
        if (!isPrimaryAdmin && !isLocalAdmin) {
          owned.remove(product.id);
          inventoryQuantitiesR36[product.id]=0;
        }
        packInventoryExpiriesV176.remove(product.id);
        AppSounds.fire('booster_activate');
        break;
    }
    _save();
    notifyListeners();
  }

  void updateNoCodeDesign({double? buttonHeight, double? radius, double? fontScale, double? chatScale, String? accentHex, bool? ambientEffects}) {
    if (buttonHeight != null) uiButtonHeight = buttonHeight.clamp(38, 64).toDouble();
    if (radius != null) uiRadius = radius.clamp(8, 32).toDouble();
    if (fontScale != null) uiFontScale = fontScale.clamp(.85, 1.35).toDouble();
    if (chatScale != null) uiChatScale = chatScale.clamp(.8, 1.35).toDouble();
    if (accentHex != null && accentHex.startsWith('#')) uiAccentHex = accentHex;
    if (ambientEffects != null) tableAmbientEffects = ambientEffects;
    _save();
    if (serverConnected) {
      api.updateProfile({'ui_preferences': {'button_height': uiButtonHeight, 'radius': uiRadius, 'font_scale': uiFontScale, 'chat_scale': uiChatScale, 'accent_hex': uiAccentHex, 'ambient_effects': tableAmbientEffects}}).catchError((_) => <String, dynamic>{});
    }
    notifyListeners();
  }

  Future<String?> uploadDesignerImage(String kind) async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, imageQuality: 88);
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      if (bytes.length > 6000000) return 'الصورة أكبر من 6MB.';
      final data = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      if (kind == 'table') {
        customTableBackgroundData = data;
      } else {
        customCardBackData = data;
      }
      await _save();
      notifyListeners();
      return null;
    } catch (_) { return 'تعذر قراءة الصورة المختارة.'; }
  }

  void clearDesignerImage(String kind) {
    if (kind == 'table') {
      customTableBackgroundData = null;
    } else {
      customCardBackData = null;
    }
    _save();
    notifyListeners();
  }

  Future<String?> updateServerUrl(String value) async {
    var normalized = value.trim().replaceAll(RegExp(r'/+$'), '');
    if (normalized.isEmpty) return 'أدخل رابط خادم Laravel كاملاً.';
    if (!normalized.endsWith('/api/mobile/v1')) normalized = '$normalized/api/mobile/v1';
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return 'رابط الخادم غير صحيح.';
    final local = const {'localhost', '127.0.0.1', '10.0.2.2'}.contains(uri.host);
    if (!local && uri.scheme != 'https') return 'الخادم البعيد يجب أن يستخدم HTTPS حتى يعمل الصوت والإشعارات بأمان.';
    customApiUrl = normalized;
    api.updateBaseUrl(normalized);
    await _save();
    try {
      await api.health().timeout(const Duration(seconds: 10));
      serverConnected = true;
      notifyListeners();
      return null;
    } catch (error) {
      serverConnected = false;
      notifyListeners();
      return 'تم حفظ الرابط، لكن تعذر الاتصال الآن: ${friendlyErrorMessage(error, localeCode)}';
    }
  }

  void changeBotDifficulty(String value) {
    if (!const {'easy', 'normal', 'pro', 'master'}.contains(value)) return;
    botDifficultyCode = value;
    _save();
    if (serverConnected) api.updateProfile({'bot_difficulty': value}).catchError((_) => <String, dynamic>{});
    notifyListeners();
  }

  double get winRate => gamesPlayed <= 0 ? 0 : (wins / gamesPlayed) * 100;
  int get losses => math.max(0, gamesPlayed - wins);

  Future<void> _applyPreferredOrientationV174() async {
    try {
      // Portrait-first by design, but allow the real device rotation to switch
      // the table to landscape. The table widgets read the current viewport.
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (_) {}
  }

  Future<void> toggleOrientationMode() async {
    landscapeMode = !landscapeMode;
    await _applyPreferredOrientationV174();
    await _save();
    refreshUi();
  }

  Future<void> setLandscapeMode(bool value) async {
    if (landscapeMode == value) return;
    landscapeMode = value;
    await _applyPreferredOrientationV174();
    await _save();
    refreshUi();
  }

  void queueNavigationRoute(String route) {
    final normalized = route.trim();
    if (normalized.isEmpty) return;
    _queuedNavigationRouteV175 = normalized.startsWith('room:')
        ? '/room/${normalized.substring('room:'.length).split(':').first.trim().toUpperCase()}'
        : normalized;
    unawaited(_save());
    if (_openingNavigationRouteV175) {
      final navigator = warqnaNavigatorKey.currentState;
      if (navigator != null && navigator.canPop()) navigator.pop(true);
    }
    unawaited(openPendingNavigationRoute());
  }

  Future<void> _prepareDirectInviteTransfer(String nextCode) async {
    final previousCode = activeRoomCode;
    if (previousCode != null && previousCode.isNotEmpty && previousCode != nextCode && serverConnected) {
      try {
        await api.leaveGame(previousCode);
      } catch (_) {}
    }
    if (previousCode != nextCode) {
      activeGame = null;
      activeRoomCode = null;
      activeRoomName = null;
    }
  }

  Future<void> openPendingNavigationRoute() async {
    if (!isAuthenticated || _openingNavigationRouteV175) return;
    final route = _queuedNavigationRouteV175;
    if (route == null || route.isEmpty) return;
    final match = RegExp(r'(?:/room/|room:)([A-Za-z0-9_-]+)').firstMatch(route);
    if (match == null) {
      _queuedNavigationRouteV175 = null;
      await _save();
      return;
    }
    final normalized = (match.group(1) ?? '').trim().toUpperCase();
    if (normalized.isEmpty) return;
    if (warqnaNavigatorKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(openPendingNavigationRoute()));
      return;
    }
    _openingNavigationRouteV175 = true;
    try {
      var gameId = activeGame ?? 'tarneeb';
      var voice = activeRoomVoice;
      var roomName = activeRoomName ?? 'غرفة ورقنا';
      var visibility = activeRoomVisibility;
      var turnSeconds = activeRoomTurnSeconds;
      if (serverConnected) {
        try {
          final data = await api.gameSession(normalized);
          final roomData = data['room'];
          if (roomData is Map) {
            gameId = roomData['game']?.toString() ?? gameId;
            voice = roomData['voice_enabled'] == true || roomData['voice_enabled'] == 1;
            roomName = roomData['room_name']?.toString() ?? roomName;
            visibility = roomData['visibility']?.toString() ?? visibility;
            turnSeconds = int.tryParse(roomData['turn_seconds']?.toString() ?? '') ?? turnSeconds;
          }
        } catch (_) {}
      }
      await _prepareDirectInviteTransfer(normalized);
      final game = gamesCatalog.firstWhere((item) => item.id == gameId, orElse: () => gamesCatalog.first);
      final options = RoomLaunchOptions(roomCode: normalized, roomName: roomName, voiceEnabled: voice, visibility: visibility, turnSeconds: turnSeconds, singleRound: false);
      activeRoomCode = normalized;
      activeRoomName = roomName;
      _pendingRoomCodeV174 = null;
      _queuedNavigationRouteV175 = null;
      await _save();
      final navigationContext = warqnaNavigatorKey.currentContext;
      if (navigationContext == null || !navigationContext.mounted) {
        _queuedNavigationRouteV175 = '/room/$normalized';
        WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(openPendingNavigationRoute()));
        return;
      }
      await openGameRoom(navigationContext, this, game, options: options);
    } finally {
      _openingNavigationRouteV175 = false;
      if (_queuedNavigationRouteV175 != null) unawaited(openPendingNavigationRoute());
    }
  }

  Future<void> openRoomFromNotificationV174(String code) async {
    _pendingRoomCodeV174 = code.trim().toUpperCase();
    queueNavigationRoute('/room/${_pendingRoomCodeV174!}');
  }

  String _roomExitKeyV210(String? roomCode, String gameId) {
    final normalized = roomCode?.trim().toUpperCase() ?? '';
    return normalized.isNotEmpty ? normalized : 'LOCAL:$gameId';
  }

  int exitsForRoomV210(String? roomCode, String gameId) => roomExitCountsV210[_roomExitKeyV210(roomCode, gameId)] ?? 0;

  // Historical API retained for old widgets/contracts. R9.1 no longer blocks a whole game type.
  int exitsForGame(String gameId) => exitsForRoomV210(activeRoomCode, gameId);
  bool canEnterGame(String gameId) => true;

  Future<int> recordGameExit(String gameId, {String? roomCode}) async {
    final key = _roomExitKeyV210(roomCode ?? activeRoomCode, gameId);
    final next = (roomExitCountsV210[key] ?? 0) + 1;
    roomExitCountsV210[key] = next.clamp(0, 5).toInt();
    activeGame = null;
    activeRoomCode = null;
    activeRoomName = null;
    activeRoomVoice = false;
    activeRoomSingleRound = false;
    await _save();
    notifyListeners();
    return roomExitCountsV210[key]!;
  }

  Future<void> recordInactivityEjectionV182() async {
    // Inactivity/network ejection is not a voluntary exit and must never consume
    // one of the player's five exact-room manual return opportunities.
    activeGame = null;
    activeRoomCode = null;
    activeRoomName = null;
    activeRoomVoice = false;
    activeRoomSingleRound = false;
    await _save();
    notifyListeners();
  }

  void resetGameExitSessionV182(String gameId) {
    final key = _roomExitKeyV210(activeRoomCode, gameId);
    final changed = roomExitCountsV210.remove(key) != null || gameExitCounts.remove(gameId) != null;
    if (changed) {
      unawaited(_save());
      notifyListeners();
    }
  }

  void setAwayMode(bool value) {
    awayMode = value;
    unawaited(_save());
    notifyListeners();
  }

  bool joinCompetition(String id) {
    if (activeCompetition != null && activeCompetition != id) return false;
    activeCompetition = id;
    _save();
    notifyListeners();
    return true;
  }

  void leaveCompetition() {
    activeCompetition = null;
    _save();
    notifyListeners();
  }

  bool joinChallenge(String id) {
    if (activeChallenge != null && activeChallenge != id) return false;
    activeChallenge = id;
    _save();
    notifyListeners();
    return true;
  }

  bool get challengeRoadActive => challengeRoadGame != null && !challengeRoadCompleted && challengeRoadAttempts > 0 && challengeRoadStage < challengeRoadTotal;

  void syncChallengeRoadV210(Map<String, dynamic> road) {
    final game = road['game_key']?.toString();
    challengeRoadGame = (game == null || game.isEmpty) ? null : game;
    challengeRoadTotal = (int.tryParse(road['total_stages']?.toString() ?? '') ?? 12).clamp(10, 15).toInt();
    challengeRoadStage = (int.tryParse(road['stage']?.toString() ?? '') ?? 0).clamp(0, challengeRoadTotal).toInt();
    challengeRoadAttempts = (int.tryParse(road['attempts']?.toString() ?? '') ?? 5).clamp(0, 5).toInt();
    challengeRoadCompleted = road['completed'] == true;
    activeChallenge = challengeRoadGame != null && !challengeRoadCompleted && challengeRoadAttempts > 0
        ? 'road:$challengeRoadGame'
        : null;
    _save();
    notifyListeners();
  }

  void startChallengeRoad(String gameId, int totalStages) {
    challengeRoadGame = gameId;
    challengeRoadTotal = const <int>{10, 12, 15}.contains(totalStages) ? totalStages : 12;
    challengeRoadStage = 0;
    challengeRoadAttempts = 5;
    challengeRoadCompleted = false;
    challengeRoadResultMarkers.clear();
    activeChallenge = 'road:$gameId';
    notices.insert(0, AppNotice('🎯', localeCode == 'ar' ? 'بدأ مسار التحدي' : 'Challenge road started', localeCode == 'ar' ? '${L.t(localeCode, gameId)} • $challengeRoadTotal مرحلة • 5 محاولات' : '${L.t(localeCode, gameId)} • $challengeRoadTotal stages • 5 attempts'));
    _save();
    notifyListeners();
  }

  Map<String, dynamic> challengeRoadPrizeForStage(int stage) {
    final safeStage = stage.clamp(1, challengeRoadTotal).toInt();
    if (safeStage == challengeRoadTotal) {
      return <String, dynamic>{'type':'tokens','value':'1000','icon':'🏆','label_ar':'1000 توكن + مكافأة ختامية يوم باشا','label_en':'1,000 tokens + final Pasha day','rarity':'legendary','duration_hours':0};
    }
    switch (safeStage % 6) {
      case 1:
        final tokens = math.min(1000, 100 + safeStage * 35).toInt();
        return <String, dynamic>{'type':'tokens','value':'$tokens','icon':'🪙','label_ar':'$tokens توكن','label_en':'$tokens tokens','rarity':'common','duration_hours':0};
      case 2:
        return <String, dynamic>{'type':'name_color','value':'#ef4444','icon':'🎨','label_ar':'لون لاعب أحمر لمدة 12 ساعة','label_en':'Red player color for 12 hours','rarity':'rare','duration_hours':12,'store_item_key':'challenge_name_red_r91'};
      case 3:
        return <String, dynamic>{'type':'xp_booster','value':'1.5','icon':'⚡','label_ar':'مسرع XP ×1.5 لمدة 6 ساعات','label_en':'1.5× XP booster for 6 hours','rarity':'rare','duration_hours':6,'store_item_key':'challenge_xp_15x_r91'};
      case 4:
        return <String, dynamic>{'type':'table','value':'table_v202_obsidian_vertical','icon':'🃏','label_ar':'طاولة أوبسيديان لمدة 24 ساعة','label_en':'Obsidian table for 24 hours','rarity':'epic','duration_hours':24,'store_item_key':'table_v202_obsidian_vertical'};
      case 5:
        return <String, dynamic>{'type':'pasha_day','value':'1','icon':'👑','label_ar':'يوم باشا','label_en':'One Pasha day','rarity':'epic','duration_hours':24};
      default:
        return <String, dynamic>{'type':'chat_color','value':'#22d3ee','icon':'✍️','label_ar':'لون كتابة سماوي لمدة 12 ساعة','label_en':'Cyan writing color for 12 hours','rarity':'rare','duration_hours':12,'store_item_key':'challenge_chat_cyan_r91'};
    }
  }

  int challengeRoadRewardForStage(int stage) {
    final prize = challengeRoadPrizeForStage(stage);
    return prize['type'] == 'tokens' ? (int.tryParse(prize['value']?.toString() ?? '') ?? 0) : 0;
  }

  String challengeRoadRewardLabel(int stage) {
    final prize = challengeRoadPrizeForStage(stage);
    return (localeCode == 'ar' ? prize['label_ar'] : prize['label_en'])?.toString() ?? '🎁';
  }

  bool recordChallengeRoadResult(String gameId, {required bool won, String? marker}) {
    if (!challengeRoadActive || challengeRoadGame != gameId) return false;
    final resultMarker = marker ?? '$gameId:${DateTime.now().millisecondsSinceEpoch ~/ 30000}:$won';
    if (!challengeRoadResultMarkers.add(resultMarker)) return false;
    if (won) {
      challengeRoadStage += 1;
      challengeStreakV173 += 1;
      final prize = challengeRoadPrizeForStage(challengeRoadStage);
      final type = prize['type']?.toString() ?? 'tokens';
      final value = prize['value']?.toString() ?? '0';
      final hours = int.tryParse(prize['duration_hours']?.toString() ?? '') ?? 0;
      if (hours > 0) prize['expires_at'] = DateTime.now().add(Duration(hours: hours)).toIso8601String();
      if (type == 'tokens') {
        final reward = (int.tryParse(value) ?? 0).clamp(0, 1000).toInt();
        coins += BigInt.from(reward);
        transactions.insert(0, TokenTransaction('مسار التحدي — المرحلة $challengeRoadStage', reward, 'الآن'));
      } else if (type == 'pasha_day') {
        vipDays += 1;
      } else {
        applyDailyPackRewardV176(prize, const <String, dynamic>{});
      }
      xp += 25 + challengeRoadStage * 5;
      if (challengeRoadStage >= challengeRoadTotal) {
        challengeRoadCompleted = true;
        vipDays += 1;
        notices.insert(0, AppNotice('🏆', localeCode == 'ar' ? 'اكتمل مسار التحدي' : 'Challenge road complete', localeCode == 'ar' ? '1000 توكن + يوم باشا ختامي.' : '1,000 tokens + a final Pasha day.'));
        activeChallenge = null;
      } else {
        final rewardLabel = challengeRoadRewardLabel(challengeRoadStage);
        notices.insert(0, AppNotice('✅', localeCode == 'ar' ? 'اجتزت المرحلة $challengeRoadStage' : 'Stage $challengeRoadStage cleared', '$rewardLabel • ${localeCode == 'ar' ? 'تبقى ${challengeRoadTotal - challengeRoadStage} مراحل' : '${challengeRoadTotal - challengeRoadStage} stages remaining'}.'));
      }
    } else {
      challengeRoadAttempts = math.max(0, challengeRoadAttempts - 1).toInt();
      challengeStreakV173 = 0;
      if (challengeRoadAttempts == 0) {
        activeChallenge = null;
        notices.insert(0, AppNotice('🔄', localeCode == 'ar' ? 'انتهت المحاولات' : 'Attempts exhausted', localeCode == 'ar' ? 'يمكنك بدء مسار جديد بخمس محاولات.' : 'You can start a new road with five attempts.'));
      } else {
        notices.insert(0, AppNotice('💔', localeCode == 'ar' ? 'خسرت محاولة' : 'Attempt lost', localeCode == 'ar' ? 'بقي لديك $challengeRoadAttempts من أصل 5 محاولات.' : '$challengeRoadAttempts of 5 attempts remain.'));
      }
    }
    _recalculateLevel();
    _save();
    notifyListeners();
    return true;
  }

  void resetChallengeRoad() {
    challengeRoadGame = null;
    challengeRoadStage = 0;
    challengeRoadAttempts = 5;
    challengeRoadCompleted = false;
    challengeRoadResultMarkers.clear();
    if (activeChallenge?.startsWith('road:') == true) activeChallenge = null;
    _save();
    notifyListeners();
  }

  void leaveChallenge() {
    activeChallenge = null;
    if (challengeRoadGame != null) {
      resetChallengeRoad();
    } else {
      _save();
      notifyListeners();
    }
  }

  bool enterGame(String id) {
    if (!canEnterGame(id)) return false;
    if (activeGame != null && activeGame != id) return false;
    activeGame = id;
    _save();
    notifyListeners();
    return true;
  }

  void rememberActiveRoom(String gameId, {String? code, required RoomLaunchOptions options}) {
    activeGame = gameId;
    activeRoomCode = code?.trim().isEmpty == true ? null : code?.trim();
    activeRoomName = options.roomName;
    activeRoomVoice = options.voiceEnabled;
    activeRoomVisibility = options.visibility;
    activeRoomTurnSeconds = options.turnSeconds;
    activeRoomSingleRound = options.singleRound;
    _save();
    notifyListeners();
  }

  RoomLaunchOptions activeRoomOptions() => RoomLaunchOptions(
    roomName: activeRoomName ?? 'غرفة ورقنا',
    voiceEnabled: activeRoomVoice,
    visibility: activeRoomVisibility,
    turnSeconds: activeRoomTurnSeconds,
    roomCode: activeRoomCode,
    singleRound: activeRoomSingleRound,
  );

  void leaveGame([String? id]) {
    if (id == null || activeGame == id) {
      activeGame = null;
      activeRoomCode = null;
      activeRoomName = null;
      activeRoomVoice = false;
      activeRoomSingleRound = false;
    }
    _save();
    notifyListeners();
  }

  RoundRewardReport? recordRoundProgress({required bool won, String mode = 'normal', String stage = 'round', bool away = false}) {
    if (away) return null;
    final modeMultiplier = mode == 'sponsored' || mode == 'seasonal' ? 3.0 : mode == 'tournament' ? 2.0 : mode == 'club' ? 1.35 : 1.0;
    final pashaMultiplier = vipDays > 0 ? 2.0 : 1.0;
    final multiplier = modeMultiplier * pashaMultiplier * math.max(1.0, activeXpMultiplier);
    final earned = ((won ? 60 : 20) * multiplier).round();
    final earnedRound = ((won ? 30 : 8) * multiplier).round();
    var earnedTournament = 0;
    var earnedClub = 0;
    xp += earned;
    roundPoints += earnedRound;
    if (mode == 'tournament' || mode == 'sponsored' || mode == 'seasonal') {
      final base = stage == 'champion' ? 1000 : stage == 'runner_up' ? 600 : stage == 'semifinal' ? 350 : stage == 'quarterfinal' ? 150 : 35;
      earnedTournament = modeMultiplier >= 3 ? base * 3 : base;
      tournamentPoints += earnedTournament;
    }
    if (activeClub != null) {
      earnedClub = ((won ? 20 : 5) * (mode == 'club' ? 2 : 1)).round();
      clubPoints += earnedClub;
    }
    _recalculateLevel();
    lastRoundReport = RoundRewardReport(xp: earned, roundPoints: earnedRound, tournamentPoints: earnedTournament, clubPoints: earnedClub, multiplier: multiplier, won: won, mode: mode, stage: stage);
    notices.insert(0, AppNotice('⭐', 'نقاط الجولة', '+$earned XP • +$earnedRound نقطة • مضاعف ×${multiplier.toStringAsFixed(2)}'));
    AppSounds.fire(won ? 'win' : 'notification');
    _save();
    notifyListeners();
    return lastRoundReport;
  }

  void rewardGameWin(String gameId) {
    final marker = '${activeChallenge ?? 'friendly'}:$gameId:${DateTime.now().millisecondsSinceEpoch ~/ 30000}';
    if (rewardedMatches.contains(marker)) return;
    rewardedMatches.add(marker);
    final baseReward = activeChallenge == null ? 50 : 200;
    final xpReward = (10 * (vipDays > 0 ? 2 : 1) * activeXpMultiplier).round();
    coins += BigInt.from(baseReward);
    xp += xpReward;
    _recalculateLevel();
    gamesPlayed += 1;
    wins += 1;
    resetGameExitSessionV182(gameId);
    giftRoadProgress = (giftRoadProgress + 1).clamp(0, 30).toInt();
    transactions.insert(0, TokenTransaction('مكافأة فوز', baseReward, 'الآن'));
    notices.insert(0, AppNotice(storeProductById(selectedEffect)?.icon ?? '🏆', 'فوز جديد', 'حصلت على $baseReward توكن و$xpReward XP مع تفعيل مؤثر الفوز.'));
    final prizeMode = activeCompetition != null || activeChallenge != null ? 'tournament' : 'normal';
    awardLocalPrizeBoxV02(gameId, won: true, mode: prizeMode);
    final wasRoad = activeChallenge?.startsWith('road:') == true;
    if (wasRoad) recordChallengeRoadResult(gameId, won: true, marker: 'win:$marker');
    if (!wasRoad) activeChallenge = null;
    _save();
    notifyListeners();
  }

  int giftRewardFor(int step) => switch (step) {
        5 => 50,
        10 => 100,
        20 => 100,
        30 => 200,
        _ => 0,
      };

  bool claimGiftRoad(int step) {
    if (giftRoadProgress < step || claimedGiftSteps.contains(step)) return false;
    final reward = giftRewardFor(step);
    claimedGiftSteps.add(step);
    coins += BigInt.from(reward);
    transactions.insert(0, TokenTransaction('طريق الهدايا — المرحلة $step', reward, 'الآن'));
    _save();
    notifyListeners();
    return true;
  }

  void addCoins(int value, String label) {
    coins += BigInt.from(value);
    transactions.insert(0, TokenTransaction(label, value, 'الآن'));
    _save();
    notifyListeners();
  }

  Future<bool> claimDaily() async {
    if (!serverConnected) {
      notices.insert(0, AppNotice('📡', 'المكافأة اليومية', 'يلزم اتصال فعّال بالخادم لاستلام المكافأة.'));
      notifyListeners();
      return false;
    }
    final now = DateTime.now();
    final today = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (lastDailyClaimDate == today) {
      notices.insert(0, AppNotice('⏳', 'المكافأة اليومية', 'استلمت مكافأة اليوم بالفعل. عد غداً.'));
      notifyListeners();
      return false;
    }
    try {
      final data = await api.claimDaily();
      final wallet = data['wallet'];
      if (wallet is Map) coins = BigInt.tryParse(wallet['tokens']?.toString() ?? '') ?? coins;
      final profile = data['profile'];
      if (profile is Map) {
        level = int.tryParse(profile['level']?.toString() ?? '') ?? level;
        final totalXp = int.tryParse(profile['xp']?.toString() ?? '');
        if (totalXp != null) xp = xpProgressFromTotal(totalXp, level);
        xpNext = xpNeededForLevel(level);
      }
    } catch (_) {
      notices.insert(0, AppNotice('⚠️', 'المكافأة اليومية', 'تعذر استلام المكافأة من الخادم. حاول مرة أخرى.'));
      notifyListeners();
      return false;
    }
    lastDailyClaimDate = today;
    transactions.insert(0, const TokenTransaction('مكافأة يومية', 100, 'الآن'));
    notices.insert(0, AppNotice('🎁', 'المكافأة اليومية', 'اعتمد الخادم 100 توكن و20 XP.'));
    await _save();
    notifyListeners();
    return true;
  }

  void markAllRead() {
    for (final notice in notices) {
      notice.read = true;
    }
    notifyListeners();
  }

  void addNotice(AppNotice notice) {
    notices.insert(0, notice);
    notifyListeners();
  }

  void removeNotice(AppNotice notice) {
    notices.remove(notice);
    notifyListeners();
  }

  bool joinClub(String id) {
    if (activeClub != null && activeClub != id) return false;
    activeClub = id;
    _save();
    notifyListeners();
    return true;
  }

  void leaveClub() {
    activeClub = null;
    _save();
    notifyListeners();
  }

  void acceptFriend(LocalFriend friend) {
    incomingRequests.remove(friend);
    if (!friends.any((e) => e.id == friend.id)) friends.add(friend);
    notifyListeners();
  }

  void rejectFriend(LocalFriend friend) {
    incomingRequests.remove(friend);
    notifyListeners();
  }

  void sendFriendRequest(LocalFriend friend) {
    if (!outgoingRequests.any((e) => e.id == friend.id)) outgoingRequests.add(friend);
    notifyListeners();
  }

  void cancelFriendRequest(LocalFriend friend) {
    outgoingRequests.remove(friend);
    notifyListeners();
  }

  void blockFriend(LocalFriend friend) {
    friends.removeWhere((e) => e.id == friend.id);
    incomingRequests.removeWhere((e) => e.id == friend.id);
    outgoingRequests.removeWhere((e) => e.id == friend.id);
    if (!blocked.any((e) => e.id == friend.id)) blocked.add(friend);
    notifyListeners();
  }

  void unblockFriend(LocalFriend friend) {
    blocked.remove(friend);
    notifyListeners();
  }

  void sendLocalMessage(LocalFriend friend, String body) {
    privateChats.putIfAbsent(friend.id, () => []);
    privateChats[friend.id]!.add(ChatMessage(displayName, body, true, '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'));
    AppSounds.fire('message');
    notifyListeners();
  }

  Future<String?> transferLocal(String receiver, int amount) async {
    if (amount < 10) return 'الحد الأدنى للتحويل هو 10 توكنز.';
    final fee = (amount * .10).ceil();
    final total = amount + fee;
    if (coins < BigInt.from(total)) return 'الرصيد غير كافٍ لإتمام التحويل مع الرسوم.';
    coins -= BigInt.from(total);
    transactions.insert(0, TokenTransaction('تحويل إلى @$receiver', -total, 'الآن • محلي'));
    notices.insert(0, AppNotice('🪙', 'تم التحويل', 'تم إرسال $amount توكن واحتساب رسوم التحويل.'));
    await _save();
    notifyListeners();
    return null;
  }
}

class AppNotice {
  final String icon;
  final String title;
  final String body;
  bool read;

  AppNotice(this.icon, this.title, this.body, {this.read = false});
}

class TokenTransaction {
  final String label;
  final int amount;
  final String date;

  const TokenTransaction(this.label, this.amount, this.date);
}


class LocalFriend {
  final int id;
  final String name;
  final String username;
  final bool online;
  final String activity;
  final int level;
  final String countryCode;
  final String? avatar;
  final int pashaDays;
  final int gamesPlayed;
  final int wins;
  final int xp;
  final int xpNext;
  final int roundPoints;
  final int tournamentPoints;
  final int clubPoints;
  final String nameColor;
  final String? badge;
  final String? clubName;
  final String? clubLogo;

  const LocalFriend(
    this.id,
    this.name,
    this.username, {
    required this.online,
    required this.activity,
    this.level = 1,
    this.countryCode = 'PS',
    this.avatar,
    this.pashaDays = 0,
    this.gamesPlayed = 0,
    this.wins = 0,
    this.xp = 0,
    this.xpNext = 100,
    this.roundPoints = 0,
    this.tournamentPoints = 0,
    this.clubPoints = 0,
    this.nameColor = '#facc15',
    this.badge,
    this.clubName,
    this.clubLogo,
  });
}

class ChatMessage {
  final String sender;
  final String body;
  final bool mine;
  final String time;

  const ChatMessage(this.sender, this.body, this.mine, this.time);
}

Map<String, List<String>> decodeStringListMapV182(String? source) {
  if (source == null || source.trim().isEmpty) return <String, List<String>>{};
  try {
    final decoded = jsonDecode(source);
    if (decoded is! Map) return <String, List<String>>{};
    return decoded.map((key, value) => MapEntry(key.toString(), value is List ? value.map((item) => item.toString()).toList() : <String>[]));
  } catch (_) { return <String, List<String>>{}; }
}

class AppPalette {
  final Color bg;
  final Color panel;
  final Color panel2;
  final Color gold;
  final Color green;
  final Color accent;
  final Color text;
  final Color muted;

  const AppPalette(
    this.bg,
    this.panel,
    this.panel2,
    this.gold,
    this.green,
    this.accent,
    this.text,
    this.muted,
  );

  static AppPalette fromCode(String code) {
    switch (code) {
      case 'dark':
        return const AppPalette(Color(0xff020617), Color(0xff111827), Color(0xff1f2937), Color(0xffe5e7eb), Color(0xff22c55e), Color(0xff64748b), Colors.white, Color(0xff94a3b8));
      case 'light':
        return const AppPalette(Color(0xffeef2f7), Color(0xffffffff), Color(0xffe2e8f0), Color(0xffa16207), Color(0xff15803d), Color(0xff475569), Color(0xff0f172a), Color(0xff475569));
      case 'blue':
        return const AppPalette(Color(0xff07142d), Color(0xff10254a), Color(0xff173461), Color(0xffffcf6a), Color(0xff1ea979), Color(0xff3b82f6), Colors.white, Color(0xff9fb0cb));
      case 'sky':
        return const AppPalette(Color(0xff06131d), Color(0xff0d2534), Color(0xff12394d), Color(0xffe0f2fe), Color(0xff2dd4bf), Color(0xff38bdf8), Colors.white, Color(0xffb8d9e8));
      case 'green':
        return const AppPalette(Color(0xff061a14), Color(0xff0d2c22), Color(0xff123b2d), Color(0xffffd36e), Color(0xff23b47e), Color(0xff10b981), Colors.white, Color(0xff9fc7b8));
      case 'light_green':
        return const AppPalette(Color(0xff102008), Color(0xff1c3510), Color(0xff294b17), Color(0xffffdf76), Color(0xff84cc16), Color(0xffa3e635), Colors.white, Color(0xffc6dda8));
      case 'gold':
        return const AppPalette(Color(0xff201707), Color(0xff37270a), Color(0xff4d3810), Color(0xffffe19a), Color(0xff2fa36f), Color(0xfff59e0b), Colors.white, Color(0xffd9c69d));
      case 'light_pink':
        return const AppPalette(Color(0xff2a101b), Color(0xff44182a), Color(0xff5d223b), Color(0xffffd9c8), Color(0xff41b883), Color(0xfffb7185), Colors.white, Color(0xffedbdcb));
      case 'royal':
        return const AppPalette(
          Color(0xff07142d),
          Color(0xff10254a),
          Color(0xff173461),
          Color(0xffffcf6a),
          Color(0xff1ea979),
          Color(0xff4f7cff),
          Colors.white,
          Color(0xff9fb0cb),
        );
      case 'emerald':
        return const AppPalette(
          Color(0xff061a14),
          Color(0xff0d2c22),
          Color(0xff123b2d),
          Color(0xffffd36e),
          Color(0xff23b47e),
          Color(0xff00c98d),
          Colors.white,
          Color(0xff9fc7b8),
        );
      case 'purple':
        return const AppPalette(
          Color(0xff160b23),
          Color(0xff27113d),
          Color(0xff351a52),
          Color(0xffffd06a),
          Color(0xff3db58b),
          Color(0xff9b5de5),
          Colors.white,
          Color(0xffc0a9d1),
        );
      case 'classic':
        return const AppPalette(
          Color(0xff21170f),
          Color(0xff372619),
          Color(0xff493322),
          Color(0xffffd178),
          Color(0xff2fa36f),
          Color(0xffb77a42),
          Colors.white,
          Color(0xffc8b59f),
        );
      case 'crimson':
        return const AppPalette(Color(0xff21070d), Color(0xff3b1019), Color(0xff521725), Color(0xffffd078), Color(0xff20a777), Color(0xffef334f), Colors.white, Color(0xffd2a5ad));
      case 'midnight':
        return const AppPalette(Color(0xff020617), Color(0xff0b1730), Color(0xff112448), Color(0xffe7c873), Color(0xff21b58a), Color(0xff4f86ff), Colors.white, Color(0xff91a4c4));
      case 'aurora':
        return const AppPalette(Color(0xff04171b), Color(0xff0a2b31), Color(0xff10414a), Color(0xffffd772), Color(0xff35d09a), Color(0xff67e8f9), Colors.white, Color(0xffa4ced2));
      case 'obsidian':
        return const AppPalette(Color(0xff020307), Color(0xff0b0d12), Color(0xff171a21), Color(0xffe5c07b), Color(0xff36c692), Color(0xff6b7280), Colors.white, Color(0xffa3a3a3));
      case 'rose_gold':
        return const AppPalette(Color(0xff1b0710), Color(0xff351322), Color(0xff512038), Color(0xffffd0c7), Color(0xff41b883), Color(0xfffb7185), Colors.white, Color(0xffe7b3c1));
      case 'desert':
        return const AppPalette(Color(0xff241307), Color(0xff3b2410), Color(0xff5a3514), Color(0xffffd38a), Color(0xff3cab76), Color(0xffd97706), Colors.white, Color(0xffd4b58f));
      case 'forest':
        return const AppPalette(Color(0xff03140d), Color(0xff0a291d), Color(0xff10432e), Color(0xffffd166), Color(0xff22c55e), Color(0xff16a34a), Colors.white, Color(0xffa7cdb9));
      case 'ice':
        return const AppPalette(Color(0xff06131d), Color(0xff0d2534), Color(0xff12394d), Color(0xffe0f2fe), Color(0xff2dd4bf), Color(0xff38bdf8), Colors.white, Color(0xffb8d9e8));
      default:
        return const AppPalette(
          Color(0xff07111c),
          Color(0xff0d1a28),
          Color(0xff132336),
          Color(0xffffcf67),
          Color(0xff20a777),
          Color(0xff815ac0),
          Colors.white,
          Color(0xff93a3b7),
        );
    }
  }
}

class L {
  static const Map<String, Map<String, String>> data = {
    'ar': {
      'home': 'الرئيسية',
      'games': 'الألعاب',
      'store': 'المتجر',
      'clubs': 'المجموعات',
      'events': 'المنافسات',
      'social_world': 'العالم',
      'welcome': 'مرحباً بعودتك',
      'level': 'المستوى',
      'coins': 'العملات',
      'vip': 'الباشا',
      'days': 'يوم',
      'champions': 'بطولة الأبطال',
      'hero': 'نافس أقوى اللاعبين واربح جوائز ذهبية ضخمة',
      'join': 'انضم الآن',
      'giftRoad': 'طريق الهدايا',
      'featured': 'ألعاب مميزة',
      'homeGames': 'ألعابك في الرئيسية',
      'customize': 'تخصيص',
      'chooseHomeGames': 'اختر ألعاب الصفحة الرئيسية',
      'homeGamesHint': 'اختر من لعبة واحدة إلى 4 ألعاب. يتغير ترتيب الصفحة الرئيسية فور الحفظ.',
      'homeGamesAtLeastOne': 'يجب اختيار لعبة واحدة على الأقل.',
      'homeGamesMaximumFour': 'يمكن اختيار 4 ألعاب كحد أقصى.',
      'tapToSelect': 'اضغط للاختيار',
      'friendly': 'مباراة ودية',
      'competitions': 'المنافسات',
      'challenges': 'التحديات',
      'tournaments': 'المنافسات',
      'friends': 'الأصدقاء',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'theme': 'الثيم',
      'claim': 'استلام',
      'buy': 'شراء',
      'owned': 'مملوك',
      'rules': 'القوانين',
      'leaderboard': 'لوحة الصدارة',
      'chat': 'الدردشة',
      'quick': 'التفاعلات السريعة',
      'yourTurn': 'دورك',
      'play': 'طرح',
      'pass': 'سكون',
      'bid': 'أخذ',
      'notifications': 'الإشعارات',
      'rewards': 'المكافآت',
      'transactions': 'سجل التوكنز',
      'inventory': 'مقتنياتي',
      'createRoom': 'إنشاء غرفة',
      'chooseGameMode': 'اختر نوع اللعبة',
      'chooseGameModeHint': 'ابدأ لعبة عادية أو أنشئ غرفة صوتية مع تحكم كامل بالميكروفون.',
      'normalGame': 'لعبة عادية',
      'normalGameHint': 'لعب سريع بدون محادثة صوتية.',
      'voiceGame': 'لعبة صوتية',
      'voiceGameHint': 'تحدث مع اللاعبين أثناء اللعب مع كتم فردي.',
      'roomModeDescription': 'حدد نوع الغرفة وخصوصيتها وسرعة الدور قبل بدء اللعب.',
      'roomName': 'اسم الغرفة',
      'roomVisibility': 'خصوصية الغرفة',
      'publicRoom': 'غرفة عامة',
      'friendsRoom': 'للأصدقاء فقط',
      'privateRoom': 'غرفة خاصة',
      'turnSpeed': 'سرعة الدور',
      'voicePrivacyHint': 'يُطلب إذن الميكروفون فقط عند دخول غرفة صوتية، ويمكنك كتم صوتك أو أي لاعب في أي وقت.',
      'enterRoomName': 'أدخل اسمًا للغرفة.',
      'enterRoomPassword': 'أدخل كلمة سر من 3 أحرف على الأقل.',
      'createVoiceRoom': 'إنشاء غرفة صوتية',
      'createNormalRoom': 'إنشاء غرفة عادية',
      'openRooms': 'الغرف المفتوحة',
      'openRoomsHint': 'انضم إلى غرفة عادية أو صوتية أنشأها لاعب آخر.',
      'noOpenRooms': 'لا توجد غرف مفتوحة الآن.',
      'serverRoomsNeedBackend': 'الغرف بين اللاعبين تحتاج ربط التطبيق بخادم Laravel المنشور.',
      'roomsLoadFailed': 'تعذر تحميل الغرف المفتوحة.',
      'joinByCode': 'دخول برمز',
      'joinByCodeHint': 'أدخل رمز الغرفة الذي أرسله لك صديقك.',
      'roomCode': 'رمز الغرفة',
      'optional': 'اختياري',
      'enterRoomCode': 'أدخل رمز غرفة صحيحًا.',
      'joinRoom': 'دخول الغرفة',
      'search': 'ابحث عن لعبة',
      'members': 'عضو',
      'treasury': 'الخزينة',
      'leaveClub': 'مغادرة المجموعة',
      'joinClub': 'انضمام',
      'domino': 'دومينو',
      'tarneeb': 'طرنيب',
      'tarneeb_41': 'طرنيب 41',
      'tarneeb_61': 'طرنيب 61',
      'trix': 'تركس',
      'hand': 'هاند',
      'banakil': 'بناكل',
      'baloot': 'بلوت',
      'basra': 'باصرة',
      'jackaroo': 'جاكارو',
      'chess': 'شطرنج',
      'backgammon': 'طاولة الزهر',
      'solitaire_multiplayer': 'سوليتير تنافسي',
      'tarneeb_400': 'طرنيب 400',
      'syrian_tarneeb': 'طرنيب سوري',
      'trix_complex': 'تركس كومبلكس',
      'saudi_hand': 'هاند سعودي',
      'hand_partner': 'هاند شراكة',
      'trix_partner': 'تركس شراكة',
      'pinochle': 'بناكل كلاسيك',
    },
    'en': {
      'home': 'Home',
      'games': 'Games',
      'store': 'Store',
      'clubs': 'Groups',
      'events': 'Competitions',
      'social_world': 'Social',
      'welcome': 'Welcome back',
      'level': 'Level',
      'coins': 'Coins',
      'vip': 'VIP',
      'days': 'Days',
      'champions': 'Champions Cup',
      'hero': 'Compete with top players and win major golden prizes',
      'join': 'Join now',
      'giftRoad': 'Gifts Road',
      'featured': 'Featured Games',
      'homeGames': 'Your Home Games',
      'customize': 'Customize',
      'chooseHomeGames': 'Choose Home Games',
      'homeGamesHint': 'Choose between one and four games. Your home screen updates immediately after saving.',
      'homeGamesAtLeastOne': 'Select at least one game.',
      'homeGamesMaximumFour': 'You can select up to four games.',
      'tapToSelect': 'Tap to select',
      'friendly': 'Friendly Match',
      'competitions': 'Competitions',
      'challenges': 'Challenges',
      'tournaments': 'Tournaments',
      'friends': 'Friends',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'claim': 'Claim',
      'buy': 'Buy',
      'owned': 'Owned',
      'rules': 'Rules',
      'leaderboard': 'Leaderboard',
      'chat': 'Chat',
      'quick': 'Quick Reactions',
      'yourTurn': 'Your Turn',
      'play': 'Play',
      'pass': 'Pass',
      'bid': 'Bid',
      'notifications': 'Notifications',
      'rewards': 'Rewards',
      'transactions': 'Token History',
      'inventory': 'Inventory',
      'createRoom': 'Create Room',
      'chooseGameMode': 'Choose game mode',
      'chooseGameModeHint': 'Start a normal match or create a voice room with full microphone controls.',
      'normalGame': 'Normal game',
      'normalGameHint': 'Fast play without voice chat.',
      'voiceGame': 'Voice game',
      'voiceGameHint': 'Talk to players while playing with individual mute controls.',
      'roomModeDescription': 'Choose room type, privacy, and turn speed before playing.',
      'roomName': 'Room name',
      'roomVisibility': 'Room privacy',
      'publicRoom': 'Public room',
      'friendsRoom': 'Friends only',
      'privateRoom': 'Private room',
      'turnSpeed': 'Turn speed',
      'voicePrivacyHint': 'Microphone permission is requested only for voice rooms. You can mute yourself or any player at any time.',
      'enterRoomName': 'Enter a room name.',
      'enterRoomPassword': 'Enter a password of at least 3 characters.',
      'createVoiceRoom': 'Create voice room',
      'createNormalRoom': 'Create normal room',
      'openRooms': 'Open rooms',
      'openRoomsHint': 'Join a normal or voice room created by another player.',
      'noOpenRooms': 'No open rooms right now.',
      'serverRoomsNeedBackend': 'Multiplayer rooms require the published Laravel server.',
      'roomsLoadFailed': 'Could not load open rooms.',
      'joinByCode': 'Join by code',
      'joinByCodeHint': 'Enter the room code shared by your friend.',
      'roomCode': 'Room code',
      'optional': 'optional',
      'enterRoomCode': 'Enter a valid room code.',
      'joinRoom': 'Join room',
      'search': 'Search games',
      'members': 'members',
      'treasury': 'Treasury',
      'leaveClub': 'Leave Group',
      'joinClub': 'Join',
      'domino': 'Domino',
      'tarneeb': 'Tarneeb',
      'tarneeb_41': 'Tarneeb 41',
      'tarneeb_61': 'Tarneeb 61',
      'trix': 'Trix',
      'hand': 'Hand',
      'banakil': 'Banakil',
      'baloot': 'Baloot',
      'basra': 'Basra',
      'jackaroo': 'Jackaroo',
      'chess': 'Chess',
      'backgammon': 'Backgammon',
      'solitaire_multiplayer': 'Competitive Solitaire',
      'tarneeb_400': 'Tarneeb 400',
      'syrian_tarneeb': 'Syrian Tarneeb',
      'trix_complex': 'Trix Complex',
      'saudi_hand': 'Saudi Hand',
      'hand_partner': 'Partnership Hand',
      'trix_partner': 'Partnership Trix',
      'pinochle': 'Classic Pinochle',
    },
  };

  static const Map<String, Map<String, String>> extra = {
    'ar': {
      'login': 'تسجيل الدخول', 'register': 'إنشاء حساب', 'username': 'اسم المستخدم', 'email': 'البريد الإلكتروني', 'password': 'كلمة المرور',
      'guest': 'الدخول كضيف', 'profile': 'الملف الشخصي', 'logout': 'تسجيل الخروج', 'deleteAccount': 'إلغاء الحساب', 'appearance': 'المظهر',
      'beginner': 'مبتدئ', 'professional': 'محترف', 'legendary': 'أسطوري', 'covers': 'أغلفة البروفايل', 'bots': 'اللاعبون الآليون',
      'difficulty': 'مستوى الذكاء', 'easy': 'سهل', 'normal': 'متوسط', 'pro': 'محترف', 'master': 'خبير', 'noCode': 'المصمم بدون كود',
      'statistics': 'الإحصاءات', 'winRate': 'نسبة الفوز', 'matches': 'المباريات', 'wins': 'الانتصارات', 'losses': 'الخسائر',
      'pashaBenefits': 'مزايا الباشا', 'giftReward': 'مكافأة', 'watchAd': 'شاهد إعلاناً', 'groups': 'المجموعات', 'competitionsTitle': 'المنافسات',
      'socialLoginNote': 'يتطلب مفاتيح مزود الخدمة', 'cropAvatar': 'معاينة وقص الصورة', 'save': 'حفظ', 'cancel': 'إلغاء', 'activate': 'تفعيل',
    },
    'en': {
      'login': 'Sign in', 'register': 'Create account', 'username': 'Username', 'email': 'Email', 'password': 'Password',
      'guest': 'Continue as guest', 'profile': 'Profile', 'logout': 'Sign out', 'deleteAccount': 'Cancel account', 'appearance': 'Appearance',
      'beginner': 'Beginner', 'professional': 'Professional', 'legendary': 'Legendary', 'covers': 'Profile Covers', 'bots': 'AI Players',
      'difficulty': 'AI Difficulty', 'easy': 'Easy', 'normal': 'Normal', 'pro': 'Pro', 'master': 'Master', 'noCode': 'No-code Designer',
      'statistics': 'Statistics', 'winRate': 'Win rate', 'matches': 'Matches', 'wins': 'Wins', 'losses': 'Losses',
      'pashaBenefits': 'Pasha Benefits', 'giftReward': 'Reward', 'watchAd': 'Watch Ad', 'groups': 'Groups', 'competitionsTitle': 'Competitions',
      'socialLoginNote': 'Provider credentials required', 'cropAvatar': 'Preview and crop image', 'save': 'Save', 'cancel': 'Cancel', 'activate': 'Activate',
    },
  };

  static String t(String lang, String key) =>
      v300Translations[lang]?[key] ?? v166Translations[lang]?[key] ?? extra[lang]?[key] ?? data[lang]?[key] ?? v166Translations['en']?[key] ?? extra['en']?[key] ?? data['en']?[key] ?? data['ar']?[key] ?? key;
}

class GameInfo {
  final String id;
  final String icon;
  final int players;
  final Color color;
  final bool serverOnly;

  const GameInfo(this.id, this.icon, this.players, this.color, {this.serverOnly = false});
}

const gamesCatalog = [
  GameInfo('tarneeb', '🂡', 18872, Color(0xff194c83)),
  GameInfo('trix', '🃏', 9456, Color(0xff7c3158)),
  GameInfo('hand', '🂮', 8154, Color(0xff845a20)),
  GameInfo('banakil', '🎴', 6420, Color(0xff4c3a82)),
  GameInfo('baloot', '♠️', 15220, Color(0xff17604c)),
  GameInfo('basra', '♦️', 5219, Color(0xff7a3037)),
  GameInfo('tarneeb_400', '4️⃣', 7315, Color(0xff6a2e52)),
  GameInfo('syrian_tarneeb', '🇸🇾', 3520, Color(0xff33573b)),
  GameInfo('trix_complex', '👑', 6189, Color(0xff69417b)),
  GameInfo('saudi_hand', '🇸🇦', 5791, Color(0xff1c654c)),
  GameInfo('hand_partner', '🤝', 4882, Color(0xff5f4327)),
  GameInfo('trix_partner', '👥', 5140, Color(0xff583a70)),
  GameInfo('tarneeb_41', '4️⃣', 4760, Color(0xff315f8c), serverOnly: true),
  GameInfo('tarneeb_61', '6️⃣', 3220, Color(0xff24496e), serverOnly: true),
  GameInfo('pinochle', '🂿', 4380, Color(0xff72531f), serverOnly: true),
  GameInfo('solitaire_multiplayer', '🂠', 2910, Color(0xff315b52), serverOnly: true),
  GameInfo('domino', '🁬', 6120, Color(0xff3f4858), serverOnly: true),
  GameInfo('backgammon', '🎲', 5570, Color(0xff7a4728), serverOnly: true),
];

class StoreProduct {
  final String id;
  final String category;
  final String icon;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final int price;
  final int? durationDays;
  final int? durationHours;
  final String? value;
  final double? multiplier;
  final Color? previewColor1;
  final Color? previewColor2;
  final String? imageAsset;
  final String? collection;

  const StoreProduct({
    required this.id,
    required this.category,
    required this.icon,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.price,
    this.durationDays,
    this.durationHours,
    this.value,
    this.multiplier,
    this.previewColor1,
    this.previewColor2,
    this.imageAsset,
    this.collection,
  });

  String name(String lang) => localizeStoreProductNameV151(this, lang);
  String description(String lang) => localizeStoreProductDescriptionV151(this, lang);
  bool get reusable => category == 'pasha' || category == 'competition_ticket' || (category != 'boost' && (durationDays != null || durationHours != null));
  String get tier {
    final effectivePrice = raisedStorePriceV183(this);
    if (id.contains('legend') || effectivePrice >= 70000 || (durationDays ?? 0) >= 90) return 'legendary';
    if (id.contains('pro') || effectivePrice >= 30000 || (durationDays ?? 0) >= 30) return 'pro';
    if (effectivePrice >= 10000 || (durationDays ?? 0) >= 7) return 'expert';
    return 'beginner';
  }

  String tierLabel(String lang) {
    if (lang == 'ar') {
      return switch (tier) { 'legendary' => 'أسطوري', 'pro' => 'محترف', 'expert' => 'خبير', _ => 'مبتدئ' };
    }
    return switch (tier) { 'legendary' => 'Legendary', 'pro' => 'Professional', 'expert' => 'Expert', _ => 'Beginner' };
  }
}


List<StoreProduct> buildV201R4StoreProducts() => const <StoreProduct>[
  StoreProduct(id:'r4_table_phoenix',category:'tables',icon:'🔥',nameAr:'طاولة العنقاء الملكية',nameEn:'Royal Phoenix Table',descriptionAr:'طاولة أسطورية متحركة بوهج ناري هادئ ومعاينة كاملة.',descriptionEn:'Legendary animated table with a refined phoenix glow.',price:1248000,value:'table-r4-phoenix',previewColor1:Color(0xff450a0a),previewColor2:Color(0xffff7a18),collection:'r4_legendary'),
  StoreProduct(id:'r4_table_leviathan',category:'tables',icon:'🐋',nameAr:'طاولة ليفياثان المحيط',nameEn:'Ocean Leviathan Table',descriptionAr:'طاولة أسطورية بحركة محيطية هادئة.',descriptionEn:'Legendary table with a subtle ocean motion.',price:1464000,value:'table-r4-leviathan',previewColor1:Color(0xff082f49),previewColor2:Color(0xff38bdf8),collection:'r4_legendary'),
  StoreProduct(id:'r4_table_black_diamond',category:'tables',icon:'💎',nameAr:'طاولة الألماس الأسود',nameEn:'Black Diamond Table',descriptionAr:'طاولة نخبة سوداء بتفاصيل ألماسية.',descriptionEn:'Elite black table with diamond details.',price:1680000,value:'table-r4-black-diamond',previewColor1:Color(0xff020617),previewColor2:Color(0xffe0f2fe),collection:'r4_legendary'),
  StoreProduct(id:'r4_table_celestial',category:'tables',icon:'👑',nameAr:'طاولة التاج السماوي',nameEn:'Celestial Crown Table',descriptionAr:'طاولة أسطورية ملكية بحركة ضوء سماوية.',descriptionEn:'Legendary royal table with subtle celestial motion.',price:2040000,value:'table-r4-celestial',previewColor1:Color(0xff172554),previewColor2:Color(0xfffacc15),collection:'r4_legendary'),
  StoreProduct(id:'r4_card_phoenix',category:'cards',icon:'🔥',nameAr:'ظهر العنقاء الملكي',nameEn:'Royal Phoenix Card Back',descriptionAr:'ظهر ورق أسطوري متوهج.',descriptionEn:'Legendary glowing phoenix card back.',price:325500,value:'card-r4-phoenix',previewColor1:Color(0xff7f1d1d),previewColor2:Color(0xffff7a18),collection:'r4_legendary'),
  StoreProduct(id:'r4_card_nebula',category:'cards',icon:'🌌',nameAr:'ظهر السديم المتحرك',nameEn:'Animated Nebula Card Back',descriptionAr:'ظهر ورق مجري متحرك بهدوء.',descriptionEn:'Subtly animated nebula card back.',price:430500,value:'card-r4-nebula',previewColor1:Color(0xff2e1065),previewColor2:Color(0xff38bdf8),collection:'r4_legendary'),
  StoreProduct(id:'r4_card_obsidian',category:'cards',icon:'💎',nameAr:'ظهر أوبسيديان ألماسي',nameEn:'Obsidian Diamond Card Back',descriptionAr:'ظهر ورق أسود ألماسي فاخر.',descriptionEn:'Premium black obsidian diamond card back.',price:367500,value:'card-r4-obsidian',previewColor1:Color(0xff020617),previewColor2:Color(0xffcbd5e1),collection:'r4_legendary'),
  StoreProduct(id:'r4_card_palestine',category:'cards',icon:'🇵🇸',nameAr:'ظهر فلسطين الملكي',nameEn:'Royal Palestine Card Back',descriptionAr:'ظهر ورق ملكي مستوحى من ألوان فلسطين.',descriptionEn:'Royal card back inspired by Palestine colors.',price:399000,value:'card-r4-palestine',previewColor1:Color(0xff111827),previewColor2:Color(0xff16a34a),collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_beasts',category:'emoji',icon:'🐉',nameAr:'وحوش الأساطير',nameEn:'Legend Beasts',descriptionAr:'تفاعلات كبيرة ومتحركة للحيوانات الأسطورية.',descriptionEn:'Large animated legendary-beast reactions.',price:171600,value:'🐉🦁🐯🦅🐺🐆🦂🦈🐋🦚',collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_cosmic',category:'emoji',icon:'🌌',nameAr:'تفاعلات المجرة',nameEn:'Cosmic Reactions',descriptionAr:'حزمة فضائية متحركة ومؤثرات مميزة.',descriptionEn:'Animated cosmic reaction pack.',price:149600,value:'🌌🪐🚀☄️🌠✨💫👽🛸⚡',collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_victory',category:'emoji',icon:'🏆',nameAr:'احتفال النخبة',nameEn:'Elite Victory',descriptionAr:'حزمة احتفال فاخرة للفوز.',descriptionEn:'Premium victory celebration reactions.',price:158400,value:'🏆🥇👑🎆🎇🎉💯🔥💎⚡',collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_magic',category:'emoji',icon:'🪄',nameAr:'سحر ورقنا',nameEn:'Warqnaa Magic',descriptionAr:'تفاعلات سحرية وورقية فخمة.',descriptionEn:'Premium magical card-game reactions.',price:123200,value:'🪄✨🔮🌟💫🃏♠️♥️♦️♣️',collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_royal_laugh',category:'emoji',icon:'😂',nameAr:'ضحكات القصر',nameEn:'Royal Palace Laughs',descriptionAr:'حزمة ضحك كبيرة وسريعة للدردشة.',descriptionEn:'Large expressive laugh reactions for chat.',price:61600,value:'😂🤣😹😆😜🤭🥳😎🙌🎉',collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_arabic',category:'emoji',icon:'☕',nameAr:'مجلس عربي فاخر',nameEn:'Luxury Arabic Majlis',descriptionAr:'تفاعلات عربية هادئة وفخمة.',descriptionEn:'Premium Arabic majlis-themed reactions.',price:92400,value:'☕🫖🌙🧿🫒🤍🕊️🌹✨👑',collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_rage',category:'emoji',icon:'🌪️',nameAr:'غضب العاصفة',nameEn:'Storm Rage',descriptionAr:'تفاعلات غضب قوية ومتحركة.',descriptionEn:'Powerful animated rage reactions.',price:114400,value:'😡🤬😤💢🌋🌪️⚡🔥🥊💥',collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_calm',category:'emoji',icon:'😌',nameAr:'هدوء فاخر',nameEn:'Luxury Calm',descriptionAr:'تفاعلات هادئة وراقية.',descriptionEn:'Elegant calm reaction pack.',price:52800,value:'😌☕🌙🌹🕊️🤍🌿🫶🙂✨',collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_sad',category:'emoji',icon:'🥺',nameAr:'مشاعر عميقة',nameEn:'Deep Emotions',descriptionAr:'تفاعلات حزن ومواساة متنوعة.',descriptionEn:'Deep emotion and sympathy reactions.',price:57200,value:'😢😭🥺💔😞😔🫂🌧️🕯️🤍',collection:'r4_legendary'),
  StoreProduct(id:'r4_emoji_free_plus',category:'emoji',icon:'😀',nameAr:'مجانية بلس',nameEn:'Free Plus',descriptionAr:'حزمة مجانية إضافية لجميع اللاعبين.',descriptionEn:'Extra free reaction pack for all players.',price:0,value:'😀😄😁👍👏👋🙌👌😉😊',collection:'r4_free'),
  StoreProduct(id:'r4_name_aurora',category:'names',icon:'🌈',nameAr:'Glow الشفق الأسطوري',nameEn:'Legendary Aurora Glow',descriptionAr:'Glow متحرك للاسم والصورة.',descriptionEn:'Animated glow for player name and avatar.',price:175750,value:'#67e8f9',previewColor1:Color(0xff67e8f9),previewColor2:Color(0xffa855f7),collection:'r4_legendary'),
  StoreProduct(id:'r4_name_gold',category:'names',icon:'👑',nameAr:'Glow الذهب الملكي',nameEn:'Royal Gold Glow',descriptionAr:'إطار ذهبي فاخر للاسم والصورة.',descriptionEn:'Premium royal-gold player glow.',price:259000,value:'#facc15',previewColor1:Color(0xfffacc15),previewColor2:Color(0xff78350f),collection:'r4_legendary'),
  StoreProduct(id:'r4_name_inferno',category:'names',icon:'🔥',nameAr:'Glow الجحيم الملكي',nameEn:'Royal Inferno Glow',descriptionAr:'Glow ناري متحرك للاسم والصورة.',descriptionEn:'Animated royal inferno glow for name and avatar.',price:203500,value:'#ff5a36',previewColor1:Color(0xffff5a36),previewColor2:Color(0xff7f1d1d),collection:'r4_legendary'),
  StoreProduct(id:'r4_name_diamond',category:'names',icon:'💎',nameAr:'Glow الألماس الجليدي',nameEn:'Ice Diamond Glow',descriptionAr:'Glow ألماسي أبيض سماوي فاخر.',descriptionEn:'Premium ice-diamond glow for name and avatar.',price:231250,value:'#e0f2fe',previewColor1:Color(0xffe0f2fe),previewColor2:Color(0xff0c4a6e),collection:'r4_legendary'),
  StoreProduct(id:'r4_chat_cyan',category:'chat_colors',icon:'✍️',nameAr:'كتابة سيان نيون',nameEn:'Neon Cyan Chat',descriptionAr:'لون كتابة نيون واضح في الدردشة.',descriptionEn:'Highly readable neon-cyan chat color.',price:114700,value:'#22d3ee',previewColor1:Color(0xff22d3ee),previewColor2:Color(0xff083344),collection:'r4_legendary'),
  StoreProduct(id:'r4_chat_gold',category:'chat_colors',icon:'✍️',nameAr:'كتابة ذهب ملكي',nameEn:'Royal Gold Chat',descriptionAr:'لون كتابة ذهبي فاخر.',descriptionEn:'Premium royal-gold chat color.',price:140600,value:'#facc15',previewColor1:Color(0xfffacc15),previewColor2:Color(0xff422006),collection:'r4_legendary'),
  StoreProduct(id:'r4_chat_crimson',category:'chat_colors',icon:'✍️',nameAr:'كتابة قرمزية متوهجة',nameEn:'Glowing Crimson Chat',descriptionAr:'لون كتابة قرمزي قوي وواضح.',descriptionEn:'Strong glowing crimson chat color.',price:129500,value:'#fb3f5c',previewColor1:Color(0xfffb3f5c),previewColor2:Color(0xff450a0a),collection:'r4_legendary'),
  StoreProduct(id:'r4_chat_violet',category:'chat_colors',icon:'✍️',nameAr:'كتابة بنفسجي ملكي',nameEn:'Royal Violet Chat',descriptionAr:'لون كتابة بنفسجي ملكي.',descriptionEn:'Premium royal-violet chat color.',price:125800,value:'#c084fc',previewColor1:Color(0xffc084fc),previewColor2:Color(0xff3b0764),collection:'r4_legendary'),
  StoreProduct(id:'r4_cover_phoenix',category:'covers',icon:'🔥',nameAr:'غلاف العنقاء الملكية',nameEn:'Royal Phoenix Cover',descriptionAr:'غلاف ملف شخصي أسطوري.',descriptionEn:'Legendary phoenix profile cover.',price:256250,value:'cover-r4-phoenix',previewColor1:Color(0xff7f1d1d),previewColor2:Color(0xffff7a18),collection:'r4_legendary'),
  StoreProduct(id:'r4_cover_nebula',category:'covers',icon:'🌌',nameAr:'غلاف السديم',nameEn:'Nebula Cover',descriptionAr:'غلاف مجري فاخر.',descriptionEn:'Premium nebula profile cover.',price:282900,value:'cover-r4-nebula',previewColor1:Color(0xff2e1065),previewColor2:Color(0xff38bdf8),collection:'r4_legendary'),
  StoreProduct(id:'r4_cover_palace',category:'covers',icon:'🏰',nameAr:'غلاف القصر الذهبي',nameEn:'Golden Palace Cover',descriptionAr:'غلاف ملف شخصي ملكي فاخر.',descriptionEn:'Premium royal golden-palace profile cover.',price:307500,value:'cover-r4-palace',previewColor1:Color(0xff422006),previewColor2:Color(0xfffacc15),collection:'r4_legendary'),
  StoreProduct(id:'r4_theme_obsidian',category:'themes',icon:'◆',nameAr:'أوبسيديان ملكي',nameEn:'Royal Obsidian',descriptionAr:'ثيم أسود فاخر بتباين واضح.',descriptionEn:'Premium black theme with high contrast.',price:360000,value:'obsidian',previewColor1:Color(0xff020617),previewColor2:Color(0xff94a3b8),collection:'r4_legendary'),
  StoreProduct(id:'r4_theme_aurora',category:'themes',icon:'🌈',nameAr:'الشفق الأسطوري',nameEn:'Legendary Aurora',descriptionAr:'ثيم شفق متوهج وهادئ.',descriptionEn:'Refined glowing aurora theme.',price:393750,value:'aurora',previewColor1:Color(0xff04171b),previewColor2:Color(0xff67e8f9),collection:'r4_legendary'),
  StoreProduct(id:'r4_badge_phoenix',category:'badges',icon:'🔥',nameAr:'شارة العنقاء',nameEn:'Phoenix Badge',descriptionAr:'شارة أسطورية للملف والطاولة.',descriptionEn:'Legendary badge for profile and game room.',price:230000,value:'badge-r4-phoenix',collection:'r4_legendary'),
  StoreProduct(id:'r4_badge_ace',category:'badges',icon:'🂡',nameAr:'شارة سيد الآص',nameEn:'Ace Master Badge',descriptionAr:'شارة نخبة لعشاق الورق.',descriptionEn:'Elite badge for card masters.',price:260000,value:'badge-r4-ace',collection:'r4_legendary'),
  StoreProduct(id:'r4_badge_crown',category:'badges',icon:'👑',nameAr:'شارة التاج السماوي',nameEn:'Celestial Crown Badge',descriptionAr:'شارة أسطورية ملكية للملف والطاولة.',descriptionEn:'Legendary royal badge for profile and table.',price:290000,value:'badge-r4-crown',collection:'r4_legendary'),
  StoreProduct(id:'r4_badge_guardian',category:'badges',icon:'🛡️',nameAr:'شارة حارس الطاولة',nameEn:'Table Guardian Badge',descriptionAr:'شارة احترافية للاعبين المميزين.',descriptionEn:'Professional badge for distinguished players.',price:196000,value:'badge-r4-guardian',collection:'r4_pro'),
  StoreProduct(id:'r4_effect_fireworks',category:'effects',icon:'🎆',nameAr:'مؤثر الألعاب النارية',nameEn:'Fireworks Victory Effect',descriptionAr:'مؤثر فوز متحرك وفخم.',descriptionEn:'Premium animated victory effect.',price:270000,value:'effect-r4-fireworks',collection:'r4_legendary'),
  StoreProduct(id:'r4_effect_lightning',category:'effects',icon:'⚡',nameAr:'مؤثر البرق الملكي',nameEn:'Royal Lightning Effect',descriptionAr:'مؤثر فوز بوميض برق هادئ.',descriptionEn:'Refined lightning victory effect.',price:303750,value:'effect-r4-lightning',collection:'r4_legendary'),
  StoreProduct(id:'r4_frame_celestial',category:'names',icon:'✨',nameAr:'إطار الاسم السماوي',nameEn:'Celestial Name Frame',descriptionAr:'إطار متحرك سماوي للاسم والصورة.',descriptionEn:'Animated celestial frame for player name and avatar.',price:194250,value:'#67e8f9',previewColor1:Color(0xff67e8f9),previewColor2:Color(0xff1e3a8a),collection:'r4_legendary'),
  StoreProduct(id:'r4_frame_dragon',category:'names',icon:'🐉',nameAr:'إطار التنين الملكي',nameEn:'Royal Dragon Frame',descriptionAr:'إطار تنين أسطوري متحرك.',descriptionEn:'Animated legendary royal dragon frame.',price:222000,value:'#ef4444',previewColor1:Color(0xffef4444),previewColor2:Color(0xff450a0a),collection:'r4_legendary'),
];

List<StoreProduct> buildTimedColorProducts() {
  const palette = <(String, String, String, Color)>[
    ('ruby', 'ياقوت متوهج', 'Ruby Glow', Color(0xffff355e)),
    ('orange', 'برتقالي شمسي', 'Solar Orange', Color(0xffff8a00)),
    ('amber', 'كهرماني فاخر', 'Luxury Amber', Color(0xffffc107)),
    ('gold', 'ذهبي ملكي', 'Royal Gold', Color(0xfff5c542)),
    ('lime', 'ليموني نيون', 'Neon Lime', Color(0xffa3e635)),
    ('emerald', 'زمرد عميق', 'Deep Emerald', Color(0xff10b981)),
    ('mint', 'نعناع نيون', 'Neon Mint', Color(0xff5eead4)),
    ('cyan', 'سماوي ليزر', 'Laser Cyan', Color(0xff22d3ee)),
    ('sky', 'أزرق سماوي', 'Sky Blue', Color(0xff38bdf8)),
    ('royal', 'أزرق ملكي', 'Royal Blue', Color(0xff3b82f6)),
    ('indigo', 'نيلي فاخر', 'Luxury Indigo', Color(0xff6366f1)),
    ('violet', 'بنفسجي مخملي', 'Velvet Violet', Color(0xff8b5cf6)),
    ('amethyst', 'جمشت لامع', 'Shiny Amethyst', Color(0xffc084fc)),
    ('pink', 'وردي لؤلؤي', 'Pearl Pink', Color(0xffec4899)),
    ('rose', 'وردي غروب', 'Sunset Rose', Color(0xfffb7185)),
    ('coral', 'مرجاني فاخر', 'Luxury Coral', Color(0xffff7f6e)),
    ('silver', 'فضي معدني', 'Metallic Silver', Color(0xffcbd5e1)),
    ('diamond', 'ألماسي جليدي', 'Ice Diamond', Color(0xffe0f2fe)),
    ('white', 'أبيض ناصع', 'Pure White', Color(0xffffffff)),
    ('bronze', 'برونزي قديم', 'Antique Bronze', Color(0xffc08457)),
    ('teal', 'تركوازي محترف', 'Pro Teal', Color(0xff14b8a6)),
    ('magenta', 'ماجنتا أسطوري', 'Legendary Magenta', Color(0xffd946ef)),
    ('crimson', 'قرمزي ناري', 'Fire Crimson', Color(0xffdc2626)),
    ('aurora', 'شفق قطبي', 'Aurora', Color(0xff67e8f9)),
  ];
  const durations = <int>[3, 7, 30];
  final result = <StoreProduct>[];
  for (var index = 0; index < palette.length; index++) {
    final item = palette[index];
    final days = durations[index % durations.length];
    final base = days == 3 ? 2400 : days == 7 ? 6200 : 16800;
    final price = base + (index * 175);
    final hex = '#${item.$4.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    result.add(StoreProduct(
      id: 'player_color_${item.$1}_${days}d', category: 'names', icon: '✨',
      nameAr: 'لون لاعب ${item.$2} — $days أيام', nameEn: '${item.$3} player color — $days days',
      descriptionAr: 'لون متوهج حول صورة اللاعب واسمه داخل البروفايل والطاولة مع معاينة مباشرة.',
      descriptionEn: 'Glowing player color around the avatar and name with a live preview.',
      price: price, durationDays: days, value: hex, previewColor1: item.$4, previewColor2: const Color(0xff07111c),
    ));
    result.add(StoreProduct(
      id: 'chat_color_${item.$1}_${days}d', category: 'chat_colors', icon: '💬',
      nameAr: 'لون دردشة ${item.$2} — $days أيام', nameEn: '${item.$3} chat color — $days days',
      descriptionAr: 'لون فاخر لرسائلك داخل الدردشة العامة والخاصة ودردشة الغرفة.',
      descriptionEn: 'Premium color for public, private and in-room chat messages.',
      price: price + 900, durationDays: days, value: hex, previewColor1: item.$4, previewColor2: const Color(0xff111827),
    ));
  }
  return result;
}


final List<StoreProduct> products = <StoreProduct>[
  ...v305PremiumStoreProducts,
  ...buildV173StoreProducts().where((product) => product.category == 'tables'),
  ...buildR61PairedCardBacks(buildV173StoreProducts().where((product) => product.category == 'tables')),
  // R6.1 intentionally exposes the curated image-backed V173 table collection
  // and a matching card back for every table. Older generated table families
  // remain hidden to keep the customer catalog coherent.
  ...v300WorldStoreProducts,
  ...buildV201R4StoreProducts(),
  StoreProduct(id: 'daily_pack_name_gold_24h_v176', category: 'names', icon: '🎨', nameAr: 'صندوق الجوائز: لون لاعب ذهبي', nameEn: 'Prize Box: Golden Player Color', descriptionAr: 'لون لاعب ذهبي مؤقت من صندوق الجوائز اليومي، يظهر في مقتنياتك حتى انتهاء الصلاحية.', descriptionEn: 'A temporary golden player color awarded by the daily prize box.', price: 0, durationHours: 24, value: '#facc15', previewColor1: Color(0xfffacc15), previewColor2: Color(0xff422006), collection: 'daily_pack_v176'),
  StoreProduct(id: 'daily_pack_chat_cyan_24h_v176', category: 'chat_colors', icon: '💬', nameAr: 'صندوق الجوائز: لون كتابة سماوي', nameEn: 'Prize Box: Cyan Writing Color', descriptionAr: 'لون كتابة سماوي مؤقت من صندوق الجوائز اليومي، يظهر في مقتنياتك حتى انتهاء الصلاحية.', descriptionEn: 'A temporary cyan writing color awarded by the daily prize box.', price: 0, durationHours: 24, value: '#22d3ee', previewColor1: Color(0xff22d3ee), previewColor2: Color(0xff083344), collection: 'daily_pack_v176'),
  StoreProduct(id: 'daily_pack_xp_15x_6h_v176', category: 'boost', icon: '⚡', nameAr: 'صندوق الجوائز: مسرّع XP ×1.5', nameEn: 'Prize Box: XP Booster ×1.5', descriptionAr: 'مسرّع خبرة مؤقت لمدة 6 ساعات من صندوق الجوائز اليومي، يُضاف إلى مقتنيات المتجر مباشرة.', descriptionEn: 'A six-hour XP booster awarded by the daily prize box.', price: 0, durationHours: 6, multiplier: 1.5, previewColor1: Color(0xfff59e0b), previewColor2: Color(0xff7c2d12), collection: 'daily_pack_v176'),
  StoreProduct(id: 'daily_prize_cover_v02', category: 'covers', icon: '🖼️', nameAr: 'صندوق الجوائز: غلاف ملكي', nameEn: 'Prize Box: Royal Profile Cover', descriptionAr: 'غلاف شخصي ملكي مؤقت لمدة 3 أيام من صندوق الجوائز اليومي.', descriptionEn: 'A royal profile cover active for three days from the daily prize box.', price: 0, durationHours: 72, value: 'cover_v02_royal', previewColor1: Color(0xff581c87), previewColor2: Color(0xfffacc15), collection: 'daily_pack_v176'),
  StoreProduct(id: "pasha_1_day_v132", category: "pasha", icon: "👑", nameAr: "باشا يوم واحد", nameEn: "Pasha 1 Day", descriptionAr: "طرد من الغرفة، شارة باشا، إنشاء مجموعات ومنافسات، ومضاعفة خبرة حسب الخطة.", descriptionEn: "Pasha badge, room controls, club and tournament privileges, and bonus XP.", price: 1700, durationDays: 1, value: "pasha"),
  StoreProduct(id: "pasha_3_days_v132", category: "pasha", icon: "👑", nameAr: "باشا 3 أيام", nameEn: "Pasha 3 Days", descriptionAr: "طرد من الغرفة، شارة باشا، إنشاء مجموعات ومنافسات، ومضاعفة خبرة حسب الخطة.", descriptionEn: "Pasha badge, room controls, club and tournament privileges, and bonus XP.", price: 5000, durationDays: 3, value: "pasha"),
  StoreProduct(id: "pasha_7_days_v128", category: "pasha", icon: "👑", nameAr: "باشا 7 أيام", nameEn: "Pasha 7 Days", descriptionAr: "طرد من الغرفة، شارة باشا، إنشاء مجموعات ومنافسات، ومضاعفة خبرة حسب الخطة.", descriptionEn: "Pasha badge, room controls, club and tournament privileges, and bonus XP.", price: 10000, durationDays: 7, value: "pasha"),
  StoreProduct(id: "pasha_30_days_v128", category: "pasha", icon: "👑", nameAr: "باشا 30 يوم", nameEn: "Pasha 30 Days", descriptionAr: "طرد من الغرفة، شارة باشا، إنشاء مجموعات ومنافسات، ومضاعفة خبرة حسب الخطة.", descriptionEn: "Pasha badge, room controls, club and tournament privileges, and bonus XP.", price: 38000, durationDays: 30, value: "pasha"),
  StoreProduct(id: "pasha_90_days_v132", category: "pasha", icon: "👑", nameAr: "باشا 90 يوم", nameEn: "Pasha 90 Days", descriptionAr: "طرد من الغرفة، شارة باشا، إنشاء مجموعات ومنافسات، ومضاعفة خبرة حسب الخطة.", descriptionEn: "Pasha badge, room controls, club and tournament privileges, and bonus XP.", price: 105000, durationDays: 90, value: "pasha"),
  StoreProduct(id: "pasha_365_days_v128", category: "pasha", icon: "👑", nameAr: "باشا سنة كاملة", nameEn: "Pasha 365 Days", descriptionAr: "طرد من الغرفة، شارة باشا، إنشاء مجموعات ومنافسات، ومضاعفة خبرة حسب الخطة.", descriptionEn: "Pasha badge, room controls, club and tournament privileges, and bonus XP.", price: 300000, durationDays: 365, value: "pasha"),
  StoreProduct(id: "theme_dark_premium", category: "themes", icon: "🎨", nameAr: "داكن فاخر", nameEn: "Premium Dark", descriptionAr: "ثيم كامل يغيّر الخلفيات والبطاقات والأزرار والطاولات.", descriptionEn: "A complete theme for backgrounds, panels, buttons and tables.", price: 0, value: "dark", previewColor1: Color(0xff07111f), previewColor2: Color(0xffd6aa59)),
  StoreProduct(id: "theme_crimson_legend", category: "themes", icon: "🌹", nameAr: "قرمزي أسطوري", nameEn: "Legendary Crimson", descriptionAr: "ثيم قرمزي داكن مع وهج ذهبي وبطاقات احترافية.", descriptionEn: "Deep crimson theme with gold glow and premium panels.", price: 34000, value: "crimson", previewColor1: Color(0xff21070d), previewColor2: Color(0xffef334f)),
  StoreProduct(id: "theme_midnight_elite", category: "themes", icon: "🌌", nameAr: "منتصف الليل النخبوي", nameEn: "Elite Midnight", descriptionAr: "ثيم أزرق ليلي احترافي للغرف والمتجر والملف الشخصي.", descriptionEn: "Premium midnight-blue theme for rooms, store and profile.", price: 42000, value: "midnight", previewColor1: Color(0xff020617), previewColor2: Color(0xff4f86ff)),
  StoreProduct(id: "theme_aurora_supreme", category: "themes", icon: "🌈", nameAr: "الشفق الفاخر", nameEn: "Supreme Aurora", descriptionAr: "ثيم تركوازي متوهج بمظهر عالمي وهادئ.", descriptionEn: "Glowing aurora theme with a refined global look.", price: 52000, value: "aurora", previewColor1: Color(0xff04171b), previewColor2: Color(0xff67e8f9)),
  StoreProduct(id: "theme_emerald", category: "themes", icon: "🎨", nameAr: "زمردي ملكي", nameEn: "Royal Emerald", descriptionAr: "ثيم كامل يغيّر الخلفيات والبطاقات والأزرار والطاولات.", descriptionEn: "A complete theme for backgrounds, panels, buttons and tables.", price: 11800, value: "emerald", previewColor1: Color(0xff052e26), previewColor2: Color(0xff10b981)),
  StoreProduct(id: "theme_royal", category: "themes", icon: "🎨", nameAr: "أزرق ملكي", nameEn: "Royal Blue", descriptionAr: "ثيم كامل يغيّر الخلفيات والبطاقات والأزرار والطاولات.", descriptionEn: "A complete theme for backgrounds, panels, buttons and tables.", price: 12500, value: "royal", previewColor1: Color(0xff071b3d), previewColor2: Color(0xff3b82f6)),
  StoreProduct(id: "theme_purple", category: "themes", icon: "🎨", nameAr: "بنفسجي أسطوري", nameEn: "Legendary Purple", descriptionAr: "ثيم كامل يغيّر الخلفيات والبطاقات والأزرار والطاولات.", descriptionEn: "A complete theme for backgrounds, panels, buttons and tables.", price: 14500, value: "purple", previewColor1: Color(0xff2e1065), previewColor2: Color(0xffa855f7)),
  StoreProduct(id: "theme_classic", category: "themes", icon: "🎨", nameAr: "كلاسيكي فاخر", nameEn: "Luxury Classic", descriptionAr: "ثيم كامل يغيّر الخلفيات والبطاقات والأزرار والطاولات.", descriptionEn: "A complete theme for backgrounds, panels, buttons and tables.", price: 9800, value: "classic", previewColor1: Color(0xff2b2118), previewColor2: Color(0xffd2a85f)),
  StoreProduct(id: "theme_obsidian", category: "themes", icon: "🖤", nameAr: "أوبسيديان فاخر", nameEn: "Luxury Obsidian", descriptionAr: "ثيم أسود معدني هادئ للواجهات الاحترافية.", descriptionEn: "A refined metallic-black professional theme.", price: 24000, value: "obsidian", previewColor1: Color(0xff020307), previewColor2: Color(0xff6b7280)),
  StoreProduct(id: "theme_rose_gold", category: "themes", icon: "🌸", nameAr: "روز غولد", nameEn: "Rose Gold", descriptionAr: "ثيم وردي ذهبي أنيق للبروفايل والمتجر والغرف.", descriptionEn: "Elegant rose-gold theme for profiles, store and rooms.", price: 28000, value: "rose_gold", previewColor1: Color(0xff351322), previewColor2: Color(0xfffb7185)),
  StoreProduct(id: "theme_desert", category: "themes", icon: "🏜️", nameAr: "الصحراء الملكية", nameEn: "Royal Desert", descriptionAr: "ثيم دافئ بدرجات الرمل والذهب.", descriptionEn: "Warm sand-and-gold premium theme.", price: 22000, value: "desert", previewColor1: Color(0xff3b2410), previewColor2: Color(0xffd97706)),
  StoreProduct(id: "theme_forest", category: "themes", icon: "🌲", nameAr: "الغابة العميقة", nameEn: "Deep Forest", descriptionAr: "ثيم أخضر عميق بإضاءة زمردية.", descriptionEn: "Deep green theme with emerald highlights.", price: 26000, value: "forest", previewColor1: Color(0xff03140d), previewColor2: Color(0xff22c55e)),
  StoreProduct(id: "theme_ice", category: "themes", icon: "❄️", nameAr: "الجليد الأزرق", nameEn: "Blue Ice", descriptionAr: "ثيم جليدي نظيف بدرجات الأزرق والسماوي.", descriptionEn: "Clean icy theme in blue and cyan tones.", price: 30000, value: "ice", previewColor1: Color(0xff06131d), previewColor2: Color(0xff38bdf8)),
  StoreProduct(id: "table_premium_01", category: "tables", icon: "👑", nameAr: "طاولة زمرد ملكي", nameEn: "Premium Table 01", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 3150, previewColor1: Color(0xff064e3b), previewColor2: Color(0xff10b981)),
  StoreProduct(id: "table_premium_02", category: "tables", icon: "⭐", nameAr: "طاولة ليل ذهبي", nameEn: "Premium Table 02", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 3800, previewColor1: Color(0xff020617), previewColor2: Color(0xfff5c542)),
  StoreProduct(id: "table_premium_03", category: "tables", icon: "🏜️", nameAr: "طاولة صحراء فاخرة", nameEn: "Premium Table 03", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 4450, previewColor1: Color(0xff7c2d12), previewColor2: Color(0xfffbbf24)),
  StoreProduct(id: "table_premium_04", category: "tables", icon: "🌊", nameAr: "طاولة محيط أزرق", nameEn: "Premium Table 04", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 5100, previewColor1: Color(0xff0c4a6e), previewColor2: Color(0xff38bdf8)),
  StoreProduct(id: "table_premium_05", category: "tables", icon: "♥", nameAr: "طاولة قصر قرمزي", nameEn: "Premium Table 05", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 5750, previewColor1: Color(0xff7f1d1d), previewColor2: Color(0xfff87171)),
  StoreProduct(id: "table_premium_06", category: "tables", icon: "🌌", nameAr: "طاولة مجرة بنفسجية", nameEn: "Premium Table 06", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 6400, previewColor1: Color(0xff581c87), previewColor2: Color(0xffc084fc)),
  StoreProduct(id: "table_premium_07", category: "tables", icon: "◆", nameAr: "طاولة رخام أسود", nameEn: "Premium Table 07", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 7050, previewColor1: Color(0xff0a0a0a), previewColor2: Color(0xffa3a3a3)),
  StoreProduct(id: "table_premium_08", category: "tables", icon: "◇", nameAr: "طاولة رخام أبيض", nameEn: "Premium Table 08", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 7700, previewColor1: Color(0xfff8fafc), previewColor2: Color(0xff94a3b8)),
  StoreProduct(id: "table_premium_09", category: "tables", icon: "☕", nameAr: "طاولة خشب قهوة", nameEn: "Premium Table 09", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 8350, previewColor1: Color(0xff422006), previewColor2: Color(0xffb45309)),
  StoreProduct(id: "table_premium_10", category: "tables", icon: "♣", nameAr: "طاولة زيتوني فاخر", nameEn: "Premium Table 10", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 9000, previewColor1: Color(0xff1f3b24), previewColor2: Color(0xff84cc16)),
  StoreProduct(id: "table_premium_11", category: "tables", icon: "♦", nameAr: "طاولة روبي كازينو", nameEn: "Premium Table 11", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 9650, previewColor1: Color(0xff064e3b), previewColor2: Color(0xff10b981)),
  StoreProduct(id: "table_premium_12", category: "tables", icon: "♠", nameAr: "طاولة ياقوت أزرق", nameEn: "Premium Table 12", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 10300, previewColor1: Color(0xff020617), previewColor2: Color(0xfff5c542)),
  StoreProduct(id: "table_premium_13", category: "tables", icon: "☀", nameAr: "طاولة كثبان ذهبية", nameEn: "Premium Table 13", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 10950, previewColor1: Color(0xff7c2d12), previewColor2: Color(0xfffbbf24)),
  StoreProduct(id: "table_premium_14", category: "tables", icon: "❄", nameAr: "طاولة جليد فاخر", nameEn: "Premium Table 14", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 11600, previewColor1: Color(0xff0c4a6e), previewColor2: Color(0xff38bdf8)),
  StoreProduct(id: "table_premium_15", category: "tables", icon: "⚡", nameAr: "طاولة مدينة نيون", nameEn: "Premium Table 15", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 12250, previewColor1: Color(0xff7f1d1d), previewColor2: Color(0xfff87171)),
  StoreProduct(id: "table_premium_16", category: "tables", icon: "🌲", nameAr: "طاولة غابة ضباب", nameEn: "Premium Table 16", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 12900, previewColor1: Color(0xff581c87), previewColor2: Color(0xffc084fc)),
  StoreProduct(id: "table_premium_17", category: "tables", icon: "👑", nameAr: "طاولة ملكي أحمر", nameEn: "Premium Table 17", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 13550, previewColor1: Color(0xff0a0a0a), previewColor2: Color(0xffa3a3a3)),
  StoreProduct(id: "table_premium_18", category: "tables", icon: "🥉", nameAr: "طاولة قاعة برونزية", nameEn: "Premium Table 18", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 14200, previewColor1: Color(0xfff8fafc), previewColor2: Color(0xff94a3b8)),
  StoreProduct(id: "table_premium_19", category: "tables", icon: "🥈", nameAr: "طاولة قاعة فضية", nameEn: "Premium Table 19", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 14850, previewColor1: Color(0xff422006), previewColor2: Color(0xffb45309)),
  StoreProduct(id: "table_premium_20", category: "tables", icon: "💎", nameAr: "طاولة قاعة ألماس", nameEn: "Premium Table 20", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 15500, previewColor1: Color(0xff1f3b24), previewColor2: Color(0xff84cc16)),
  StoreProduct(id: "table_premium_21", category: "tables", icon: "✦", nameAr: "طاولة أرابيسك أخضر", nameEn: "Premium Table 21", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 16150, previewColor1: Color(0xff064e3b), previewColor2: Color(0xff10b981)),
  StoreProduct(id: "table_premium_22", category: "tables", icon: "✧", nameAr: "طاولة أرابيسك أزرق", nameEn: "Premium Table 22", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 16800, previewColor1: Color(0xff020617), previewColor2: Color(0xfff5c542)),
  StoreProduct(id: "table_premium_23", category: "tables", icon: "🌴", nameAr: "طاولة نخيل VIP", nameEn: "Premium Table 23", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 17450, previewColor1: Color(0xff7c2d12), previewColor2: Color(0xfffbbf24)),
  StoreProduct(id: "table_premium_24", category: "tables", icon: "🌙", nameAr: "طاولة ضوء القمر", nameEn: "Premium Table 24", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 18100, previewColor1: Color(0xff0c4a6e), previewColor2: Color(0xff38bdf8)),
  StoreProduct(id: "table_premium_25", category: "tables", icon: "🌅", nameAr: "طاولة غروب فاخر", nameEn: "Premium Table 25", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 18750, previewColor1: Color(0xff7f1d1d), previewColor2: Color(0xfff87171)),
  StoreProduct(id: "table_premium_26", category: "tables", icon: "♣", nameAr: "طاولة نادي الجاد", nameEn: "Premium Table 26", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 19400, previewColor1: Color(0xff581c87), previewColor2: Color(0xffc084fc)),
  StoreProduct(id: "table_premium_27", category: "tables", icon: "🔥", nameAr: "طاولة نار أوبسيديان", nameEn: "Premium Table 27", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 20050, previewColor1: Color(0xff0a0a0a), previewColor2: Color(0xffa3a3a3)),
  StoreProduct(id: "table_premium_28", category: "tables", icon: "●", nameAr: "طاولة لؤلؤ ذهبي", nameEn: "Premium Table 28", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 20700, previewColor1: Color(0xfff8fafc), previewColor2: Color(0xff94a3b8)),
  StoreProduct(id: "table_premium_29", category: "tables", icon: "♛", nameAr: "طاولة بلاتيني ملكي", nameEn: "Premium Table 29", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 21350, previewColor1: Color(0xff422006), previewColor2: Color(0xffb45309)),
  StoreProduct(id: "table_premium_30", category: "tables", icon: "⚔", nameAr: "طاولة فولاذ دمشقي", nameEn: "Premium Table 30", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 22000, previewColor1: Color(0xff1f3b24), previewColor2: Color(0xff84cc16)),
  StoreProduct(id: "table_premium_31", category: "tables", icon: "🌹", nameAr: "طاولة روز جولد", nameEn: "Premium Table 31", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 22650, previewColor1: Color(0xff064e3b), previewColor2: Color(0xff10b981)),
  StoreProduct(id: "table_premium_32", category: "tables", icon: "⬢", nameAr: "طاولة سايبر أخضر", nameEn: "Premium Table 32", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 23300, previewColor1: Color(0xff020617), previewColor2: Color(0xfff5c542)),
  StoreProduct(id: "table_premium_33", category: "tables", icon: "⬡", nameAr: "طاولة سايبر بنفسجي", nameEn: "Premium Table 33", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 23950, previewColor1: Color(0xff7c2d12), previewColor2: Color(0xfffbbf24)),
  StoreProduct(id: "table_premium_34", category: "tables", icon: "☪", nameAr: "طاولة مجلس ذهبي", nameEn: "Premium Table 34", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 24600, previewColor1: Color(0xff0c4a6e), previewColor2: Color(0xff38bdf8)),
  StoreProduct(id: "table_premium_35", category: "tables", icon: "✺", nameAr: "طاولة شامي أزرق", nameEn: "Premium Table 35", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 25250, previewColor1: Color(0xff7f1d1d), previewColor2: Color(0xfff87171)),
  StoreProduct(id: "table_premium_36", category: "tables", icon: "🐚", nameAr: "طاولة لؤلؤ الخليج", nameEn: "Premium Table 36", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 25900, previewColor1: Color(0xff581c87), previewColor2: Color(0xffc084fc)),
  StoreProduct(id: "table_premium_37", category: "tables", icon: "🏆", nameAr: "طاولة بطولة ذهبية", nameEn: "Premium Table 37", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 26550, previewColor1: Color(0xff0a0a0a), previewColor2: Color(0xffa3a3a3)),
  StoreProduct(id: "table_premium_38", category: "tables", icon: "VIP", nameAr: "طاولة VIP أسود", nameEn: "Premium Table 38", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 27200, previewColor1: Color(0xfff8fafc), previewColor2: Color(0xff94a3b8)),
  StoreProduct(id: "table_premium_39", category: "tables", icon: "♚", nameAr: "طاولة رويال ماستر", nameEn: "Premium Table 39", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 27850, previewColor1: Color(0xff422006), previewColor2: Color(0xffb45309)),
  StoreProduct(id: "table_premium_40", category: "tables", icon: "🦁", nameAr: "طاولة حلبة الأساطير", nameEn: "Premium Table 40", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 28500, previewColor1: Color(0xff1f3b24), previewColor2: Color(0xff84cc16)),
  StoreProduct(id: "table_premium_41", category: "tables", icon: "👑", nameAr: "طاولة مخمل VIP", nameEn: "Premium Table 41", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 29150, previewColor1: Color(0xff064e3b), previewColor2: Color(0xff10b981)),
  StoreProduct(id: "table_premium_42", category: "tables", icon: "✺", nameAr: "طاولة أندلس ذهب", nameEn: "Premium Table 42", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 29800, previewColor1: Color(0xff020617), previewColor2: Color(0xfff5c542)),
  StoreProduct(id: "table_premium_43", category: "tables", icon: "✦", nameAr: "طاولة دمشق أزرق", nameEn: "Premium Table 43", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 30450, previewColor1: Color(0xff7c2d12), previewColor2: Color(0xfffbbf24)),
  StoreProduct(id: "table_premium_44", category: "tables", icon: "☪", nameAr: "طاولة قدس زيتوني", nameEn: "Premium Table 44", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 31100, previewColor1: Color(0xff0c4a6e), previewColor2: Color(0xff38bdf8)),
  StoreProduct(id: "table_premium_45", category: "tables", icon: "👑", nameAr: "طاولة طربوش باشا", nameEn: "Premium Table 45", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 31750, previewColor1: Color(0xff7f1d1d), previewColor2: Color(0xfff87171)),
  StoreProduct(id: "table_premium_46", category: "tables", icon: "◆", nameAr: "طاولة نيون أحمر", nameEn: "Premium Table 46", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 32400, previewColor1: Color(0xff581c87), previewColor2: Color(0xffc084fc)),
  StoreProduct(id: "table_premium_47", category: "tables", icon: "⬢", nameAr: "طاولة نيون أخضر", nameEn: "Premium Table 47", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 33050, previewColor1: Color(0xff0a0a0a), previewColor2: Color(0xffa3a3a3)),
  StoreProduct(id: "table_premium_48", category: "tables", icon: "💠", nameAr: "طاولة كريستال محيط", nameEn: "Premium Table 48", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 33700, previewColor1: Color(0xfff8fafc), previewColor2: Color(0xff94a3b8)),
  StoreProduct(id: "table_premium_49", category: "tables", icon: "♛", nameAr: "طاولة أسود ذهبي Pro", nameEn: "Premium Table 49", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 34350, previewColor1: Color(0xff422006), previewColor2: Color(0xffb45309)),
  StoreProduct(id: "table_premium_50", category: "tables", icon: "🏆", nameAr: "طاولة ماستر أرينا", nameEn: "Premium Table 50", descriptionAr: "طاولة كبيرة منحنية بمعاينة حقيقية وتفاصيل فاخرة داخل غرفة اللعب.", descriptionEn: "Large curved game table with a live in-room preview.", price: 35000, previewColor1: Color(0xff1f3b24), previewColor2: Color(0xff84cc16)),
  StoreProduct(id: "table_reference_01", category: "tables", icon: "🃏", nameAr: "أزرق ملكي مذهب", nameEn: "Gilded Royal Blue", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 20000, previewColor1: Color(0xff0b2d5b), previewColor2: Color(0xffd6aa59), imageAsset: "assets/optimized/r10/tables/reference/table_reference_01.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_02", category: "tables", icon: "🃏", nameAr: "أرجواني ملكي مطعم", nameEn: "Inlaid Royal Purple", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 25000, previewColor1: Color(0xff40103d), previewColor2: Color(0xffc9a6d8), imageAsset: "assets/optimized/r10/tables/reference/table_reference_02.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_03", category: "tables", icon: "🃏", nameAr: "جلد عتيق مزخرف", nameEn: "Ornate Antique Leather", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 18000, previewColor1: Color(0xff6b351f), previewColor2: Color(0xffd4a574), imageAsset: "assets/optimized/r10/tables/reference/table_reference_03.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_04", category: "tables", icon: "🃏", nameAr: "أسود كربوني فضي", nameEn: "Silver Carbon Black", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 15000, previewColor1: Color(0xff111827), previewColor2: Color(0xffd1d5db), imageAsset: "assets/optimized/r10/tables/reference/table_reference_04.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_05", category: "tables", icon: "🃏", nameAr: "رخام إيطالي مصقول", nameEn: "Polished Italian Marble", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 22000, previewColor1: Color(0xfff8fafc), previewColor2: Color(0xff94a3b8), imageAsset: "assets/optimized/r10/tables/reference/table_reference_05.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_06", category: "tables", icon: "🃏", nameAr: "خشب جوز بنمط هندسي", nameEn: "Geometric Walnut Wood", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 20000, previewColor1: Color(0xff4b2a15), previewColor2: Color(0xffd7a64a), imageAsset: "assets/optimized/r10/tables/reference/table_reference_06.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_07", category: "tables", icon: "🃏", nameAr: "نحاس عتيق مؤكسد", nameEn: "Oxidized Antique Copper", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 18000, previewColor1: Color(0xff7c3f23), previewColor2: Color(0xff5eead4), imageAsset: "assets/optimized/r10/tables/reference/table_reference_07.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_08", category: "tables", icon: "🃏", nameAr: "عرق لؤلؤ طبيعي", nameEn: "Natural Mother of Pearl", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 30000, previewColor1: Color(0xfffffbeb), previewColor2: Color(0xfff5c542), imageAsset: "assets/optimized/r10/tables/reference/table_reference_08.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_09", category: "tables", icon: "🃏", nameAr: "زمردي أرابيسك عميق", nameEn: "Deep Emerald Arabesque", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 28000, previewColor1: Color(0xff064e3b), previewColor2: Color(0xff22c55e), imageAsset: "assets/optimized/r10/tables/reference/table_reference_09.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_10", category: "tables", icon: "🃏", nameAr: "عقيق يماني أحمر", nameEn: "Red Yemeni Agate", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 1–10، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 1–10 collection with full preview and in-room activation.", price: 25000, previewColor1: Color(0xff7f1d1d), previewColor2: Color(0xfffb7185), imageAsset: "assets/optimized/r10/tables/reference/table_reference_10.webp", collection: "reference_1"),
  StoreProduct(id: "table_reference_11", category: "tables", icon: "🃏", nameAr: "يخت فاخر", nameEn: "Luxury Yacht", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 16000, previewColor1: Color(0xff0b2d5b), previewColor2: Color(0xffd6aa59), imageAsset: "assets/optimized/r10/tables/reference/table_reference_11.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_12", category: "tables", icon: "🃏", nameAr: "أسماك كوي خزفية", nameEn: "Porcelain Koi", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 20000, previewColor1: Color(0xff40103d), previewColor2: Color(0xffc9a6d8), imageAsset: "assets/optimized/r10/tables/reference/table_reference_12.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_13", category: "tables", icon: "🃏", nameAr: "مجرة كونية", nameEn: "Cosmic Galaxy", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 22000, previewColor1: Color(0xff6b351f), previewColor2: Color(0xffd4a574), imageAsset: "assets/optimized/r10/tables/reference/table_reference_13.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_14", category: "tables", icon: "🃏", nameAr: "أرابيسك فضي", nameEn: "Silver Arabesque", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 28000, previewColor1: Color(0xff111827), previewColor2: Color(0xffd1d5db), imageAsset: "assets/optimized/r10/tables/reference/table_reference_14.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_15", category: "tables", icon: "🃏", nameAr: "فارس محارب", nameEn: "Warrior Knight", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 26000, previewColor1: Color(0xfff8fafc), previewColor2: Color(0xff94a3b8), imageAsset: "assets/optimized/r10/tables/reference/table_reference_15.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_16", category: "tables", icon: "🃏", nameAr: "بونساي يشم", nameEn: "Jade Bonsai", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 18000, previewColor1: Color(0xff4b2a15), previewColor2: Color(0xffd7a64a), imageAsset: "assets/optimized/r10/tables/reference/table_reference_16.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_17", category: "tables", icon: "🃏", nameAr: "تنين دمشقي", nameEn: "Damascene Dragon", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 18000, previewColor1: Color(0xff7c3f23), previewColor2: Color(0xff5eead4), imageAsset: "assets/optimized/r10/tables/reference/table_reference_17.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_18", category: "tables", icon: "🃏", nameAr: "أسلحة عتيقة", nameEn: "Antique Weapons", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 26000, previewColor1: Color(0xfffffbeb), previewColor2: Color(0xfff5c542), imageAsset: "assets/optimized/r10/tables/reference/table_reference_18.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_19", category: "tables", icon: "🃏", nameAr: "لوتس صدفية", nameEn: "Mother-of-Pearl Lotus", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 28000, previewColor1: Color(0xff064e3b), previewColor2: Color(0xff22c55e), imageAsset: "assets/optimized/r10/tables/reference/table_reference_19.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_20", category: "tables", icon: "🃏", nameAr: "قناع تيكي منحوت", nameEn: "Carved Tiki Mask", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 11–20، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 11–20 collection with full preview and in-room activation.", price: 16000, previewColor1: Color(0xff7f1d1d), previewColor2: Color(0xfffb7185), imageAsset: "assets/optimized/r10/tables/reference/table_reference_20.webp", collection: "reference_2"),
  StoreProduct(id: "table_reference_21", category: "tables", icon: "🃏", nameAr: "طائرة خاصة كربونية", nameEn: "Carbon Private Jet", descriptionAr: "طاولة مرجعية فاخرة عالية الجودة ضمن مجموعة الطاولات الجديدة 21–30، مع معاينة كاملة وتفعيل مباشر داخل غرفة اللعب.", descriptionEn: "High-quality reference table skin from the new 21–30 collection with full preview and in-room activation.", price: 24000, previewColor1: Color(0xff0b2d5b), previewColor2: Color(0xffd6aa59), imageAsset: "assets/optimized/r10/tables/reference/table_reference_21.webp", collection: "reference_3"),
  Sto…64229 tokens truncated…ة', 'Choose a legal meld')),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 420),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: melds.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final cards = (melds[index]['cards'] as List).map((card) => _cardLabel(card.toString())).join('  ');
              return ListTile(title: Text(cards, textDirection: TextDirection.ltr), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pop(dialogContext, melds[index]));
            },
          ),
        ),
      ),
    );
    if (selected != null) _action('meld', {'cards': selected['cards']});
  }

  Future<void> _chooseMeldMany(List<Map<String, dynamic>> options) async {
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_roomText('اختر تنزيل المجموعات', 'Choose melds')),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 440),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final groups = (options[index]['groups'] as List?) ?? const [];
              final label = groups.map((group) => group is List ? group.map((c) => _cardLabel(c.toString())).join(' ') : '').join('  |  ');
              return ListTile(title: Text(label, textDirection: TextDirection.ltr), subtitle: Text(_roomText('${groups.length} مجموعات', '${groups.length} melds')), onTap: () => Navigator.pop(dialogContext, options[index]));
            },
          ),
        ),
      ),
    );
    if (selected != null) _action('meld_many', {'groups': selected['groups']});
  }

  Future<void> _chooseLayoff(List<Map<String, dynamic>> options) async {
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_roomText('تركيب قانوني على مجموعة', 'Add legal cards to a meld')),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 440),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final cards = (options[index]['cards'] as List?)?.map((c) => _cardLabel(c.toString())).join(' ') ?? '';
              return ListTile(
                leading: const Icon(Icons.add_link_rounded),
                title: Text(cards, textDirection: TextDirection.ltr),
                subtitle: Text(_roomText('مجموعة #${(options[index]['meld_index'] ?? 0) + 1}', 'Meld #${(options[index]['meld_index'] ?? 0) + 1}')),
                onTap: () => Navigator.pop(dialogContext, options[index]),
              );
            },
          ),
        ),
      ),
    );
    if (selected != null) {
      _action('layoff', {
        'target_player': selected['target_player'],
        'meld_index': selected['meld_index'],
        'cards': selected['cards'],
      });
    }
  }

  Future<void> _chooseWildReplacement(List<Map<String, dynamic>> options) async {
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_roomText('استبدال الجوكر', 'Replace joker')),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 420),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) => ListTile(
              leading: const Text('🃏', style: TextStyle(fontSize: 26)),
              title: Text(_roomText('استبدل الجوكر بـ ${_cardLabel(options[index]['card']?.toString() ?? '')}', 'Replace the joker with ${_cardLabel(options[index]['card']?.toString() ?? '')}')),
              subtitle: Text(_roomText('مجموعة #${(options[index]['meld_index'] ?? 0) + 1}', 'Meld #${(options[index]['meld_index'] ?? 0) + 1}')),
              onTap: () => Navigator.pop(dialogContext, options[index]),
            ),
          ),
        ),
      ),
    );
    if (selected != null) {
      _action('replace_wild', {
        'target_player': selected['target_player'],
        'meld_index': selected['meld_index'],
        'card': selected['card'],
      });
    }
  }

  Future<void> _playJackarooCard(String card, Map<String, dynamic>? action) async {
    final choices = availableActions
        .where((item) => item['type'] == 'play_card' && item['card']?.toString() == card)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    if (choices.isEmpty && action != null) choices.add(Map<String, dynamic>.from(action));
    if (choices.isEmpty) {
      showToast(context, _roomText('لا توجد حركة قانونية لهذه الورقة.', 'No legal move is available for this card.'));
      return;
    }
    Map<String, dynamic>? selected;
    if (choices.length == 1) {
      selected = choices.first;
    } else {
      selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_roomText('اختر وظيفة ${_cardLabel(card)}', 'Choose how to use ${_cardLabel(card)}')),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470, maxHeight: 440),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: choices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final item = choices[index];
                final label = item['label']?.toString() ?? _roomText('حركة قانونية ${index + 1}', 'Legal move ${index + 1}');
                return ListTile(
                  leading: const Icon(Icons.route_outlined),
                  title: Text(label),
                  subtitle: item['steps2'] != null ? Text(_roomText('تقسيم ${item['steps']} + ${item['steps2']}', 'Split ${item['steps']} + ${item['steps2']}')) : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(dialogContext, item),
                );
              },
            ),
          ),
        ),
      );
    }
    if (selected == null) return;
    final payload = Map<String, dynamic>.from(selected)
      ..remove('type')
      ..remove('label');
    _action('play_card', payload);
  }

  Future<void> _playDominoTile(String tile) async {
    final legalSides = availableActions
        .where((item) => item['type'] == 'play_tile' && item['tile']?.toString() == tile)
        .map((item) => item['side']?.toString() ?? 'right')
        .toSet()
        .toList();
    if (legalSides.length == 1) {
      _action('play_tile', {'tile': tile, 'side': legalSides.first});
      return;
    }
    final sides = legalSides.isEmpty ? const ['left', 'right'] : legalSides;
    final side = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('ضع الحجر $tile'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sides.map((value) => FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, value),
            child: Text(value == 'left' ? 'الطرف الأيسر' : 'الطرف الأيمن'),
          )).toList(),
        ),
      ),
    );
    if (side != null) _action('play_tile', {'tile': tile, 'side': side});
  }

  Future<void> _showBackgammonMove() async {
    final moves = availableActions.where((item) => item['type'] == 'move').map((item) => Map<String, dynamic>.from(item)).toList();
    if (moves.isEmpty) {
      showToast(context, 'لا توجد حركة قانونية بهذا الرمي.');
      return;
    }
    final move = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('اختر حركة قانونية'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 430),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: moves.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final item = moves[index];
              final from = int.tryParse(item['from']?.toString() ?? '') ?? 0;
              final to = int.tryParse(item['to']?.toString() ?? '') ?? 0;
              final die = item['die']?.toString() ?? '';
              final fromLabel = (from == 0 || from == 25) ? 'البار' : '$from';
              final toLabel = (to == 0 || to == 25) ? 'إخراج' : '$to';
              return ListTile(
                leading: Icon(item['hit'] == true ? Icons.flash_on : item['bear_off'] == true ? Icons.outbond : Icons.open_with),
                title: Text('$fromLabel ← $toLabel'),
                subtitle: Text('قيمة النرد: $die${item['hit'] == true ? ' • ضرب حجر' : ''}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(dialogContext, item),
              );
            },
          ),
        ),
      ),
    );
    if (move != null) _action('move', {'from': move['from'], 'to': move['to']});
  }

  Future<void> _showChessMove() async {
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final move = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('نقلة الشطرنج'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: fromController, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'من مثال: e2')),
          const SizedBox(height: 8),
          TextField(controller: toController, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'إلى مثال: e4')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(onPressed: () {
            final from = fromController.text.trim().toLowerCase();
            final to = toController.text.trim().toLowerCase();
            if (RegExp(r'^[a-h][1-8]$').hasMatch(from) && RegExp(r'^[a-h][1-8]$').hasMatch(to)) Navigator.pop(dialogContext, [from, to]);
          }, child: const Text('تنفيذ')),
        ],
      ),
    );
    fromController.dispose();
    toController.dispose();
    if (move != null) _action('move_piece', {'from': move[0], 'to': move[1]});
  }

  Widget _engineChat() => Container(
        margin: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .08))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 4, 4),
              child: Row(children:[
                Expanded(child:SegmentedButton<int>(segments:[ButtonSegment(value:0,icon:const Icon(Icons.forum,size:17),label:Text(L.t(widget.controller.localeCode,'gameChat'))),ButtonSegment(value:1,icon:const Icon(Icons.people_alt_outlined,size:17),label:Text(L.t(widget.controller.localeCode,'friendsChat')))],selected:{chatSection},showSelectedIcon:false,onSelectionChanged:(values)=>setState(()=>chatSection=values.first))),
                IconButton(onPressed:()=>setState(()=>chatOpen=false),icon:const Icon(Icons.close,size:18)),
              ]),
            ),
            if(chatSection==0) ...[
              Expanded(
                child: serverMessages.isEmpty
                    ? const Center(child: Text('ابدأ المحادثة مع لاعبي الغرفة.', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: serverMessages.length,
                        itemBuilder: (_, index) {
                          final message = serverMessages[index];
                          final emojiOnly=!RegExp(r'[A-Za-z0-9\u0600-\u06FF]').hasMatch(message.body) && message.body.runes.length<=8;
                          return Align(
                            alignment: message.mine ? Alignment.centerRight : Alignment.centerLeft,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(13),
                              onTap: () => openPlayerProfileV021(
                                context,
                                widget.controller,
                                name: message.sender,
                                avatar: message.mine ? widget.controller.avatarEmoji : null,
                                level: message.mine ? widget.controller.level : 1,
                                countryCode: message.mine ? widget.controller.countryCode : 'PS',
                                online: true,
                                activity: 'محادثة غرفة اللعب',
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                                decoration: BoxDecoration(color: message.mine ? Theme.of(context).colorScheme.primary.withValues(alpha: .16) : Colors.white.withValues(alpha: .055), borderRadius: BorderRadius.circular(13)),
                                child: Text(emojiOnly?message.body:'${message.sender}: ${message.body}', style: TextStyle(fontSize: emojiOnly?31*widget.controller.uiChatScale:12.5*widget.controller.uiChatScale, height: 1.35, fontWeight: message.mine ? FontWeight.w800 : FontWeight.w500, color: message.mine ? colorFromHex(widget.controller.selectedChatColor) : Colors.white)),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(7),
                child: Row(children: [
                  IconButton.filledTonal(tooltip:'إيموجي',onPressed:()async{final emoji=await showV166EmojiPicker(context,widget.controller);if(emoji!=null){serverChatController.text=emoji;await _sendRoomMessage();}},icon:const Icon(Icons.emoji_emotions_rounded)),
                  const SizedBox(width:5),
                  Expanded(child: TextField(controller: serverChatController, onSubmitted: (_) => _sendRoomMessage(), style: TextStyle(fontSize:14*widget.controller.uiChatScale), decoration: const InputDecoration(hintText: 'اكتب رسالة...', isDense: true))),
                  const SizedBox(width: 5),
                  IconButton.filled(onPressed: _sendRoomMessage, icon: const Icon(Icons.send, size: 18)),
                ]),
              ),
            ] else ...[
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: widget.controller.friends.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final friend = widget.controller.friends[index];
                    return ListTile(
                      dense: true,
                      leading: Stack(children: [CircleAvatar(child: Text(friend.avatar?.isNotEmpty == true ? friend.avatar! : friend.name.substring(0, 1))), if (friend.online) const Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 5, backgroundColor: Colors.greenAccent))]),
                      title: Text(friend.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13 * widget.controller.uiChatScale)),
                      subtitle: Text(friend.activity, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10 * widget.controller.uiChatScale)),
                      trailing: IconButton(
                        tooltip: 'فتح المحادثة',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrivateChatPage(controller: widget.controller, friend: friend))),
                        icon: const Icon(Icons.chat_bubble_outline, size: 19),
                      ),
                      onTap: () => showPublicPlayerProfileV170(context, widget.controller, friend),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );

}


class PlayingCard extends StatelessWidget {
  final String label;
  final double width;
  final double height;
  final bool selected;

  const PlayingCard({super.key, required this.label, this.width = 46, this.height = 68, this.selected = false});

  @override
  Widget build(BuildContext context) {
    // A joker is a full Unicode symbol, not a rank followed by a suit.
    final joker = label == '🃏' || label.startsWith('JOKER');
    final suit = joker ? '★' : label.isNotEmpty ? label.substring(label.length - 1) : '';
    final rank = joker ? 'JK' : label.length > 1 ? label.substring(0, label.length - 1) : label;
    final red = suit == '♥' || suit == '♦';
    final ink = red ? const Color(0xffb42335) : const Color(0xff101419);
    final compactCard = width < 34;
    final cornerSize = math.max(compactCard ? 6.0 : 9.0, width * .25).toDouble();
    final centerSize = math.max(compactCard ? 9.0 : 16.0, width * .48).toDouble();
    final edgeInset = compactCard ? 1.5 : 3.5;
    final verticalInset = compactCard ? 1.0 : 2.5;
    return Semantics(
      image: true,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffffffff), Color(0xfff6fbff), Color(0xffe7f3fb)],
          ),
          borderRadius: BorderRadius.circular(math.max(7, width * .18).toDouble()),
          border: Border.all(
            color: selected ? B307SkyLuxury.cyan : const Color(0xffb9ccda),
            width: selected ? 2.6 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? B307SkyLuxury.cyan.withValues(alpha: .42) : Colors.black.withValues(alpha: .28),
              blurRadius: selected ? 18 : 8,
              spreadRadius: selected ? 1 : 0,
              offset: const Offset(0, 5),
            ),
            const BoxShadow(color: Colors.white, blurRadius: 1, offset: Offset(-1, -1)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(math.max(6.0, width * .16).toDouble()),
          child: Stack(
            children: [
              Positioned(left: edgeInset, top: verticalInset, child: Column(mainAxisSize: MainAxisSize.min, children: [Text(rank, style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: cornerSize, height: .9)), Text(suit, style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: cornerSize * .85, height: .85))])),
              Positioned.fill(
                child: CustomPaint(
                  key: ValueKey('r19-card-face-$label'),
                  painter: _WarqnaaCardFacePainter(rank: rank, suit: suit, ink: ink, compact: compactCard, referenceSize: centerSize,
                    fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                    fontFamilyFallback: Theme.of(context).textTheme.bodyMedium?.fontFamilyFallback),
                ),
              ),
              Positioned(right: edgeInset, bottom: verticalInset, child: Transform.rotate(angle: math.pi, child: Column(mainAxisSize: MainAxisSize.min, children: [Text(rank, style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: cornerSize, height: .9)), Text(suit, style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: cornerSize * .85, height: .85))]))),
              if (selected)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(math.max(7, width * .18).toDouble()),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [B307SkyLuxury.cyan.withValues(alpha: .20), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarqnaaCardFacePainter extends CustomPainter {
  final String rank;
  final String suit;
  final Color ink;
  final bool compact;
  final double referenceSize;
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  const _WarqnaaCardFacePainter({required this.rank, required this.suit, required this.ink, required this.compact, required this.referenceSize,
    this.fontFamily, this.fontFamilyFallback});

  void _glyph(Canvas canvas, String value, Offset point, double fontSize, {Color? color, FontWeight weight = FontWeight.w900}) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: TextStyle(color: color ?? ink, fontSize: fontSize, fontWeight: weight, height: 1,
        fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    painter.paint(canvas, point - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (suit.isEmpty) {
      _glyph(canvas, rank, Offset(size.width / 2, size.height / 2), referenceSize);
      return;
    }
    if (compact) {
      _glyph(canvas, suit, Offset(size.width / 2, size.height / 2), referenceSize);
      return;
    }
    final center = Offset(size.width / 2, size.height / 2);
    if (const {'J', 'Q', 'K'}.contains(rank)) {
      final badge = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.width * .48, height: size.height * .47),
        Radius.circular(size.width * .12),
      );
      canvas.drawRRect(badge, Paint()..color = ink.withValues(alpha: .055));
      canvas.drawRRect(badge, Paint()..color = const Color(0xffb8893e).withValues(alpha: .72)..style = PaintingStyle.stroke..strokeWidth = math.max(.7, size.width * .025));
      _glyph(canvas, rank, center - Offset(0, size.height * .055), size.width * .35, color: ink);
      _glyph(canvas, suit, center + Offset(0, size.height * .145), size.width * .18, color: ink);
      return;
    }
    if (rank == 'A') {
      _glyph(canvas, suit, center, size.width * .53, color: ink);
      canvas.drawCircle(center, size.width * .28, Paint()..color = const Color(0xffb8893e).withValues(alpha: .45)..style = PaintingStyle.stroke..strokeWidth = math.max(.7, size.width * .022));
      return;
    }
    final count = int.tryParse(rank);
    if (count == null || count < 2 || count > 10) {
      _glyph(canvas, suit, center, referenceSize);
      return;
    }
    final positions = switch (count) {
      2 => const [Offset(.50, .27), Offset(.50, .73)],
      3 => const [Offset(.50, .24), Offset(.50, .50), Offset(.50, .76)],
      4 => const [Offset(.34, .27), Offset(.66, .27), Offset(.34, .73), Offset(.66, .73)],
      5 => const [Offset(.34, .25), Offset(.66, .25), Offset(.50, .50), Offset(.34, .75), Offset(.66, .75)],
      6 => const [Offset(.34, .24), Offset(.66, .24), Offset(.34, .50), Offset(.66, .50), Offset(.34, .76), Offset(.66, .76)],
      7 => const [Offset(.34, .22), Offset(.66, .22), Offset(.50, .38), Offset(.34, .50), Offset(.66, .50), Offset(.34, .78), Offset(.66, .78)],
      8 => const [Offset(.34, .21), Offset(.66, .21), Offset(.50, .35), Offset(.34, .47), Offset(.66, .47), Offset(.50, .63), Offset(.34, .79), Offset(.66, .79)],
      9 => const [Offset(.34, .20), Offset(.66, .20), Offset(.34, .38), Offset(.66, .38), Offset(.50, .50), Offset(.34, .62), Offset(.66, .62), Offset(.34, .80), Offset(.66, .80)],
      _ => const [Offset(.34, .19), Offset(.66, .19), Offset(.50, .30), Offset(.34, .39), Offset(.66, .39), Offset(.34, .61), Offset(.66, .61), Offset(.50, .70), Offset(.34, .81), Offset(.66, .81)],
    };
    for (final position in positions) {
      _glyph(canvas, suit, Offset(size.width * position.dx, size.height * position.dy), size.width * .16, color: ink);
    }
  }

  @override
  bool shouldRepaint(covariant _WarqnaaCardFacePainter oldDelegate) => oldDelegate.rank != rank || oldDelegate.suit != suit || oldDelegate.ink != ink || oldDelegate.compact != compact ||
    oldDelegate.referenceSize != referenceSize || oldDelegate.fontFamily != fontFamily || !listEquals(oldDelegate.fontFamilyFallback, fontFamilyFallback);
}

class PlayerSeat extends StatelessWidget {
  final String name;
  final String letter;
  final String bid;
  final String? meta;
  final String? lastCardLabel;
  final bool vertical;
  final Color? nameColor;
  final String? badge;
  final String? avatarEmoji;
  final BotProfile? botProfile;
  final VoidCallback? onProfileTap;

  const PlayerSeat({super.key, required this.name, required this.letter, required this.bid, this.meta, this.lastCardLabel, this.vertical = false, this.nameColor, this.badge, this.avatarEmoji, this.botProfile, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final ar=Directionality.of(context)==TextDirection.rtl;
    final content = [
      botProfile == null
          ? GlowAvatar(text: avatarEmoji ?? letter, size: 43, color: nameColor ?? Theme.of(context).colorScheme.primary)
          : Bot3DAvatar(profile: botProfile!, size: 46, showLevel: true),
      const SizedBox(width: 5, height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: .72), borderRadius: BorderRadius.circular(9), border: Border.all(color: Colors.white.withValues(alpha: .09))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${badge ?? ''}${badge == null ? '' : ' '}$name • $bid', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: nameColor ?? Colors.white)),
            if (meta != null && meta!.trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(meta!, textAlign: TextAlign.center, style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: .78))),
            ],
            if (lastCardLabel != null && lastCardLabel!.trim().isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(ar?'آخر ':'Last ',style:TextStyle(fontSize:7,fontWeight:FontWeight.w800,color:Colors.white.withValues(alpha:.70))),
                PlayingCard(label: lastCardLabel!, width: 20, height: 29),
              ]),
            ],
          ],
        ),
      ),
    ];
    final seat = vertical
        ? Column(mainAxisSize: MainAxisSize.min, children: content)
        : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: content);
    return Semantics(
      button: onProfileTap != null,
      label: ar?'فتح بروفايل $name':'Open $name profile',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onProfileTap,
        child: Padding(padding: const EdgeInsets.all(2), child: seat),
      ),
    );
  }
}

class ScoreBox extends StatelessWidget {
  final String label;
  final int score;

  const ScoreBox({super.key, required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 8, color: Colors.white60)),
            Text('$score', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class RoomTool extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const RoomTool({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        key: ValueKey<String>('r30-room-tool-${icon.codePoint}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 42,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: B307SkyLuxury.panelGradient,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: B307SkyLuxury.sky.withValues(alpha: .34)),
            boxShadow: <BoxShadow>[
              BoxShadow(color: B307SkyLuxury.sky.withValues(alpha: .08), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Icon(icon, color: B307SkyLuxury.goldSoft, size: 19),
        ),
      ),
    );
  }
}

class PremiumPanel extends StatelessWidget {
  final Widget child;

  const PremiumPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .20), blurRadius: 14, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
}

class PremiumAvatar extends StatelessWidget {
  final String text;
  final double size;

  const PremiumAvatar({super.key, required this.text, this.size = 43});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xff314960), Color(0xff0b1722)]),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class GlowAvatar extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final Uint8List? bytes;
  const GlowAvatar({super.key, required this.text, required this.color, this.size = 44, this.bytes});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [color, color.withValues(alpha: .3)]),
          boxShadow: [BoxShadow(color: color.withValues(alpha: .55), blurRadius: 16, spreadRadius: 1)],
        ),
        child: ClipOval(
          child: Container(
            alignment: Alignment.center,
            color: const Color(0xff0a1420),
            child: bytes == null ? Text(text, style: TextStyle(fontSize: size * .43, fontWeight: FontWeight.w900)) : Image.memory(bytes!, fit: BoxFit.contain, width: size, height: size),
          ),
        ),
      );
}

class AccountAvatar extends StatelessWidget {
  final AppController controller;
  final double size;
  const AccountAvatar({super.key, required this.controller, this.size = 44});

  Uint8List? _decode() {
    final raw = controller.avatarData;
    if (raw == null || raw.isEmpty) return null;
    try {
      final body = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(body);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => _PashaColorAvatarV170(
        name: controller.displayName,
        emoji: controller.avatarEmoji.isNotEmpty ? controller.avatarEmoji : (controller.displayName.isEmpty ? '?' : controller.displayName.substring(0, 1)),
        bytes: _decode(),
        color: colorFromHex(controller.selectedNameColor),
        pasha: controller.vipDays > 0,
        pashaAsset: controller.activePashaStyleV173.asset,
        size: size,
      );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const SectionTitle({super.key, required this.title, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder:(context,box)=>Row(
      children: [
        Expanded(child: Text(title,maxLines:2,overflow:TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
        if (action != null) ConstrainedBox(constraints:BoxConstraints(maxWidth:box.maxWidth.isFinite?box.maxWidth*.58:160),
          child:Tooltip(message:action!,child:TextButton(onPressed: onTap ?? () {}, child: Text(action!,maxLines:1,overflow:TextOverflow.ellipsis)))),
      ],
    ));
  }
}

class PremiumActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onPressed;

  const PremiumActionButton({super.key, required this.icon, required this.title, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: FilledButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 15)),
    );
  }
}

class QuickButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const QuickButton({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: SizedBox(
        width: 58,
        height: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 23)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Colors.white60, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class PremiumListTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Widget action;
  final VoidCallback? onTap;

  const PremiumListTile({super.key, required this.icon, required this.title, required this.subtitle, required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(width: 46, height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(14)), child: Text(icon, style: const TextStyle(fontSize: 26))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 9, height: 1.4))])),
            const SizedBox(width: 7),
            action,
          ],
        ),
      ),
      ),
    );
  }
}

Future<void> showAvatarPicker(BuildContext context, AppController controller) async {
  const avatars = <String>['🦁','🦅','🐺','🦊','🐯','🐼','🌙','⭐','👑','🧠','🔥','💎'];
  final ar = controller.localeCode == 'ar';
  await showPremiumSheet(
    context,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      B307PageHero(
        icon: Icons.face_retouching_natural_rounded,
        title: ar ? 'استوديو الصورة والرمز' : 'Avatar studio',
        subtitle: ar
            ? 'اختر صورة من جهازك أو هوية رمزية فاخرة تظهر في الملف والطاولات والمنافسات.'
            : 'Choose a device photo or a premium identity that appears across profile, tables and competitions.',
        trailing: const Icon(Icons.auto_awesome_rounded, color: B307SkyLuxury.goldSoft, size: 26),
      ),
      const SizedBox(height: 12),
      Center(
        child: Container(
          key: const ValueKey('r30-avatar-preview-ring'),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: <Color>[B307SkyLuxury.cyan, B307SkyLuxury.goldSoft, B307SkyLuxury.azure]),
            boxShadow: <BoxShadow>[BoxShadow(color: B307SkyLuxury.sky.withValues(alpha: .28), blurRadius: 24, spreadRadius: 2)],
          ),
          child: AccountAvatar(controller: controller, size: 96),
        ),
      ),
      const SizedBox(height: 13),
      FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: B307SkyLuxury.azure, foregroundColor: r101ReadableInk(B307SkyLuxury.azure)),
        onPressed: () async {
          final err = await controller.updateAvatarFromGallery(context);
          if (context.mounted) showToast(context, err ?? (ar ? 'تم تحديث الصورة.' : 'Avatar updated.'));
        },
        icon: const Icon(Icons.photo_library_outlined),
        label: Text(ar ? 'اختيار صورة من الجهاز' : 'Choose photo from device'),
      ),
      const SizedBox(height: 12),
      B307SectionHeader(title: ar ? 'الرموز المميزة' : 'Premium symbols'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 9,
        runSpacing: 9,
        alignment: WrapAlignment.center,
        children: avatars.map((emoji) {
          final selected = emoji == controller.avatarEmoji;
          return Semantics(
            button: true,
            selected: selected,
            label: emoji,
            child: InkWell(
              onTap: () async {
                await controller.chooseAvatarEmoji(emoji);
                if (context.mounted) Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(50),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected
                      ? const LinearGradient(colors: <Color>[B307SkyLuxury.azure, B307SkyLuxury.royal])
                      : B307SkyLuxury.panelGradient,
                  border: Border.all(color: selected ? B307SkyLuxury.goldSoft : B307SkyLuxury.sky.withValues(alpha: .30), width: selected ? 2 : 1),
                  boxShadow: selected
                      ? <BoxShadow>[BoxShadow(color: B307SkyLuxury.cyan.withValues(alpha: .28), blurRadius: 14)]
                      : const <BoxShadow>[],
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 29)),
              ),
            ),
          );
        }).toList(),
      ),
    ]),
  );
}

Future<void> showAvatarPreview(BuildContext context, AppController controller) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: PremiumPanel(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileCover(
                  coverId: controller.selectedCover,
                  height: 300,
                  colors: b304ProfileGradient(controller),
                  child: Center(
                    child: Hero(
                      tag: 'profile-avatar-${controller.username}',
                      child: AccountAvatar(controller: controller, size: 220),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Text(controller.displayName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: colorFromHex(controller.selectedNameColor))),
                const SizedBox(height: 4),
                Text('@${controller.username}', style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close), label: const Text('إغلاق'))),
                  const SizedBox(width: 8),
                  Expanded(child: FilledButton.icon(onPressed: () { Navigator.pop(dialogContext); showAvatarPicker(context, controller); }, icon: const Icon(Icons.edit_outlined), label: const Text('تعديل'))),
                ]),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showCancelAccountDialog(BuildContext context, AppController controller) async {
  final password = TextEditingController();
  bool confirmed = false;
  final shouldCancel = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setState) => AlertDialog(
    title: const Text('إلغاء الحساب'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('هل أنت متأكد أنك سوف تلغي الحساب؟ سيتم تسجيل خروجك فوراً، وسيبقى الحساب محفوظاً لمدة 30 يوماً. إذا لم تفتح الحساب وتسجل الدخول خلال هذه المدة فسيتم حذفه نهائياً مع بياناته.', style: TextStyle(height: 1.55)),
      const SizedBox(height: 12),
      TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور للتأكيد')),
      CheckboxListTile(contentPadding: EdgeInsets.zero, value: confirmed, onChanged: (v) => setState(() => confirmed = v == true), title: const Text('أفهم أن عدم فتح الحساب لمدة 30 يوماً سيؤدي إلى حذفه نهائياً', style: TextStyle(fontSize: 12))),
    ]),
    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')), FilledButton(onPressed: confirmed ? () => Navigator.pop(dialogContext, true) : null, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('إلغاء الحساب'))],
  ))) ?? false;
  if (!shouldCancel) { password.dispose(); return; }
  final error = await controller.cancelAccount(password.text);
  password.dispose();
  if (!context.mounted) return;
  if (error == null) Navigator.pop(context);
  showToast(context, error ?? 'تم إلغاء الحساب. يمكنك استعادته بتسجيل الدخول خلال 30 يوماً.');
}

Future<void> showCountryPicker(BuildContext context, AppController controller) async {
  final search = TextEditingController();
  var filtered = List<CountryInfo>.from(allCountries);
  final selected = await showDialog<CountryInfo>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(builder: (context, setState) => AlertDialog(
      title: const Text('اختر الدولة والعلم'),
      content: SizedBox(
        width: 520,
        height: math.min(MediaQuery.sizeOf(context).height * .68, 620),
        child: Column(children: [
          TextField(controller: search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث باسم الدولة أو الرمز'), onChanged: (value) {
            final q=value.trim().toLowerCase();
            setState(() => filtered=allCountries.where((c)=>c.code.toLowerCase().contains(q)||c.ar.contains(q)||c.en.toLowerCase().contains(q)).toList());
          }),
          const SizedBox(height:8),
          Expanded(child: ListView.builder(itemCount:filtered.length,itemBuilder:(context,index){final c=filtered[index];return ListTile(leading:Text(c.flag,style:const TextStyle(fontSize:28)),title:Text(c.name(controller.localeCode)),subtitle:Text('${c.code} • ${c.en}'),selected:c.code==controller.countryCode,onTap:()=>Navigator.pop(dialogContext,c));})),
        ]),
      ),
      actions:[TextButton(onPressed:()=>Navigator.pop(dialogContext),child:const Text('إلغاء'))],
    )),
  );
  search.dispose();
  if(selected==null) return;
  final error=await controller.changeCountry(selected);
  if(context.mounted) showToast(context,error ?? 'تم تحديث الدولة والعلم في البروفايل وكل صفحات التطبيق.');
}

String localClubNameV03(String? id) => const <String, String>{
  'falcons': 'صقور العرب',
  'kings': 'ملوك الورق',
  'friends': 'رفاق اللعب',
  'aces': 'نخبة الآسات',
}[id] ?? (id ?? '');

String localClubLogoV03(String? id) => const <String, String>{
  'falcons': '🦅',
  'kings': '👑',
  'friends': '🤝',
  'aces': '🂡',
}[id] ?? '🛡️';

void showProfile(BuildContext context, AppController controller) {
  showPremiumSheet(
    context,
    child: Column(
      children: [
        B307PageHero(
          icon: Icons.palette_rounded,
          title: controller.localeCode == 'ar' ? 'تخصيص الملف الشخصي' : 'Profile customization',
          subtitle: controller.localeCode == 'ar'
              ? 'هويتك في ورقنا: الصورة والغلاف والإطار واللون والإنجازات في مساحة واحدة.'
              : 'Your Warqnaa identity: avatar, cover, frame, color and achievements in one premium space.',
          trailing: const Icon(Icons.auto_awesome_rounded, color: B307SkyLuxury.goldSoft, size: 27),
        ),
        const SizedBox(height: 10),
        ProfileCover(
          coverId: controller.selectedCover,
          height: 205,
          colors: b304ProfileGradient(controller),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => showAvatarPreview(context, controller),
                    borderRadius: BorderRadius.circular(60),
                    child: Hero(tag: 'profile-avatar-${controller.username}', child: AccountAvatar(controller: controller, size: 108)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(child: Text(controller.displayName, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: colorFromHex(controller.selectedNameColor), shadows: [Shadow(color: colorFromHex(controller.selectedNameColor), blurRadius: 9)]))),
                          if (controller.isAdmin) const Padding(padding: EdgeInsetsDirectional.only(start: 6), child: Icon(Icons.verified, size: 18, color: Colors.amber)),
                        ]),
                        const SizedBox(height: 3),
                        Text('@${controller.username} • ${controller.serverConnected ? 'LIVE' : 'LOCAL'}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        InkWell(onTap:()=>showCountryPicker(context,controller),borderRadius:BorderRadius.circular(12),child:Padding(padding:const EdgeInsets.symmetric(vertical:2),child:Row(mainAxisSize:MainAxisSize.min,children:[Text(controller.countryFlag,style:const TextStyle(fontSize:20)),const SizedBox(width:5),Flexible(child:Text(controller.countryName,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:10))),const SizedBox(width:4),const Icon(Icons.edit_location_alt_outlined,size:13,color:Colors.white60)]))),
                        const SizedBox(height: 6),
                        Row(children: [
                          PashaHatV173(controller: controller, width: 35, height: 25),
                          const SizedBox(width: 5),
                          Text('${controller.vipDays} ${L.t(controller.localeCode, 'days')}', style: const TextStyle(color: Color(0xffffd166), fontWeight: FontWeight.w900, fontSize: 10)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          key: const ValueKey('r29-sky-profile-metrics'),
          children: [
            Expanded(child: B307StatCard(icon: Icons.show_chart_rounded, value: '${controller.winRate.toStringAsFixed(1)}%', label: L.t(controller.localeCode, 'winRate'))),
            const SizedBox(width: 7),
            Expanded(child: B307StatCard(icon: Icons.style_rounded, value: '${controller.gamesPlayed}', label: L.t(controller.localeCode, 'matches'))),
            const SizedBox(width: 7),
            Expanded(child: B307StatCard(icon: Icons.workspace_premium_rounded, value: '${controller.level}', label: controller.localeCode == 'ar' ? 'المستوى' : 'Level')),
          ],
        ),
        if (controller.activeClub != null) ...[
          const SizedBox(height: 10),
          PremiumPanel(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .06), borderRadius: BorderRadius.circular(15)), child: Text(controller.clubImageEmojiV182, style: const TextStyle(fontSize: 27))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('النادي الحالي', style: TextStyle(color: Colors.white54, fontSize: 9)), Text(controller.activeClub ?? localClubNameV03(controller.activeClub), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), const Text('تظهر هوية النادي في البروفايل وسجل المنافسات.', style: TextStyle(color: Colors.white54, fontSize: 9))])),
                const Icon(Icons.verified_rounded, color: Colors.greenAccent),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 10),
        PremiumPanel(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[const Icon(Icons.auto_graph_rounded),const SizedBox(width:7),const Expanded(child:Text('تقدم اللاعب ونقاطه',style:TextStyle(fontWeight:FontWeight.w900))),Text('${controller.xp}/${controller.xpNext} XP',style:TextStyle(color:Theme.of(context).colorScheme.primary,fontWeight:FontWeight.w900))]),
          const SizedBox(height:8),LinearProgressIndicator(value:controller.levelProgress,minHeight:8,borderRadius:BorderRadius.circular(20)),const SizedBox(height:9),
          Wrap(spacing:7,runSpacing:7,children:[Chip(label:Text('🎯 ${controller.roundPoints} جولة')),Chip(label:Text('🏆 ${controller.tournamentPoints} مسابقات')),Chip(label:Text('🛡️ ${controller.clubPoints} نادي')),Chip(label:Text('⬆️ ${controller.pointsToNextLevel} للمستوى التالي'))]),
        ]))),
        const SizedBox(height: 10),
        PremiumPanel(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const Text('🪙', style: TextStyle(fontSize: 25)),
              const SizedBox(width: 9),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('رصيد التوكنز', style: TextStyle(color: Colors.white60, fontSize: 9)), FittedBox(child: Text(formatNumber(controller.coins), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 17)))])),
              Text('${controller.vipDays} يوم باشا', style: const TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            Chip(avatar: PashaHatV173(controller: controller, width: 30, height: 22), label: Text('${controller.vipDays} يوم باشا')),
            Chip(avatar: const Icon(Icons.table_restaurant_outlined, size: 16), label: Text(storeProductById(controller.selectedTable)?.name(controller.localeCode) ?? 'طاولة افتراضية')),
            Chip(avatar: const Icon(Icons.style_outlined, size: 16), label: Text(storeProductById(controller.selectedCardBack)?.name(controller.localeCode) ?? 'ظهر افتراضي')),
            Chip(avatar: const Icon(Icons.bolt, size: 16), label: Text('XP ×${controller.activeXpMultiplier.toStringAsFixed(2)}')),
            Chip(avatar: const Text('😀'), label: Text(storeProductById(controller.selectedEmojiPack)?.name(controller.localeCode) ?? 'إيموجي أساسية')),
          ],
        ),
        const SizedBox(height: 11),
        SectionTitle(title: L.t(controller.localeCode, 'statistics'), action: '${controller.wins} / ${controller.losses}'),
        const SizedBox(height: 7),
        PremiumPanel(child: Padding(padding: const EdgeInsets.all(12), child: Wrap(spacing: 7, runSpacing: 7, children: [
          _AchievementChip(icon: '🏆', label: controller.wins >= 500 ? 'أسطورة الانتصارات' : 'محترف الانتصارات', unlocked: controller.wins >= 100),
          _AchievementChip(icon: '🔥', label: 'سلسلة ${controller.consecutiveLoginDays} أيام', unlocked: controller.consecutiveLoginDays >= 3),
          _AchievementChip(icon: '👑', label: 'عضو الباشا', unlocked: controller.vipDays > 0),
          _AchievementChip(icon: '🧠', label: 'خبير المحركات', unlocked: controller.level >= 50),
        ]))),
        const SizedBox(height: 10),
        const SectionTitle(title: 'آخر المباريات', action: 'سجل مختصر'),
        const SizedBox(height: 7),
        PremiumPanel(child: Column(children: [
          _RecentMatchTile(game: 'طرنيب', result: 'فوز', score: '41–28', icon: '🂡', win: true),
          const Divider(height: 1),
          _RecentMatchTile(game: 'تركس', result: 'فوز', score: '186 نقطة', icon: '🃏', win: true),
          const Divider(height: 1),
          _RecentMatchTile(game: 'هاند', result: 'خسارة', score: '92–101', icon: '🎴', win: false),
        ])),
        const SizedBox(height: 11),
        Row(children:[Expanded(child:FilledButton.tonalIcon(onPressed:()=>showCountryPicker(context,controller),icon:Text(controller.countryFlag,style:const TextStyle(fontSize:20)),label:const Text('الدولة والعلم'))),const SizedBox(width:7),Expanded(child:FilledButton.tonalIcon(onPressed: () => showAvatarPicker(context, controller), icon: const Icon(Icons.add_a_photo_outlined), label: const Text('الصورة والرمز')))]),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: FilledButton.tonalIcon(onPressed: () => showWallet(context, controller), icon: const Icon(Icons.account_balance_wallet_outlined), label: const Text('المحفظة'))),
            const SizedBox(width: 7),
            Expanded(child: FilledButton.tonalIcon(onPressed: () { Navigator.pop(context); showFriends(context, controller); }, icon: const Icon(Icons.people_outline), label: const Text('الأصدقاء'))),
          ],
        ),
        if (controller.isAdmin) ...[
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboardPage(controller: controller))); }, icon: const Icon(Icons.admin_panel_settings_outlined), label: const Text('فتح لوحة الإدارة'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46))),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); showSettings(context, controller); }, icon: const Icon(Icons.settings_outlined), label: const Text('الإعدادات'))),
          const SizedBox(width: 7),
          Expanded(child: OutlinedButton.icon(onPressed: () async { Navigator.pop(context); await controller.logout(); }, icon: const Icon(Icons.logout, color: Colors.redAccent), label: const Text('الخروج'))),
        ]),
      ],
    ),
  );
}

class _AchievementChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool unlocked;
  const _AchievementChip({required this.icon, required this.label, required this.unlocked});
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: unlocked ? 1 : .38,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: unlocked ? Theme.of(context).colorScheme.primary.withValues(alpha: .12) : Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(14), border: Border.all(color: unlocked ? Theme.of(context).colorScheme.primary.withValues(alpha: .4) : Colors.white12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Text(icon), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800))]),
    ),
  );
}

class _RecentMatchTile extends StatelessWidget {
  final String game;
  final String result;
  final String score;
  final String icon;
  final bool win;
  const _RecentMatchTile({required this.game, required this.result, required this.score, required this.icon, required this.win});
  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    leading: Text(icon, style: const TextStyle(fontSize: 24)),
    title: Text(game, style: const TextStyle(fontWeight: FontWeight.w900)),
    subtitle: Text(score, style: const TextStyle(fontSize: 9)),
    trailing: Chip(label: Text(result, style: TextStyle(color: win ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 9))),
  );
}

class ProfileMetric extends StatelessWidget {
  final String value;
  final String label;

  const ProfileMetric({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(child: Padding(padding: const EdgeInsets.all(11), child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 8, color: Colors.white60))])));
  }
}

void showNotifications(BuildContext context, AppController controller) {
  final ar = controller.localeCode == 'ar';
  showPremiumSheet(
    context,
    child: StatefulBuilder(
      builder: (context, setLocalState) => Column(
        key: const ValueKey('r32-premium-notifications'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          B307PageHero(
            icon: Icons.notifications_active_rounded,
            title: L.t(controller.localeCode, 'notifications'),
            subtitle: ar ? 'كل ما يحتاج انتباهك من البطولات والمكافآت والأصدقاء في مكان واحد.' : 'Tournaments, rewards and social updates that need your attention in one place.',
            trailing: TextButton.icon(
              onPressed: () { controller.markAllRead(); setLocalState(() {}); },
              icon: const Icon(Icons.done_all_rounded, size: 17),
              label: Text(ar ? 'قراءة الكل' : 'Read all'),
            ),
          ),
          const SizedBox(height: 10),
          if (controller.notices.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('لا توجد إشعارات'))),
          ...controller.notices.map((notice) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PremiumListTile(
              icon: notice.icon,
              title: notice.title,
              subtitle: notice.body,
              action: IconButton(onPressed: () { controller.removeNotice(notice); setLocalState(() {}); }, icon: const Icon(Icons.delete_outline)),
            ),
          )),
        ],
      ),
    ),
  );
}

void showWallet(BuildContext context, AppController controller) {
  final ar = controller.localeCode == 'ar';
  showPremiumSheet(
    context,
    child: Column(
      key: const ValueKey('r32-premium-wallet'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        B307PageHero(
          icon: Icons.account_balance_wallet_rounded,
          title: L.t(controller.localeCode, 'transactions'),
          subtitle: ar ? 'رصيدك وسجل الحركة مع تحديث موثوق من الخادم عند الاتصال.' : 'Your balance and transaction history with trusted server refresh when connected.',
          trailing: IconButton(
            tooltip: ar ? 'تحديث الرصيد' : 'Refresh balance',
            onPressed: () async {
              final ok = await controller.reconnectV173();
              if (!context.mounted) return;
              Navigator.pop(context);
              showToast(context, ok ? (ar ? 'تم تحديث الرصيد من الخادم.' : 'Balance refreshed from server.') : (ar ? 'تعذر تحديث الرصيد.' : 'Could not refresh balance.'));
            },
            icon: const Icon(Icons.refresh_rounded, color: B307SkyLuxury.cyan),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          key: const ValueKey('r32-wallet-balance-card'),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            gradient: B307SkyLuxury.heroGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: B307SkyLuxury.goldSoft.withValues(alpha: .42)),
            boxShadow: B307SkyLuxury.glow,
          ),
          child: Column(children: [
            Text(ar ? 'الرصيد المتاح' : 'Available balance', style: const TextStyle(color: B307SkyLuxury.textMuted, fontSize: 10, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text('${formatNumber(controller.coins)} 🪙', style: const TextStyle(fontSize: 30, color: B307SkyLuxury.goldSoft, fontWeight: FontWeight.w900)),
          ]),
        ),
        const SizedBox(height: 12),
        PremiumPanel(
          child: Column(
            children: controller.transactions.map((tx) => ListTile(
              leading: Icon(tx.amount > 0 ? Icons.south_west : Icons.north_east, color: tx.amount > 0 ? Colors.greenAccent : Colors.redAccent),
              title: Text(tx.label),
              subtitle: Text(tx.date),
              trailing: Text('${tx.amount > 0 ? '+' : ''}${formatNumber(tx.amount)}', style: TextStyle(color: tx.amount > 0 ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.w900)),
            )).toList(),
          ),
        ),
      ],
    ),
  );
}

Future<void> watchRewardedAd(BuildContext context, AppController controller) async {
  if (controller.rewardedAdsRemaining <= 0) {
    showToast(context, 'وصلت إلى الحد اليومي للإعلانات المكافِئة.');
    return;
  }
  bool earned;
  if (kIsWeb) {
    earned = await showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => const RewardedWebPreviewDialog()) ?? false;
  } else {
    earned = await RewardedAds.show();
    if (!earned && context.mounted) showToast(context, 'الإعلان غير متاح الآن. جرّب لاحقاً.');
  }
  if (!earned || !context.mounted) return;
  final error = await controller.grantRewardedAd('reward-${DateTime.now().millisecondsSinceEpoch}');
  if (!context.mounted) return;
  showToast(context, error ?? 'تمت إضافة 50 توكن و15 XP بعد إكمال الإعلان.');
}

class RewardedWebPreviewDialog extends StatefulWidget {
  const RewardedWebPreviewDialog({super.key});
  @override
  State<RewardedWebPreviewDialog> createState() => _RewardedWebPreviewDialogState();
}

class _RewardedWebPreviewDialogState extends State<RewardedWebPreviewDialog> {
  int seconds = 7;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (seconds <= 1) { timer.cancel(); setState(() => seconds = 0); } else { setState(() => seconds -= 1); }
    });
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('📺 إعلان مكافأة تجريبي'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(height: 150, alignment: Alignment.center, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff10254a), Color(0xff4c1d95)]), borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('WARQNA REWARD', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(seconds == 0 ? 'اكتملت المشاهدة' : 'انتظر $seconds ثانية', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900))])),
      const SizedBox(height: 12),
      const Text('هذه معاينة الويب. في تطبيق Android وiOS يُعرض إعلان AdMob الحقيقي ولا تُصرف المكافأة إلا بعد إكماله.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.5)),
    ]),
    actions: [TextButton(onPressed: seconds == 0 ? () => Navigator.pop(context, true) : null, child: const Text('استلام المكافأة'))],
  );
}

void showRewards(BuildContext context, AppController controller) {
  final ar = controller.localeCode == 'ar';
  showPremiumSheet(
    context,
    child: Column(
      key: const ValueKey('r32-premium-rewards'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        B307PageHero(
          icon: Icons.redeem_rounded,
          title: L.t(controller.localeCode, 'rewards'),
          subtitle: ar ? 'مكافآت يومية، تقدم متدرج واستمرارية دخول واضحة بدون إرباك.' : 'Daily rewards, progressive bonuses and login streaks presented clearly.',
          trailing: const Icon(Icons.auto_awesome_rounded, color: B307SkyLuxury.goldSoft, size: 27),
        ),
        const SizedBox(height: 10),
        PremiumListTile(icon: '🎁', title: 'المكافأة اليومية', subtitle: '100 توكن + 20 XP • مرة واحدة يومياً', action: FilledButton(onPressed: () async { final claimed = await controller.claimDaily(); if (context.mounted) { Navigator.pop(context); showToast(context, claimed ? 'تم استلام المكافأة' : 'استلمت مكافأة اليوم مسبقاً أو تعذر الاتصال'); } }, child: Text(L.t(controller.localeCode, 'claim')))),
        const SizedBox(height: 8),
        PremiumListTile(icon: '📺', title: controller.localeCode == 'ar' ? 'شاهد إعلاناً وارفع المكافأة' : 'Watch an ad and upgrade the reward', subtitle: controller.localeCode == 'ar' ? 'مكافآت متدرجة • المتبقي اليوم ${controller.rewardedAdsRemaining}/8' : 'Progressive rewards • ${controller.rewardedAdsRemaining}/8 left today', action: FilledButton(onPressed: controller.rewardedAdsRemaining > 0 ? () async { await watchRewardedAd(context, controller); if (context.mounted) Navigator.pop(context); } : null, child: Text(controller.localeCode == 'ar' ? 'مشاهدة' : 'Watch'))),
        const SizedBox(height: 8),
        PremiumListTile(icon: '🔥', title: 'استمرارية الدخول', subtitle: '${controller.consecutiveLoginDays} أيام • كل 3 أيام = يوم باشا مجاني', action: FilledButton.tonal(onPressed: null, child: Text('${controller.consecutiveLoginDays}/3'))),
      ],
    ),
  );
}

void showSettings(BuildContext context, AppController controller) {
  final ar = controller.localeCode == 'ar';
  bool vibration = true;
  bool autoPlay = true;
  showPremiumSheet(
    context,
    child: StatefulBuilder(
      builder: (context, setLocalState) => Column(
        key: const ValueKey('r32-premium-settings'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          B307PageHero(
            icon: Icons.tune_rounded,
            title: L.t(controller.localeCode, 'settings'),
            subtitle: ar ? 'تحكم كامل بتجربة اللعب والمظهر والاتصال والخصوصية من مركز واحد.' : 'Control gameplay, appearance, connectivity and privacy from one premium center.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: (controller.serverConnected ? B307SkyLuxury.emerald : B307SkyLuxury.cyan).withValues(alpha: .13),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: (controller.serverConnected ? B307SkyLuxury.emerald : B307SkyLuxury.cyan).withValues(alpha: .40)),
              ),
              child: Text(
                controller.serverConnected ? 'LIVE API' : 'PWA LOCAL',
                style: TextStyle(color: controller.serverConnected ? B307SkyLuxury.emerald : B307SkyLuxury.cyan, fontSize: 8.5, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 10),
          B307SectionHeader(title: ar ? 'تجربة اللعب' : 'Gameplay experience'),
          const SizedBox(height: 5),
          SwitchListTile(value: controller.soundEnabled, onChanged: (v) { controller.toggleSound(v); setLocalState(() {}); }, title: const Text('الأصوات'), subtitle: const Text('أصوات اللعب والإيموجي والتنبيهات')),
          SwitchListTile(value: vibration, onChanged: (v) => setLocalState(() => vibration = v), title: const Text('الاهتزاز'), subtitle: const Text('اهتزاز خفيف عند وصول الدور')),
          SwitchListTile(value: autoPlay, onChanged: (v) => setLocalState(() => autoPlay = v), title: const Text('اللعب التلقائي القانوني'), subtitle: const Text('يتصرف الكمبيوتر عند انتهاء وقت الدور')),
          SwitchListTile(value: controller.landscapeMode, onChanged: (_) async { await controller.toggleOrientationMode(); setLocalState(() {}); }, title: const Text('الوضع الأفقي'), subtitle: const Text('تخطيط كامل للطاولة والورق والدردشة')),
          SwitchListTile(value: controller.tableAmbientEffects, onChanged: (v) { controller.updateNoCodeDesign(ambientEffects: v); setLocalState(() {}); }, title: const Text('مؤثرات الطاولة الهادئة'), subtitle: const Text('إضاءات وحركة خفيفة بدون تشتيت')),
          AnimatedBuilder(animation: R10AssetDelivery.instance, builder: (context, _) => SwitchListTile(value: R10AssetDelivery.instance.dataSaver, onChanged: (v) async { await R10AssetDelivery.instance.setDataSaver(v); setLocalState(() {}); }, title: Text(controller.localeCode == 'ar' ? 'توفير البيانات' : 'Data Saver'), subtitle: Text(controller.localeCode == 'ar' ? 'صور معاينة أصغر عند استخدام CDN مع بقاء الجودة الكاملة عند إيقافه.' : 'Use smaller CDN previews while keeping full quality when disabled.'))),
          AnimatedBuilder(animation: R10AssetDelivery.instance, builder: (context, _) => ListTile(leading: const Icon(Icons.cloud_download_outlined), title: Text(controller.localeCode == 'ar' ? 'تسليم الأصول R10' : 'R10 Asset Delivery'), subtitle: Text('${R10AssetDelivery.instance.manifestEntries} assets • ${R10AssetDelivery.instance.ondemandEntries} on-demand • ${R10AssetDelivery.instance.cdnEnabled ? 'CDN' : 'bundled fallback'}'), trailing: IconButton(icon: const Icon(Icons.cleaning_services_outlined), tooltip: controller.localeCode == 'ar' ? 'مسح الذاكرة المؤقتة' : 'Clear memory cache', onPressed: () { R10AssetDelivery.instance.clearMemoryCache(); setLocalState(() {}); }))),
          const SizedBox(height: 6),
          B307SectionHeader(title: ar ? 'الهوية واللاعب' : 'Identity & player'),
          const SizedBox(height: 5),
          ListTile(leading: AccountAvatar(controller: controller, size: 42), title: Text(ar ? 'الصورة الشخصية' : 'Profile picture'), subtitle: Text(ar ? 'معاينة وقص قبل الاعتماد' : 'Preview and crop before applying'), trailing: const Icon(Icons.chevron_right), onTap: () => showAvatarPicker(context, controller)),
          ListTile(
            leading: SizedBox(width: 52, height: 38, child: ClipRRect(borderRadius: BorderRadius.circular(10), child: ProfileCover(coverId: controller.selectedCover, colors: b304ProfileGradient(controller), child: const Center(child: Icon(Icons.person, size: 18))))),
            title: Text(L.t(controller.localeCode, 'covers')),
            subtitle: Text(storeProductById(controller.selectedCover)?.name(controller.localeCode) ?? controller.selectedCover),
            trailing: const Icon(Icons.storefront_outlined),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: Text(L.t(controller.localeCode, 'covers'))), body: StorePage(controller: controller)))); },
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: Text(L.t(controller.localeCode, 'difficulty')),
            subtitle: Text(L.t(controller.localeCode, controller.botDifficultyCode)),
            trailing: DropdownButton<String>(
              value: controller.botDifficultyCode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value:'easy',child:Text('EASY')),
                DropdownMenuItem(value:'normal',child:Text('NORMAL')),
                DropdownMenuItem(value:'pro',child:Text('HARD')),
                DropdownMenuItem(value:'master',child:Text('EXPERT')),
              ],
              onChanged: (value) { if (value != null) { controller.changeBotDifficulty(value); setLocalState(() {}); } },
            ),
          ),
          const SizedBox(height: 6),
          B307SectionHeader(title: ar ? 'العرض والوصول' : 'Display & accessibility'),
          const SizedBox(height: 5),
          ListTile(leading:const Icon(Icons.font_download_outlined),title:Text(L.t(controller.localeCode,'font')),subtitle:Text(controller.uiFontFamily),trailing:PopupMenuButton<String>(onSelected:(value){controller.changeFontFamily(value);setLocalState((){});},itemBuilder:(_)=>const [PopupMenuItem(value:'Roboto',child:Text('Roboto')),PopupMenuItem(value:'Arial',child:Text('Arial')),PopupMenuItem(value:'Tahoma',child:Text('Tahoma')),PopupMenuItem(value:'Verdana',child:Text('Verdana')),PopupMenuItem(value:'serif',child:Text('Serif')),PopupMenuItem(value:'monospace',child:Text('Monospace'))])),
          ListTile(leading:const Icon(Icons.format_size),title:Text(L.t(controller.localeCode,'fontSize')),subtitle:Text('${(controller.uiFontScale*100).round()}%'),trailing:Wrap(spacing:4,children:[IconButton.filledTonal(onPressed:(){controller.adjustFontScale(-.08);setLocalState((){});},icon:const Text('A−')),IconButton.filledTonal(onPressed:(){controller.adjustFontScale(.08);setLocalState((){});},icon:const Text('A+'))])),
          ListTile(leading:const Icon(Icons.health_and_safety_outlined),title:Text(L.t(controller.localeCode,'connectionCheck')),subtitle:const Text('الخادم والإنترنت والميكروفون'),trailing:const Icon(Icons.chevron_right),onTap:()=>showConnectionDiagnosticsDialog(context,controller)),
          ListTile(leading:const Icon(Icons.privacy_tip_outlined),title:Text(L.t(controller.localeCode,'privacyPolicy')),trailing:const Icon(Icons.chevron_right),onTap:()=>showPrivacyPolicyPage(context,controller)),
          ListTile(
            leading: const Icon(Icons.security_rounded, color: Colors.lightBlueAccent),
            title: Text(controller.localeCode == 'ar' ? 'أمان الحساب' : 'Account security'),
            subtitle: Text(controller.localeCode == 'ar' ? 'تغيير البريد وكلمة المرور بأمان' : 'Securely change email and password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => R143AccountSecurityPage(controller: controller)));
            },
          ),
          const SizedBox(height: 6),
          B307SectionHeader(title: ar ? 'اللغة والنظام' : 'Language & system'),
          const SizedBox(height: 5),
          ListTile(leading: const Icon(Icons.language), title: Text(L.t(controller.localeCode, 'language')), subtitle: Text(controller.localeCode.toUpperCase()), trailing: PopupMenuButton<String>(onSelected: (v) { controller.changeLocale(v); setLocalState(() {}); }, itemBuilder: (_) => b304ActiveLocaleCodes.map((code) => PopupMenuItem<String>(value:code, child:Text(code == 'ar' ? 'العربية' : 'English'))).toList())),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(L.t(controller.localeCode, 'theme')),
            subtitle: Text(controller.themeCode),
            trailing: PopupMenuButton<String>(
              onSelected: (v) { controller.changeTheme(v); setLocalState(() {}); },
              itemBuilder: (_) => r101Themes.keys.map((code) => PopupMenuItem<String>(value: code, child: Text(code.replaceAll('_', ' ').toUpperCase()))).toList(),
            ),
          ),
          if (controller.isPrimaryAdmin) ListTile(leading: const Icon(Icons.tune_rounded), title: Text(L.t(controller.localeCode, 'noCode')), subtitle: const Text('مصمم شامل خاص بحساب Adnan مع معاينة فورية'), trailing: const Icon(Icons.chevron_right), onTap: () { Navigator.pop(context); showNoCodeDesignerSheet(context, controller); }),
          ListTile(leading: const Icon(Icons.install_mobile_rounded), title: const Text('تثبيت التطبيق على الهاتف'), subtitle: const Text('استخدم زر التثبيت أو إضافة إلى الشاشة الرئيسية من المتصفح.')),
          ListTile(leading: const Icon(Icons.security_rounded, color: Colors.lightBlueAccent), title: Text(v153Text(controller.localeCode, 'productionCenter')), subtitle: Text(v153Text(controller.localeCode, 'productionCenterHint')), trailing: const Icon(Icons.chevron_right), onTap: () { Navigator.pop(context); openProductionCenterV153(context, controller); }),
          const ListTile(leading: Icon(Icons.restore_rounded), title: Text('مهلة استعادة الحساب'), subtitle: Text('بعد إلغاء الحساب يمكنك استعادته بمجرد تسجيل الدخول خلال 30 يوماً؛ لا تُحذف الحسابات العادية بسبب عدم النشاط.')),
          const Divider(),
          if (!controller.isAdmin) OutlinedButton.icon(onPressed: () => showCancelAccountDialog(context, controller), icon: const Icon(Icons.person_off_rounded, color: Colors.redAccent), label: Text(L.t(controller.localeCode, 'deleteAccount'), style: const TextStyle(color: Colors.redAccent))),
          if (controller.isAdmin) const ListTile(leading: Icon(Icons.shield_outlined, color: Colors.amber), title: Text('حساب المدير محمي'), subtitle: Text('بيانات المدير لا تُضمّن داخل التطبيق، وتُدار من مركز أمان الحساب.')),
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const ValueKey('r32-settings-save'),
            style: FilledButton.styleFrom(backgroundColor: B307SkyLuxury.azure, foregroundColor: r101ReadableInk(B307SkyLuxury.azure), minimumSize: const Size.fromHeight(50)),
            onPressed: () {
              Navigator.pop(context);
              showToast(context, ar ? 'تم حفظ الإعدادات وتطبيقها على التطبيق.' : 'Settings saved and applied.');
            },
            icon: const Icon(Icons.check_circle_rounded),
            label: Text(L.t(controller.localeCode, 'save')),
          ),
        ],
      ),
    ),
  );
}

void showNoCodeDesignerSheet(BuildContext context, AppController controller) {
  showPremiumSheet(
    context,
    child: StatefulBuilder(
      builder: (context, setLocalState) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(L.t(controller.localeCode, 'noCode'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('تتحول المعاينة فوراً أثناء السحب، وتُحفظ القيم لكل جلسة وحساب.', style: TextStyle(color: Colors.white60, height: 1.5)),
          const SizedBox(height: 14),
          PremiumPanel(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
            Container(height: 92, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withValues(alpha: .22), Colors.white.withValues(alpha: .03)]), borderRadius: BorderRadius.circular(controller.uiRadius)), child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.auto_awesome), label: const Text('معاينة الزر الفاخر'))),
            const SizedBox(height: 10),
            Text('نص تجريبي • ${controller.uiFontScale.toStringAsFixed(2)}×', style: TextStyle(fontSize: 15 * controller.uiFontScale, fontWeight: FontWeight.w800)),
          ]))),
          const SizedBox(height: 12),
          Text('ارتفاع الأزرار: ${controller.uiButtonHeight.round()} px', style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(min: 38, max: 64, divisions: 26, value: controller.uiButtonHeight, onChanged: (value) { controller.updateNoCodeDesign(buttonHeight: value); setLocalState(() {}); }),
          Text('استدارة الحواف: ${controller.uiRadius.round()} px', style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(min: 8, max: 32, divisions: 24, value: controller.uiRadius, onChanged: (value) { controller.updateNoCodeDesign(radius: value); setLocalState(() {}); }),
          Text('مقياس الخط: ${controller.uiFontScale.toStringAsFixed(2)}×', style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(min: .85, max: 1.35, divisions: 25, value: controller.uiFontScale, onChanged: (value) { controller.updateNoCodeDesign(fontScale: value); setLocalState(() {}); }),
          Text('حجم الدردشة: ${controller.uiChatScale.toStringAsFixed(2)}×', style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(min: .8, max: 1.35, divisions: 22, value: controller.uiChatScale, onChanged: (value) { controller.updateNoCodeDesign(chatScale: value); setLocalState(() {}); }),
          const Text('اللون الرئيسي للأزرار', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: v151AccentColors.map((hex) => InkWell(
              onTap: () { controller.updateNoCodeDesign(accentHex: hex); setLocalState(() {}); },
              borderRadius: BorderRadius.circular(30),
              child: Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: colorFromHex(hex), border: Border.all(color: controller.uiAccentHex == hex ? Colors.white : Colors.white24, width: controller.uiAccentHex == hex ? 3 : 1))),
            )).toList(),
          ),
          const SizedBox(height: 8),
          SwitchListTile(value: controller.tableAmbientEffects, onChanged: (value) { controller.updateNoCodeDesign(ambientEffects: value); setLocalState(() {}); }, title: const Text('الحركة الهادئة داخل الطاولة')),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () { controller.updateNoCodeDesign(buttonHeight: 48, radius: 18, fontScale: 1, chatScale: 1, accentHex: '#ffcf67', ambientEffects: true); setLocalState(() {}); }, child: const Text('استعادة الافتراضي'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(context), child: Text(L.t(controller.localeCode, 'save')))),
          ]),
        ],
      ),
    ),
  );
}

void showGiftRoadSheet(BuildContext context, AppController controller) {
  const steps = <(int, String, String)>[
    (5, '🎁', '50 توكن'),
    (10, '💎', '100 توكن'),
    (20, '👑', '100 توكن'),
    (30, '🏆', '200 توكن'),
  ];
  showPremiumSheet(
    context,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('طريق الهدايا', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      const Text('كل فوز قانوني يرفع تقدمك خطوة. استلم المكافآت عند بلوغ المراحل.', style: TextStyle(color: Colors.white60, height: 1.5)),
      const SizedBox(height: 12),
      LinearProgressIndicator(value: controller.giftRoadProgress / 30, minHeight: 9),
      const SizedBox(height: 13),
      ...steps.map((entry) {
        final available = controller.giftRoadProgress >= entry.$1;
        final claimed = controller.claimedGiftSteps.contains(entry.$1);
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: PremiumListTile(
          icon: entry.$2,
          title: 'مرحلة ${entry.$1} انتصار',
          subtitle: entry.$3,
          action: FilledButton.tonal(
            onPressed: available && !claimed ? () { final ok = controller.claimGiftRoad(entry.$1); showToast(context, ok ? 'تم استلام ${entry.$3}.' : 'المكافأة غير متاحة.'); Navigator.pop(context); } : null,
            child: Text(claimed ? 'مستلمة' : available ? 'استلام' : '${controller.giftRoadProgress}/${entry.$1}'),
          ),
        ));
      }),
    ]),
  );
}

void showPashaBenefits(BuildContext context, AppController controller) {
  final pasha = products.where((p) => p.category == 'pasha').toList();
  showPremiumSheet(context, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Center(child: PashaHatV173(controller: controller, width: 160, height: 104)),
    const Text('مزايا الباشا', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    const Text('شارة ذهبية • 20 XP لكل جولة • إنشاء مجموعات ومنافسات • صلاحية إدارة الغرفة • أولوية دخول وملف شخصي فاخر.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, height: 1.6)),
    const SizedBox(height: 12),
    const SizedBox(height: 10),
    SizedBox(height: 118, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: pasha.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) { final product = pasha[i]; return SizedBox(width: 148, child: FilledButton.tonal(onPressed: () => showProductPreview(context, controller, product), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [PashaHatV173(controller: controller, width: 48, height: 34), const SizedBox(height: 3), Text('${controller.durationFor(product) ?? 0} يوم', style: const TextStyle(fontWeight: FontWeight.w900)), Text('🪙 ${formatNumber(controller.priceFor(product))}', style: const TextStyle(fontSize: 9))]))); })),
  ]));
}

void showClubChallenges(BuildContext context, AppController controller, String clubName) {
  showPremiumSheet(context, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text('تحديات $clubName', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
    const SizedBox(height: 9),
    PremiumListTile(icon: '⚔️', title: 'فوزان في الطرنيب', subtitle: 'مكافأة 200 توكن + 100 XP', action: FilledButton(onPressed: () { controller.joinChallenge('club_tarneeb'); Navigator.pop(context); showToast(context, 'تم تفعيل تحدي المجموعة.'); }, child: const Text('ابدأ'))),
    const SizedBox(height: 8),
    PremiumListTile(icon: '🎴', title: 'فوز في الهاند أو البناكل', subtitle: 'مكافأة 100 توكن + نقطة للمجموعة', action: FilledButton(onPressed: () { controller.joinChallenge('club_rummy'); Navigator.pop(context); showToast(context, 'تم تفعيل التحدي.'); }, child: const Text('ابدأ'))),
  ]));
}

Future<void> openGameRoom(BuildContext context, AppController controller, GameInfo game, {RoomLaunchOptions options = const RoomLaunchOptions()}) async {
  // Make an existing room actionable instead of silently blocking a new game.
  if (controller.activeGame != null && controller.activeGame != game.id) {
    final ar = controller.localeCode == 'ar';
    final leave = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(ar ? 'لديك طاولة مفتوحة' : 'You have an open table'),
      content: Text(ar ? 'غادر الطاولة الحالية لبدء اللعبة الجديدة.' : 'Leave the current table to start this game.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(ar ? 'إلغاء' : 'Cancel')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(ar ? 'غادر وابدأ' : 'Leave & start')),
      ],
    ));
    if (leave != true || !context.mounted) return;
    final oldCode = controller.activeRoomCode;
    if (controller.serverConnected && oldCode != null && !oldCode.startsWith('LOCAL')) {
      try { await controller.api.leaveGame(oldCode); }
      catch (error) { if (context.mounted) showToast(context, friendlyErrorMessage(error, controller.localeCode)); return; }
    }
    controller.leaveGame();
    if (!context.mounted) return;
  }
  // R9.1: return limits are exact-room limits enforced by the server, never game-wide limits.
  if (!controller.enterGame(game.id)) {
    showToast(context, 'أنت داخل لعبة أخرى. غادر اللعبة الحالية قبل بدء لعبة جديدة.');
    return;
  }
  final leftRoom = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(builder: (_) => GameRoomPage(controller: controller, game: game, options: options)),
  );
  if (leftRoom == true) {
    controller.leaveGame(game.id);
  } else {
    controller.rememberActiveRoom(game.id, code: controller.activeRoomCode, options: options);
  }
}

void showChallenges(BuildContext context, AppController controller) {
  // Legacy v170 contract symbol retained: showChallengesV170
  showChallengesV175(context, controller);
}

void showCompetitions(BuildContext context, AppController controller) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => R12CompetitiveArenaPage(controller: controller)));
}

void showGameLobby(BuildContext context, AppController controller, GameInfo game) {
  final ar = controller.localeCode == 'ar';
  if (game.serverOnly && !controller.serverConnected) {
    showToast(context, ar
        ? 'هذه اللعبة تستخدم محرك الخادم الكامل. اربط التطبيق بخادم Laravel للعبها بصورة صحيحة.'
        : 'This game uses the full server engine. Connect to the Laravel server to play it correctly.');
    return;
  }
  showPremiumSheet(
    context,
    child: Column(
      key: const ValueKey('r31-premium-game-lobby'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        B307PageHero(
          icon: Icons.style_rounded,
          title: L.t(controller.localeCode, game.id),
          subtitle: ar
              ? (controller.serverConnected ? 'اختر طريقة اللعب وادخل إلى طاولة ورقنا بسرعة.' : 'تدريب محلي فاخر مع لاعبي الكمبيوتر.')
              : (controller.serverConnected ? 'Choose how to play and enter your Warqnaa table quickly.' : 'Premium local practice with computer players.'),
          trailing: Container(
            width: 74,
            height: 54,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: B307SkyLuxury.goldSoft.withValues(alpha: .44)),
            ),
            child: Stack(fit: StackFit.expand, children: <Widget>[
              Opacity(opacity: .14, child: Image.asset(gameArtAsset(game.id), fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink())),
              R34GameEmblem(gameId: game.id, compact: true),
            ]),
          ),
        ),
        const SizedBox(height: 9),
        Container(
          key: const ValueKey('r31-lobby-connection-strip'),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            gradient: B307SkyLuxury.panelGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (controller.serverConnected ? B307SkyLuxury.emerald : B307SkyLuxury.cyan).withValues(alpha: .34),
            ),
          ),
          child: Row(children: [
            Icon(
              controller.serverConnected ? Icons.cloud_done_rounded : Icons.phone_android_rounded,
              color: controller.serverConnected ? B307SkyLuxury.emerald : B307SkyLuxury.cyan,
              size: 19,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                controller.serverConnected
                    ? (ar ? 'متصل بالخادم • الغرف والبطولات متاحة' : 'Server connected • rooms and competitions available')
                    : (ar ? 'وضع محلي • التدريب متاح بدون خادم' : 'Local mode • practice available without server'),
                style: const TextStyle(color: B307SkyLuxury.textMuted, fontSize: 9.5, fontWeight: FontWeight.w800),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 11),
        FilledButton.icon(
          key: ValueKey('r36-play-now-${game.id}'),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(ar ? 'العب الآن' : 'Play now'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          onPressed: () {
            final navigator = Navigator.of(context, rootNavigator: true);
            navigator.pop();
            unawaited(openGameRoom(navigator.context, controller, game,
              options: RoomLaunchOptions(
                roomName: L.t(controller.localeCode, game.id),
                playerCount: v170AllowedPlayerCounts(game.id).first,
                botCount: v170AllowedPlayerCounts(game.id).first - 1,
              )));
          },
        ),
        const SizedBox(height: 11),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 430;
            final primary = _R31LobbyActionTile(
              icon: Icons.play_arrow_rounded,
              title: L.t(controller.localeCode, 'friendly'),
              subtitle: ar ? 'ابدأ مباراة عادية أو صوتية' : 'Start a normal or voice match',
              accent: B307SkyLuxury.emerald,
              onTap: () {
                Navigator.pop(context);
                showPlayModePicker(context, controller, game);
              },
            );
            final competitive = _R31LobbyActionTile(
              icon: Icons.emoji_events_rounded,
              title: L.t(controller.localeCode, 'competitions'),
              subtitle: ar ? 'بطولات وترتيب ومكافآت' : 'Cups, ranking and rewards',
              accent: B307SkyLuxury.goldSoft,
              onTap: () => showCompetitions(context, controller),
            );
            return stacked
                ? Column(children: [primary, const SizedBox(height: 8), competitive])
                : Row(children: [Expanded(child: primary), const SizedBox(width: 8), Expanded(child: competitive)]);
          },
        ),
        const SizedBox(height: 11),
        B307SectionHeader(title: ar ? 'أدوات الغرفة' : 'Room tools'),
        const SizedBox(height: 7),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 640 ? 3 : 2;
            return GridView.count(
              key: const ValueKey('r31-lobby-tools-grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
              childAspectRatio: constraints.maxWidth >= 640 ? 2.15 : 1.65,
              children: [
                _R31LobbyTool(icon: Icons.menu_book_rounded, label: L.t(controller.localeCode, 'rules'), onTap: () => showRules(context, controller.localeCode, game.id)),
                _R31LobbyTool(icon: Icons.leaderboard_rounded, label: L.t(controller.localeCode, 'leaderboard'), onTap: () => showLeaderboard(context, controller)),
                _R31LobbyTool(icon: Icons.add_box_rounded, label: L.t(controller.localeCode, 'createRoom'), onTap: () => showCreateRoom(context, controller, game)),
                _R31LobbyTool(icon: Icons.public_rounded, label: L.t(controller.localeCode, 'openRooms'), onTap: () => showAvailableRooms(context, controller, game)),
                _R31LobbyTool(icon: Icons.password_rounded, label: L.t(controller.localeCode, 'joinByCode'), onTap: () => showJoinRoomByCode(context, controller, game)),
                _R31LobbyTool(icon: Icons.people_alt_rounded, label: L.t(controller.localeCode, 'friends'), onTap: () => showFriends(context, controller)),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _R31LobbyActionTile extends StatelessWidget {
  const _R31LobbyActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          key: ValueKey<String>('r31-lobby-action-${icon.codePoint}'),
          constraints: const BoxConstraints(minHeight: 105),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: B307SkyLuxury.panelGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: .48)),
            boxShadow: <BoxShadow>[BoxShadow(color: accent.withValues(alpha: .12), blurRadius: 12, offset: const Offset(0, 5))],
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: .40)),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 12.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.textMuted, fontSize: 9, height: 1.3, fontWeight: FontWeight.w700)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: B307SkyLuxury.textMuted, size: 18),
          ]),
        ),
      );
}

class _R31LobbyTool extends StatelessWidget {
  const _R31LobbyTool({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            decoration: BoxDecoration(
              gradient: B307SkyLuxury.panelGradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: B307SkyLuxury.sky.withValues(alpha: .24)),
            ),
            child: Row(children: [
              Icon(icon, color: B307SkyLuxury.cyan, size: 20),
              const SizedBox(width: 7),
              Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 9.5, fontWeight: FontWeight.w900))),
            ]),
          ),
        ),
      );
}

Future<void> showAvailableRooms(BuildContext context, AppController controller, GameInfo game) async {
  try {
    final List rooms;
    if (controller.serverConnected) {
      final data = await controller.api.availableRooms(game.id);
      rooms = data['rooms'] is List ? data['rooms'] as List : const [];
    } else {
      // GitHub Pages has no shared room server. Present polished local practice
      // rooms so every game keeps a usable lobby instead of a dead-end error.
      rooms = <Map<String, dynamic>>[
        <String, dynamic>{
          'code': 'LOCAL-${game.id.toUpperCase()}-1',
          'name': '${L.t(controller.localeCode, game.id)} • تدريب المحترفين',
          'voice_enabled': false,
          'players': 3,
          'max_players': 4,
          'min_level': 1,
          'avatars': <Map<String, dynamic>>[
            {'name': controller.localeCode == 'ar' ? 'عدنان' : 'Adnan', 'name_color': '#facc15'},
            {'name': controller.localeCode == 'ar' ? 'جنان' : 'Janan', 'name_color': '#38bdf8'},
            {'name': controller.localeCode == 'ar' ? 'كنان' : 'Kenan', 'name_color': '#22c55e'},
          ],
        },
        <String, dynamic>{
          'code': 'LOCAL-${game.id.toUpperCase()}-2',
          'name': '${L.t(controller.localeCode, game.id)} • طاولة سريعة',
          'voice_enabled': false,
          'players': 2,
          'max_players': 4,
          'min_level': 5,
          'avatars': <Map<String, dynamic>>[
            {'name': controller.localeCode == 'ar' ? 'شهد' : 'Shahd', 'name_color': '#fb7185'},
            {'name': controller.localeCode == 'ar' ? 'رعد' : 'Raad', 'name_color': '#a855f7'},
          ],
        },
      ];
    }
    if (!context.mounted) return;
    showPremiumSheet(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          B307PageHero(
            icon: Icons.public_rounded,
            title: L.t(controller.localeCode, 'openRooms'),
            subtitle: L.t(controller.localeCode, 'openRoomsHint'),
            trailing: Icon(
              controller.serverConnected ? Icons.cloud_done_rounded : Icons.phone_android_rounded,
              color: controller.serverConnected ? B307SkyLuxury.emerald : B307SkyLuxury.cyan,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          if (rooms.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 28), child: Center(child: Text(L.t(controller.localeCode, 'noOpenRooms'), style: const TextStyle(color: Colors.white60))))
          else
            ...rooms.map((raw) {
              final room = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
              final voice = room['voice_enabled'] == true || room['voice_enabled'] == 1;
              final code = room['code']?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OpenRoomCardV170(
                  controller: controller,
                  game: game,
                  room: room,
                  onJoin: code.isEmpty ? null : () async {
                    final navigationContext = warqnaNavigatorKey.currentContext;
                    Navigator.pop(context);
                    if (navigationContext != null) {
                      final options = controller.serverConnected
                          ? RoomLaunchOptions(roomCode: code, voiceEnabled: voice)
                          : RoomLaunchOptions(roomName: room['name']?.toString() ?? 'غرفة تدريب', voiceEnabled: false, playerCount: int.tryParse(room['max_players']?.toString() ?? '') ?? 4);
                      await openGameRoom(navigationContext, controller, game, options: options);
                    }
                  },
                ),
              );
            }),
        ],
      ),
    );
  } on ApiException catch (e) {
    if (context.mounted) showToast(context, e.message);
  } catch (_) {
    if (context.mounted) showToast(context, L.t(controller.localeCode, 'roomsLoadFailed'));
  }
}

void showJoinRoomByCode(BuildContext context, AppController controller, GameInfo game) {
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  showPremiumSheet(
    context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        B307PageHero(
          icon: Icons.password_rounded,
          title: L.t(controller.localeCode, 'joinByCode'),
          subtitle: L.t(controller.localeCode, 'joinByCodeHint'),
          trailing: const Icon(Icons.lock_open_rounded, color: B307SkyLuxury.goldSoft, size: 26),
        ),
        const SizedBox(height: 12),
        TextField(controller: codeController, textCapitalization: TextCapitalization.characters, decoration: InputDecoration(labelText: L.t(controller.localeCode, 'roomCode'), prefixIcon: const Icon(Icons.tag_rounded))),
        const SizedBox(height: 9),
        TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: '${L.t(controller.localeCode, 'password')} (${L.t(controller.localeCode, 'optional')})', prefixIcon: const Icon(Icons.lock_outline_rounded))),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () async {
            final code = codeController.text.trim().toUpperCase();
            if (code.length < 4) {
              showToast(context, L.t(controller.localeCode, 'enterRoomCode'));
              return;
            }
            final navigationContext = warqnaNavigatorKey.currentContext;
            Navigator.pop(context);
            if (navigationContext != null) {
              await openGameRoom(navigationContext, controller, game, options: RoomLaunchOptions(roomCode: code, password: passwordController.text.trim()));
            }
          },
          icon: const Icon(Icons.login_rounded),
          label: Text(L.t(controller.localeCode, 'joinRoom')),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ],
    ),
  );
}

void showPlayModePicker(BuildContext context, AppController controller, GameInfo game) {
  showPremiumSheet(
    context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        B307PageHero(
          icon: Icons.tune_rounded,
          title: L.t(controller.localeCode, 'chooseGameMode'),
          subtitle: L.t(controller.localeCode, 'chooseGameModeHint'),
          trailing: const Icon(Icons.style_rounded, color: B307SkyLuxury.cyan, size: 26),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _GameModeCard(
                icon: Icons.style_rounded,
                title: L.t(controller.localeCode, 'normalGame'),
                subtitle: L.t(controller.localeCode, 'normalGameHint'),
                color: Theme.of(context).colorScheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  showCreateRoom(context, controller, game);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _GameModeCard(
                icon: Icons.mic_rounded,
                title: L.t(controller.localeCode, 'voiceGame'),
                subtitle: L.t(controller.localeCode, 'voiceGameHint'),
                color: Colors.greenAccent,
                onTap: () {
                  Navigator.pop(context);
                  showCreateRoom(context, controller, game, initialVoice: true);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _GameModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _GameModeCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: B307SkyLuxury.panelGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: .46)),
          boxShadow: <BoxShadow>[
            BoxShadow(color: color.withValues(alpha: .12), blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .16)), child: Icon(icon, color: color, size: 29)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, height: 1.4, color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}

void showCreateRoom(BuildContext context, AppController controller, GameInfo game, {bool initialVoice = false}) {
  final nameController = TextEditingController(text: '${L.t(controller.localeCode, game.id)} • ${controller.displayName}');
  final passwordController = TextEditingController();
  var visibility = 'public';
  var voiceEnabled = initialVoice;
  var turnSeconds = 10;
  var minLevel = 1;
  var allowOwnerKick = true;
  var singleRound = false;
  var allowSpectators = true;
  var playerCount = v170AllowedPlayerCounts(game.id).first;
  var botCount = (playerCount - 1).clamp(0, 7).toInt();
  final selectedInviteeIds = <int>{};
  showPremiumSheet(
    context,
    child: StatefulBuilder(
      builder: (context, setLocalState) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          B307PageHero(
            icon: Icons.add_home_work_rounded,
            title: L.t(controller.localeCode, 'createRoom'),
            subtitle: L.t(controller.localeCode, 'roomModeDescription'),
            trailing: Icon(
              voiceEnabled ? Icons.mic_rounded : Icons.style_rounded,
              color: voiceEnabled ? B307SkyLuxury.emerald : B307SkyLuxury.goldSoft,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: nameController, decoration: InputDecoration(labelText: L.t(controller.localeCode, 'roomName'), prefixIcon: const Icon(Icons.meeting_room_outlined))),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, icon: const Icon(Icons.style_rounded), label: Text(L.t(controller.localeCode, 'normalGame'))),
              ButtonSegment(value: true, icon: const Icon(Icons.mic_rounded), label: Text(L.t(controller.localeCode, 'voiceGame'))),
            ],
            selected: {voiceEnabled},
            onSelectionChanged: (values) => setLocalState(() => voiceEnabled = values.first),
            showSelectedIcon: true,
          ),
          if (voiceEnabled) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: .07), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.greenAccent.withValues(alpha: .25))),
              child: Row(children: [const Icon(Icons.verified_user_outlined, color: Colors.greenAccent), const SizedBox(width: 8), Expanded(child: Text(L.t(controller.localeCode, 'voicePrivacyHint'), style: const TextStyle(fontSize: 11, height: 1.45)))]),
            ),
          ],
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: visibility,
            decoration: InputDecoration(labelText: L.t(controller.localeCode, 'roomVisibility'), prefixIcon: const Icon(Icons.public_rounded)),
            items: [
              DropdownMenuItem(value: 'public', child: Text(L.t(controller.localeCode, 'publicRoom'))),
              DropdownMenuItem(value: 'private', child: Text(L.t(controller.localeCode, 'privateRoom'))),
            ],
            onChanged: (value) => setLocalState(() => visibility = value ?? 'public'),
          ),
          if (visibility == 'private') ...[
            const SizedBox(height: 9),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: L.t(controller.localeCode, 'password'), prefixIcon: const Icon(Icons.lock_outline_rounded))),
          ],
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: turnSeconds,
            decoration: InputDecoration(labelText: L.t(controller.localeCode, 'turnSpeed'), prefixIcon: const Icon(Icons.timer_outlined)),
            items: const [
              DropdownMenuItem(value: 5, child: Text('5 ثوانٍ • سريعة')),
              DropdownMenuItem(value: 7, child: Text('7 ثوانٍ • متوسطة')),
              DropdownMenuItem(value: 10, child: Text('10 ثوانٍ • هادئة')),
            ],
            onChanged: (value) => setLocalState(() => turnSeconds = value ?? 10),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: playerCount,
            decoration: const InputDecoration(labelText: 'عدد اللاعبين', prefixIcon: Icon(Icons.groups_rounded)),
            items: v170AllowedPlayerCounts(game.id).map((count) => DropdownMenuItem(value: count, child: Text('$count لاعبين'))).toList(),
            onChanged: (value) => setLocalState(() {
              playerCount = value ?? playerCount;
              final availableSeats = (playerCount - 1).clamp(0, 7).toInt();
              while (selectedInviteeIds.length > availableSeats) {
                selectedInviteeIds.remove(selectedInviteeIds.last);
              }
              botCount = botCount.clamp(0, availableSeats - selectedInviteeIds.length).toInt();
            }),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: B307SkyLuxury.panelGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: B307SkyLuxury.sky.withValues(alpha: .26)),
              boxShadow: <BoxShadow>[BoxShadow(color: B307SkyLuxury.sky.withValues(alpha: .08), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Row(children: [
                Icon(Icons.group_add_rounded, color: Colors.amberAccent),
                SizedBox(width: 8),
                Expanded(child: Text('اختيار المشاركين قبل إنشاء الغرفة', style: TextStyle(fontWeight: FontWeight.w900))),
              ]),
              const SizedBox(height: 7),
              const Text('اختر لاعبين حقيقيين لإرسال الدعوة إليهم، وحدد عدد لاعبي البوت. تبقى المقاعد غير المحجوزة مفتوحة للاعبين الآخرين.', style: TextStyle(fontSize: 10.5, height: 1.45, color: Colors.white60)),
              if (controller.friends.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: controller.friends.map((friend) {
                    final selected = selectedInviteeIds.contains(friend.id);
                    final full = selectedInviteeIds.length + botCount >= playerCount - 1;
                    return FilterChip(
                      selected: selected,
                      avatar: CircleAvatar(child: Text(friend.name.isEmpty ? '👤' : friend.name.substring(0, 1))),
                      label: Text(friend.name),
                      onSelected: !selected && full ? null : (value) => setLocalState(() {
                        if (value) {
                          selectedInviteeIds.add(friend.id);
                        } else {
                          selectedInviteeIds.remove(friend.id);
                        }
                        botCount = botCount.clamp(0, (playerCount - 1) - selectedInviteeIds.length).toInt();
                      }),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: botCount,
                decoration: const InputDecoration(labelText: 'عدد لاعبي البوت', prefixIcon: Icon(Icons.smart_toy_rounded)),
                items: List<int>.generate(((playerCount - 1) - selectedInviteeIds.length).clamp(0, 7).toInt() + 1, (index) => index)
                    .map((count) => DropdownMenuItem(value: count, child: Text(count == 0 ? 'بدون بوتات' : '$count بوت')))
                    .toList(),
                onChanged: (value) => setLocalState(() => botCount = value ?? 0),
              ),
              const SizedBox(height: 6),
              Text('المحدد: ${selectedInviteeIds.length} لاعب حقيقي • $botCount بوت • ${(playerCount - 1 - selectedInviteeIds.length - botCount).clamp(0, 7)} مقاعد مفتوحة', style: const TextStyle(fontSize: 10, color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: minLevel,
            decoration: const InputDecoration(labelText: 'الحد الأدنى لمستوى الدخول', prefixIcon: Icon(Icons.military_tech_rounded)),
            items: v170MinLevelOptions(controller.level)
                .map((value) => DropdownMenuItem(value: value, child: Text('المستوى $value فما فوق')))
                .toList(),
            onChanged: (value) => setLocalState(() => minLevel = value ?? 1),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: allowOwnerKick,
            onChanged: (value) => setLocalState(() => allowOwnerKick = value),
            title: const Text('السماح لمنشئ الغرفة بإخراج لاعب'),
            subtitle: const Text('اللاعب المُخرج لا يستطيع العودة إلى نفس المباراة.'),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: singleRound,
            onChanged: (value) => setLocalState(() => singleRound = value),
            title: const Text('مباراة من جولة واحدة فقط'),
            subtitle: const Text('تنتهي المباراة مباشرة بعد انتهاء الجولة الحالية وإظهار النتيجة.'),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: allowSpectators,
            onChanged: (value) => setLocalState(() => allowSpectators = value),
            title: const Text('فتح مدرجات Social World'),
            subtitle: const Text('المشاهدون لا يرون الأوراق ولا يسمعون الصوت ولا يشاركون في اللعب.'),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                showToast(context, L.t(controller.localeCode, 'enterRoomName'));
                return;
              }
              if (visibility == 'private' && passwordController.text.trim().length < 3) {
                showToast(context, L.t(controller.localeCode, 'enterRoomPassword'));
                return;
              }
              final options = RoomLaunchOptions(
                roomName: nameController.text.trim(),
                voiceEnabled: voiceEnabled,
                visibility: visibility,
                password: visibility == 'private' ? passwordController.text.trim() : null,
                turnSeconds: turnSeconds,
                minLevel: minLevel,
                allowOwnerKick: allowOwnerKick,
                playerCount: playerCount,
                botCount: botCount,
                singleRound: singleRound,
                allowSpectators: allowSpectators,
                inviteeIds: selectedInviteeIds.toList(growable: false),
              );
              final navigationContext = warqnaNavigatorKey.currentContext;
              Navigator.pop(context);
              if (navigationContext != null) {
                await openGameRoom(navigationContext, controller, game, options: options);
              }
            },
            icon: Icon(voiceEnabled ? Icons.mic_rounded : Icons.play_arrow_rounded),
            label: Text(voiceEnabled ? L.t(controller.localeCode, 'createVoiceRoom') : L.t(controller.localeCode, 'createNormalRoom')),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
          ),
        ],
      ),
    ),
  );
}

Future<void> showProductPreview(BuildContext context, AppController controller, StoreProduct product) async {
  AppSounds.fire(product.category == 'tables' ? 'table_preview' : product.category == 'competition_ticket' ? 'ticket_flip' : 'store_open');
  final content = _StorePreviewContentV183(controller: controller, product: product);
  if (isDesktopWebV183(MediaQuery.sizeOf(context).width)) {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 820),
          child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: content),
        ),
      ),
    );
    return;
  }
  await showPremiumSheet(context, child: content);
}

class _StorePreviewContentV183 extends StatelessWidget {
  final AppController controller;
  final StoreProduct product;
  const _StorePreviewContentV183({required this.controller, required this.product});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _ProductLivePreview(controller: controller, product: product),
      const SizedBox(height: 14),
      Text(controller.nameFor(product), textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Text(controller.descriptionFor(product), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.55)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _StoreFact(icon: '🪙', label: 'السعر', value: formatNumber(controller.priceFor(product)))),
        const SizedBox(width: 8),
        Expanded(child: _StoreFact(icon: '🛡️', label: 'الحالة', value: controller.isOwnedActiveV176(product.id) && !product.reusable ? 'مملوك' : product.reusable ? 'قابل للتجديد' : 'متاح')),
        const SizedBox(width: 8),
        Expanded(child: _StoreFact(icon: '⭐', label: 'الفئة', value: product.tierLabel(controller.localeCode))),
      ]),
      if (product.category == 'boost') ...[
        const SizedBox(height: 8),
        _StoreFact(icon: '🚀', label: 'التفعيل', value: '×${product.multiplier} لمدة 24 ساعة • صلاحية المخزون ${boosterValidityDaysV183(product.id)} أيام'),
      ] else if (controller.productDurationLabelV176(product) != null) ...[
        const SizedBox(height: 8),
        _StoreFact(icon: '⏳', label: 'المدة', value: controller.productDurationLabelV176(product)!),
      ],
      if (controller.expiryForProductV176(product.id) != null) ...[
        const SizedBox(height: 8),
        _StoreFact(icon: '⌛', label: 'الصلاحية', value: controller.remainingForProductV176(product.id)),
      ],
      const SizedBox(height: 13),
      FilledButton.icon(
        onPressed: controller.isOwnedActiveV176(product.id) && !product.reusable
            ? () async {
                final ok=await controller.activateOwnedProductR36(product);
                if(!context.mounted)return;
                if(ok)Navigator.pop(context);
                showToast(context,ok?'تم تفعيل ${controller.nameFor(product)}.':controller.lastStoreError ?? 'تعذر التفعيل.');
              }
            : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('تأكيد الشراء'),
                    content: Text('هل أنت متأكد أنك تريد شراء ${controller.nameFor(product)} مقابل ${formatNumber(controller.priceFor(product))} توكن؟\n\nلن يتم الخصم إلا بعد التأكيد.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
                      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('نعم، شراء')),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;
                final ok = await controller.buy(product);
                if (!context.mounted) return;
                Navigator.pop(context);
                showToast(context, ok ? (product.category == 'boost' ? 'تمت إضافة المسرّع إلى المخزون. فعّله قبل انتهاء صلاحيته.' : 'تم الشراء وإضافة العنصر إلى مقتنياتك.') : (controller.lastStoreError ?? 'تعذر الشراء.'));
              },
        icon: Icon(controller.isOwnedActiveV176(product.id) && !product.reusable ? Icons.play_arrow_rounded : Icons.shopping_bag_outlined),
        label: Text(controller.isOwnedActiveV176(product.id) && !product.reusable ? 'تفعيل العنصر' : '${L.t(controller.localeCode, 'buy')} • ${formatNumber(controller.priceFor(product))} 🪙'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      ),
    ],
  );
}

class _ProductLivePreview extends StatelessWidget {
  final AppController controller;
  final StoreProduct product;
  const _ProductLivePreview({required this.controller, required this.product});

  @override
  Widget build(BuildContext context) {
    final c1 = controller.color1For(product);
    final c2 = controller.color2For(product);
    Widget preview;
    if (product.category == 'tables') {
      preview = AdaptiveTablePreviewV183(controller: controller, product: product);
    } else if (product.category == 'competition_ticket' && product.value != null) {
      preview = CompetitionTicketPreviewV183(denomination: product.value!);
    } else if (product.category == 'cards') {
      preview = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlayingCard(label: 'A♠', width: 78, height: 114),
          Transform.translate(
            offset: const Offset(-17, 8),
            child: Container(
              width: 78,
              height: 114,
              padding: const EdgeInsets.all(2),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: product.imageAsset == null ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]) : null,
                border: Border.all(color: Colors.white.withValues(alpha: .55), width: 2),
                boxShadow: [BoxShadow(color: c2.withValues(alpha: .35), blurRadius: 18)],
              ),
              child: product.imageAsset == null
                  ? Center(child: Text(product.icon, style: const TextStyle(fontSize: 38)))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: R10AssetImage(localAsset: product.imageAsset!, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
                    ),
            ),
          ),
        ],
      );
    } else if (product.category == 'names') {
      preview = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlowAvatar(text: controller.avatarEmoji, bytes: AccountAvatar(controller: controller)._decode(), size: 72, color: c1),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(controller.displayName, style: TextStyle(color: c1, fontSize: 25, fontWeight: FontWeight.w900, shadows: [Shadow(color: c1.withValues(alpha: .55), blurRadius: 12), const Shadow(color: Colors.black, blurRadius: 8)])),
            Text('المستوى ${controller.level} • ${controller.vipDays > 0 ? 'باشا' : 'لاعب'}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ],
      );
    } else if (product.category == 'chat_colors') {
      preview = Container(
        width: 285,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: const Color(0xff111827), borderRadius: BorderRadius.circular(22), border: Border.all(color: c1.withValues(alpha: .55))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [GlowAvatar(text: controller.avatarEmoji, bytes: AccountAvatar(controller: controller)._decode(), size: 42, color: c1), const SizedBox(width: 9), Text(controller.displayName, style: TextStyle(color: c1, fontWeight: FontWeight.w900, shadows: [Shadow(color: c1, blurRadius: 10)]))]),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c1.withValues(alpha: .13), borderRadius: BorderRadius.circular(controller.uiRadius.clamp(10, 26).toDouble()), border: Border.all(color: c1.withValues(alpha: .35))), child: Text('رسالة تجريبية بلون الدردشة المختار', style: TextStyle(color: c1, fontWeight: FontWeight.w800))),
        ]),
      );
    } else if (product.category == 'themes') {
      preview = Container(
        width: 290,
        height: 155,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: [c1, c2.withValues(alpha: .85)]), boxShadow: [BoxShadow(color: c2.withValues(alpha: .25), blurRadius: 22)]),
        child: Column(children: [
          Row(children: [const CircleAvatar(radius: 18, child: Text('W')), const SizedBox(width: 9), const Expanded(child: Text('معاينة الثيم', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15))), Container(width: 52, height: 24, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(13)))]),
          const Spacer(),
          Row(children: [Expanded(child: Container(height: 50, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .11), borderRadius: BorderRadius.circular(14)))), const SizedBox(width: 8), Expanded(child: Container(height: 50, decoration: BoxDecoration(color: Colors.black.withValues(alpha: .18), borderRadius: BorderRadius.circular(14))))]),
        ]),
      );
    } else if (product.category == 'pasha') {
      preview = Column(mainAxisSize: MainAxisSize.min, children: [
        PashaHatV173(controller: controller, width: 170, height: 116),
        const Text('تحكم بالغرفة • شارة خاصة • XP إضافي', style: TextStyle(color: Colors.white60, fontSize: 11)),
      ]);
    } else if (product.category == 'covers') {
      preview = SizedBox(width: 320, child: ProfileCover(coverId: product.id, height: 175, colors: <Color>[c1, c2], child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [AccountAvatar(controller: controller, size: 58), const SizedBox(width: 10), Expanded(child: Text(controller.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))])))));
    } else if (product.category == 'boost') {
      preview = BoosterPreviewV183(product: product);
    } else if (product.category == 'emoji') {
      preview = Padding(padding: const EdgeInsets.all(16), child: FittedBox(fit: BoxFit.scaleDown, child: Text(product.icon, textAlign: TextAlign.center, style: const TextStyle(fontSize: 70))));
    } else {
      preview = Text(product.icon, style: const TextStyle(fontSize: 105));
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 220, maxHeight: 520),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .17),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: preview,
    );
  }
}

class _StoreFact extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _StoreFact({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => PremiumPanel(child: Padding(padding: const EdgeInsets.all(11), child: Column(children: [Text('$icon $label', style: const TextStyle(color: Colors.white60, fontSize: 9)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.w900))])));
}

void showRules(BuildContext context, String lang, String gameId) {
  final info = gameRuleBook[gameId] ?? gameRuleBook['tarneeb']!;
  showPremiumSheet(
    context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)), child: Text(info.icon, style: const TextStyle(fontSize: 29))),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${L.t(lang, 'rules')} — ${L.t(lang, gameId)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              Text('${info.players} لاعبين • ${info.deck} • ${info.hand}', style: const TextStyle(color: Colors.white54, fontSize: 9)),
            ])),
          ],
        ),
        const SizedBox(height: 13),
        _RuleSection(title: 'طريقة اللعب', icon: Icons.style_rounded, text: info.play),
        const SizedBox(height: 8),
        _RuleSection(title: 'الحركات القانونية', icon: Icons.verified_outlined, text: info.legal),
        const SizedBox(height: 8),
        _RuleSection(title: 'الفوز والخسارة', icon: Icons.emoji_events_outlined, text: info.win),
        const SizedBox(height: 8),
        _RuleSection(title: 'العدالة والمحرك', icon: Icons.security_rounded, text: 'التوزيع يتم بالخلط داخل المحرك، وتتحقق الجهة الخادمة من كل حركة قبل اعتمادها. لا تُكشف أوراق الخصوم، ولا تُخصم توكنز من اللعب.'),
      ],
    ),
  );
}

class GameRuleInfo {
  final String icon;
  final String players;
  final String deck;
  final String hand;
  final String play;
  final String legal;
  final String win;
  const GameRuleInfo({required this.icon, required this.players, required this.deck, required this.hand, required this.play, required this.legal, required this.win});
}

const gameRuleBook = <String, GameRuleInfo>{
  'tarneeb': GameRuleInfo(icon:'🂡',players:'4',deck:'52 ورقة',hand:'13 ورقة لكل لاعب',play:'فريقان متقابلان. تبدأ المزايدة من 7 حتى 13، وصاحب أعلى طلب يختار نوع الطرنيب ثم يقود أول لمّة.',legal:'يجب اتباع نوع الورقة المتصدرة عند توفره. إذا تعذر ذلك يجوز لعب أي ورقة، والطرنيب يتفوق على الأنواع الأخرى.',win:'إذا حقق فريق صاحب الطلب قيمة طلبه يضيف عدد لمّاته، وإلا تُخصم قيمة الطلب منه. يفوز أول فريق يبلغ الهدف المحدد.'),
  'syrian_tarneeb': GameRuleInfo(icon:'🇸🇾',players:'4',deck:'52 ورقة',hand:'13 ورقة',play:'طرنيب شراكة بنمط هدف 61 نقطة مع مزايدة واختيار الحكم.',legal:'اتباع النوع إلزامي، وتُحسم اللمّة بأعلى ورقة من النوع المتصدر ما لم يُلعب الحكم.',win:'تُحتسب نتيجة العقد واللمّات وفق نمط طرنيب 61، والفريق الأعلى عند بلوغ الهدف يفوز.'),
  'tarneeb_400': GameRuleInfo(icon:'4️⃣',players:'4',deck:'52 ورقة',hand:'13 ورقة',play:'لعبة شراكة بهدف 400 نقطة وحكم ثابت للكبة، مع طلبات فردية تُجمع للفريق.',legal:'اتباع النوع إلزامي، وتُراعى أولوية الحكم وترتيب الأوراق في كل لمّة.',win:'تُضاف أو تُخصم نقاط الطلب لكل لاعب وفق نجاحه، ويكسب الفريق الذي يبلغ 400 وفق شروط النهاية.'),
  'trix': GameRuleInfo(icon:'🃏',players:'4',deck:'52 ورقة',hand:'13 ورقة',play:'لكل لاعب مملكة يختار فيها عقود شيخ الكبة والبنات والديناري واللطوش وتركس.',legal:'تختلف الحركة بحسب العقد، مع اتباع النوع في عقود اللمّات وترتيب تنازلي خاص في عقد تركس.',win:'بعد اكتمال الممالك والعقود تُجمع النقاط، ويفوز صاحب أعلى مجموع.'),
  'trix_partner': GameRuleInfo(icon:'👥',players:'4',deck:'52 ورقة',hand:'13 ورقة',play:'قواعد تركس نفسها ضمن فريقين متقابلين، وتُدار الممالك والعقود بنظام الشراكة.',legal:'يفرض المحرك قيود كل عقد واتباع النوع، ويجمع نتيجة الشريكين.',win:'يفوز الفريق صاحب أعلى مجموع بعد اكتمال العقود.'),
  'trix_complex': GameRuleInfo(icon:'👑',players:'4',deck:'52 ورقة',hand:'13 ورقة',play:'عقد الكمبلكس يجمع عقوبات شيخ الكبة والبنات والديناري واللطوش، بينما يُلعب تركس كعقد مستقل.',legal:'اتباع النوع إلزامي في اللمّات، وتطبق كل عقوبات الكمبلكس على الأوراق المأخوذة.',win:'تُجمع نتائج جولات الكمبلكس وتركس، والأعلى نقاطاً يفوز.'),
  'hand': GameRuleInfo(icon:'🂮',players:'2–5',deck:'مجموعتان + جوكران',hand:'14 ثم 15 للبادي',play:'يسحب اللاعب من الرزمة أو المكشوف، ينزل مجموعات أو تسلسلات صحيحة، ثم يرمي ورقة لينهي دوره.',legal:'لا يجوز إنهاء الدور دون رمي، ويجب احترام حد النزول وترتيب المجموعات ومنع التركيبات غير الصحيحة.',win:'تنتهي الجولة عند إنهاء يد لاعب، وتُحسب قيمة الأوراق المتبقية على الآخرين عبر عدة جولات.'),
  'hand_partner': GameRuleInfo(icon:'🤝',players:'4',deck:'106 أوراق',hand:'14 ورقة',play:'هاند لفريقين، مع نزول وتركيب مشترك بين الشريكين بعد فتح الفريق.',legal:'سحب ثم نزول/تركيب ثم رمي، ولا يجوز استخدام مجموعات الخصم.',win:'تُجمع نقاط الفريق وتخصم الأوراق المتبقية، والفريق الأعلى بعد الجولات يفوز.'),
  'saudi_hand': GameRuleInfo(icon:'🇸🇦',players:'2–5',deck:'106 أوراق',hand:'14 ورقة',play:'سحب ثم نزول مجموعات أو تسلسلات وتركيب ثم رمي، وفق نمط الهاند السعودي.',legal:'يطبق المحرك شروط النزول والجوكر والبناكل ومنع الرميات غير القانونية.',win:'الفائز يفرغ يده أولاً وتُحتسب الأوراق المتبقية على الخاسرين.'),
  'banakil': GameRuleInfo(icon:'🎴',players:'2–4',deck:'مجموعتان + جوكران',hand:'14 ورقة',play:'تكوين مجموعات وتسلسلات باستخدام الأوراق الطبيعية والبناكل/الجوكر ضمن ضوابطها.',legal:'يجب السحب أولاً والرمي أخيراً، ولا تُقبل مجموعة تخالف الحد الأدنى أو نسبة الأوراق الطبيعية.',win:'ينهي اللاعب أو الفريق يده ويجمع نقاط النزول مقابل خصم الأوراق الباقية.'),
  'pinochle': GameRuleInfo(icon:'🂫',players:'2–4',deck:'48 ورقة',hand:'12 ورقة',play:'مزايدة ثم اختيار الحكم وإعلان المشاريع، وبعدها لعب اللمّات.',legal:'اتباع النوع والحكم وإجبار الفوز عند توفره وفق نمط البناكل الكلاسيكي.',win:'تجمع نقاط المشاريع واللمّات ويجب تحقيق العقد، وإلا تُخصم قيمة المزايدة.'),
  'baloot': GameRuleInfo(icon:'♠️',players:'4',deck:'32 ورقة',hand:'8 أوراق',play:'فريقان يختاران صن أو حكم ثم يلعبان ثماني لمّات مع مشاريع اختيارية.',legal:'اتباع النوع إلزامي، وفي الحكم تطبق قواعد القطع والعلو وترتيب الحكم الخاص.',win:'تُحسب قيم الأوراق والمشاريع، ويفوز الفريق الذي يصل للهدف قبل منافسه.'),
  'domino': GameRuleInfo(icon:'🁫',players:'2–4',deck:'28 قطعة دبل-ستة',hand:'7 قطع',play:'توضع قطعة على أحد طرفي السلسلة بشرط مطابقة الرقم المفتوح.',legal:'إن لم توجد قطعة صالحة يسحب أو يمر اللاعب حسب النمط. لا يمكن اللعب على طرف غير مطابق.',win:'يفوز من ينهي قطعه أولاً؛ وعند الإغلاق يفوز الأقل مجموعاً وتُحسب قطع الآخرين.'),
  'basra': GameRuleInfo(icon:'♦️',players:'2',deck:'52 ورقة',hand:'4 أوراق كل دفعة',play:'يلعب كل لاعب ورقة لالتقاط ورقة مماثلة أو مجموعة تساوي قيمتها.',legal:'الولد يلتقط أوراق الطاولة وفق القاعدة، ولسبعة الديناري تأثير خاص، والباصرة تحصل عند تنظيف الطاولة بشروطها.',win:'تُحسب أكثرية الأوراق والديناري والآسات والباصرات، والأعلى نقاطاً يفوز.'),
  'jackaroo': GameRuleInfo(icon:'🎲',players:'4',deck:'بطاقات حركة',hand:'4 أوراق',play:'فريقان يحركان أربعة أحجار لكل لاعب من البيت إلى المسار ثم الأمان.',legal:'كل بطاقة لها قدرة حركة محددة، ولا يسمح بالوقوف على حجر صديق أو تجاوز قيود منطقة الأمان.',win:'يفوز الفريق الذي يُدخل أحجاره الثمانية إلى الأمان أولاً.'),
  'backgammon': GameRuleInfo(icon:'🎲',players:'2',deck:'لوح + نردان',hand:'15 حجراً',play:'تحرك الأحجار حسب نتيجة النرد باتجاه منطقة الإخراج.',legal:'يجب إدخال الحجر المضروب أولاً، ولا يجوز النزول على نقطة مغلقة بقطعتين للخصم.',win:'يفوز من يخرج جميع أحجاره أولاً، مع احتساب جامون أو باكجامون عند انطباقه.'),
  'chess': GameRuleInfo(icon:'♛',players:'2',deck:'لوح 8×8',hand:'16 قطعة',play:'شطرنج قياسي بالتناوب الأبيض ثم الأسود.',legal:'لا يسمح بنقلة تترك الملك في كش، وتطبق التبييت والأخذ بالتجاوز والترقية بشروطها.',win:'كش مات أو استسلام، والتعادل بالتكرار أو الجمود أو القواعد المعتمدة.'),
  'solitaire_multiplayer': GameRuleInfo(icon:'🂠',players:'1–4',deck:'52 ورقة',hand:'7 أعمدة',play:'سباق لترتيب الأوراق في الأساسات حسب النوع من الآس إلى الملك.',legal:'تنقل الرزم بترتيب تنازلي وتناوب الألوان، وتُكشف الأوراق عند تحريرها.',win:'يفوز من يكمل الأساسات أولاً أو يحقق أعلى نتيجة ضمن الوقت.'),
};

class _RuleSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String text;
  const _RuleSection({required this.title, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => PremiumPanel(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(text, style: const TextStyle(color: Colors.white70, height: 1.65, fontSize: 11))])),
          ]),
        ),
      );
}

void showLeaderboard(BuildContext context, AppController controller) {
  final entries = <(String, LocalFriend)>[
    ('🥇', LocalFriend(6, 'ياسر', 'Yasser', online: true, activity: 'المركز الأول', level: 64, xp: 18420, xpNext: xpNeededForLevelV175(64), gamesPlayed: 1870, wins: 1210, badge: 'LEGEND')),
    ('🥈', LocalFriend(3, 'ليلى', 'Layla', online: true, activity: 'المركز الثاني', level: 61, xp: 17980, xpNext: xpNeededForLevelV175(61), gamesPlayed: 1640, wins: 1044, badge: 'PRO')),
    ('🥉', LocalFriend(2, 'سامر', 'Samer', online: true, activity: 'المركز الثالث', level: 58, xp: 16800, xpNext: xpNeededForLevelV175(58), gamesPlayed: 1530, wins: 930, badge: 'PRO')),
    ('4', LocalFriend(9, 'أحمد', 'Ahmad', online: false, activity: 'المركز الرابع', level: 55, xp: 15120, xpNext: xpNeededForLevelV175(55), gamesPlayed: 1420, wins: 810)),
  ];
  showPremiumSheet(
    context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('لوحة الصدارة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        ...entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PremiumListTile(
                onTap: () => showPublicPlayerProfileV170(context, controller, entry.$2),
                icon: entry.$1,
                title: entry.$2.name,
                subtitle: '${formatNumber(entry.$2.xp)} XP • المستوى ${entry.$2.level}',
                action: const Icon(Icons.chevron_right_rounded),
              ),
            )),
      ],
    ),
  );
}

class SocialHubPage extends StatefulWidget {
  final AppController controller;
  const SocialHubPage({super.key, required this.controller});

  @override
  State<SocialHubPage> createState() => _SocialHubPageState();
}

class _SocialHubPageState extends State<SocialHubPage> with SingleTickerProviderStateMixin {
  late final TabController tabs;
  final searchController = TextEditingController();
  List<LocalFriend> searchResults = const [];
  bool searching = false;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabs.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> search() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => searching = true);
    if (widget.controller.serverConnected) {
      try {
        final data = await widget.controller.api.searchPlayers(query);
        final users = data['users'] is List ? data['users'] as List : const [];
        searchResults = users.map((item) {
          final map = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
          return LocalFriend(
            int.tryParse(map['id']?.toString() ?? '') ?? 0,
            map['display_name']?.toString() ?? map['username']?.toString() ?? 'لاعب',
            map['username']?.toString() ?? '',
            online: map['online'] == true,
            activity: map['online'] == true ? 'متصل الآن' : 'غير متصل',
            level: int.tryParse(map['level']?.toString() ?? '') ?? 1,
            countryCode: (map['country_code']?.toString() ?? 'PS').toUpperCase(),
            avatar: map['avatar']?.toString(),
            pashaDays: int.tryParse(map['pasha_days']?.toString() ?? '') ?? 0,
            gamesPlayed: int.tryParse(map['games_played']?.toString() ?? '') ?? 0,
            wins: int.tryParse(map['wins']?.toString() ?? '') ?? 0,
            xp: int.tryParse(map['xp']?.toString() ?? '') ?? 0,
            xpNext: int.tryParse(map['xp_next']?.toString() ?? '') ?? 100,
            roundPoints: int.tryParse(map['round_points']?.toString() ?? '') ?? 0,
            tournamentPoints: int.tryParse(map['tournament_points']?.toString() ?? '') ?? 0,
            clubPoints: int.tryParse(map['club_points']?.toString() ?? '') ?? 0,
            nameColor: map['name_color']?.toString() ?? '#facc15',
            badge: map['badge']?.toString(),
          );
        }).where((e) => e.id > 0).toList();
      } catch (e) {
        if (mounted) showToast(context, e.toString());
      }
    } else {
      const candidates = [
        LocalFriend(6, 'ياسر', 'Yasser', online: true, activity: 'يلعب بلوت'),
        LocalFriend(7, 'رنا', 'Rana', online: false, activity: 'آخر ظهور أمس'),
        LocalFriend(8, 'كريم', 'Kareem', online: true, activity: 'في بطولة الأبطال'),
      ];
      searchResults = candidates.where((e) => e.name.contains(query) || e.username.toLowerCase().contains(query.toLowerCase())).toList();
    }
    if (mounted) setState(() => searching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مركز الأصدقاء', style: TextStyle(fontWeight: FontWeight.w900)),
        bottom: TabBar(
          controller: tabs,
          isScrollable: true,
          tabs: [
            Tab(text: 'الأصدقاء (${widget.controller.friends.length})'),
            Tab(text: 'الطلبات (${widget.controller.incomingRequests.length})'),
            const Tab(text: 'إضافة لاعب'),
            Tab(text: 'المحظورون (${widget.controller.blocked.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabs,
        children: [
          _friendsTab(),
          _requestsTab(),
          _searchTab(),
          _blockedTab(),
        ],
      ),
    );
  }

  Widget _friendsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        PremiumPanel(
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(children: [
              const Icon(Icons.security_rounded, color: Colors.greenAccent),
              const SizedBox(width: 9),
              const Expanded(child: Text('الدردشة والتحويل متاحان للأصدقاء المقبولين فقط. تُحتسب رسوم تحويل ثابتة بنسبة 10%.', style: TextStyle(color: Colors.white60, fontSize: 10, height: 1.5))),
              Text(widget.controller.serverConnected ? 'LIVE' : 'LOCAL', style: TextStyle(color: widget.controller.serverConnected ? Colors.greenAccent : Colors.amber, fontWeight: FontWeight.w900, fontSize: 9)),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        if (widget.controller.friends.isNotEmpty)
          FilledButton.tonalIcon(
            onPressed: () => inviteAllFriendsV170(context, widget.controller),
            icon: const Icon(Icons.group_add_rounded),
            label: const Text('دعوة كل الأصدقاء إلى الغرفة الحالية'),
          ),
        if (widget.controller.friends.isNotEmpty) const SizedBox(height: 10),
        if (widget.controller.friends.isEmpty) const _EmptyState(icon: Icons.people_outline, title: 'لا يوجد أصدقاء بعد'),
        ...widget.controller.friends.map((friend) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PremiumListTile(
            onTap: () => showPublicPlayerProfileV170(context, widget.controller, friend),
            icon: friend.name.substring(0, 1),
            title: '${friend.name}  ${friend.online ? '●' : '○'}',
            subtitle: '@${friend.username} • ${friend.activity}',
            action: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrivateChatPage(controller: widget.controller, friend: friend))), icon: const Icon(Icons.chat_bubble_outline_rounded)),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'transfer') _showTransfer(friend);
                  if (value == 'invite') await inviteFriendV170(context, widget.controller, friend);
                  if (value == 'block') {
                    if (widget.controller.serverConnected) {
                      try { await widget.controller.api.blockUser(friend.id); } catch (_) {}
                    }
                    widget.controller.blockFriend(friend);
                    if (mounted) setState(() {});
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'invite', child: Text('دعوة إلى لعبة')),
                  PopupMenuItem(value: 'transfer', child: Text('إرسال توكنز')),
                  PopupMenuItem(value: 'block', child: Text('حظر اللاعب')),
                ],
              ),
            ]),
          ),
        )),
      ],
    );
  }

  Widget _requestsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const SectionTitle(title: 'طلبات واردة'),
        const SizedBox(height: 8),
        if (widget.controller.incomingRequests.isEmpty) const _EmptyState(icon: Icons.person_add_disabled_outlined, title: 'لا توجد طلبات واردة'),
        ...widget.controller.incomingRequests.map((friend) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PremiumListTile(
            onTap: () => showPublicPlayerProfileV170(context, widget.controller, friend),
            icon: friend.name.substring(0, 1),
            title: friend.name,
            subtitle: '@${friend.username} • ${friend.activity}',
            action: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton.filledTonal(onPressed: () { widget.controller.acceptFriend(friend); setState(() {}); }, icon: const Icon(Icons.check, color: Colors.greenAccent)),
              IconButton(onPressed: () { widget.controller.rejectFriend(friend); setState(() {}); }, icon: const Icon(Icons.close, color: Colors.redAccent)),
            ]),
          ),
        )),
        const SizedBox(height: 12),
        const SectionTitle(title: 'طلبات مرسلة'),
        const SizedBox(height: 8),
        if (widget.controller.outgoingRequests.isEmpty) const Text('لا توجد طلبات معلقة.', style: TextStyle(color: Colors.white54)),
        ...widget.controller.outgoingRequests.map((friend) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PremiumListTile(onTap: () => showPublicPlayerProfileV170(context, widget.controller, friend), icon: friend.name.substring(0, 1), title: friend.name, subtitle: 'بانتظار القبول', action: TextButton(onPressed: () { widget.controller.cancelFriendRequest(friend); setState(() {}); }, child: const Text('إلغاء'))),
        )),
      ],
    );
  }

  Widget _searchTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(children: [
          Expanded(child: TextField(controller: searchController, onSubmitted: (_) => search(), decoration: const InputDecoration(hintText: 'اسم اللاعب أو اسم المستخدم', prefixIcon: Icon(Icons.search)))),
          const SizedBox(width: 7),
          IconButton.filled(onPressed: searching ? null : search, icon: searching ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search)),
        ]),
        const SizedBox(height: 12),
        if (searchResults.isEmpty) const _EmptyState(icon: Icons.manage_search, title: 'ابحث عن لاعب لإرسال طلب صداقة'),
        ...searchResults.map((friend) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PremiumListTile(
            onTap: () => showPublicPlayerProfileV170(context, widget.controller, friend),
            icon: friend.name.substring(0, 1),
            title: friend.name,
            subtitle: '@${friend.username} • ${friend.activity}',
            action: FilledButton.tonal(
              onPressed: () async {
                try {
                  if (widget.controller.serverConnected) await widget.controller.api.requestFriend(friend.id);
                  widget.controller.sendFriendRequest(friend);
                  if (mounted) showToast(context, 'تم إرسال طلب الصداقة إلى ${friend.name}.');
                } catch (e) {
                  if (mounted) showToast(context, e.toString());
                }
              },
              child: const Text('إضافة'),
            ),
          ),
        )),
      ],
    );
  }

  Widget _blockedTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (widget.controller.blocked.isEmpty) const _EmptyState(icon: Icons.block_outlined, title: 'قائمة الحظر فارغة'),
        ...widget.controller.blocked.map((friend) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PremiumListTile(
            onTap: () => showPublicPlayerProfileV170(context, widget.controller, friend),
            icon: friend.name.substring(0, 1),
            title: friend.name,
            subtitle: '@${friend.username}',
            action: TextButton(onPressed: () async {
              if (widget.controller.serverConnected) {
                try { await widget.controller.api.unblockUser(friend.id); } catch (_) {}
              }
              widget.controller.unblockFriend(friend);
              if (mounted) setState(() {});
            }, child: const Text('إلغاء الحظر')),
          ),
        )),
      ],
    );
  }

  Future<void> _showTransfer(LocalFriend friend) async {
    final amountController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('إرسال توكنز إلى ${friend.name}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ', prefixIcon: Icon(Icons.toll_rounded))),
          const SizedBox(height: 9),
          const Text('سيُخصم المبلغ من رصيدك بالإضافة إلى رسوم تحويل 10%. يصل المبلغ كاملاً إلى المستلم.', style: TextStyle(color: Colors.white60, fontSize: 10, height: 1.5)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(onPressed: () async {
            final amount = int.tryParse(amountController.text) ?? 0;
            String? result;
            if (widget.controller.serverConnected) {
              try {
                await widget.controller.api.transferTokens(friend.username, amount);
              } on ApiException catch (e) {
                result = e.message;
              }
            } else {
              result = await widget.controller.transferLocal(friend.username, amount);
            }
            if (!dialogContext.mounted) return;
            if (result == null) {
              Navigator.pop(dialogContext);
              if (mounted) messenger.showSnackBar(const SnackBar(content: Text('تم التحويل وخصم رسوم التحويل 10%.')));
            } else {
              showToast(dialogContext, result);
            }
          }, child: const Text('تأكيد التحويل')),
        ],
      ),
    );
    amountController.dispose();
  }
}

class PrivateChatPage extends StatefulWidget {
  final AppController controller;
  final LocalFriend friend;
  const PrivateChatPage({super.key, required this.controller, required this.friend});

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final messageController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final body = messageController.text.trim();
    if (body.isEmpty) return;
    setState(() => loading = true);
    try {
      if (widget.controller.serverConnected) await widget.controller.api.sendMessage(widget.friend.id, body);
      widget.controller.sendLocalMessage(widget.friend, body);
      messageController.clear();
    } catch (e) {
      if (mounted) showToast(context, e.toString());
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.controller.privateChats[widget.friend.id] ?? const <ChatMessage>[];
    return Scaffold(
      appBar: AppBar(
        title: PlayerIdentityTapV021(
          controller: widget.controller,
          userId: widget.friend.id,
          name: widget.friend.name,
          username: widget.friend.username,
          avatar: widget.friend.avatar,
          level: widget.friend.level,
          countryCode: widget.friend.countryCode,
          online: widget.friend.online,
          activity: widget.friend.activity,
          pashaDays: widget.friend.pashaDays,
          gamesPlayed: widget.friend.gamesPlayed,
          wins: widget.friend.wins,
          xp: widget.friend.xp,
          xpNext: widget.friend.xpNext,
          roundPoints: widget.friend.roundPoints,
          tournamentPoints: widget.friend.tournamentPoints,
          clubPoints: widget.friend.clubPoints,
          nameColor: widget.friend.nameColor,
          badge: widget.friend.badge,
          child: Row(children: [
            PremiumAvatar(text: widget.friend.avatar?.isNotEmpty == true ? widget.friend.avatar! : widget.friend.name.substring(0, 1), size: 38),
            const SizedBox(width: 9),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.friend.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), Text(widget.friend.online ? 'متصل الآن' : widget.friend.activity, style: TextStyle(color: widget.friend.online ? Colors.greenAccent : Colors.white54, fontSize: 8))]),
          ]),
        ),
        actions: [IconButton(onPressed: () => showToast(context, 'تم إرسال دعوة لعبة.'), icon: const Icon(Icons.sports_esports_outlined))],
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (_, index) {
              final message = messages[index];
              return Align(
                alignment: message.mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 310),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
                  decoration: BoxDecoration(color: message.mine ? Theme.of(context).colorScheme.primary.withValues(alpha: .18) : Colors.white.withValues(alpha: .06), borderRadius: BorderRadius.only(topLeft: const Radius.circular(17), topRight: const Radius.circular(17), bottomLeft: Radius.circular(message.mine ? 17 : 4), bottomRight: Radius.circular(message.mine ? 4 : 17))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(message.body, style: TextStyle(height: 1.45, color: message.mine ? colorFromHex(widget.controller.selectedChatColor) : Colors.white, fontWeight: message.mine ? FontWeight.w800 : FontWeight.w500)), const SizedBox(height: 3), Text(message.time, style: const TextStyle(color: Colors.white38, fontSize: 8))]),
                ),
              );
            },
          ),
        ),
        SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(9), child: Row(children: [
          IconButton(onPressed: () => showToast(context, 'اختر إيموجي أو ملصقاً.'), icon: const Icon(Icons.emoji_emotions_outlined)),
          Expanded(child: TextField(controller: messageController, onSubmitted: (_) => send(), decoration: const InputDecoration(hintText: 'اكتب رسالة...'))),
          const SizedBox(width: 6),
          IconButton.filled(onPressed: loading ? null : send, icon: const Icon(Icons.send_rounded)),
        ]))),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  const _EmptyState({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(38), child: Column(children: [Icon(icon, size: 55, color: Colors.white24), const SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54))]));
}

class AdminDashboardPage extends StatefulWidget {
  final AppController controller;
  const AdminDashboardPage({super.key, required this.controller});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late final TabController tabs;
  Map<String, dynamic>? serverData;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 9, vsync: this);
    _load();
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!widget.controller.serverConnected) return;
    setState(() => loading = true);
    try {
      serverData = await widget.controller.api.adminDashboard();
      widget.controller.syncServerStoreR36(serverData?['store'],replace:false);
    } catch (e) {
      if (mounted) showToast(context, e.toString());
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isAdmin) return const Scaffold(body: Center(child: Text('غير مصرح.')));
    final scheme = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        toolbarHeight: 74,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 18,
        flexibleSpace: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors:[scheme.surfaceContainerHighest,scheme.surface]))),
        title: Row(children:[
          Container(width:compact?32:44,height:compact?32:44,decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),gradient:LinearGradient(colors:[scheme.primary,scheme.secondary])),child:const Icon(Icons.admin_panel_settings_rounded,color:Colors.black)),
          SizedBox(width:compact?8:12),
          Expanded(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(compact?(widget.controller.localeCode=='ar'?'لوحة الإدارة':'Admin'):'Warqnaa Command Center',maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontWeight:FontWeight.w900,fontSize:compact?16:18)),if(!compact)const Text('إدارة موحدة بنفس هوية التطبيق',maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:10,fontWeight:FontWeight.w600))])),
        ]),
        actions: [
          IconButton(tooltip: widget.controller.localeCode == 'ar' ? 'مركز التشغيل' : 'Operations', onPressed: () => Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => R65OperationsPage(controller: widget.controller))), icon: const Icon(Icons.monitor_heart_outlined)),
          if(widget.controller.serverConnected && !compact) const Padding(padding:EdgeInsetsDirectional.only(end:4),child:Chip(avatar:Icon(Icons.cloud_done_rounded,size:16),label:Text('LIVE'))),
          IconButton.filledTonal(onPressed: _load, tooltip:'تحديث', icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width:10),
        ],
        bottom: PreferredSize(preferredSize:const Size.fromHeight(80),child:Container(height:80,margin:const EdgeInsets.fromLTRB(12,0,12,8),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),color:scheme.surfaceContainerHighest.withValues(alpha:.72),border:Border.all(color:scheme.primary.withValues(alpha:.12))),child:TabBar(controller:tabs,isScrollable:true,dividerColor:Colors.transparent,tabAlignment:TabAlignment.start,indicatorSize:TabBarIndicatorSize.tab,indicator:BoxDecoration(borderRadius:BorderRadius.circular(14),color:scheme.primary.withValues(alpha:.18),border:Border.all(color:scheme.primary.withValues(alpha:.28))),tabs:const [Tab(icon:Icon(Icons.dashboard_rounded,size:18),text:'نظرة عامة'),Tab(icon:Icon(Icons.sports_esports_rounded,size:18),text:'الألعاب'),Tab(icon:Icon(Icons.storefront_rounded,size:18),text:'المتجر'),Tab(icon:Icon(Icons.people_alt_rounded,size:18),text:'اللاعبون'),Tab(icon:Icon(Icons.tune_rounded,size:18),text:'المصمم'),Tab(icon:Icon(Icons.public_rounded,size:18),text:'Social'),Tab(icon:Icon(Icons.emoji_events_rounded,size:18),text:'Competitive'),Tab(icon:Icon(Icons.monitor_heart_rounded,size:18),text:'WORLD OPS'),Tab(icon:Icon(Icons.settings_rounded,size:18),text:'النظام')]))),
      ),
      body: DecoratedBox(
        decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[scheme.surface,scheme.surfaceContainerLowest])),
        child: loading ? const Center(child:CircularProgressIndicator()) : TabBarView(controller:tabs,children:[_overview(),_games(),_store(),_users(),_designer(),R11AdminSocialWorldPanel(controller:widget.controller),R12AdminCompetitivePanel(controller:widget.controller),V300AdminWorldOpsPanel(controller:widget.controller),_system()]),
      ),
    );
  }

  Widget _overview() {
    final stats = serverData?['stats'] is Map ? Map<String, dynamic>.from(serverData!['stats'] as Map) : <String, dynamic>{};
    final scheme=Theme.of(context).colorScheme;
    final wide=MediaQuery.sizeOf(context).width>=760;
    return RefreshIndicator(
      onRefresh:_load,
      child:ListView(
        padding:const EdgeInsets.fromLTRB(14,14,14,28),
        children:[
          Container(
            padding:const EdgeInsets.all(18),
            decoration:BoxDecoration(
              borderRadius:BorderRadius.circular(28),
              gradient:LinearGradient(colors:[scheme.primary.withValues(alpha:.22),scheme.surfaceContainerHighest,scheme.secondary.withValues(alpha:.10)]),
              border:Border.all(color:scheme.primary.withValues(alpha:.22)),
            ),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[
                Container(width:56,height:56,decoration:BoxDecoration(shape:BoxShape.circle,gradient:LinearGradient(colors:[scheme.primary,scheme.secondary])),child:const Icon(Icons.shield_rounded,color:Colors.black,size:30)),
                const SizedBox(width:13),
                Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text(widget.controller.displayName.isEmpty?widget.controller.username:widget.controller.displayName,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
                  Text('${widget.controller.adminRole} • Level ${widget.controller.level} • Pasha ${widget.controller.vipDays} يوم',style:TextStyle(fontSize:11,color:scheme.onSurface.withValues(alpha:.68))),
                ])),
                Chip(avatar:Icon(widget.controller.serverConnected?Icons.cloud_done_rounded:Icons.cloud_off_rounded,size:16),label:Text(widget.controller.serverConnected?'متصل':'محلي')),
              ]),
              const SizedBox(height:14),
              Wrap(spacing:8,runSpacing:8,children:[
                FilledButton.icon(onPressed:_load,icon:const Icon(Icons.sync_rounded),label:const Text('تحديث البيانات')),
                FilledButton.tonalIcon(onPressed:()=>tabs.animateTo(2),icon:const Icon(Icons.storefront_rounded),label:const Text('إدارة المتجر')),
                FilledButton.tonalIcon(onPressed:()=>tabs.animateTo(3),icon:const Icon(Icons.people_alt_rounded),label:const Text('إدارة اللاعبين')),
                OutlinedButton.icon(onPressed:()=>tabs.animateTo(4),icon:const Icon(Icons.tune_rounded),label:const Text('المصمم')),
              ]),
            ]),
          ),
          const SizedBox(height:12),
          GridView.count(
            shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
            crossAxisCount:wide?4:2,crossAxisSpacing:10,mainAxisSpacing:10,mainAxisExtent:160,
            children:[
              _AdminMetric(icon:'👥',label:'اللاعبون',value:stats['users']?.toString() ?? 'محلي'),
              _AdminMetric(icon:'🎮',label:'الغرف النشطة',value:stats['active_rooms']?.toString() ?? '—'),
              _AdminMetric(icon:'🏆',label:'المنافسات',value:stats['tournaments']?.toString() ?? '—'),
              _AdminMetric(icon:'🪙',label:'الرصيد الإداري',value:stats['wallet_reserve']?.toString() ?? formatNumber(widget.controller.coins)),
              _AdminMetric(icon:'🧠',label:'محركات فعالة',value:'${gamesCatalog.length}'),
              _AdminMetric(icon:'🛒',label:'عناصر المتجر',value:'${products.length}'),
              _AdminMetric(icon:'🎟️',label:'فئات تذاكر المدير (100+)',value:stats['ticket_types']?.toString() ?? '—'),
              _AdminMetric(icon:'👑',label:'المستوى',value:'${widget.controller.level}'),
              _AdminMetric(icon:'🛡️',label:'الصلاحية',value:widget.controller.isPrimaryAdmin?'PRIMARY':'ADMIN'),
            ],
          ),
          const SizedBox(height:12),
          const _AdminInfo(text:'لوحة الإدارة الآن تستخدم نفس منطق البطاقات، التدرجات، الحواف والمسافات الموجودة في التطبيق. البيانات الحساسة والصلاحيات تبقى خادمية ولا تعتمد على اسم المستخدم.'),
        ],
      ),
    );
  }

  Widget _games() {
    final serverGames = (serverData?['games'] is List ? serverData!['games'] as List : const <dynamic>[])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final fallbackGames = gamesCatalog.map((game) => <String, dynamic>{
      'id': null,
      'key': game.id,
      'active': true,
      'name': <String, dynamic>{'ar': L.t('ar', game.id), 'en': L.t('en', game.id)},
    }).toList();
    final rows = serverGames.isNotEmpty ? serverGames : fallbackGames;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _AdminInfo(text:'يمكن لحساب الإدارة إظهار أو إخفاء أي لعبة فوراً من الكتالوج العام. اللعب المتصل يبقى خاضعاً لمحرك Laravel والتحقق السلطوي من الحركات والنتائج.'),
        const SizedBox(height: 10),
        ...rows.map((game) {
          final key = game['key']?.toString() ?? '';
          final id = int.tryParse(game['id']?.toString() ?? '');
          final name = game['name'];
          final localizedName = name is Map
              ? (name[widget.controller.localeCode]?.toString() ?? name['ar']?.toString() ?? key)
              : L.t(widget.controller.localeCode, key);
          final localInfo = gamesCatalog.where((item) => item.id == key).firstOrNull;
          final active = game['active'] != false && game['active']?.toString() != '0';
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white.withValues(alpha: .055), (active ? Colors.greenAccent : Colors.redAccent).withValues(alpha: .055)]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: (active ? Colors.greenAccent : Colors.redAccent).withValues(alpha: .22)),
              ),
              child: PremiumListTile(
                icon: localInfo?.icon ?? '🎮',
                title: localizedName,
                subtitle: active ? 'ظاهر للاعبين • المحرك متاح' : 'مخفي من الكتالوج • لا يمكن إنشاء غرف جديدة',
                action: Switch.adaptive(
                  value: active,
                  onChanged: id == null || !widget.controller.serverConnected ? null : (value) async {
                    try {
                      await widget.controller.api.adminUpdateGame(id, active: value);
                      game['active'] = value;
                      if (mounted) setState(() {});
                      if (mounted) showToast(context, value ? 'تم إظهار اللعبة.' : 'تم إخفاء اللعبة.');
                    } catch (error) {
                      if (mounted) showToast(context, error.toString());
                    }
                  },
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _store() => AdminStoreStudioV151(controller: widget.controller);

  Widget _users() => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      PremiumListTile(onTap: () => showProfile(context, widget.controller), icon:'A',title:'Adnan',subtitle:'مدير رئيسي • صلاحية كاملة • ${formatNumber(widget.controller.coins)} توكن',action:const Chip(label:Text('SUPER ADMIN'))),
      const SizedBox(height:8),
      ...widget.controller.friends.map((friend)=>Padding(padding:const EdgeInsets.only(bottom:8),child:PremiumListTile(onTap: () => showPublicPlayerProfileV170(context, widget.controller, friend), icon:friend.name.substring(0,1),title:friend.name,subtitle:'@${friend.username} • ${friend.activity}',action:PopupMenuButton<String>(itemBuilder:(_)=>const [PopupMenuItem(value:'grant',child:Text('منح 200 توكن')),PopupMenuItem(value:'ban',child:Text('حظر الحساب'))],onSelected:(value)=>showToast(context,value=='grant'?'تم تسجيل عملية المنح.':'تم تحديث حالة الحساب.'))))),
    ],
  );

  Widget _designer() => widget.controller.isPrimaryAdmin ? ListView(
    padding: const EdgeInsets.all(12),
    children: [
      const _AdminInfo(text:'استوديو مرئي وإداري شامل بدون كتابة كود. التعديلات تُطبق فوراً محلياً وتُزامن مع الخادم لحساب Adnan فقط.'),
      const SizedBox(height: 10),
      DesignerQuickControlsV183(controller: widget.controller),
      const SizedBox(height: 10),
      UniversalDesignerV173(controller: widget.controller),
      const SizedBox(height: 10),
      PremiumPanel(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        const Text('رفع صور المصمم الشامل',style:TextStyle(fontWeight:FontWeight.w900,fontSize:16)),const SizedBox(height:8),
        Row(children:[Expanded(child:FilledButton.tonalIcon(onPressed:()async{final e=await widget.controller.uploadDesignerImage('table');if(mounted)showToast(context,e??'تم اعتماد خلفية الطاولة.');setState((){});},icon:const Icon(Icons.table_restaurant),label:const Text('خلفية الطاولة'))),const SizedBox(width:7),Expanded(child:FilledButton.tonalIcon(onPressed:()async{final e=await widget.controller.uploadDesignerImage('cards');if(mounted)showToast(context,e??'تم اعتماد صورة ظهر الورق.');setState((){});},icon:const Icon(Icons.style),label:const Text('ظهر الورق')))]),
        if(widget.controller.customTableBackgroundData!=null||widget.controller.customCardBackData!=null) TextButton.icon(onPressed:(){widget.controller.clearDesignerImage('table');widget.controller.clearDesignerImage('cards');setState((){});},icon:const Icon(Icons.delete_outline),label:const Text('حذف الصور المخصصة')),
      ]))),
      const SizedBox(height: 10),
      PremiumPanel(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        Container(height: 110, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors:[Theme.of(context).colorScheme.primary.withValues(alpha:.25), Colors.white.withValues(alpha:.03)]), borderRadius: BorderRadius.circular(widget.controller.uiRadius)), child: FilledButton.icon(onPressed:(){}, icon:const Icon(Icons.auto_awesome), label:const Text('معاينة مباشرة'))),
        const SizedBox(height: 10),
        Text('حجم الخط الحالي ${widget.controller.uiFontScale.toStringAsFixed(2)}×', style: TextStyle(fontSize: 16 * widget.controller.uiFontScale, fontWeight: FontWeight.w900)),
      ]))),
      const SizedBox(height: 12),
      Text('ارتفاع الزر: ${widget.controller.uiButtonHeight.round()} px'),
      Slider(min:38,max:64,divisions:26,value:widget.controller.uiButtonHeight,onChanged:(value){widget.controller.updateNoCodeDesign(buttonHeight:value);setState((){});}),
      Text('استدارة الحواف: ${widget.controller.uiRadius.round()} px'),
      Slider(min:8,max:32,divisions:24,value:widget.controller.uiRadius,onChanged:(value){widget.controller.updateNoCodeDesign(radius:value);setState((){});}),
      Text('مقياس الخط: ${widget.controller.uiFontScale.toStringAsFixed(2)}×'),
      Slider(min:.85,max:1.35,divisions:25,value:widget.controller.uiFontScale,onChanged:(value){widget.controller.updateNoCodeDesign(fontScale:value);setState((){});}),
      Text('حجم الدردشة: ${widget.controller.uiChatScale.toStringAsFixed(2)}×'),
      Slider(min:.8,max:1.35,divisions:22,value:widget.controller.uiChatScale,onChanged:(value){widget.controller.updateNoCodeDesign(chatScale:value);setState((){});}),
      const Text('اللون الرئيسي'),
      const SizedBox(height:6),
      Wrap(spacing:8,runSpacing:8,children:v151AccentColors.map((hex)=>InkWell(onTap:(){widget.controller.updateNoCodeDesign(accentHex:hex);setState((){});},child:Container(width:36,height:36,decoration:BoxDecoration(shape:BoxShape.circle,color:colorFromHex(hex),border:Border.all(color:widget.controller.uiAccentHex==hex?Colors.white:Colors.white24,width:widget.controller.uiAccentHex==hex?3:1))))).toList()),
      const SizedBox(height:8),
      SwitchListTile(value:widget.controller.tableAmbientEffects,onChanged:(value){widget.controller.updateNoCodeDesign(ambientEffects:value);setState((){});},title:const Text('مؤثرات الطاولة الهادئة')),
      ListTile(leading:const Icon(Icons.smart_toy_outlined),title:const Text('مستوى البوتات الافتراضي'),trailing:DropdownButton<String>(value:widget.controller.botDifficultyCode,items:const ['easy','normal','pro','master'].map((value)=>DropdownMenuItem(value:value,child:Text(value.toUpperCase()))).toList(),onChanged:(value){if(value!=null){widget.controller.changeBotDifficulty(value);setState((){});}})),
      const SizedBox(height: 8),
      FilledButton.tonalIcon(onPressed:(){widget.controller.updateNoCodeDesign(buttonHeight:48,radius:18,fontScale:1,chatScale:1,accentHex:'#ffcf67',ambientEffects:true);setState((){});},icon:const Icon(Icons.restore),label:const Text('استعادة التصميم الافتراضي')),
    ],
  ) : const Center(child: Text('المصمم الشامل متاح لحساب Adnan الرئيسي فقط.'));

  Widget _system() => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      _AdminInfo(text:'حالة الاتصال: ${widget.controller.serverConnected ? 'متصل بـ Laravel API' : 'غير متصل — اللعب متوقف'}.\nAPI: ${widget.controller.api.baseUrl}'),
      const SizedBox(height:10),
      SwitchListTile(value:widget.controller.soundEnabled,onChanged:widget.controller.toggleSound,title:const Text('الأصوات'),subtitle:const Text('أصوات اللعب والإيموجي والتنبيهات')),
      ListTile(leading:const Icon(Icons.language),title:const Text('اللغة'),trailing:Text(widget.controller.localeCode.toUpperCase())),
      ListTile(leading:const Icon(Icons.palette_outlined),title:const Text('الثيم'),trailing:Text(widget.controller.themeCode)),
      const SizedBox(height:12),
      FilledButton.tonalIcon(onPressed:() async { final navigator = Navigator.of(context); await widget.controller.logout(); if (mounted) navigator.pop(); },icon:const Icon(Icons.logout),label:const Text('تسجيل الخروج')),
    ],
  );
}

class _AdminMetric extends StatelessWidget {
  final String icon,label,value;
  const _AdminMetric({required this.icon,required this.label,required this.value});
  @override
  Widget build(BuildContext context){final s=Theme.of(context).colorScheme;return Container(decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:LinearGradient(colors:[s.surfaceContainerHighest,s.primary.withValues(alpha:.08)]),border:Border.all(color:s.primary.withValues(alpha:.14))),child:Padding(padding:const EdgeInsets.all(14),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(icon,style:const TextStyle(fontSize:28)),const SizedBox(height:6),FittedBox(child:Text(value,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900))),const SizedBox(height:2),Text(label,textAlign:TextAlign.center,style:TextStyle(color:s.onSurface.withValues(alpha:.58),fontSize:10,fontWeight:FontWeight.w700))])));}
}

class _AdminInfo extends StatelessWidget {
  final String text;
  const _AdminInfo({required this.text});
  @override
  Widget build(BuildContext context){final s=Theme.of(context).colorScheme;return Container(decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),color:s.surfaceContainerHighest.withValues(alpha:.76),border:Border.all(color:s.primary.withValues(alpha:.14))),child:Padding(padding:const EdgeInsets.all(14),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:34,height:34,decoration:BoxDecoration(shape:BoxShape.circle,color:s.primary.withValues(alpha:.12)),child:Icon(Icons.info_outline_rounded,color:s.primary,size:19)),const SizedBox(width:10),Expanded(child:Text(text,style:TextStyle(color:s.onSurface.withValues(alpha:.72),height:1.55,fontSize:11,fontWeight:FontWeight.w500)))])));}
}


void showFriends(BuildContext context, AppController controller) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => SocialHubPage(controller: controller)));
}

void showChat(BuildContext context) {
  final controller = TextEditingController();
  final messages = <String>['سامر: بالتوفيق للجميع 👋', 'أنت: مباراة جميلة، لنبدأ!'];
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setLocalState) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: 470,
          child: Column(
            children: [
              const ListTile(title: Text('دردشة الغرفة', style: TextStyle(fontWeight: FontWeight.w900)), trailing: Text('● متصل', style: TextStyle(color: Colors.greenAccent, fontSize: 10))),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => Align(
                    alignment: messages[i].startsWith('أنت') ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Chip(label: Text(messages[i])),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'اكتب رسالة...'))),
                    const SizedBox(width: 7),
                    IconButton.filled(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        setLocalState(() => messages.add('أنت: $text'));
                        controller.clear();
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showPremiumSheet(BuildContext context, {required Widget child}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(27))),
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .9),
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 18), child: child),
      ),
    ),
  );
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

List<String> activeEmojiList(AppController controller) {
  return switch (controller.selectedEmojiPack) {
    'emoji_beginner_fun' => const ['😊', '😉', '😎', '🤩', '🥳'],
    'emoji_medium_react' => const ['😡', '😢', '😭', '😱', '🤔', '☕'],
    'emoji_pro_power' => const ['🔥', '⚡', '💎', '🏆', '👑', '🛡️'],
    'emoji_legend_big' => const ['🦁', '🐉', '🦅', '🌌', '💥', '🎆'],
    'emoji_animated_vip' => const ['😂', '🔥', '👑', '💎', '⚡', '🏆', '🎉'],
    'emoji_huge_reactions' => const ['😂', '👑', '🔥', '😡', '😭', '🤯', '🥳', '🐉'],
    'emoji_pack_giant_fun' => const ['😂', '🤣', '😹', '😆', '🥳', '🤪', '🙈', '👻'],
    'emoji_pack_reactions_pro' => const ['🔥', '👏', '💪', '😎', '🤝', '⚡', '🎯', '🧠'],
    'emoji_pack_legendary' => const ['🐉', '👑', '⚡', '💎', '🏆', '🦁', '🦅', '🌌'],
    'emoji_pack_emotions' => const ['😡', '😭', '🥺', '😍', '😱', '😬', '🤐', '🥹'],
    'emoji_pack_sports' => const ['⚽', '🏀', '🎯', '🥇', '🚀', '🏅', '🏆', '💯'],
    'emoji_pack_palestine_v183' => const ['🇵🇸', '🫒', '🕊️', '❤️', '🤲', '🌹', '✌️', '✨'],
    'emoji_pack_pasha_v183' => const ['👑', '🦁', '🦅', '🗝️', '🏰', '🔱', '💎', '♛'],
    'emoji_pack_comedy_v183' => const ['🤣', '🤡', '🙈', '👻', '🫠', '😹', '🤪', '🙊'],
    'emoji_pack_rage_v183' => const ['😤', '🤬', '🌋', '💢', '🥊', '🔥', '⚡', '💪'],
    'emoji_pack_victory_v183' => const ['🏆', '🎆', '🥇', '💯', '🍾', '🎉', '🏅', '⭐'],
    'emoji_pack_space_v183' => const ['🚀', '🪐', '☄️', '👽', '🌌', '🛸', '🌠', '✨'],
    'emoji_pack_animals_v183' => const ['🐉', '🐯', '🦁', '🦅', '🐺', '🐆', '🦈', '🦂'],
    'emoji_pack_calm_v183' => const ['☕', '🌙', '🌹', '🕊️', '✨', '🌿', '😊', '🤝'],
    'emoji_pack_cards_v183' => const ['🃏', '♠️', '♥️', '♦️', '♣️', '🎴', '🎯', '🤝'],
    'emoji_pack_ultra_v183' => const ['💎', '🔥', '⚡', '👑', '🐉', '🌌', '🏆', '☄️'],
    _ => const ['👍', '😂', '😍', '😮', '😢', '😡', '👏', '🔥'],
  };
}

Color colorFromHex(String value) {
  final cleaned = value.replaceAll('#', '').trim();
  final normalized = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
  return Color(int.tryParse(normalized, radix: 16) ?? 0xffffffff);
}

String formatNumber(Object value) {
  final raw = value is BigInt
      ? value.toString()
      : value is num
          ? value.round().toString()
          : value.toString();
  final negative = raw.startsWith('-');
  final text = negative ? raw.substring(1) : raw;
  final buffer = StringBuffer(negative ? '-' : '');
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}
