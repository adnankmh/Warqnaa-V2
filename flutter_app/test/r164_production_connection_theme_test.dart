import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R164 production connection follows theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<Color> inspect(
      ThemeData theme,
      TextDirection direction,
      bool connected,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: ProductionConnectionIconV153(connected: connected),
          ),
        ),
      ));
      await tester.pump();

      final finder =
          find.byKey(const ValueKey('r164-production-connection-icon'));
      final icon = tester.widget<Icon>(finder);
      final scheme = Theme.of(tester.element(finder)).colorScheme;

      expect(
        icon.icon,
        connected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
      );
      expect(icon.color, connected ? scheme.tertiary : scheme.outline);
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.takeException(), isNull);
      return icon.color!;
    }

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245f80),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245f80),
        brightness: Brightness.dark,
      ),
    );

    final lightConnected = await inspect(light, TextDirection.rtl, true);
    final darkOffline = await inspect(dark, TextDirection.ltr, false);
    expect(darkOffline, isNot(lightConnected));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
