import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R119 premium primitives follow light and dark color schemes',
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

    Future<({
      Color panel,
      Color border,
      Color subtitle,
      Color iconBackground,
      Color quickLabel,
    })> inspect(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(
            children: [
              const PremiumPanel(
                key: ValueKey('r119-panel'),
                child: SizedBox(width: 80, height: 40),
              ),
              PremiumListTile(
                key: const ValueKey('r119-list-tile'),
                icon: '★',
                title: 'Title',
                subtitle: 'Subtitle',
                action: const SizedBox.shrink(),
              ),
              QuickButton(
                key: const ValueKey('r119-quick-button'),
                icon: '⚙',
                label: 'Quick',
                onTap: () {},
              ),
            ],
          ),
        ),
      ));
      await tester.pump();

      final panelBox = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byKey(const ValueKey('r119-panel')),
          matching: find.byType(DecoratedBox),
        ),
      );
      final panelDecoration = panelBox.decoration as BoxDecoration;
      final panelBorder = panelDecoration.border! as Border;

      final subtitle = tester.widget<Text>(find.text('Subtitle'));
      final iconContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('★'),
          matching: find.byType(Container),
        ).first,
      );
      final iconDecoration = iconContainer.decoration! as BoxDecoration;
      final quickLabel = tester.widget<Text>(find.text('Quick'));

      return (
        panel: panelDecoration.color!,
        border: panelBorder.top.color,
        subtitle: subtitle.style!.color!,
        iconBackground: iconDecoration.color!,
        quickLabel: quickLabel.style!.color!,
      );
    }

    final lightColors = await inspect(light);
    expect(lightColors.panel, light.colorScheme.surface);
    expect(
      lightColors.border,
      light.colorScheme.outlineVariant.withValues(alpha: .55),
    );
    expect(lightColors.subtitle, light.colorScheme.onSurfaceVariant);
    expect(
      lightColors.iconBackground,
      light.colorScheme.surfaceContainerHighest,
    );
    expect(lightColors.quickLabel, light.colorScheme.onSurfaceVariant);

    final darkColors = await inspect(dark);
    expect(darkColors.panel, dark.colorScheme.surface);
    expect(
      darkColors.border,
      dark.colorScheme.outlineVariant.withValues(alpha: .55),
    );
    expect(darkColors.subtitle, dark.colorScheme.onSurfaceVariant);
    expect(
      darkColors.iconBackground,
      dark.colorScheme.surfaceContainerHighest,
    );
    expect(darkColors.quickLabel, dark.colorScheme.onSurfaceVariant);
    expect(darkColors, isNot(equals(lightColors)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
