import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  testWidgets('R148 connection diagnostics hint follows theme and direction',
      (tester) async {
    AppSounds.enabled = false;
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

    Future<Color> inspect(
      ThemeData theme,
      String locale,
      TextDirection direction,
    ) async {
      controller.localeCode = locale;
      final originalServer = controller.api.baseUrl;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r148-connection-${theme.brightness}-$locale'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Builder(
          builder: (context) => FilledButton(
            key: const ValueKey('r148-open-connection'),
            onPressed: () => showConnectionDiagnosticsDialog(
              context,
              controller,
            ),
            child: const Text('Open diagnostics'),
          ),
        ),
      ));
      await tester.tap(find.byKey(const ValueKey('r148-open-connection')));
      await tester.pump();

      final hintFinder =
          find.byKey(const ValueKey('r148-connection-phone-hint'));
      final hint = tester.widget<Text>(hintFinder);
      final serverField = tester.widget<TextField>(find.byType(TextField));

      expect(hint.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(hint.style!.fontSize, 11);
      expect(hint.data, contains('HTTPS'));
      expect(Directionality.of(tester.element(hintFinder)), direction);
      expect(serverField.controller!.text, originalServer);
      expect(controller.api.baseUrl, originalServer);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(hintFinder)).pop();
      await tester.pumpAndSettle();
      expect(hintFinder, findsNothing);
      return hint.style!.color!;
    }

    final lightColor = await inspect(light, 'ar', TextDirection.rtl);
    final darkColor = await inspect(dark, 'en', TextDirection.ltr);
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
