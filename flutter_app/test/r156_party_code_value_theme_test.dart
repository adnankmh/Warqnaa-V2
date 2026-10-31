import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R156 party code value follows theme and direction',
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
      TextDirection direction,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r156-party-code-${theme.brightness}'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: const Scaffold(
          body: R65PartyCodeValue(code: 'AB12CD3'),
        ),
      ));
      await tester.pump();

      final finder = find.byKey(const ValueKey('r156-party-code-value'));
      final value = tester.widget<SelectableText>(finder);

      expect(value.data, 'AB12CD3');
      expect(value.style?.color, theme.colorScheme.primary);
      expect(value.style?.fontSize, 32);
      expect(value.style?.fontWeight, FontWeight.w900);
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.takeException(), isNull);
      return value.style!.color!;
    }

    final lightColor = await inspect(light, TextDirection.rtl);
    final darkColor = await inspect(dark, TextDirection.ltr);
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
