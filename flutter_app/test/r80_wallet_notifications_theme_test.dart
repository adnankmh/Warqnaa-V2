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
      testWidgets('R80 account sheets inherit $themeCode in $locale',
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
        final key = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: Builder(builder: (context) => Column(children: [
            FilledButton(
              onPressed: () => showNotifications(context, controller),
              child: const Text('Open notifications'),
            ),
            FilledButton(
              onPressed: () => showWallet(context, controller),
              child: const Text('Open wallet'),
            ),
          ]))),
          controller,
          key,
        ));

        await tester.tap(find.text('Open notifications'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text(locale == 'ar'
            ? 'بدأ التسجيل في بطولة الأبطال'
            : 'Champions tournament registration is open'), findsOneWidget);
        expect(find.text(locale == 'ar'
            ? 'يمكنك القبول من مركز الأصدقاء.'
            : 'You can accept it from the Friends center.'), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
        expect(find.byIcon(Icons.card_giftcard_rounded), findsOneWidget);
        expect(find.byIcon(Icons.person_add_alt_1_rounded), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(tester, key,
              '$locale-r80-notifications-$themeCode-390x844');
        }
        Navigator.of(tester.element(find.byType(B307PageHero))).pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Open wallet'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        final balance = tester.widget<Container>(
            find.byKey(const ValueKey('r32-wallet-balance-card')));
        final transactions = tester.widget<Container>(
            find.byKey(const ValueKey('r80-wallet-transactions')));
        final expected = R69PlaySurfaceColors.of(tester.element(
            find.byKey(const ValueKey('r32-wallet-balance-card'))));
        for (final decoration in <BoxDecoration>[
          balance.decoration! as BoxDecoration,
          transactions.decoration! as BoxDecoration,
        ]) {
          expect(decoration.gradient, isA<LinearGradient>());
          expect(decoration.border!.top.color.toARGB32(),
              expected.accent.withValues(alpha: .40).toARGB32());
        }
        expect(find.text(locale == 'ar' ? 'مكافأة يومية' : 'Daily reward'),
            findsOneWidget);
        expect(find.text(locale == 'ar' ? 'اليوم 09:12' : 'Today 09:12'),
            findsOneWidget);
        expect(find.text(locale == 'ar' ? 'شراء حزمة المرح' : 'Fun pack purchase'),
            findsOneWidget);
        expect(find.textContaining('🪙'), findsNothing);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r80-wallet-$themeCode-390x844');
        }
      });
    }
  }

  testWidgets('R80 empty notifications are bilingual', (tester) async {
    final controller = AppController()
      ..localeCode = 'en'
      ..notices.clear();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: Builder(builder: (context) => FilledButton(
        onPressed: () => showNotifications(context, controller),
        child: const Text('Open'),
      )),
    )));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('No notifications'), findsOneWidget);
    expect(find.text('New updates will appear here.'), findsOneWidget);
    expect(find.byKey(const ValueKey('r80-notifications-empty')), findsOneWidget);
  });
}
