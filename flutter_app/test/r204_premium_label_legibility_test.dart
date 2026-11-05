import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets(
      'R204 premium compact labels keep the 11px floor in portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> verify({
      required Brightness brightness,
      required TextDirection direction,
      required String quickLabel,
      required String subtitle,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0a8f62),
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Column(
              children: [
                QuickButton(
                  key: const ValueKey('r204-quick'),
                  icon: '★',
                  label: quickLabel,
                  onTap: () {},
                ),
                PremiumListTile(
                  key: const ValueKey('r204-tile'),
                  icon: '🎁',
                  title: direction == TextDirection.rtl ? 'المكافأة' : 'Reward',
                  subtitle: subtitle,
                  action: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ));
      // Let MaterialApp finish its AnimatedTheme transition before
      // comparing semantic colors across consecutive light/dark cases.
      await tester.pump(const Duration(milliseconds: 300));

      final quick = tester.widget<Text>(find.text(quickLabel));
      final detail = tester.widget<Text>(find.text(subtitle));
      expect(quick.style!.fontSize, greaterThanOrEqualTo(11));
      expect(detail.style!.fontSize, greaterThanOrEqualTo(11));
      expect(quick.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(detail.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(
        tester.getSize(find.byKey(const ValueKey('r204-quick'))),
        const Size(58, 66),
      );
      expect(tester.takeException(), isNull);
    }

    await verify(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
      quickLabel: 'الترتيب',
      subtitle: '١٠٠ توكن ومكافأة يومية',
    );
    await verify(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
      quickLabel: 'Leaderboard',
      subtitle: '100 tokens and a daily reward',
    );
  });
}
