import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R165 production actions follow theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<List<Color>> inspect(
      ThemeData theme,
      TextDirection direction,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: const Scaffold(
            body: Column(
              children: [
                ProductionActionIconV153(action: ProductionActionV153.voice),
                ProductionActionIconV153(
                  action: ProductionActionV153.verification,
                ),
                ProductionActionIconV153(action: ProductionActionV153.report),
                ProductionActionIconV153(
                  action: ProductionActionV153.deletion,
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pump();

      final actions = ProductionActionV153.values;
      final icons = actions.map((action) {
        final finder = find.byKey(
          ValueKey('r165-production-action-${action.name}'),
        );
        expect(Directionality.of(tester.element(finder)), direction);
        return tester.widget<Icon>(finder);
      }).toList();
      final scheme = Theme.of(tester.element(find.byType(Scaffold))).colorScheme;

      expect(
        icons.map((icon) => icon.icon),
        [
          Icons.mic_rounded,
          Icons.mark_email_read_rounded,
          Icons.report_gmailerrorred_rounded,
          Icons.person_off_rounded,
        ],
      );
      expect(
        icons.map((icon) => icon.color),
        [scheme.primary, scheme.tertiary, scheme.error, scheme.error],
      );
      expect(tester.takeException(), isNull);
      return icons.map((icon) => icon.color!).toList();
    }

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245f80),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245f80),
        brightness: Brightness.dark,
      ),
    );

    final lightColors = await inspect(light, TextDirection.rtl);
    final darkColors = await inspect(dark, TextDirection.ltr);
    expect(darkColors, isNot(lightColors));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
