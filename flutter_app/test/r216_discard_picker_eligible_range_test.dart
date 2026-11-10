import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R216 only eligible discard origins $locale $brightness $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final ar = locale == 'ar';
          final direction = ar ? TextDirection.rtl : TextDirection.ltr;
          int? submittedCount;
          const discards = <String>[
            '3_C', '4_D', '5_H', '6_S', '7_C', '8_D',
          ];
          final scheme = ColorScheme.fromSeed(
            seedColor: const Color(0xff1565c0),
            brightness: brightness,
          );
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(useMaterial3: true, colorScheme: scheme),
            home: Scaffold(body: Builder(builder: (context) =>
              Center(child: FilledButton(
                onPressed: () async {
                  submittedCount = await showDialog<int>(
                    context: context,
                    builder: (_) => Directionality(
                      textDirection: direction,
                      child: AlertDialog(
                        content: R40DiscardStackPicker(
                          maxCount: 3, cards: discards, ar: ar),
                      ),
                    ),
                  );
                },
                child: const Text('Open picker'),
              )),
            )),
          ));
          await tester.tap(find.text('Open picker'));
          await tester.pumpAndSettle();

          // There are six public discards, but only the newest three are
          // eligible. Older cards must not be tappable: clamping a tap on
          // the fourth card to three would pick the wrong origin.
          for (var needed = 4; needed <= discards.length; needed++) {
            expect(find.byKey(ValueKey('r44-discard-select-$needed')),
              findsNothing);
          }
          for (var needed = 1; needed <= 3; needed++) {
            expect(find.byKey(ValueKey('r44-discard-select-$needed')),
              findsOneWidget);
          }

          final origin = find.byKey(
            const ValueKey('r213-discard-pickup-origin'));
          String originText() => tester.widget<Text>(origin).data!;
          expect(originText(), contains(r52CardLabel('7_C')));
          expect(Directionality.of(tester.element(origin)), direction);
          final palette = R69PlaySurfaceColors.of(tester.element(origin));
          expect(tester.widget<Text>(origin).style!.color, palette.onSurface);
          expect(Theme.of(tester.element(origin)).colorScheme.primary,
            scheme.primary);

          await tester.tap(
            find.byKey(const ValueKey('r44-discard-select-3')));
          await tester.pump();
          expect(originText(), contains(r52CardLabel('6_S')));
          expect(originText(), contains('3'));
          expect(originText(),
            contains(ar ? 'بداية السحب' : 'Pickup starts at'));
          expect(find.byKey(const ValueKey('r40-discard-preview-0')),
            findsOneWidget);

          final confirm = find.byKey(
            const ValueKey('r40-confirm-discard-stack'));
          await tester.ensureVisible(confirm);
          await tester.pumpAndSettle();
          await tester.tap(confirm);
          await tester.pumpAndSettle();
          expect(submittedCount, 3);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
