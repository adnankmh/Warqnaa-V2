import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/r9_design_system.dart';

void main() {
  test('R234 live home dashboard delegates to the blue backdrop', () {
    final source = File('lib/r5_world_class.dart').readAsStringSync();
    expect(source.contains('return R234BlueHomeBackdrop('), isTrue);
    expect(source.contains('Color(0xff171512)'), isFalse);
  });

  for (final locale in <String>['ar', 'en']) {
    for (final dark in <bool>[false, true]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R234 blue home canvas $locale dark=$dark portrait $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final direction =
              locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
          await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            theme: R9Design.theme(
              light: !dark,
              accent: R9Design.azure,
              arabic: locale == 'ar',
            ),
            home: Directionality(
              textDirection: direction,
              child: const Scaffold(
                body: R234BlueHomeBackdrop(
                  child: SizedBox.expand(
                    child: Center(child: Text('Warqnaa')),
                  ),
                ),
              ),
            ),
          ));

          final backdrop =
              find.byKey(const ValueKey('r234-blue-home-backdrop'));
          expect(backdrop, findsOneWidget);
          expect(Directionality.of(tester.element(backdrop)), direction);
          expect(tester.getSize(backdrop).width, width);
          expect(find.text('Warqnaa'), findsOneWidget);

          final box = tester.widget<DecoratedBox>(backdrop);
          final gradient = (box.decoration as BoxDecoration).gradient!
              as LinearGradient;
          final scheme = Theme.of(tester.element(backdrop)).colorScheme;
          expect(
            gradient.begin.resolve(direction),
            locale == 'ar' ? Alignment.topRight : Alignment.topLeft,
          );
          expect(
            gradient.end.resolve(direction),
            locale == 'ar' ? Alignment.bottomLeft : Alignment.bottomRight,
          );
          expect(
            gradient.colors.first,
            Color.alphaBlend(
              R9Design.azure.withValues(alpha: dark ? .22 : .14),
              scheme.surface,
            ),
          );
          expect(
            gradient.colors[1],
            Color.alphaBlend(
              R9Design.sky.withValues(alpha: dark ? .12 : .07),
              scheme.surface,
            ),
          );
          expect(gradient.colors.last, scheme.surface);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R234 landscape keeps original blue and directional lighting',
      (tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: R9Design.theme(light: false, accent: R9Design.azure),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: R234BlueHomeBackdrop(
            child: SizedBox.expand(child: Center(child: Text('Warqnaa'))),
          ),
        ),
      ),
    ));
    final backdrop = find.byKey(const ValueKey('r234-blue-home-backdrop'));
    expect(tester.getSize(backdrop), const Size(844, 390));
    final box = tester.widget<DecoratedBox>(backdrop);
    final gradient = (box.decoration as BoxDecoration).gradient!
        as LinearGradient;
    expect(gradient.begin.resolve(TextDirection.rtl), Alignment.topRight);
    expect(gradient.colors.last,
        Theme.of(tester.element(backdrop)).colorScheme.surface);
    expect(tester.takeException(), isNull);
  });
}
