import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R157 operations status icon follows theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff286c88),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff286c88),
        brightness: Brightness.dark,
      ),
    );
    final report = <String, dynamic>{
      'release': 'R157',
      'environment': 'test',
      'generated_at': '2026-10-31T00:00:00Z',
    };

    Future<Color> inspect(
      ThemeData theme,
      TextDirection direction,
      bool ar,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r157-operations-icon-${theme.brightness}'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: R65OperationsStatusHero(report: report, ar: ar),
        ),
      ));
      await tester.pump();

      final finder =
          find.byKey(const ValueKey('r157-operations-status-icon'));
      final icon = tester.widget<Icon>(finder);

      expect(icon.icon, Icons.monitor_heart_outlined);
      expect(icon.color, theme.colorScheme.primary);
      expect(icon.size, 36);
      expect(Directionality.of(tester.element(finder)), direction);
      expect(
        find.text(ar ? 'حالة منصتك الآن' : 'Your platform now'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      return icon.color!;
    }

    final lightColor =
        await inspect(light, TextDirection.rtl, true);
    final darkColor =
        await inspect(dark, TextDirection.ltr, false);
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
