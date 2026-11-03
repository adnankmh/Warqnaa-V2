import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R166 production safety controls follow theme and direction',
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
          child: Scaffold(
            body: Column(
              children: [
                const ProductionErrorTextV153(message: 'Server unavailable'),
                ProductionDestructiveButtonV153(
                  onPressed: () {},
                  child: const Text('Delete account'),
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final errorFinder =
          find.byKey(const ValueKey('r166-production-error-text'));
      final buttonFinder =
          find.byKey(const ValueKey('r166-production-destructive-button'));
      final errorText = tester.widget<Text>(errorFinder);
      final button = tester.widget<FilledButton>(buttonFinder);
      final scheme = Theme.of(tester.element(errorFinder)).colorScheme;

      expect(errorText.data, 'Server unavailable');
      expect(errorText.style?.color, scheme.error);
      expect(errorText.style?.fontSize, 11);
      expect(button.style?.backgroundColor?.resolve({}), scheme.error);
      expect(button.style?.foregroundColor?.resolve({}), scheme.onError);
      expect(Directionality.of(tester.element(errorFinder)), direction);
      expect(Directionality.of(tester.element(buttonFinder)), direction);
      expect(tester.takeException(), isNull);
      return [scheme.error, scheme.onError];
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
