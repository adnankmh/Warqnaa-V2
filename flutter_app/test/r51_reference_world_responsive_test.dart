import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'r7_runtime_review_test.dart' as review;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSounds.enabled = false;
  });
  setUpAll(() async {
    if (review.reviewDirectory.isEmpty) return;
    final bytes = await File(const String.fromEnvironment('R7_REVIEW_FONT')).readAsBytes();
    for (final family in ['R7Review', 'Roboto']) {
      await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    await (FontLoader('MaterialIcons')..addFont(
      File(const String.fromEnvironment('R7_MATERIAL_FONT')).readAsBytes()
          .then((bytes) => ByteData.sublistView(bytes)),
    )).load();
    const emoji = String.fromEnvironment('R7_EMOJI_FONT');
    if (emoji.isNotEmpty) {
      await (FontLoader('R7Emoji')..addFont(
        File(emoji).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      )).load();
    }
  });
  for (final locale in ['ar', 'en']) {
    for (final layout in <({Size size, bool stacked, int gameColumns})>[
      (size: Size(320, 640), stacked: true, gameColumns: 2),
      (size: Size(390, 844), stacked: true, gameColumns: 2),
      (size: Size(600, 800), stacked: true, gameColumns: 3),
      (size: Size(844, 390), stacked: false, gameColumns: 3),
      (size: Size(1440, 900), stacked: false, gameColumns: 4),
    ]) {
      for (final scale in [1.0, 1.4]) {
        testWidgets('R51 actual Home games and tournaments $locale ${layout.size} text $scale', (tester) async {
          tester.view.physicalSize = layout.size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final controller = AppController()..localeCode = locale;
          addTearDown(controller.dispose);
          var selectedTab = -1;
          final key = GlobalKey();
          await tester.pumpWidget(review.reviewApp(
            Builder(builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
              child: Scaffold(body: B307HomeDashboard(
                controller: controller, onTab: (tab) => selectedTab = tab,
              )),
            )), controller, key,
          ));
          await tester.pump();
          expect(find.byType(B307HomeDashboard), findsOneWidget);
          expect(find.byKey(const ValueKey('r35-sky-grand-tournament-banner')), findsOneWidget);
          final games = find.byKey(const ValueKey('r51-games-panel'));
          await tester.ensureVisible(games);
          await tester.pump();
          expect(find.byType(R51FeaturedGamesAndTournaments), findsOneWidget);
          expect(find.byKey(ValueKey(layout.stacked ? 'r51-featured-stacked' : 'r51-featured-wide')), findsOneWidget);
          expect(find.byKey(ValueKey(layout.stacked ? 'r51-featured-wide' : 'r51-featured-stacked')), findsNothing);
          final cards = find.descendant(of: games, matching: find.byType(GridView));
          final grid = tester.widget<GridView>(cards);
          expect((grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, layout.gameColumns);
          final firstCard = find.byKey(const ValueKey('r35-game-tarneeb'));
          expect(firstCard, findsOneWidget);
          expect(tester.getSize(firstCard).width, greaterThan(110));
          final tournaments = find.byKey(const ValueKey('r51-tournaments-panel'));
          final gameRect = tester.getRect(games);
          final tournamentRect = tester.getRect(tournaments);
          if (layout.stacked) {
            expect(tournamentRect.top, greaterThanOrEqualTo(gameRect.bottom + 11));
            expect(tournamentRect.width, closeTo(gameRect.width, .1));
          } else {
            expect(tournamentRect.top, closeTo(gameRect.top, .1));
            expect(gameRect.overlaps(tournamentRect), isFalse);
            expect(locale == 'ar' ? gameRect.left > tournamentRect.left : gameRect.left < tournamentRect.left, isTrue);
          }
          if (review.reviewDirectory.isNotEmpty && scale == 1) {
            final dimensions = '${layout.size.width.toInt()}x${layout.size.height.toInt()}';
            await review.capture(tester, key, '$locale-r51-home-games-$dimensions');
            await tester.ensureVisible(tournaments);
            await tester.pump();
            await review.capture(tester, key, '$locale-r51-home-tournaments-$dimensions');
          }
          final viewAll = find.descendant(of: games, matching: find.byType(TextButton));
          await tester.ensureVisible(viewAll);
          await tester.tap(viewAll);
          expect(selectedTab, 1);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
    for (final game in ['hand', 'banakil']) {
      testWidgets('R51 actual Home opens $game friendly settings $locale', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: B307HomeDashboard(controller: controller, onTab: (_) {})),
          controller, GlobalKey(),
        ));
        final card = find.byKey(ValueKey('r35-game-$game'));
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pumpAndSettle();
        final friendly = find.text(L.t(locale, 'friendly'));
        expect(friendly, findsOneWidget);
        await tester.ensureVisible(friendly);
        await tester.tap(friendly);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('r48-create-room-settings')), findsOneWidget);
        expect(find.byKey(const ValueKey('r48-create-room-submit')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
