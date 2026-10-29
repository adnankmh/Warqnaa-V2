import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R124 room connection error follows active theme and locale',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    var retries = 0;

    Future<(Color, Color)> supportColors(ThemeData theme, bool ar) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: R124RoomConnectionError(
            ar: ar,
            message: ar ? 'تعذر الوصول إلى الخادم.' : 'Server unavailable.',
            onRetry: () => retries++,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final message = tester.widget<Text>(
        find.byKey(const ValueKey('r124-room-error-message')),
      );
      final hint = tester.widget<Text>(
        find.byKey(const ValueKey('r124-room-error-hint')),
      );
      expect(
        find.text(ar ? 'تعذّر الاتصال بالطاولة' : 'Unable to connect to the table'),
        findsOneWidget,
      );
      expect(find.text(ar ? 'إعادة الاتصال' : 'Reconnect'), findsOneWidget);
      expect(tester.takeException(), isNull);
      return (message.style!.color!, hint.style!.color!);
    }

    final lightColors = await supportColors(light, true);
    expect(lightColors.$1, light.colorScheme.onSurfaceVariant);
    expect(lightColors.$2, light.colorScheme.onSurfaceVariant);
    await tester.tap(find.text('إعادة الاتصال'));
    expect(retries, 1);

    final darkColors = await supportColors(dark, false);
    expect(darkColors.$1, dark.colorScheme.onSurfaceVariant);
    expect(darkColors.$2, dark.colorScheme.onSurfaceVariant);
    expect(darkColors.$1, isNot(equals(lightColors.$1)));
    await tester.tap(find.text('Reconnect'));
    expect(retries, 2);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
