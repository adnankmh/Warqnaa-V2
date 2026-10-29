import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R122 store progress follows light and dark themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()..localeCode = 'en';
    addTearDown(controller.dispose);

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

    Future<(Color, Color, Color)> surfaceColors(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Material(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const ProfileMetric(value: '12', label: 'Test metric'),
                R47StoreProgressPanel(controller: controller),
              ],
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final metric = tester.widget<Text>(
        find.byKey(const ValueKey('r47-store-metric-Test metric')),
      );
      final nextLevel = tester.widget<Text>(
        find.byKey(const ValueKey('r47-store-next-level')),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byKey(const ValueKey('r122-store-level-progress')),
      );
      return (
        metric.style!.color!,
        nextLevel.style!.color!,
        progress.backgroundColor!,
      );
    }

    final lightColors = await surfaceColors(light);
    expect(lightColors.$1, light.colorScheme.onSurfaceVariant);
    expect(lightColors.$2, light.colorScheme.onSurfaceVariant);
    expect(lightColors.$3, light.colorScheme.surfaceContainerHighest);

    final darkColors = await surfaceColors(dark);
    expect(darkColors.$1, dark.colorScheme.onSurfaceVariant);
    expect(darkColors.$2, dark.colorScheme.onSurfaceVariant);
    expect(darkColors.$3, dark.colorScheme.surfaceContainerHighest);
    expect(darkColors.$1, isNot(equals(lightColors.$1)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
