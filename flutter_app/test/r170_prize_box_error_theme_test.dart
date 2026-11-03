import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R170 prize box error follows theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<Color> inspect(
      ThemeData theme,
      TextDirection direction,
      String message,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: PrizeBoxErrorTextR170(message: message),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final finder = find.byKey(const ValueKey('r170-prize-box-error'));
      final text = tester.widget<Text>(finder);
      final scheme = Theme.of(tester.element(finder)).colorScheme;

      expect(text.data, message);
      expect(text.textAlign, TextAlign.center);
      expect(text.style?.color, scheme.error);
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.takeException(), isNull);
      return scheme.error;
    }

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff6d28d9),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff6d28d9),
        brightness: Brightness.dark,
      ),
    );

    final lightError = await inspect(
      light,
      TextDirection.rtl,
      'تعذر تحميل صناديق الجوائز',
    );
    final darkError = await inspect(
      dark,
      TextDirection.ltr,
      'Could not load prize boxes',
    );
    expect(darkError, isNot(lightError));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
