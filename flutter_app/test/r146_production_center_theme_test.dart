import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets(
      'R146 production server status follows theme, locale, and refresh',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController();
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.dark,
      ),
    );

    Future<Text> waitForStatus() async {
      final finder =
          find.byKey(const ValueKey('r146-production-status'));
      for (var attempt = 0; attempt < 60 && finder.evaluate().isEmpty; attempt++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(finder, findsOneWidget);
      return tester.widget<Text>(finder);
    }

    Future<Color> inspect(
      ThemeData theme,
      String locale,
      TextDirection direction,
      String expectedStatus,
    ) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r146-production-${theme.brightness}-$locale'),
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: ProductionCenterV153(controller: controller),
        ),
      ));

      var status = await waitForStatus();
      expect(status.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(status.data, contains(expectedStatus));
      expect(
        Directionality.of(tester.element(
          find.byKey(const ValueKey('r146-production-status')),
        )),
        direction,
      );

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();
      status = await waitForStatus();
      expect(status.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(status.data, contains(expectedStatus));
      expect(tester.takeException(), isNull);
      return status.style!.color!;
    }

    final lightColor = await inspect(
      light,
      'ar',
      TextDirection.rtl,
      'وضع محلي',
    );
    final darkColor = await inspect(
      dark,
      'en',
      TextDirection.ltr,
      'Local mode',
    );
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
