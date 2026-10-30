import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R154 party error message follows theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff286c88),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff286c88),
        brightness: Brightness.dark,
      ),
    );

    Future<Color> inspect(
      ThemeData theme,
      String message,
      TextDirection direction,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r154-party-error-${theme.brightness}-$direction'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: R65PartyErrorMessage(message: message),
        ),
      ));
      await tester.pump();

      final errorFinder =
          find.byKey(const ValueKey('r154-party-error-message'));
      final errorText = tester.widget<Text>(errorFinder);
      final padding = tester.widget<Padding>(
        find.byKey(const ValueKey('r154-party-error-container')),
      );

      expect(errorText.data, message);
      expect(errorText.style!.color, theme.colorScheme.error);
      expect(
        padding.padding,
        const EdgeInsets.symmetric(vertical: 12),
      );
      expect(Directionality.of(tester.element(errorFinder)), direction);
      expect(tester.takeException(), isNull);
      return errorText.style!.color!;
    }

    final lightColor = await inspect(
      light,
      'تعذر الانضمام إلى المجموعة.',
      TextDirection.rtl,
    );
    final darkColor = await inspect(
      dark,
      'Could not join the party.',
      TextDirection.ltr,
    );
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
