import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

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
      testWidgets('R77 room entry inherits $themeCode in $locale',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()
          ..localeCode = locale
          ..themeCode = themeCode
          ..uiAccentHex = '#25e4df';
        addTearDown(controller.dispose);
        final game = gamesCatalog.firstWhere((entry) => entry.id == 'hand');
        final key = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: Builder(builder: (context) => Column(children: [
            FilledButton(
              onPressed: () => showJoinRoomByCode(context, controller, game),
              child: const Text('Open join'),
            ),
            FilledButton(
              onPressed: () => showCreateRoom(
                context, controller, game, initialVoice: true),
              child: const Text('Open voice room'),
            ),
          ]))),
          controller,
          key,
        ));

        await tester.tap(find.text('Open join'));
        await tester.pumpAndSettle();
        final joinFinder =
            find.byKey(const ValueKey('r77-join-room-code-status'));
        final joinIcon = tester.widget<Icon>(joinFinder);
        expect(joinIcon.color,
            r77RoomEntryAccent(tester.element(joinFinder)));
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, key, '$locale-r77-join-code-$themeCode-390x844');
        }

        Navigator.of(tester.element(joinFinder)).pop();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open voice room'));
        await tester.pumpAndSettle();

        final modeFinder =
            find.byKey(const ValueKey('r77-create-room-mode-status'));
        final modeIcon = tester.widget<Icon>(modeFinder);
        expect(modeIcon.color,
            r77RoomEntryAccent(tester.element(modeFinder), positive: true));
        final noticeFinder =
            find.byKey(const ValueKey('r77-voice-privacy-notice'));
        await tester.ensureVisible(noticeFinder);
        await tester.pumpAndSettle();
        final notice = tester.widget<Container>(noticeFinder);
        final decoration = notice.decoration! as BoxDecoration;
        expect(decoration.gradient, isA<LinearGradient>());
        expect(
          decoration.border!.top.color.toARGB32(),
          r77RoomEntryAccent(tester.element(noticeFinder), positive: true)
              .withValues(alpha: .38)
              .toARGB32(),
        );
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, key, '$locale-r77-create-voice-$themeCode-390x844');
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
