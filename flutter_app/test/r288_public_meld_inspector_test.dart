import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final ar in [false, true]) {
    for (final partnership in [false, true]) {
      testWidgets('public meld inspector ar=$ar partnership=$partnership',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final seen = <String>[];
        var draws = 0;
        final groups = <List<String>>[
          ['3_H', '3_S', '3_D'],
          ['4_H', '4_S', '4_D'],
          ['5_H', '5_S', '5_D'],
          ['6_H', '6_S', '6_D'],
          ['7_H', '7_S', '7_D'],
        ];
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff1565c0),
            brightness: ar ? Brightness.dark : Brightness.light,
          )),
          home: Directionality(
            textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(body: Center(child: SizedBox(
              width: 340, height: 440,
              child: R44RummyTableOverlay(
                state: {
                  'melds': {'p1': groups},
                  'teams': {'teamA': ['p1']},
                  'deck_count': 20,
                  'deck': ['PRIVATE_STOCK'],
                  'discard': ['8_S'],
                },
                players: const [
                  {'key': 'p1', 'name': 'Public player', 'hand': ['PRIVATE_HAND']},
                ],
                ar: ar, partnership: partnership,
                cardLabel: (card) { seen.add(card); return 'A♠'; },
                onDrawDeck: () => draws++,
                onDrawDiscard: () => draws++,
              ),
            ))),
          ),
        ));
        await tester.pumpAndSettle();
        expect(seen, isNot(contains('7_H')));
        final more = find.byKey(const ValueKey('r288-more-melds-p1'));
        expect(more, findsOneWidget);
        await tester.ensureVisible(more);
        await tester.tap(more);
        await tester.pumpAndSettle();
        final list = find.byKey(const ValueKey('r288-public-meld-list'));
        expect(list, findsOneWidget);
        final fifth = find.byKey(const ValueKey('r288-public-meld-4'));
        await tester.scrollUntilVisible(fifth, 100,
            scrollable: find.descendant(of: list,
                matching: find.byType(Scrollable)).first);
        expect(fifth, findsOneWidget);
        expect(seen, contains('7_H'));
        expect(seen, isNot(contains('PRIVATE_STOCK')));
        expect(seen, isNot(contains('PRIVATE_HAND')));
        expect(draws, 0);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('only public discard top card is included in pile semantics',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: Center(child: SizedBox(width: 240, height: 180,
        child: R44RummyTableOverlay(
          state: const {'deck_count': 12, 'deck': ['hidden'],
            'discard': ['2_H', '8_S']},
          players: const [], ar: false, partnership: false,
          cardLabel: (card) => card,
        ),
      )),
    )));
    expect(find.byWidgetPredicate((w) => w is Semantics &&
        w.properties.label == 'Discard 2 • Top card 8_S'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Semantics &&
        w.properties.label == 'Stock 12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
