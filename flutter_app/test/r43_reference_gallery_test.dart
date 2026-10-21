import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final size in <Size>[
      const Size(320, 720),
      const Size(390, 844),
      const Size(1280, 800),
    ]) {
      testWidgets('R43 reference gallery uses real controls on $locale $size',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        final tabs = <int>[];
        await tester.pumpWidget(MaterialApp(
          locale: Locale(locale),
          home: Scaffold(
            body: SingleChildScrollView(
              child: R43ReferenceQuickDestinations(
                controller: controller,
                onTab: tabs.add,
              ),
            ),
          ),
        ));

        expect(find.byKey(const ValueKey('r43-reference-navigation')), findsOneWidget);
        final grid = find.byKey(const ValueKey('r43-reference-destinations-grid'));
        expect(grid, findsOneWidget);
        expect(find.byType(R43DestinationTile), findsNWidgets(9));
        expect(find.text(locale == 'ar' ? 'معلومات عامة' : 'About Warqnaa'), findsOneWidget);

        final store = find.text(locale == 'ar' ? 'المتجر' : 'Store');
        await tester.ensureVisible(store);
        await tester.pump();
        await tester.tap(store);
        expect(tabs, <int>[0]);

        final bots = find.text(locale == 'ar' ? 'الروبوتات' : 'Practice bots');
        await tester.ensureVisible(bots);
        await tester.pump();
        await tester.tap(bots);
        expect(tabs, <int>[0, 1]);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
