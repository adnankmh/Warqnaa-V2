import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R169 spectator error follows theme and direction',
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
            body: R11SpectatorErrorTextR169(message: message),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final finder = find.byKey(const ValueKey('r169-spectator-error'));
      final text = tester.widget<Text>(finder);
      final scheme = Theme.of(tester.element(finder)).colorScheme;

      expect(text.data, message);
      expect(text.style?.color, scheme.error);
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.takeException(), isNull);
      return scheme.error;
    }

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

    final lightError = await inspect(
      light,
      TextDirection.rtl,
      'تعذر تحميل حالة المشاهدة',
    );
    final darkError = await inspect(
      dark,
      TextDirection.ltr,
      'Could not load spectator state',
    );
    expect(darkError, isNot(lightError));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
