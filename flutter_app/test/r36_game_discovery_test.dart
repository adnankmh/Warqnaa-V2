import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R36 finds either language, Arabic marks and Basra aliases', () {
    final tarneeb = customerGamesR101.firstWhere((g) => g.id == 'tarneeb');
    final basra = customerGamesR101.firstWhere((g) => g.id == 'basra');
    final partner = customerGamesR101.firstWhere((g) => g.id == 'trix_partner');
    expect(matchesGameSearchR36(tarneeb, '  TARNEEB  '), isTrue);
    expect(matchesGameSearchR36(tarneeb, 'طَـرْنِيب'), isTrue);
    expect(matchesGameSearchR36(basra, 'بصرة'), isTrue);
    expect(matchesGameSearchR36(basra, 'basrah'), isTrue);
    expect(matchesGameSearchR36(partner, 'تركس شراكة'), isTrue);
    expect(matchesGameSearchR36(tarneeb, 'هاند'), isFalse);
    expect(matchesGameSearchR36(tarneeb, '', family: 'meld'), isFalse);
    expect(customerGamesR101.where((g) => matchesGameSearchR36(g, '', family: 'meld')), hasLength(4));
  });

  testWidgets('R36 game hall combines family and search and resets empty results', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() { tester.view.resetPhysicalSize(); tester.view.resetDevicePixelRatio(); });
    final controller = AppController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: GamesPage(controller: controller)),
    )));
    expect(find.byKey(const ValueKey('r36-game-results')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('r36-family-tarneeb')));
    await tester.pumpAndSettle();
    expect(find.text('النتائج: 3 / 12'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('r36-game-search')), 'هاند');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('r36-games-empty')), findsOneWidget);
    await tester.tap(find.text('عرض جميع الألعاب'));
    await tester.pumpAndSettle();
    expect(find.text('النتائج: 12 / 12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
