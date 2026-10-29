import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R118 social surfaces use active ColorScheme tokens', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(
      source,
      contains(
        'Theme.of(context).colorScheme.surfaceContainerHighest',
      ),
    );
    expect(
      source,
      contains(
        'Theme.of(context).colorScheme.onSurfaceVariant',
      ),
    );
    expect(
      source,
      isNot(contains(
        'message.mine ? Theme.of(context).colorScheme.primary.withValues(alpha: .18) : Colors.white.withValues(alpha: .06)',
      )),
    );
  });

  testWidgets('R118 empty social state follows light and dark themes',
      (tester) async {
    final controller = AppController()..localeCode = 'ar';
    addTearDown(controller.dispose);

    Future<(Color, Color)> blockedStateColors(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: SocialHubPage(controller: controller),
      ));
      await tester.pump();

      await tester.tap(find.text('المحظورون (0)'));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find.byKey(const ValueKey('r118-empty-state-icon')),
      );
      final label = tester.widget<Text>(
        find.byKey(const ValueKey('r118-empty-state-label')),
      );
      return (icon.color!, label.style!.color!);
    }

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

    final lightColors = await blockedStateColors(light);
    expect(lightColors.$1, light.colorScheme.outline);
    expect(lightColors.$2, light.colorScheme.onSurfaceVariant);

    final darkColors = await blockedStateColors(dark);
    expect(darkColors.$1, dark.colorScheme.outline);
    expect(darkColors.$2, dark.colorScheme.onSurfaceVariant);
    expect(darkColors, isNot(equals(lightColors)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
