import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R44 Rummy shows owned melds and two distinct, server-gated piles',
      (tester) async {
    var stockDraws = 0;
    var discardDraws = 0;
    final state = <String, dynamic>{
      'config': <String, dynamic>{'partnership': true},
      'deck_count': 61,
      'discard': <String>['5_H', '9_C'],
      'melds': <String, dynamic>{
        'p0': <Map<String, dynamic>>[
          <String, dynamic>{'cards': <String>['3_C', '4_C', '5_C'], 'value': 12},
        ],
        'p2': <Map<String, dynamic>>[
          <String, dynamic>{'cards': <String>['A_H', 'A_C', 'A_S'], 'value': 33},
        ],
      },
    };
    final players = <Map<String, dynamic>>[
      <String, dynamic>{'id': 'p0', 'name': 'Player', 'team': 0},
      <String, dynamic>{'id': 'p1', 'name': 'Opponent', 'team': 1},
      <String, dynamic>{'id': 'p2', 'name': 'Partner', 'team': 0},
      <String, dynamic>{'id': 'p3', 'name': 'Opponent 2', 'team': 1},
    ];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
      child: SizedBox(
        width: 340, height: 390,
        child: R44RummyTableOverlay(
          state: state, players: players, ar: true,
          cardLabel: (card) => card,
          onDrawDeck: () => stockDraws++,
          onDrawDiscard: () => discardDraws++,
        ),
      ),
    ))));
    expect(find.byKey(const ValueKey('r44-stock-pile')), findsOneWidget);
    expect(find.byKey(const ValueKey('r44-fire-pile')), findsOneWidget);
    expect(find.byKey(const ValueKey('r44-meld-owner-p0')), findsOneWidget);
    expect(find.byKey(const ValueKey('r44-meld-owner-p2')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('r44-stock-pile')));
    await tester.tap(find.byKey(const ValueKey('r44-fire-pile')));
    expect(stockDraws, 1);
    expect(discardDraws, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('R44 tapping buried discard takes exactly that and newer cards',
      (tester) async {
    int? drawn;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
      child: Builder(builder: (context) => FilledButton(
        onPressed: () async {
          drawn = await showDialog<int>(
            context: context,
            builder: (context) => AlertDialog(content: R40DiscardStackPicker(
              cards: const <String>['3_H','4_H','5_H','6_H'],
              maxCount: 4, ar: true)),
          );
        },
        child: const Text('Open fire'),
      )),
    ))));
    await tester.tap(find.text('Open fire'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('r44-discard-select-3')));
    await tester.pump();
    expect(find.text('اسحب 3 أوراق'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('r40-confirm-discard-stack')));
    await tester.pumpAndSettle();
    expect(drawn, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('R44 hand setup saves color-bordered groups without card loss',
      (tester) async {
    List<List<String>>? result;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
      child: Builder(builder: (context) => FilledButton(
        onPressed: () async {
          result = await showDialog<List<List<String>>>(
            context: context,
            builder: (_) => const R36MeldWorkspace(
              ar: true, cards: <String>['3_H','4_H','5_H','9_D']),
          );
        },
        child: const Text('Group'),
      )),
    ))));
    await tester.tap(find.text('Group'));
    await tester.pumpAndSettle();
    for (final i in <int>[0, 1, 2]) {
      await tester.tap(find.byKey(ValueKey('r36-meld-card-$i')));
    }
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('r36-add-meld-group')));
    await tester.pump();
    expect(find.byKey(const ValueKey('r44-meld-group-0')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('r36-submit-meld-groups')));
    await tester.pumpAndSettle();
    expect(result, <List<String>>[<String>['3_H','4_H','5_H']]);
    expect(tester.takeException(), isNull);
  });
}
