import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

BoxDecoration r71SeatDecoration(WidgetTester tester, String name) =>
    tester.widget<AnimatedContainer>(
      find.byKey(ValueKey<String>('r30-seat-$name')),
    ).decoration! as BoxDecoration;

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
      testWidgets('R71 table seats inherit $themeCode in $locale',
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
        final theme = review.reviewTheme(controller);
        final scheme = theme.colorScheme;
        final surface = Color.lerp(
          scheme.surface,
          theme.scaffoldBackgroundColor,
          theme.brightness == Brightness.dark ? .34 : .16,
        )!;
        final key = GlobalKey();
        final activeName = locale == 'ar' ? 'دورك' : 'Your turn';
        final waitingName = locale == 'ar' ? 'اللاعب التالي' : 'Next player';

        await tester.pumpWidget(review.reviewApp(
          Scaffold(
            body: Directionality(
              textDirection:
                  locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    R8TableSeat(
                      name: activeName,
                      avatar: const Text('A'),
                      detail: locale == 'ar' ? '3 لمّات' : '3 tricks',
                      active: true,
                      seconds: 6,
                      onTap: () {},
                    ),
                    R8TableSeat(
                      name: waitingName,
                      avatar: const Text('B'),
                      detail: locale == 'ar' ? 'ينتظر' : 'Waiting',
                      active: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          controller,
          key,
        ));
        await tester.pump();

        final active = r71SeatDecoration(tester, activeName);
        final waiting = r71SeatDecoration(tester, waitingName);
        expect((active.gradient! as LinearGradient).colors.first,
            Color.lerp(surface, scheme.primary, .38));
        expect((waiting.gradient! as LinearGradient).colors.first,
            Color.lerp(surface, scheme.primary, .14));
        expect(tester.widget<Text>(find.text(activeName)).style!.color,
            scheme.onSurface);
        expect(tester.widget<Text>(find.text(waitingName)).style!.color,
            scheme.onSurface);
        expect(tester.takeException(), isNull);

        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, key, '$locale-r71-table-seats-$themeCode-390x844');
        }
      });
    }
  }
}
