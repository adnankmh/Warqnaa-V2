import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'r81_login_test.dart' show loginHost;
import 'r8_play_experience_test.dart' show host;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() { SharedPreferences.setMockInitialValues({}); AppSounds.enabled = false; });

  test('fresh local Adnan clears server identity and preserves the cached online account', () async {
    SharedPreferences.setMockInitialValues({'warqna.account.adnan.coins': '345', 'warqna.offline.hash.adnan': 'existing-credential'});
    final controller = AppController()..authToken = 'old-token'..serverConnected = true..isAdmin = true..adminRole = 'primary_admin'..currentUserId = 42;
    controller.api.token = 'old-token';
    await controller.loginAsLocalAdmin();
    expect(controller.username, 'Adnan');
    expect(controller.isAuthenticated, isTrue);
    expect(controller.isLocalAdmin, isTrue);
    expect(controller.isPrimaryAdmin, isFalse);
    expect(controller.isAdmin, isFalse);
    expect(controller.serverConnected, isFalse);
    expect(controller.authToken, isNull);
    expect(controller.api.token, isNull);
    expect(controller.currentUserId, isNull);
    expect(await controller.reconnectV173(), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('warqna.account.adnan.coins'), '345');
    expect(prefs.getString('warqna.offline.hash.adnan'), 'existing-credential');
    expect(prefs.getString('warqna.device-admin.adnan.coins'), '1000000');
    expect(prefs.getString('authToken'), isNull);
    controller.dispose();
  });

  test('guest and ordinary local registration never inherit the device administrator role', () async {
    final controller = AppController();
    await controller.loginAsLocalAdmin();
    await controller.loginAsGuest();
    expect(controller.isLocalAdmin, isFalse);
    expect(controller.adminRole, 'player');
    expect(controller.isAdmin, isFalse);
    await controller.loginAsLocalAdmin();
    expect(await controller.registerOffline('OtherPlayer', 'other@example.test', 'test-password'), isNull);
    expect(controller.isLocalAdmin, isFalse);
    expect(controller.adminRole, 'player');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('warqna.account.otherplayer.coins'), '1500');
    controller.dispose();
  });

  testWidgets('Adnan restores saved offline preferences after restart without an API session', (tester) async {
    final first = AppController();
    await first.loginAsLocalAdmin();
    expect(await first.updateHomeGames(['trix', 'basra']), isNull);
    final restored = AppController();
    await tester.runAsync(() => restored.load());
    expect(restored.ready, isTrue);
    expect(restored.isLocalAdmin, isTrue);
    expect(restored.homeGameIds, ['trix', 'basra']);
    expect(restored.authToken, isNull);
    expect(restored.api.token, isNull);
    expect(restored.serverConnected, isFalse);
    restored.connectivityTimerV173?.cancel();
    await restored.logout();
    expect(restored.isLocalAdmin, isFalse);
    first.dispose(); restored.dispose();
  });

  for (final locale in ['ar', 'en']) {
    testWidgets('offline Adnan entry opens a functional local studio $locale', (tester) async {
      tester.view.physicalSize = const Size(390, 844); tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AppController()..localeCode = locale;
      await tester.pumpWidget(loginHost(controller));
      final entry = find.byKey(const ValueKey('r9-local-admin-login'));
      await tester.ensureVisible(entry); await tester.tap(entry);
      for (var i = 0; i < 40 && find.byType(B307HomeDashboard).evaluate().isEmpty; i++) { await tester.pump(const Duration(milliseconds: 50)); }
      expect(controller.isLocalAdmin, isTrue);
      final open = find.byKey(const ValueKey('r9-open-studio'));
      expect(open, findsOneWidget);
      await tester.scrollUntilVisible(open, 120, scrollable: find.byType(Scrollable).first);
      await tester.pump();
      await tester.tap(open); await tester.pumpAndSettle();
      expect(find.byType(R9LocalStudio), findsOneWidget);
      final before = controller.tableAmbientEffects;
      await tester.ensureVisible(find.byKey(const ValueKey('r9-studio-effects')));
      await tester.tap(find.byKey(const ValueKey('r9-studio-effects'))); await tester.pump();
      expect(controller.tableAmbientEffects, !before);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink()); controller.dispose();
    });

    testWidgets('lounge filters search and empty-state recovery work $locale', (tester) async {
      tester.view.physicalSize = const Size(320, 640); tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AppController()..localeCode = locale;
      await tester.pumpWidget(host(Scaffold(body: SingleChildScrollView(child: R9GameLibrary(controller: controller, games: customerGamesR101, onAllGames: () {}))), locale));
      await tester.tap(find.byKey(const ValueKey('r9-filter-favorites'))); await tester.pump();
      expect(tester.widgetList<R8GameTile>(find.byType(R8GameTile)).map((tile) => tile.game.id).toSet(), controller.homeGameIds.toSet());
      await tester.tap(find.byKey(const ValueKey('r9-filter-all'))); await tester.pump();
      await tester.enterText(find.byKey(const ValueKey('r9-game-search')), 'basra'); await tester.pump();
      expect(find.byType(R8GameTile), findsOneWidget);
      expect(tester.widget<R8GameTile>(find.byType(R8GameTile)).game.id, 'basra');
      await tester.enterText(find.byKey(const ValueKey('r9-game-search')), 'no-such-game'); await tester.pump();
      expect(find.byType(R8GameTile), findsNothing);
      final reset = find.text(locale == 'ar' ? 'عرض جميع الألعاب' : 'Show all games');
      await tester.ensureVisible(reset); await tester.tap(reset); await tester.pump();
      expect(find.byType(R8GameTile), findsNWidgets(customerGamesR101.length));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink()); controller.dispose();
    });
  }
}
