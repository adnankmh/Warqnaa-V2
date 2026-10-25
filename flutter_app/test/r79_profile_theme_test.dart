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
      testWidgets('R79 profile inherits $themeCode in $locale', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()
          ..localeCode = locale
          ..themeCode = themeCode
          ..uiAccentHex = '#25e4df'
          ..activeClub = locale == 'ar' ? 'نجوم غزة' : 'Gaza Stars'
          ..clubImageEmojiV182 = '🛡️'
          ..vipDays = 14
          ..wins = 514
          ..gamesPlayed = 842;
        addTearDown(controller.dispose);
        final key = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: Builder(builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showProfile(context, controller),
              child: const Text('Open profile'),
            ),
          ))),
          controller,
          key,
        ));
        await tester.tap(find.text('Open profile'));
        // The profile deliberately contains ambient animation. Pump the modal
        // transition for a bounded interval instead of waiting for all frames
        // to settle, which can never happen while that animation is active.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final expected = R69PlaySurfaceColors.of(
          tester.element(find.byKey(const ValueKey('r79-profile-club-panel'))),
        );
        for (final panelKey in <Key>[
          const ValueKey('r79-profile-club-panel'),
          const ValueKey('r79-profile-progress-panel'),
          const ValueKey('r79-profile-wallet-panel'),
        ]) {
          final decoration = tester.widget<Container>(find.byKey(panelKey))
              .decoration! as BoxDecoration;
          expect(decoration.gradient, isA<LinearGradient>());
          expect(decoration.border!.top.color.toARGB32(),
              expected.accent.withValues(alpha: .36).toARGB32());
        }
        expect(find.text(locale == 'ar' ? 'النادي الحالي' : 'Current club'),
            findsOneWidget);
        expect(find.text(locale == 'ar'
            ? 'تقدم اللاعب ونقاطه'
            : 'Player progress and points'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'رصيد التوكنز' : 'Token balance'),
            findsOneWidget);
        expect(tester.takeException(), isNull);

        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r79-profile-top-$themeCode-390x844');
        }

        await tester.scrollUntilVisible(
          find.text(locale == 'ar' ? 'آخر المباريات' : 'Recent matches'),
          260,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pump();
        expect(find.text(locale == 'ar' ? 'المحفظة' : 'Wallet'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'الإعدادات' : 'Settings'),
            findsOneWidget);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r79-profile-actions-$themeCode-390x844');
        }
      });
    }
  }
}
