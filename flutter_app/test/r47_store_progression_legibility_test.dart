import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    testWidgets('R47 store progression remains readable at 320px in $locale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = AppController()
        ..localeCode = locale
        ..vipDays = 0
        ..roundPoints = 125
        ..tournamentPoints = 45
        ..clubPoints = 30
        ..activeXpMultiplier = 1.5;
      addTearDown(() {
        controller.connectivityTimerV173?.cancel();
        controller.dispose();
      });

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Directionality(
          textDirection:
              locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: R47StoreProgressPanel(controller: controller),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byKey(const ValueKey('r47-store-progress-panel')), findsOneWidget);
      expect(find.byKey(const ValueKey('r47-store-next-level')), findsOneWidget);
      final nextLevel = tester.widget<Text>(
        find.byKey(const ValueKey('r47-store-next-level')),
      );
      expect(nextLevel.style?.fontSize, 11.5);

      final multiplier = tester.widget<Text>(
        find.byKey(const ValueKey('r47-store-multiplier')),
      );
      expect(multiplier.data, contains('×1.50'));
      expect(multiplier.style?.fontSize, 11);

      for (final label in locale == 'ar'
          ? <String>['نقاط الجولات', 'نقاط المسابقات', 'نقاط النادي']
          : <String>['Round points', 'Tournament points', 'Club points']) {
        final metric = tester.widget<Text>(
          find.byKey(ValueKey('r47-store-metric-$label')),
        );
        expect(metric.style?.fontSize, 11);
        expect(metric.maxLines, 2);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
