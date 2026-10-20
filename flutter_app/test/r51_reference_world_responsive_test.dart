import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final layout in <({Size size, bool stacked, int gameColumns})>[
      (size: Size(320, 640), stacked: true, gameColumns: 2),
      (size: Size(390, 844), stacked: true, gameColumns: 2),
      (size: Size(600, 800), stacked: true, gameColumns: 3),
      (size: Size(844, 390), stacked: false, gameColumns: 3),
      (size: Size(1440, 900), stacked: false, gameColumns: 4),
    ]) {
      testWidgets('R51 luxury world uses readable card columns $locale ${layout.size}', (tester) async {
        tester.view.physicalSize = layout.size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        var selectedTab = -1;
        await tester.pumpWidget(MaterialApp(
          home: Directionality(
            textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(body: R35ReferenceWorldDashboard(
              controller: controller,
              onTab: (tab) => selectedTab = tab,
            )),
          ),
        ));
        await tester.pump();
        expect(find.byKey(const ValueKey('r35-reference-world-dashboard')), findsOneWidget);
        expect(find.byKey(const ValueKey('r35-sky-grand-tournament-banner')), findsOneWidget);
        expect(find.byKey(ValueKey(layout.stacked ? 'r51-featured-stacked' : 'r51-featured-wide')), findsOneWidget);
        expect(find.byKey(ValueKey(layout.stacked ? 'r51-featured-wide' : 'r51-featured-stacked')), findsNothing);
        final cards = find.descendant(
          of: find.byKey(const ValueKey('r51-games-panel')),
          matching: find.byType(GridView),
        );
        expect(cards, findsOneWidget);
        final grid = tester.widget<GridView>(cards);
        final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, layout.gameColumns);
        expect(find.byKey(const ValueKey('r35-game-tarneeb')), findsWidgets);
        final viewAll = find.descendant(
          of: find.byKey(const ValueKey('r51-games-panel')),
          matching: find.byType(TextButton),
        );
        await tester.tap(viewAll);
        expect(selectedTab, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
