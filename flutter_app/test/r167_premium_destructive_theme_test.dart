import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R167 premium destructive action follows theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<List<Color>> inspect(
      ThemeData theme,
      TextDirection direction,
      String label,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: PremiumDestructiveButtonV151(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded),
              label: Text(label),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final finder =
          find.byKey(const ValueKey('r167-premium-destructive-button'));
      final button = tester.widget<FilledButton>(finder);
      final scheme = Theme.of(tester.element(finder)).colorScheme;

      expect(find.text(label), findsOneWidget);
      expect(button.style?.backgroundColor?.resolve({}), scheme.error);
      expect(button.style?.foregroundColor?.resolve({}), scheme.onError);
      expect(Directionality.of(tester.element(finder)), direction);
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

    final lightColors = await inspect(light, TextDirection.rtl, 'خروج');
    final darkColors = await inspect(dark, TextDirection.ltr, 'Leave');
    expect(darkColors, isNot(lightColors));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
