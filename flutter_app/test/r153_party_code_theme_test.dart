import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R153 party code label follows theme and direction',
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

    Future<Color> inspect(
      ThemeData theme,
      bool ar,
      TextDirection direction,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r153-party-code-${theme.brightness}-$ar'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(18),
            child: R65PartyCodeLabel(ar: ar),
          ),
        ),
      ));
      await tester.pump();

      final labelFinder =
          find.byKey(const ValueKey('r153-party-code-label'));
      final label = tester.widget<Text>(labelFinder);

      expect(label.data, ar ? 'رمز المجموعة' : 'Party code');
      expect(label.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(Directionality.of(tester.element(labelFinder)), direction);
      expect(tester.takeException(), isNull);
      return label.style!.color!;
    }

    final lightColor = await inspect(light, true, TextDirection.rtl);
    final darkColor = await inspect(dark, false, TextDirection.ltr);
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
