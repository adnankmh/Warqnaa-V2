import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

BoxDecoration r70Decoration(WidgetTester tester, Finder finder) =>
    tester.widget<Container>(finder).decoration! as BoxDecoration;

void main() {
  setUpAll(() async {
    if (review.reviewDirectory.isEmpty) return;
    final bytes = await File(const String.fromEnvironment('R7_REVIEW_FONT'))
        .readAsBytes();
    for (final family in <String>['R7Review', 'Roboto']) {
      await (FontLoader(family)
            ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes))))
          .load();
    }
    await (FontLoader('MaterialIcons')
          ..addFont(File(const String.fromEnvironment('R7_MATERIAL_FONT'))
              .readAsBytes()
              .then(ByteData.sublistView)))
        .load();
  });
  for (final locale in <String>['ar', 'en']) {
    for (final themeCode in <String>['royal_crimson', 'emerald_light']) {
      testWidgets('R70 play center and room tools inherit $themeCode in $locale',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()
          ..localeCode = locale
          ..serverConnected = false
          ..themeCode = themeCode
          ..uiAccentHex = '#25e4df';
        addTearDown(controller.dispose);
        final theme = review.reviewTheme(controller);
        final expectedAccent = theme.colorScheme.primary;
        final playKey = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: R64PlayHubPage(controller: controller)),
          controller,
          playKey,
        ));
        await tester.pump();
        final command = r70Decoration(
          tester, find.byKey(const ValueKey('r70-play-command-panel')));
        expect((command.border! as Border).top.color,
            expectedAccent.withValues(alpha: .42));
        expect(command.gradient, isA<LinearGradient>());
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, playKey, '$locale-r70-play-center-$themeCode-390x844');
        }

        final lobbyKey = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: Builder(builder: (context) => FilledButton(
            onPressed: () => showGameLobby(
              context, controller, customerGamesR101.first),
            child: const Text('Open lobby'),
          ))),
          controller,
          lobbyKey,
        ));
        await tester.tap(find.text('Open lobby'));
        await tester.pumpAndSettle();
        final toolKey = ValueKey<String>(
          'r70-lobby-tool-${Icons.menu_book_rounded.codePoint}');
        final tool = r70Decoration(tester, find.byKey(toolKey));
        expect((tool.border! as Border).top.color,
            expectedAccent.withValues(alpha: .40));
        expect(tool.gradient, isA<LinearGradient>());
        expect(find.byKey(const ValueKey('r31-lobby-tools-grid')), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, lobbyKey, '$locale-r70-room-lobby-$themeCode-390x844');
        }
      });
    }
  }
}
