import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[
      Brightness.light, Brightness.dark,
    ]) {
      for (final width in <double>[204, 390]) {
        testWidgets(
          'R215 public discard accessibility $locale $brightness $width',
          (tester) async {
            tester.view.physicalSize = const Size(390, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final ar = locale == 'ar';
            final direction = ar ? TextDirection.rtl : TextDirection.ltr;
            final scheme = ColorScheme.fromSeed(
              seedColor: const Color(0xff1565c0),
              brightness: brightness,
            );
            final labeledCards = <String>[];
            var stockDraws = 0;
            var discardDraws = 0;
            await tester.pumpWidget(MaterialApp(
              theme: ThemeData(useMaterial3: true, colorScheme: scheme),
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: width,
                      height: 184,
                      child: R44RummyTableOverlay(
                        state: <String, dynamic>{
                          'deck_count': 31,
                          // A hidden deck entry must never be announced.
                          'deck': <String>['PRIVATE_STOCK_CARD'],
                          'discard': <Map<String, String>>[
                            <String, String>{'card': '3_H'},
                            <String, String>{'card': '8_S'},
                          ],
                        },
                        players: const <Map<String, dynamic>>[],
                        ar: ar,
                        partnership: false,
                        cardLabel: (card) {
                          labeledCards.add(card);
                          return 'Visible $card';
                        },
                        onDrawDeck: () => stockDraws++,
                        onDrawDiscard: () => discardDraws++,
                      ),
                    ),
                  ),
                ),
              ),
            ));
            await tester.pump();

            final fireLabel = ar ? 'الرمي' : 'Discard';
            final stockLabel = ar ? 'الرزمة' : 'Stock';
            final topLabel = ar ? 'أعلى ورقة' : 'Top card';
            final fireSemantics = find.byWidgetPredicate((widget) =>
                widget is Semantics &&
                widget.properties.label ==
                    '$fireLabel 2 • $topLabel Visible 8_S');
            final stockSemantics = find.byWidgetPredicate((widget) =>
                widget is Semantics &&
                widget.properties.label == '$stockLabel 31');

            expect(fireSemantics, findsOneWidget);
            expect(stockSemantics, findsOneWidget);
            expect(Directionality.of(tester.element(fireSemantics)), direction);
            expect(labeledCards, isNot(contains('PRIVATE_STOCK_CARD')));
            expect(labeledCards, everyElement('8_S'));

            final fireSurface = tester.widget<Container>(
              find.byKey(const ValueKey('r69-discard-pile-surface')),
            );
            final colors = R69PlaySurfaceColors.of(
              tester.element(fireSemantics),
            );
            final decoration = fireSurface.decoration! as BoxDecoration;
            expect((decoration.border! as Border).top.color, colors.accent);
            expect(Theme.of(tester.element(fireSemantics)).colorScheme.primary,
                scheme.primary);
            expect(tester.takeException(), isNull);

            await tester.tap(find.byKey(const ValueKey('r44-stock-pile')));
            await tester.tap(find.byKey(const ValueKey('r44-fire-pile')));
            await tester.pump();
            expect(stockDraws, 1);
            expect(discardDraws, 1);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('R215 empty discard never announces a fictitious top card',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: R44RummyTableOverlay(
          state: const <String, dynamic>{
            'deck_count': 8,
            'discard': <String>[],
          },
          players: const <Map<String, dynamic>>[],
          ar: false,
          partnership: false,
          cardLabel: (card) => card,
        ),
      ),
    ));
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Semantics && widget.properties.label == 'Discard 0'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          (widget.properties.label ?? '').contains('Top card')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
