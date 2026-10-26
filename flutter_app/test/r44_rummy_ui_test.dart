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
          state: state, players: players, ar: true, partnership: true,
          cardLabel: (card) => card,
          onDrawDeck: () => stockDraws++,
          onDrawDiscard: () => discardDraws++,
        ),
      ),
    ))));
    expect(find.byKey(const ValueKey('r44-stock-pile')), findsOneWidget);
    expect(find.byKey(const ValueKey('r44-fire-pile')), findsOneWidget);
    expect(find.byKey(const ValueKey('r84-meld-team-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('r44-meld-owner-p0')), findsOneWidget);
    expect(find.byKey(const ValueKey('r44-meld-owner-p2')), findsOneWidget);
    expect(find.text('فريق أ • Player + Partner'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('r44-stock-pile')));
    await tester.tap(find.byKey(const ValueKey('r44-fire-pile')));
    expect(stockDraws, 1);
    expect(discardDraws, 1);
    expect(tester.takeException(), isNull);
  });

  for (final locale in ['ar', 'en']) {
    for (final local in [true, false]) {
      for (final size in [const Size(204, 184), const Size(274, 440), const Size(700, 330)]) {
        testWidgets('R67 public rummy state $locale local=$local $size', (tester) async {
          var draws = 0;
          final players = <Map<String, dynamic>>[
            {'key': 'user:0', 'name': 'Adnan'},
            {'user_key': 'bot:1', 'name': 'Kinan'},
            {'id': 'bot:2', 'name': 'Bayan'},
            {'player_id': 'bot:3', 'name': 'Omar'},
          ];
          final state = <String, dynamic>{
            'deck_count': 47,
            if (local) ...{
              'melds': [['3_H', '4_H', '5_H'], ['A_C', 'A_D', 'A_S']],
              'meld_owners': [1, 2],
              'discard_pile': ['9_C', '8_H'],
            } else ...{
              'melds': {
                'bot:1': [{'cards': ['3_H', '4_H', '5_H']}],
                'bot:2': [{'cards': ['A_C', 'A_D', 'A_S']}],
              },
              'discard': [{'player': 'user:0', 'card': '9_C'}, {'player': 'bot:3', 'card': '8_H'}],
            },
            if (!local) 'teams': {'teamA': ['user:0', 'bot:2'], 'teamB': ['bot:1', 'bot:3']},
          };
          await tester.pumpWidget(MaterialApp(home: Scaffold(body: Directionality(
            textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Center(child: SizedBox(width: size.width, height: size.height,
              child: R44RummyTableOverlay(state: state, players: players,
                ar: locale == 'ar', partnership: true, cardLabel: (card) => card,
                onDrawDeck: () => draws++, onDrawDiscard: () => draws += 10,
                onDrawStack: () => draws += 100))),
          ))));
          final groups = find.byKey(const ValueKey('r44-meld-owner-scroll'));
          final piles = find.byKey(const ValueKey('r44-central-rummy-piles'));
          expect(find.byKey(const ValueKey('r44-meld-owner-bot:1')), findsOneWidget);
          expect(find.byKey(const ValueKey('r44-meld-owner-bot:2')), findsOneWidget);
          expect(find.byKey(const ValueKey('r84-meld-team-1')), findsOneWidget);
          expect(find.byKey(const ValueKey('r84-meld-team-0')), findsOneWidget);
          expect(find.text('${locale == 'ar' ? 'فريق ب' : 'Team B'} • Kinan'), findsOneWidget);
          expect(find.text('${locale == 'ar' ? 'فريق أ' : 'Team A'} • Bayan'), findsOneWidget);
          expect(tester.getRect(groups).bottom, lessThanOrEqualTo(tester.getRect(piles).top));
          final fire = find.byKey(const ValueKey('r44-fire-pile'));
          expect(find.descendant(of: fire, matching: find.text('${locale == 'ar' ? 'الرمي' : 'Discard'} · 2')), findsOneWidget);
          final top = tester.widget<PlayingCard>(find.descendant(of: fire, matching: find.byType(PlayingCard)));
          expect(top.label, '8_H');
          await tester.tap(find.byKey(const ValueKey('r44-stock-pile')));
          await tester.tap(fire);
          await tester.tap(find.byKey(const ValueKey('r44-stack-pick')));
          expect(draws, 111);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

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
