import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/engines/local_game_engine.dart';
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
    const emoji = String.fromEnvironment('R7_EMOJI_FONT');
    if (emoji.isNotEmpty) {
      await (FontLoader('R7Emoji')..addFont(File(emoji).readAsBytes().then(ByteData.sublistView))).load();
    }
    const icons = String.fromEnvironment('R7_MATERIAL_FONT');
    if (icons.isNotEmpty) {
      await (FontLoader('MaterialIcons')..addFont(File(icons).readAsBytes().then(ByteData.sublistView))).load();
    }
  });

  for (final locale in ['ar', 'en']) {
    testWidgets('Trix shows a clear pass control when no card is legal in $locale', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      LocalGameSession? passingGame;
      Map<String, dynamic>? passingRoom;
      for (var seed = 0; seed < 500 && passingGame == null; seed++) {
        final game = LocalGameSession(gameId: 'trix', humanName: 'Adnan', localeCode: locale, seed: seed);
        var candidate = game.action('choose_contract', const <String, dynamic>{'contract': 'trix'});
        for (var step = 0; step < 160 && candidate['state']['game_over'] != true; step++) {
          final actions = (candidate['state']['available_actions'] as List).cast<Map>();
          if (actions.any((action) => action['type'] == 'pass_trix')) {
            passingGame = game;
            passingRoom = Map<String, dynamic>.from(candidate);
            break;
          }
          candidate = game.timeout();
        }
      }
      expect(passingGame, isNotNull, reason: 'A deterministic Trix deal must reach a blocked player');

      final controller = AppController()..localeCode = locale;
      await controller.loginAsLocalAdmin();
      final key = GlobalKey();
      final gameInfo = gamesCatalog.firstWhere((game) => game.id == 'trix');
      await tester.pumpWidget(reviewApp(
        GameRoomPage(controller: controller, game: gameInfo, options: const RoomLaunchOptions(turnSeconds: 120)),
        controller,
        key,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      final dynamic table = tester.state(find.byType(ServerEngineRoomPage));
      table.localSession = passingGame;
      table.room = passingRoom;
      table.seconds = 120;
      table.setState(() {});
      await tester.pump();

      final label = locale == 'ar' ? 'مرّر' : 'Pass';
      final pass = find.widgetWithText(OutlinedButton, label);
      expect(pass, findsOneWidget);
      expect(find.text(locale == 'ar' ? 'تشغيل الحركة التلقائية' : 'Auto play'), findsNothing);
      await snapshot(tester, key, '$locale-trix-pass-control');

      final beforeMessages = (table.state['messages'] as List).length;
      await tester.tap(pass);
      await tester.pump(const Duration(milliseconds: 350));
      expect((table.state['messages'] as List).length, greaterThan(beforeMessages));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 6));
      controller.dispose();
    });
  }

  for (final locale in ['ar', 'en']) {
    testWidgets('trick table blocks an illegal card before sending it in $locale', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      LocalGameSession? constrainedGame;
      Map<String, dynamic>? constrainedRoom;
      for (var seed = 0; seed < 500 && constrainedGame == null; seed++) {
        final game = LocalGameSession(gameId: 'trix', humanName: 'Adnan', localeCode: locale, seed: seed);
        var candidate = game.action('choose_contract', const <String, dynamic>{'contract': 'king_hearts'});
        for (var step = 0; step < 160 && candidate['state']['game_over'] != true; step++) {
          final state = Map<String, dynamic>.from(candidate['state'] as Map);
          final hand = (state['hand'] as List).map((card) => card.toString()).toList();
          final legal = (state['legal_cards'] as List).map((card) => card.toString()).toList();
          if (legal.isNotEmpty && legal.length < hand.length) {
            constrainedGame = game;
            constrainedRoom = Map<String, dynamic>.from(candidate);
            break;
          }
          candidate = game.timeout();
        }
      }
      expect(constrainedGame, isNotNull, reason: 'A deterministic trick must require following suit');

      final controller = AppController()..localeCode = locale;
      await controller.loginAsLocalAdmin();
      final key = GlobalKey();
      final gameInfo = gamesCatalog.firstWhere((game) => game.id == 'trix');
      await tester.pumpWidget(reviewApp(
        GameRoomPage(controller: controller, game: gameInfo, options: const RoomLaunchOptions(turnSeconds: 120)),
        controller,
        key,
      ));
      await tester.pump(const Duration(milliseconds: 200));

      final dynamic table = tester.state(find.byType(ServerEngineRoomPage));
      table.localSession = constrainedGame;
      table.room = constrainedRoom;
      table.seconds = 120;
      table.setState(() {});
      await tester.pump();

      final state = Map<String, dynamic>.from(constrainedRoom!['state'] as Map);
      final hand = (state['hand'] as List).map((card) => card.toString()).toList();
      final legal = (state['legal_cards'] as List).map((card) => card.toString()).toList();
      final illegalCard = hand.firstWhere((card) => !legal.contains(card));
      final legalCard = legal.first;
      String cardLabel(String value) => value
          .replaceAll('_', '')
          .replaceAll('C', '♣')
          .replaceAll('D', '♦')
          .replaceAll('S', '♠')
          .replaceAll('H', '♥');
      Finder card(String value) => find.descendant(
        of: find.byType(R8CardHand),
        matching: find.byWidgetPredicate((widget) => widget is PlayingCard && widget.label == cardLabel(value)),
      );

      await tester.ensureVisible(card(illegalCard));
      await tester.tapAt(tester.getTopLeft(card(illegalCard)) + const Offset(8, 8));
      await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
      final blockedLabel = locale == 'ar' ? 'هذه الورقة غير قانونية' : 'This card is not legal';
      final blocked = find.widgetWithText(FilledButton, blockedLabel);
      expect(blocked, findsOneWidget);
      expect(tester.widget<FilledButton>(blocked).onPressed, isNull);
      await snapshot(tester, key, '$locale-trix-illegal-card-guard');

      await tester.ensureVisible(card(legalCard));
      await tester.tapAt(tester.getTopLeft(card(legalCard)) + const Offset(8, 8));
      await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
      final play = find.widgetWithText(FilledButton, locale == 'ar' ? 'لعب الورقة' : 'Play card');
      expect(tester.widget<FilledButton>(play).onPressed, isNotNull);
      final beforeHand = (table.state['hand'] as List).length;
      await tester.tap(play);
      await tester.pump(const Duration(milliseconds: 350));
      expect((table.state['hand'] as List).length, beforeHand - 1);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 6));
      controller.dispose();
    });
  }

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
          if (game.id != 'tarneeb') {
            final table = tester.getRect(find.byKey(const ValueKey('r10-engine-table')));
            expect(table.height, greaterThanOrEqualTo(300), reason: 'Landscape must retain a visible table');
            final dynamic room = tester.state(find.byType(ServerEngineRoomPage));
            if (locale == 'en') {
              expect(
                ((room.state['messages'] as List?) ?? const []).join(' '),
                isNot(matches(RegExp(r'[\u0600-\u06FF]'))),
                reason: '${game.id} must not leak Arabic engine messages into English play',
              );
            }
            expect(find.byType(R8TableSeat), findsNWidgets((room.room['players'] as List).length));
            if (size == const Size(390, 844)) {
              final before = Map<String, dynamic>.from(room.state as Map);
              final phase = before['phase'];
              if (phase == 'bidding' || phase == 'choose_contract') {
                final bid = phase == 'bidding';
                final button = find.widgetWithText(FilledButton, bid
                  ? (locale == 'ar' ? 'اختيار الطلب' : 'Choose bid')
                  : (locale == 'ar' ? 'اختيار العقد' : 'Choose contract'));
                await tester.ensureVisible(button); await tester.pump(); await tester.tap(button); await tester.pump(const Duration(milliseconds: 500));
                expect(find.text(bid
                  ? (locale == 'ar' ? 'اختر الطلب القانوني' : 'Choose your bid')
                  : (locale == 'ar' ? 'اختر العقد المتاح' : 'Choose a contract')), findsOneWidget);
                final dialog = find.byType(AlertDialog);
                final choice = bid
                  ? find.descendant(of: dialog, matching: find.byType(TarneebBidButtonV170)).first
                  : find.descendant(of: dialog, matching: find.byType(FilledButton)).first;
                await tester.tap(choice); await tester.pump(const Duration(milliseconds: 350));
                expect(find.byType(AlertDialog), findsNothing);
                expect(room.state.toString(), isNot(before.toString()));
              } else {
                final card = find.descendant(of: find.byType(R8CardHand), matching: find.byType(PlayingCard)).first;
                await tester.ensureVisible(card);
                await tester.tapAt(tester.getTopLeft(card) + const Offset(8, 8));
                await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
                expect(room.selectedCard, isNotNull);
                final selected = room.selectedCard;
                final button = find.text(phase == 'discard'
                  ? (locale == 'ar' ? 'رمي الورقة' : 'Discard card')
                  : (locale == 'ar' ? 'لعب الورقة' : 'Play card'));
                await tester.ensureVisible(button); await tester.pump(); await tester.tap(button); await tester.pump();
                final afterHand = room.hand as List;
                expect(afterHand.length, (before['hand'] as List).length - 1);
                expect(afterHand.where((card) => card == selected).length,
                  (before['hand'] as List).where((card) => card == selected).length - 1);
                expect(room.selectedCard, isNull);
              }
              if (locale == 'en') {
                expect(
                  ((room.state['messages'] as List?) ?? const []).join(' '),
                  isNot(matches(RegExp(r'[\u0600-\u06FF]'))),
                  reason: '${game.id} must keep post-action messages in English',
                );
              }
              expect(tester.takeException(), isNull);
              await snapshot(tester, key, '$locale-${game.id}-after-action');
            }
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 6));
          controller.dispose();
        });
      }
    }
  }
}
