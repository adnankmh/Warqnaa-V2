import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R123 event and summary metadata follow active theme',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1800);
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

    Future<(Color, Color, Color)> metadataColors(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(
            children: [
              LevelCard(controller: controller),
              StatCard(
                icon: '🏆',
                label: 'Matches',
                value: '12',
                onTap: () {},
              ),
              Expanded(child: EventsPage(controller: controller)),
            ],
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final level = tester.widget<Text>(
        find.byKey(const ValueKey('r123-level-card-label')),
      );
      final stat = tester.widget<Text>(
        find.byKey(const ValueKey('r123-stat-card-label')),
      );
      final event = tester.widget<Text>(
        find.byKey(const ValueKey('r123-event-meta-champions')),
      );
      return (
        level.style!.color!,
        stat.style!.color!,
        event.style!.color!,
      );
    }

    final lightColors = await metadataColors(light);
    expect(lightColors.$1, light.colorScheme.onSurfaceVariant);
    expect(lightColors.$2, light.colorScheme.onSurfaceVariant);
    expect(lightColors.$3, light.colorScheme.onSurfaceVariant);

    final darkColors = await metadataColors(dark);
    expect(darkColors.$1, dark.colorScheme.onSurfaceVariant);
    expect(darkColors.$2, dark.colorScheme.onSurfaceVariant);
    expect(darkColors.$3, dark.colorScheme.onSurfaceVariant);
    expect(darkColors.$1, isNot(equals(lightColors.$1)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
