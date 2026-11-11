import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/r9_design_system.dart';

void main() {
  test('R235 real challenge cards use the read-only progress widget', () {
    final source = File('lib/v175_release.dart').readAsStringSync();
    expect(
      source.contains(
        'R235ChallengeProgress(name: name, progress: progress, target: target, ar: ar)',
      ),
      isTrue,
    );
  });

  for (final locale in <String>['ar', 'en']) {
    for (final dark in <bool>[false, true]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R235 $locale dark=$dark portrait $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();

          final direction =
              locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
          final name = locale == 'ar' ? 'تحدي الأصدقاء' : 'Friends Challenge';
          await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            theme: R9Design.theme(
              light: !dark,
              accent: R9Design.azure,
              arabic: locale == 'ar',
            ),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(12),
                  child: R235ChallengeProgress(
                    name: name,
                    progress: 3,
                    target: 5,
                    ar: locale == 'ar',
                  ),
                ),
              ),
            ),
          ));

          final progress = find.byKey(
            const ValueKey('r235-challenge-progress-bar'),
          );
          final count = find.byKey(
            const ValueKey('r235-challenge-progress-count'),
          );
          expect(progress, findsOneWidget);
          expect(count, findsOneWidget);
          expect(tester.widget<LinearProgressIndicator>(progress).value,
              closeTo(.6, .0001));
          expect(tester.widget<LinearProgressIndicator>(progress).color,
              dark ? R9Design.sky : R9Design.azure);
          expect(find.text('3 / 5'), findsOneWidget);
          expect(Directionality.of(tester.element(count)), TextDirection.ltr);
          expect(Directionality.of(tester.element(progress)), direction);
          expect(tester.getSize(progress).width, greaterThan(180));

          final spoken = locale == 'ar'
              ? 'تقدم $name: 3 من 5'
              : '$name progress: 3 of 5';
          expect(find.bySemanticsLabel(spoken), findsOneWidget);
          final semanticWidget = tester.widget<Semantics>(find.byKey(
            const ValueKey('r235-challenge-progress-semantics'),
          ));
          expect(semanticWidget.properties.value, '60%');
          semantics.dispose();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R235 RTL landscape clamps overflow progress to 100%',
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
          body: R235ChallengeProgress(
            name: 'تحدي',
            progress: 12,
            target: 10,
            ar: true,
          ),
        ),
      ),
    ));
    final progress = tester.widget<LinearProgressIndicator>(find.byKey(
      const ValueKey('r235-challenge-progress-bar'),
    ));
    expect(progress.value, 1);
    expect(progress.color, R9Design.sky);
    expect(find.text('12 / 10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('R235 invalid target and negative progress remain safe',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: R9Design.theme(light: true, accent: R9Design.azure),
      home: const Scaffold(
        body: R235ChallengeProgress(
          name: 'Challenge',
          progress: -2,
          target: 0,
          ar: false,
        ),
      ),
    ));
    expect(find.text('0 / 1'), findsOneWidget);
    expect(tester.widget<LinearProgressIndicator>(find.byKey(
      const ValueKey('r235-challenge-progress-bar'),
    )).value, 0);
    expect(tester.takeException(), isNull);
  });
}
