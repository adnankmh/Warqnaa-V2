import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R213 pickup origin $locale $brightness width=$width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final ar = locale == 'ar';
          final direction = ar ? TextDirection.rtl : TextDirection.ltr;
          int? pickedCount;
          const cards = <String>['3_C', '4_D', '5_H', '6_S', '7_C'];
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff1565c0),
                brightness: brightness,
              ),
            ),
            home: Scaffold(body: Builder(builder: (context) =>
              Center(child: FilledButton(
                onPressed: () async {
                  pickedCount = await showDialog<int>(
                    context: context,
                    builder: (_) => Directionality(
                      textDirection: direction,
                      child: AlertDialog(
                        content: R40DiscardStackPicker(
                          maxCount: 5, cards: cards, ar: ar),
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

          final origin = find.byKey(
            const ValueKey('r213-discard-pickup-origin'));
          expect(origin, findsOneWidget);
          Text originText() => tester.widget<Text>(origin);
          expect(originText().data, contains(r52CardLabel('6_S')));
          expect(originText().data, contains('2'));
          expect(Directionality.of(tester.element(origin)), direction);
          expect(originText().style!.color,
            R69PlaySurfaceColors.of(tester.element(origin)).onSurface);

          await tester.tap(
            find.byKey(const ValueKey('r44-discard-select-3')));
          await tester.pump();
          expect(originText().data, contains(r52CardLabel('5_H')));
          expect(originText().data, contains('3'));
          expect(originText().data,
            contains(ar ? 'بداية السحب' : 'Pickup starts at'));
          expect(find.byKey(const ValueKey('r40-discard-preview-0')),
            findsOneWidget);
          // On narrow portrait devices the dialog's content is scrollable.
          // Reach the real confirmation control before tapping it; a tap on
          // an off-viewport widget is not a valid user interaction.
          final confirm = find.byKey(
            const ValueKey('r40-confirm-discard-stack'));
          await tester.ensureVisible(confirm);
          await tester.pumpAndSettle();
          await tester.tap(confirm);
          await tester.pumpAndSettle();
          expect(pickedCount, 3);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
