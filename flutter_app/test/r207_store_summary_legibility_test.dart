import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets(
      'R207 store summary keeps the 11px floor in portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> verify({
      required String locale,
      required TextDirection direction,
      required Brightness brightness,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0a8f62),
          brightness: brightness,
        ),
      );
      final controller = AppController()..localeCode = locale;

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Material(child: StorePage(controller: controller)),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final summaryFinder =
          find.byKey(const ValueKey('r121-store-summary'));
      await tester.scrollUntilVisible(
        summaryFinder,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      final summary = tester.widget<Text>(summaryFinder);
      expect(summary.style!.fontSize, greaterThanOrEqualTo(11));
      expect(summary.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(
        Directionality.of(tester.element(summaryFinder)),
        direction,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }

    await verify(
      locale: 'ar',
      direction: TextDirection.rtl,
      brightness: Brightness.light,
    );
    await verify(
      locale: 'en',
      direction: TextDirection.ltr,
      brightness: Brightness.dark,
    );
  });
}
