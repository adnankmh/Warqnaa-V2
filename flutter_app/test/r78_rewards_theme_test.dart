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
      testWidgets('R78 rewards inherit $themeCode in $locale', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()
          ..localeCode = locale
          ..themeCode = themeCode
          ..uiAccentHex = '#25e4df'
          ..giftRoadProgress = 12;
        addTearDown(controller.dispose);
        final key = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: Builder(builder: (context) => Column(children: [
            FilledButton(
              onPressed: () => showGiftRoadSheet(context, controller),
              child: const Text('Open gift road'),
            ),
            FilledButton(
              onPressed: () => showPashaBenefits(context, controller),
              child: const Text('Open Pasha'),
            ),
            FilledButton(
              onPressed: () => showClubChallenges(
                context,
                controller,
                locale == 'ar' ? 'نجوم غزة' : 'Gaza Stars',
              ),
              child: const Text('Open club challenges'),
            ),
          ]))),
          controller,
          key,
        ));

        Future<void> verifyAndCapture(Key summaryKey, String name) async {
          final finder = find.byKey(summaryKey);
          final summary = tester.widget<Container>(finder);
          final decoration = summary.decoration! as BoxDecoration;
          final colors = R69PlaySurfaceColors.of(tester.element(finder));
          expect(decoration.gradient, isA<LinearGradient>());
          expect(
            decoration.border!.top.color.toARGB32(),
            colors.accent.withValues(alpha: .38).toARGB32(),
          );
          expect(tester.takeException(), isNull);
          if (review.reviewDirectory.isNotEmpty) {
            await review.capture(
              tester, key, '$locale-r78-$name-$themeCode-390x844');
          }
          Navigator.of(tester.element(finder)).pop();
          await tester.pumpAndSettle();
        }

        await tester.tap(find.text('Open gift road'));
        await tester.pumpAndSettle();
        expect(find.text(locale == 'ar' ? 'طريق الهدايا' : 'Gift Road'),
            findsOneWidget);
        await verifyAndCapture(
          const ValueKey('r78-gift-road-summary'), 'gift-road');

        await tester.tap(find.text('Open Pasha'));
        await tester.pumpAndSettle();
        expect(find.text(locale == 'ar' ? 'مزايا الباشا' : 'Pasha benefits'),
            findsOneWidget);
        await verifyAndCapture(
          const ValueKey('r78-pasha-benefits-summary'), 'pasha');

        await tester.tap(find.text('Open club challenges'));
        await tester.pumpAndSettle();
        expect(find.text(locale == 'ar'
            ? 'تحديات نجوم غزة'
            : 'Gaza Stars challenges'), findsOneWidget);
        await verifyAndCapture(
          const ValueKey('r78-club-challenges-summary'), 'club-challenges');
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
