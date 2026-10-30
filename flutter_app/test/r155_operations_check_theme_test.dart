import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R155 operations check icons follow theme and direction',
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

    Future<List<Color>> inspect(
      ThemeData theme,
      TextDirection direction,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r155-operations-check-${theme.brightness}'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: const Scaffold(
          body: Row(
            children: <Widget>[
              R65OperationsCheckIcon(ok: true),
              R65OperationsCheckIcon(ok: false),
            ],
          ),
        ),
      ));
      await tester.pump();

      final okFinder =
          find.byKey(const ValueKey('r155-operations-check-ok'));
      final attentionFinder =
          find.byKey(const ValueKey('r155-operations-check-attention'));
      final okIcon = tester.widget<Icon>(okFinder);
      final attentionIcon = tester.widget<Icon>(attentionFinder);

      expect(okIcon.icon, Icons.check_circle_outline);
      expect(okIcon.color, theme.colorScheme.tertiary);
      expect(attentionIcon.icon, Icons.info_outline);
      expect(attentionIcon.color, theme.colorScheme.error);
      expect(Directionality.of(tester.element(okFinder)), direction);
      expect(Directionality.of(tester.element(attentionFinder)), direction);
      expect(tester.takeException(), isNull);
      return <Color>[okIcon.color!, attentionIcon.color!];
    }

    final lightColors = await inspect(light, TextDirection.rtl);
    final darkColors = await inspect(dark, TextDirection.ltr);
    expect(darkColors, isNot(lightColors));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
