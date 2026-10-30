import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R137 tarneeb bid button follows active theme and stays interactive',
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
    var pressCount = 0;

    Future<BoxDecoration> pumpButton(
      ThemeData theme, {
      required bool selected,
    }) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r137-tarneeb-bid-${theme.brightness}-$selected'),
        theme: theme,
        home: Scaffold(
          body: Center(
            child: TarneebBidButtonV170(
              label: '7',
              subtitle: 'Hearts',
              selected: selected,
              onPressed: () => pressCount++,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final surface = tester.widget<AnimatedContainer>(
        find.byKey(const ValueKey('r137-tarneeb-bid-surface')),
      );
      return surface.decoration! as BoxDecoration;
    }

    final lightDecoration = await pumpButton(light, selected: false);
    final lightGradient = lightDecoration.gradient! as LinearGradient;
    expect(lightGradient.colors, <Color>[
      light.colorScheme.surfaceContainerHighest,
      light.colorScheme.surfaceContainer,
    ]);
    expect(lightDecoration.border!.top.color, light.colorScheme.outlineVariant);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('r137-tarneeb-bid-subtitle')),
          )
          .style
          ?.color,
      light.colorScheme.onSurfaceVariant,
    );
    await tester.tap(find.byKey(const ValueKey('r137-tarneeb-bid-label')));
    expect(pressCount, 1);

    final darkDecoration = await pumpButton(dark, selected: false);
    final darkGradient = darkDecoration.gradient! as LinearGradient;
    expect(darkGradient.colors, <Color>[
      dark.colorScheme.surfaceContainerHighest,
      dark.colorScheme.surfaceContainer,
    ]);
    expect(darkGradient.colors.first, isNot(lightGradient.colors.first));
    expect(darkDecoration.border!.top.color, dark.colorScheme.outlineVariant);

    final selectedDecoration = await pumpButton(dark, selected: true);
    expect(selectedDecoration.border!.top.color, dark.colorScheme.primary);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('r137-tarneeb-bid-label')),
          )
          .style
          ?.color,
      dark.colorScheme.onPrimary,
    );
    await tester.tap(find.byKey(const ValueKey('r137-tarneeb-bid-label')));
    expect(pressCount, 2);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
