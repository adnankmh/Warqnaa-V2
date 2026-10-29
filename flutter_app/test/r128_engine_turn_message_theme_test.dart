import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R128 engine turn message follows light and dark themes',
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
    const surfaceKey = ValueKey('r128-test-surface');

    Future<BoxDecoration> pumpMessage(ThemeData theme) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: R128EngineTurnMessage(
                message: 'Waiting for the next move',
                surfaceKey: surfaceKey,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final surface = tester.widget<Container>(find.byKey(surfaceKey));
      final message = tester.widget<Text>(find.text('Waiting for the next move'));
      expect(message.style?.color, theme.colorScheme.onSurface);
      expect((surface.decoration! as BoxDecoration).border, isNotNull);
      expect(tester.takeException(), isNull);
      return surface.decoration! as BoxDecoration;
    }

    final lightDecoration = await pumpMessage(light);
    expect(
      lightDecoration.color,
      light.colorScheme.surfaceContainerHighest.withValues(alpha: .88),
    );
    expect(
      (lightDecoration.border! as Border).top.color,
      light.colorScheme.outlineVariant,
    );

    final darkDecoration = await pumpMessage(dark);
    expect(
      darkDecoration.color,
      dark.colorScheme.surfaceContainerHighest.withValues(alpha: .88),
    );
    expect(
      (darkDecoration.border! as Border).top.color,
      dark.colorScheme.outlineVariant,
    );
    expect(darkDecoration.color, isNot(equals(lightDecoration.color)));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
