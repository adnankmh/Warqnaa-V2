import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

void main() {
  setUpAll(() async {
    if (review.reviewDirectory.isEmpty) return;
    final bytes = await File(const String.fromEnvironment('R7_REVIEW_FONT')).readAsBytes();
    for (final family in ['R7Review', 'Roboto']) {
      await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    await (FontLoader('MaterialIcons')
      ..addFont(File(const String.fromEnvironment('R7_MATERIAL_FONT'))
        .readAsBytes().then(ByteData.sublistView))).load();
  });

  for (final locale in ['ar', 'en']) {
    for (final brightness in Brightness.values) {
      for (final width in [320.0, 390.0]) {
        testWidgets('R247 visual evidence $locale $brightness $width', (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final ar = locale == 'ar';
          final key = GlobalKey();
          final scheme = ColorScheme.fromSeed(seedColor: const Color(0xff1565c0), brightness: brightness);
          final theme = ThemeData(useMaterial3: true, colorScheme: scheme,
            fontFamily: review.reviewDirectory.isEmpty ? null : 'R7Review');
          final suffix = '$locale-${brightness.name}-${width.toInt()}x844';
          Future<void> shot(String state) async {
            expect(tester.takeException(), isNull);
            if (review.reviewDirectory.isNotEmpty) {
              await review.capture(tester, key, 'r247-$state-$suffix');
            }
          }
          Future<void> tapKey(String value) async {
            final finder = find.byKey(ValueKey(value));
            await tester.ensureVisible(finder);
            await tester.pumpAndSettle();
            await tester.tap(finder);
            await tester.pumpAndSettle();
          }
          Widget app(Widget child) => RepaintBoundary(key: key, child: MaterialApp(
            locale: Locale(locale), supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: theme, home: Scaffold(body: child),
          ));
          await tester.pumpWidget(app(R36MeldWorkspace(ar: ar,
            cards: const ['3_H', '4_H', '5_H', '9_D', '9_C', '9_S', 'K_H'])));
          await tester.pumpAndSettle();
          final status = find.byKey(const ValueKey('r214-meld-selection-status'));
          String statusText() => tester.widget<Text>(status).data!;
          expect(Directionality.of(tester.element(status)), ar ? TextDirection.rtl : TextDirection.ltr);
          expect(Theme.of(tester.element(status)).colorScheme.primary, scheme.primary);
          final submit = find.byKey(const ValueKey('r36-submit-meld-groups'));
          void expectSubmit(String label) {
            expect(find.descendant(of: submit, matching: find.text(label)), findsOneWidget);
          }
          expectSubmit(ar ? 'نزّل المجموعات' : 'Meld groups');
          for (final i in [0, 1, 2]) {
            await tapKey('r36-meld-card-$i');
          }
          expect(statusText(), contains(ar ? 'جاهزة للحفظ' : 'Ready to save'));
          await tester.ensureVisible(status);
          await tester.pumpAndSettle();
          await shot('meld-ready');
          await tapKey('r36-add-meld-group');
          expectSubmit(ar ? 'نزّل مجموعة واحدة' : 'Meld 1 group');
          await tapKey('r36-meld-card-3');
          await tapKey('r214-clear-meld-selection');
          expect(statusText(), contains(ar ? 'المحدد: 0' : 'Selected: 0'));
          final group = find.byKey(const ValueKey('r44-meld-group-0'));
          expect(group, findsOneWidget);
          await tester.ensureVisible(group);
          await tester.pumpAndSettle();
          await shot('meld-cleared-group-retained');
          for (final i in [3, 4, 5]) {
            await tapKey('r36-meld-card-$i');
          }
          await tapKey('r36-add-meld-group');
          expectSubmit(ar ? 'نزّل مجموعتين' : 'Meld 2 groups');
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(app(Center(child: AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 10),
            content: R40DiscardStackPicker(maxCount: 3, ar: ar,
              cards: const ['3_C', '4_D', '5_H', '6_S', '7_C', '8_D']),
          ))));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('r44-discard-select-4')), findsNothing);
          expect(find.byKey(const ValueKey('r44-discard-select-1')), findsNothing);
          await tapKey('r44-discard-select-3');
          final origin = find.byKey(const ValueKey('r213-discard-pickup-origin'));
          expect(tester.widget<Text>(origin).data, contains(r52CardLabel('6_S')));
          await tester.ensureVisible(origin);
          await tester.pumpAndSettle();
          await shot('discard-three');
        });
      }
    }
  }
}
