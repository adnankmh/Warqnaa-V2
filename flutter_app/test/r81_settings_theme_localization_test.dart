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
      testWidgets('R81 settings inherit $themeCode in $locale', (tester) async {
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
          Scaffold(body: Builder(builder: (context) => FilledButton(
            onPressed: () => showSettings(context, controller),
            child: const Text('Open settings'),
          ))),
          controller,
          key,
        ));
        await tester.tap(find.text('Open settings'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final gameplay = tester.widget<Container>(
            find.byKey(const ValueKey('r81-settings-gameplay')));
        final expected = R69PlaySurfaceColors.of(tester.element(
            find.byKey(const ValueKey('r81-settings-gameplay'))));
        final decoration = gameplay.decoration! as BoxDecoration;
        expect(decoration.gradient, isA<LinearGradient>());
        expect(decoration.border!.top.color.toARGB32(),
            expected.accent.withValues(alpha: .40).toARGB32());
        expect(find.text(locale == 'ar' ? 'الأصوات' : 'Sounds'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'الوضع الأفقي' : 'Landscape mode'),
            findsOneWidget);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r81-settings-top-$themeCode-390x844');
        }

        final installLabel = locale == 'ar'
            ? 'تثبيت التطبيق على الهاتف'
            : 'Install the app on your phone';
        await tester.scrollUntilVisible(
          find.text(installLabel),
          500,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text(installLabel), findsOneWidget);
        expect(find.text(locale == 'ar'
            ? 'مهلة استعادة الحساب'
            : 'Account recovery period'), findsOneWidget);
        final system = tester.widget<Container>(
            find.byKey(const ValueKey('r81-settings-system')));
        expect((system.decoration! as BoxDecoration).gradient,
            isA<LinearGradient>());
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r81-settings-system-$themeCode-390x844');
        }
      });
    }
  }
}
