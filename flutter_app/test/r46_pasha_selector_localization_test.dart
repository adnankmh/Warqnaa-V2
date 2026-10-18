import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    testWidgets('R46 Pasha selector is localized and uses live prices in $locale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = AppController()..localeCode = locale;
      controller.storePriceOverrides['pasha_style_yellow_v173'] = 7777;
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
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: PashaStyleSelectorV173(controller: controller),
            ),
          ),
        ),
      ));
      await tester.pump();

      expect(
        find.text(locale == 'ar' ? 'ألوان طربوش الباشا' : 'Pasha fez colors'),
        findsOneWidget,
      );
      expect(
        find.text(locale == 'ar' ? 'Pasha fez colors' : 'ألوان طربوش الباشا'),
        findsNothing,
      );
      expect(find.text(locale == 'ar' ? 'أصفر' : 'Yellow'), findsOneWidget);
      expect(find.text('🪙 7,777'), findsOneWidget);
      expect(find.text('🪙 6,500'), findsNothing);

      final status = tester.widget<Text>(
        find.byKey(const ValueKey('r46-pasha-status-yellow')),
      );
      expect(status.style?.fontSize, 12);
      expect(status.style?.color, Colors.white);
      expect(tester.takeException(), isNull);
    });
  }
}
