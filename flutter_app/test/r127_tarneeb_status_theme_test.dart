import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R127 Tarneeb status item follows light and dark themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    const surfaceKey = ValueKey('r127-test-surface');

    Future<BoxDecoration> pumpItem(ThemeData theme) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: R127TarneebStatusItem(
                surfaceKey: surfaceKey,
                label: 'Bidder',
                value: 'Adnan',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final surface = tester.widget<Container>(find.byKey(surfaceKey));
      final label = tester.widget<Text>(find.text('Bidder'));
      final value = tester.widget<Text>(find.text('Adnan'));
      expect(label.style?.color, theme.colorScheme.onSurfaceVariant);
      expect(value.style?.color, theme.colorScheme.primary);
      expect(tester.takeException(), isNull);
      return surface.decoration! as BoxDecoration;
    }

    final lightDecoration = await pumpItem(light);
    expect(
      lightDecoration.color,
      light.colorScheme.surfaceContainerHighest.withValues(alpha: .62),
    );

    final darkDecoration = await pumpItem(dark);
    expect(
      darkDecoration.color,
      dark.colorScheme.surfaceContainerHighest.withValues(alpha: .62),
    );
    expect(darkDecoration.color, isNot(equals(lightDecoration.color)));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
