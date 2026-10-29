import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R121 store support text uses active ColorScheme tokens', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains("key: const ValueKey('r121-store-summary')"));
    expect(source, contains("key: const ValueKey('r121-store-tier')"));
    expect(source, contains("key: const ValueKey('r121-store-safety')"));
    expect(
      source,
      isNot(contains(
        "style: const TextStyle(color: Colors.white60, fontSize: 9, height: 1.4)",
      )),
    );
  });

  testWidgets('R121 store summary follows light and dark themes',
      (tester) async {
    final controller = AppController()..localeCode = 'ar';
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

    Future<Color> summaryColor(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: StorePage(controller: controller),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      final summary = tester.widget<Text>(
        find.byKey(const ValueKey('r121-store-summary')),
      );
      return summary.style!.color!;
    }

    final lightColor = await summaryColor(light);
    expect(lightColor, light.colorScheme.onSurfaceVariant);

    final darkColor = await summaryColor(dark);
    expect(darkColor, dark.colorScheme.onSurfaceVariant);
    expect(darkColor, isNot(equals(lightColor)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
