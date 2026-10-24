import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

BoxDecoration decorationOf(WidgetTester tester, Finder finder) {
  return tester.widget<Container>(finder).decoration! as BoxDecoration;
}

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final themeCode in <String>['royal_crimson', 'emerald_light']) {
      testWidgets('R69 $themeCode reaches rummy piles and meld selection in $locale',
          (tester) async {
        final expectedAccent = r101Themes[themeCode]!.accent;
        final theme = r101Theme(themeCode, '#25e4df', localeCode: locale);
        final expectedSurface = Color.lerp(
          theme.colorScheme.surface,
          theme.scaffoldBackgroundColor,
          theme.brightness == Brightness.dark ? .34 : .16,
        )!.withValues(alpha: .90);
        final state = <String, dynamic>{
          'deck_count': 41,
          'discard_pile': <String>['8_H'],
          'melds': <List<String>>[
            <String>['3_H', '4_H', '5_H'],
          ],
          'meld_owners': <int>[0],
        };
        final players = <Map<String, dynamic>>[
          <String, dynamic>{'key': 'p0', 'name': 'Adnan'},
        ];

        await tester.pumpWidget(MaterialApp(
          locale: Locale(locale),
          theme: theme,
          home: Scaffold(body: Directionality(
            textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: R44RummyTableOverlay(
              state: state,
              players: players,
              ar: locale == 'ar',
              partnership: false,
              cardLabel: (card) => card,
              onDrawDeck: () {},
              onDrawDiscard: () {},
            ),
          )),
        ));
        final stock = decorationOf(
          tester, find.byKey(const ValueKey('r69-stock-pile-surface')));
        final owner = decorationOf(
          tester, find.byKey(const ValueKey('r44-meld-owner-p0')));
        expect((stock.border! as Border).top.color, expectedAccent);
        expect(owner.color, expectedSurface);
        expect(find.byKey(const ValueKey('r44-central-rummy-piles')), findsOneWidget);

        await tester.pumpWidget(MaterialApp(
          locale: Locale(locale),
          theme: theme,
          home: Scaffold(body: Builder(builder: (context) => FilledButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => R36MeldWorkspace(
                cards: const <String>['7_C', '5_C', '6_C', 'K_S'],
                ar: locale == 'ar',
              ),
            ),
            child: const Text('Open'),
          ))),
        ));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final firstCard = find.byKey(const ValueKey('r36-meld-card-0'));
        await tester.tap(firstCard);
        await tester.pump();
        final selectedSurface =
            find.byKey(const ValueKey('r69-meld-card-surface-0'));
        final selected = decorationOf(tester, selectedSurface);
        expect((selected.border! as Border).top.color, expectedAccent);
        expect(find.byKey(const ValueKey('r64-sort-meld-cards')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
