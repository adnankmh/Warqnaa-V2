import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/engines/tarneeb_engine.dart';
import 'package:warqna_mobile/models/room_launch_options.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

Widget host(Widget child, String locale) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: Locale(locale), supportedLocales: const [Locale('ar'), Locale('en')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: r101Theme('emerald', '#ffcf67').copyWith(textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'R8Review')),
  home: child,
);

void main() {
  setUp(() { SharedPreferences.setMockInitialValues({}); AppSounds.enabled = false; });
  setUpAll(() async {
    const fontPath = String.fromEnvironment('R8_REVIEW_FONT');
    if (fontPath.isNotEmpty) {
      final bytes = ByteData.sublistView(await File(fontPath).readAsBytes());
      for (final name in ['R8Review', 'Roboto']) { await (FontLoader(name)..addFont(Future.value(bytes))).load(); }
    }
  });

  test('joining players see themselves at the bottom without changing teams', () {
    final players = [{'key':'a'}, {'key':'b'}, {'key':'c'}, {'key':'d'}];
    for (var me = 0; me < 4; me++) {
      expect(r8RelativeSeat(players, me, players[me]['key']), 0);
      expect(r8RelativeSeat(players, (me + 2) % 4, players[me]['key']), 2);
    }
    expect(r8RelativeSeat(players, 2, 'spectator'), 2);
  });

  for (final locale in ['ar', 'en']) {
    for (final size in [const Size(320, 640), const Size(390, 844), const Size(844, 390), const Size(1280, 800)]) {
      testWidgets('R8 lobby and readable table $locale $size', (tester) async {
        tester.view.physicalSize = size; tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        final boundary = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(key: boundary, child: host(HomeShell(controller: controller), locale)));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(find.textContaining('18,872'), findsNothing);
        expect(find.byType(R8HomeLobby), findsOneWidget);
        const directory = String.fromEnvironment('R8_REVIEW_DIR');
        if (directory.isNotEmpty) {
          final providers = tester.widgetList<Image>(find.byType(Image)).map((w) => w.image).toSet();
          await tester.runAsync(() async { for (final image in providers) { await precacheImage(image, boundary.currentContext!); } });
          await tester.pump(const Duration(milliseconds: 300));
          await tester.runAsync(() async {
            final image = await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage();
            final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
            final file = File('$directory/$locale-home-${size.width.toInt()}x${size.height.toInt()}.png');
            await file.parent.create(recursive: true); await file.writeAsBytes(bytes!.buffer.asUint8List()); image.dispose();
          });
        }
        await tester.pumpWidget(host(TarneebRoomPage(controller: controller, game: gamesCatalog.first), locale));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        expect(find.text(locale == 'ar' ? 'دردشة الغرفة' : 'Room chat'), findsNothing);
        final hand = find.byType(R8CardHand);
        expect(hand, findsOneWidget);
        final cards = tester.widgetList<PlayingCard>(find.descendant(of: hand, matching: find.byType(PlayingCard)));
        expect(cards.length, 13);
        expect(cards.every((card) => card.width >= 48), isTrue);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 6)); controller.dispose();
      });
    }
  }

  testWidgets('a player completes a whole Tarneeb round using visible card controls', (tester) async {
    tester.view.physicalSize = const Size(390, 844); tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AppController()..localeCode = 'en';
    await tester.pumpWidget(host(TarneebRoomPage(controller: controller, game: gamesCatalog.first, options: const RoomLaunchOptions(singleRound: true, turnSeconds: 120)), 'en'));
    final dynamic state = tester.state(find.byType(TarneebRoomPage));
    var played = 0;
    for (var step = 0; step < 300; step++) {
      await tester.pump(const Duration(milliseconds: 750));
      final TarneebLocalEngine engine = state.engine as TarneebLocalEngine;
      if (engine.phase == TarneebPhase.gameOver) break;
      if (!engine.isHumanTurn || state.botsActing == true) continue;
      if (engine.phase == TarneebPhase.bidding) {
        final pass = find.text('Pass');
        await tester.ensureVisible(pass); await tester.tap(pass); await tester.pump();
      } else if (engine.phase == TarneebPhase.chooseTrump) {
        await tester.tap(find.text('♠ Spades')); await tester.pump();
      } else if (engine.phase == TarneebPhase.playing) {
        final card = engine.legalCards(0).first;
        final tile = find.descendant(of: find.byType(R8CardHand), matching: find.byWidgetPredicate((w) => w is PlayingCard && w.label == card.label));
        await tester.ensureVisible(tile);
        // The exposed rank corner remains tappable in the overlapped hand.
        await tester.tapAt(tester.getTopLeft(tile) + const Offset(8, 8));
        // onTap waits for the double-tap recognizer to reject a second tap.
        await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
        expect(state.selectedCode, card.code, reason: 'The exposed card must be selected before playing');
        final before = engine.humanHand.length;
        final play = find.text('Play selected card');
        await tester.ensureVisible(play); await tester.tap(play); await tester.pump();
        expect(engine.humanHand.length, before - 1, reason: 'Every button press must play exactly one card');
        expect(engine.humanHand.any((held) => held.code == card.code), isFalse);
        played++;
      }
      expect(tester.takeException(), isNull);
    }
    final TarneebLocalEngine engine = state.engine as TarneebLocalEngine;
    expect(engine.phase, TarneebPhase.gameOver);
    expect(played, 13);
    expect(engine.completedTricks.length, 13);
    expect(engine.humanHand, isEmpty);
    expect(find.textContaining('Play again'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink()); await tester.pump(const Duration(seconds: 6)); controller.dispose();
  });

  testWidgets('a 19-card hand keeps every exposed card target at least 44 pixels wide', (tester) async {
    tester.view.physicalSize = const Size(320, 640); tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    final tapped = <int>[];
    await tester.pumpWidget(host(Scaffold(body: Align(
      alignment: Alignment.bottomCenter,
      child: R8CardHand(
        count: 19,
        selectedIndex: 7,
        cardBuilder: (index, width, height) => GestureDetector(
          key: ValueKey('long-hand-card-$index'),
          behavior: HitTestBehavior.opaque,
          onTap: () => tapped.add(index),
          child: PlayingCard(label: '${index + 1}♠', width: width, height: height, selected: index == 7),
        ),
      ),
    )), 'en'));
    await tester.pump();

    final rects = [for (var index = 0; index < 19; index++) tester.getRect(find.byKey(ValueKey('long-hand-card-$index')))];
    for (var index = 1; index < rects.length; index++) {
      expect(rects[index].left - rects[index - 1].left, greaterThanOrEqualTo(44), reason: 'card $index exposed width');
    }
    expect(tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView)).scrollDirection, Axis.horizontal);

    for (var index = 0; index < 19; index++) {
      final card = find.byKey(ValueKey('long-hand-card-$index'));
      await tester.ensureVisible(card);
      await tester.pump();
      await tester.tapAt(tester.getTopLeft(card) + const Offset(8, 8));
      await tester.pump();
      expect(tapped.last, index, reason: 'card $index must remain independently tappable');
    }
  });
}
