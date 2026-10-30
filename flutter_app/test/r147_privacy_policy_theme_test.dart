import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R147 privacy policy follows theme, locale, and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController();
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });
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

    Future<List<Color>> inspect(
      ThemeData theme,
      String locale,
      TextDirection direction,
      String expectedUpdated,
      String expectedBody,
    ) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r147-privacy-${theme.brightness}-$locale'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Builder(
          builder: (context) => FilledButton(
            key: const ValueKey('r147-open-privacy'),
            onPressed: () => showPrivacyPolicyPage(context, controller),
            child: const Text('Open privacy'),
          ),
        ),
      ));
      await tester.tap(find.byKey(const ValueKey('r147-open-privacy')));
      await tester.pumpAndSettle();

      final updatedFinder =
          find.byKey(const ValueKey('r147-privacy-updated'));
      final bodyFinder =
          find.byKey(const ValueKey('r147-privacy-section-body')).first;
      final updated = tester.widget<Text>(updatedFinder);
      final body = tester.widget<Text>(bodyFinder);

      expect(updated.data, expectedUpdated);
      expect(body.data, contains(expectedBody));
      expect(updated.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(body.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(Directionality.of(tester.element(updatedFinder)), direction);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(updatedFinder)).pop();
      await tester.pumpAndSettle();
      expect(updatedFinder, findsNothing);
      return <Color>[updated.style!.color!, body.style!.color!];
    }

    final lightColors = await inspect(
      light,
      'ar',
      TextDirection.rtl,
      'آخر تحديث: يوليو 2026',
      'بيانات الحساب',
    );
    final darkColors = await inspect(
      dark,
      'en',
      TextDirection.ltr,
      'Last updated: July 2026',
      'Account details',
    );
    expect(darkColors, isNot(equals(lightColors)));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
