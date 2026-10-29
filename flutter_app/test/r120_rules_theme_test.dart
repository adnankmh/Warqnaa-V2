import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R120 game rules sheet follows light and dark color schemes',
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

    Future<(Color, Color)> inspect(ThemeData theme) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Builder(builder: (context) {
          return Scaffold(
            body: FilledButton(
              onPressed: () => showRules(context, 'ar', 'hand'),
              child: const Text('open rules'),
            ),
          );
        }),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('open rules'));
      await tester.pumpAndSettle();

      final metadata = tester.widget<Text>(
        find.byKey(const ValueKey('r120-rules-metadata')),
      );
      final body = tester.widget<Text>(
        find.byKey(const ValueKey('r120-rule-body-طريقة اللعب')),
      );
      return (metadata.style!.color!, body.style!.color!);
    }

    final lightColors = await inspect(light);
    expect(lightColors.$1, light.colorScheme.onSurfaceVariant);
    expect(lightColors.$2, light.colorScheme.onSurfaceVariant);

    final darkColors = await inspect(dark);
    expect(darkColors.$1, dark.colorScheme.onSurfaceVariant);
    expect(darkColors.$2, dark.colorScheme.onSurfaceVariant);
    expect(darkColors, isNot(equals(lightColors)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
