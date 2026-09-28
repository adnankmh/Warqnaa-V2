import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/models/room_launch_options.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'r7_runtime_review_test.dart' show reviewApp;

const reviewDir = String.fromEnvironment('R10_REVIEW_DIR');

Future<void> snapshot(WidgetTester tester, GlobalKey key, String name) async {
  if (reviewDir.isEmpty) return;
  final providers = tester.widgetList<Image>(find.byType(Image)).map((w) => w.image).toSet();
  await tester.runAsync(() async {
    for (final provider in providers) {
      await precacheImage(provider, key.currentContext!);
    }
  });
  await tester.pump(const Duration(milliseconds: 200));
  await tester.runAsync(() async {
    final image = await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$reviewDir/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUp(() { SharedPreferences.setMockInitialValues({}); AppSounds.enabled = false; });
  setUpAll(() async {
    const path = String.fromEnvironment('R7_REVIEW_FONT');
    if (path.isEmpty) return;
    final bytes = ByteData.sublistView(await File(path).readAsBytes());
    for (final family in ['R7Review', 'Roboto']) {
      await (FontLoader(family)..addFont(Future.value(bytes))).load();
    }
    const icons = String.fromEnvironment('R7_MATERIAL_FONT');
    if (icons.isNotEmpty) {
      await (FontLoader('MaterialIcons')..addFont(File(icons).readAsBytes().then(ByteData.sublistView))).load();
    }
  });

  for (final locale in ['ar', 'en']) {
    for (final size in [const Size(320, 640), const Size(390, 844), const Size(844, 390), const Size(1280, 800)]) {
      for (final game in gamesCatalog.where((game) => !game.serverOnly)) {
        testWidgets('offline table ${game.id} $locale $size', (tester) async {
          tester.view.physicalSize = size; tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
          final controller = AppController()..localeCode = locale;
          await controller.loginAsLocalAdmin();
          final key = GlobalKey();
          await tester.pumpWidget(reviewApp(GameRoomPage(controller: controller, game: game,
            options: const RoomLaunchOptions(turnSeconds: 120)), controller, key));
          await tester.pump(const Duration(milliseconds: 200));
          await snapshot(tester, key, '$locale-${game.id}-${size.width.toInt()}x${size.height.toInt()}');
          expect(tester.takeException(), isNull);
          expect(controller.serverConnected, isFalse);
          expect(controller.api.token, isNull);
          expect(find.byType(R8CardHand), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          final cards = tester.widgetList<PlayingCard>(find.descendant(of: find.byType(R8CardHand), matching: find.byType(PlayingCard)));
          expect(cards, isNotEmpty);
          expect(cards.every((card) => card.width >= 48), isTrue);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 6));
          controller.dispose();
        });
      }
    }
  }
}
