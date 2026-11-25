import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('hand geometry stays bounded for portrait and narrow table slots', () {
    for (final width in [0.0, 18.0, 120.0, 204.0, 320.0, 390.0, 844.0]) {
      for (final count in [1, 13, 19]) {
        for (final compact in [false, true]) {
          final g = r289HandGeometry(width, count, compact: compact);
          expect(g.width, greaterThanOrEqualTo(0));
          expect(g.step, greaterThanOrEqualTo(0));
          expect(g.padding * 2 + g.width + (count - 1) * g.step,
            lessThanOrEqualTo(width + .001));
        }
      }
    }
    expect(r289HandGeometry(320, 19).step, greaterThanOrEqualTo(11));
    expect(r289HandGeometry(double.infinity, 19).span.isFinite, isTrue);
  });

  for (final ar in [false, true]) {
    testWidgets('active seat shows a localized countdown ar=$ar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: Locale(ar ? 'ar' : 'en'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1565c0),
          brightness: ar ? Brightness.dark : Brightness.light)),
        home: Scaffold(body: Center(child: R8TableSeat(
          name: 'Player', avatar: const Icon(Icons.person),
          detail: '13', active: true, seconds: 7, turnSeconds: 20,
          compact: true, onTap: () {},
        ))),
      ));
      final value = find.byKey(const ValueKey('r289-turn-seconds'));
      expect(tester.widget<Text>(value).data, '7');
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator));
      expect(progress.value, closeTo(.35, .001));
      expect(progress.semanticsLabel, ar ? 'الوقت المتبقي' : 'Time remaining');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('selected card semantics and all exposed tap strips remain usable',
      (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
      child: SizedBox(width: 320, child: R8CardHand(
        count: 19, selectedIndex: 7,
        cardBuilder: (index, width, height) => GestureDetector(
          key: ValueKey('card-$index'),
          behavior: HitTestBehavior.opaque,
          onTap: () => tapped.add(index),
          child: const ColoredBox(color: Colors.blue),
        ),
      )),
    ))));
    for (var i = 0; i < 19; i++) {
      final card = find.byKey(ValueKey('card-$i'));
      await tester.tapAt(tester.getTopLeft(card) + const Offset(8, 8));
      await tester.pump();
      expect(tapped.last, i);
    }
    expect(find.byWidgetPredicate((w) => w is Semantics &&
        w.properties.selected == true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
