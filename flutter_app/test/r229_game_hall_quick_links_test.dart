import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    for (final dark in [false, true]) {
      for (final width in [320.0, 390.0]) {
        testWidgets('R229 portrait $locale dark=$dark width=$width', (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });
          final tapped = <String>[];
          final direction = locale == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr;
          final semantics = tester.ensureSemantics();
          addTearDown(semantics.dispose);
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0B8CFF),
                brightness: dark ? Brightness.dark : Brightness.light,
              ),
            ),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: width - 26,
                    child: R229GameHallQuickLinks(
                      locale: locale,
                      onLeaderboard: () => tapped.add('leaderboard'),
                      onRules: () => tapped.add('rules'),
                      onCompetitions: () => tapped.add('competitions'),
                      onTap: () => tapped.add('friends'),
                    ),
                  ),
                ),
              ),
            ),
          ));
          expect(Directionality.of(
              tester.element(find.byKey(const ValueKey('r229-games-quick-links')))),
              direction);
          expect(find.byKey(const ValueKey('r229-games-quick-links')), findsOneWidget);
          for (final name in ['leaderboard', 'rules', 'competitions', 'friends']) {
            expect(find.byKey(ValueKey('r229-games-quick-$name')), findsOneWidget);
          }
          final first = tester.getTopLeft(
              find.byKey(const ValueKey('r229-games-quick-leaderboard')));
          final second = tester.getTopLeft(
              find.byKey(const ValueKey('r229-games-quick-rules')));
          final third = tester.getTopLeft(
              find.byKey(const ValueKey('r229-games-quick-competitions')));
          expect(first.dy, second.dy);
          expect(third.dy, greaterThan(first.dy));
          final expectedBlue = dark
              ? const Color(0xFF064C8C)
              : const Color(0xFF0877C7);
          expect(tester.widgetList<Material>(find.byType(Material))
              .where((material) => material.color == expectedBlue).length, 4);
          final label = locale == 'ar' ? 'قواعد اللعب' : 'Game rules';
          expect(find.bySemanticsLabel(label), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('r229-games-quick-rules')));
          expect(tapped, ['rules']);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R229 wide landscape keeps all four shortcuts on one row',
      (tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 760,
            child: R229GameHallQuickLinks(
              locale: 'en',
              onLeaderboard: () {},
              onRules: () {},
              onCompetitions: () {},
              onTap: () {},
            ),
          ),
        ),
      ),
    ));
    final first = tester.getTopLeft(
        find.byKey(const ValueKey('r229-games-quick-leaderboard')));
    final fourth = tester.getTopLeft(
        find.byKey(const ValueKey('r229-games-quick-friends')));
    expect(first.dy, fourth.dy);
    expect(tester.takeException(), isNull);
  });
}
