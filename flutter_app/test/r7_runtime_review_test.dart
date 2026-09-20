import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

const runtimeUrl = String.fromEnvironment('R7_RUNTIME_URL');
const reviewDirectory = String.fromEnvironment('R7_REVIEW_DIR');

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.pump(const Duration(milliseconds: 400));
  expect(tester.takeException(), isNull);
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$reviewDirectory/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(png!.buffer.asUint8List());
    image.dispose();
  });
}

Widget reviewApp(Widget child, AppController controller, GlobalKey key) => RepaintBoundary(
  key: key,
  child: MaterialApp(
    locale: Locale(controller.localeCode),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    // A real Arabic-capable review font replaces Flutter test's Ahem blocks.
    // These renders are review evidence, not platform-specific pixel goldens.
    theme: r101Theme(controller.themeCode, controller.uiAccentHex).copyWith(
      textTheme: r101Theme(controller.themeCode, controller.uiAccentHex).textTheme.apply(fontFamily: 'R7Review'),
    ),
    home: child,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (runtimeUrl.isEmpty) return;
    final font = FontLoader('R7Review')..addFont(
      File(const String.fromEnvironment('R7_REVIEW_FONT')).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
    );
    await font.load();
  });

  for (final locale in ['ar', 'en']) {
    testWidgets('R7 live identity and layouts $locale', (tester) async {
      final oldOverride = HttpOverrides.current;
      HttpOverrides.global = null; // Opt this integration test into its loopback server.
      addTearDown(() => HttpOverrides.global = oldOverride);
      final previousError = FlutterError.onError;
      FlutterError.onError = (details) { debugPrint(details.toString()); previousError?.call(details); };
      SharedPreferences.setMockInitialValues({});
      AppSounds.enabled = false;
      final controller = AppController()..customApiUrl = runtimeUrl;
      controller.api.updateBaseUrl(runtimeUrl);
      addTearDown(() { controller.connectivityTimerV173?.cancel(); controller.dispose(); });
      await tester.runAsync(() async {
        expect(await controller.login(const String.fromEnvironment('R7_PLAYER_LOGIN'), const String.fromEnvironment('R7_PLAYER_PASSWORD')), isNull);
        expect(controller.serverConnected, isTrue);
        expect(controller.currentUserId, int.parse(const String.fromEnvironment('R7_PLAYER_ID')));
        expect(controller.level, int.parse(const String.fromEnvironment('R7_PLAYER_LEVEL')));
        // Restore the saved online session through the production bootstrap path.
        await controller.load();
        expect(controller.serverConnected, isTrue);
        expect(controller.currentUserId, int.parse(const String.fromEnvironment('R7_PLAYER_ID')));
        expect(controller.level, int.parse(const String.fromEnvironment('R7_PLAYER_LEVEL')));
        expect(controller.selectedTable, 'v305_table_emerald_royal');
        expect(controller.selectedCardBack, 'v305_cardback_emerald_royal');
      });
      controller.localeCode = locale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      for (final size in [const Size(390, 844), const Size(844, 390), const Size(1280, 800)]) {
        tester.view.physicalSize = size;
        final dimensions = '${size.width.toInt()}x${size.height.toInt()}';
        for (final page in <(String, Widget)>[
          ('home', HomeShell(controller: controller)),
          ('profile', R61ProfilePage(controller: controller)),
          ('store', Scaffold(body: StorePage(controller: controller))),
          ('social', Scaffold(body: R61SocialHubPage(controller: controller))),
          ('table', TarneebRoomPage(controller: controller, game: gamesCatalog.firstWhere((game) => game.id == 'tarneeb'))),
        ]) {
          final key = GlobalKey();
          await tester.pumpWidget(reviewApp(page.$2, controller, key));
          await capture(tester, key, '$locale-${page.$1}-$dimensions');
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 5));
        }
      }
    }, skip: runtimeUrl.isEmpty);
  }

  testWidgets('R7 live primary role remains authoritative in Flutter', (tester) async {
    final oldOverride = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = oldOverride);
    SharedPreferences.setMockInitialValues({});
    final controller = AppController()..customApiUrl = runtimeUrl;
    controller.api.updateBaseUrl(runtimeUrl);
    addTearDown(() { controller.connectivityTimerV173?.cancel(); controller.dispose(); });
    await tester.runAsync(() async {
      expect(await controller.login(const String.fromEnvironment('R7_ADMIN_LOGIN'), const String.fromEnvironment('R7_ADMIN_PASSWORD')), isNull);
      await controller.load();
      expect(controller.isPrimaryAdmin, isTrue);
      expect(controller.level, 99);
      expect(controller.vipDays, greaterThanOrEqualTo(36500));
      expect(controller.coins, greaterThanOrEqualTo(BigInt.parse('9000000000000000000')));
      expect(controller.currentUserId, int.parse(const String.fromEnvironment('R7_ADMIN_ID')));
    });
  }, skip: runtimeUrl.isEmpty);
}
