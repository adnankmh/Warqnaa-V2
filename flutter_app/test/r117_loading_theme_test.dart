import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R117 loading screen follows light and dark color schemes',
      (tester) async {
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

    Future<List<Color>> loadingGradient(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: const AppLoadingScreen(),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      final background = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('r117-themed-loading-background')),
      );
      final decoration = background.decoration as BoxDecoration;
      return (decoration.gradient! as RadialGradient).colors;
    }

    final lightColors = await loadingGradient(light);
    expect(
      lightColors,
      equals(<Color>[
        light.colorScheme.primaryContainer,
        light.colorScheme.surface,
        light.colorScheme.surfaceContainerLowest,
      ]),
    );

    final darkColors = await loadingGradient(dark);
    expect(
      darkColors,
      equals(<Color>[
        dark.colorScheme.primaryContainer,
        dark.colorScheme.surface,
        dark.colorScheme.surfaceContainerLowest,
      ]),
    );
    expect(darkColors, isNot(equals(lightColors)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
