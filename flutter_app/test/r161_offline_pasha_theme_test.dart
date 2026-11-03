import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R161 offline and Pasha helper follow theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    Future<List<Color>> inspect(
      ThemeData theme,
      TextDirection direction,
      String helper,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r161-theme-${theme.brightness}'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: Column(
            children: <Widget>[
              const OfflineThemeIconV173(),
              PashaHelperTextV173(text: helper),
            ],
          ),
        ),
      ));
      await tester.pump();

      final icon = tester.widget<Icon>(
        find.byKey(const ValueKey('r161-offline-theme-icon')),
      );
      final text = tester.widget<Text>(
        find.byKey(const ValueKey('r161-pasha-helper')),
      );

      expect(icon.icon, Icons.wifi_off_rounded);
      expect(icon.size, 76);
      expect(icon.color, theme.colorScheme.tertiary);
      expect(text.style?.color, theme.colorScheme.onSurfaceVariant);
      expect(text.style?.fontSize, 12);
      expect(text.style?.height, 1.5);
      expect(
        Directionality.of(
          tester.element(find.byKey(const ValueKey('r161-pasha-helper'))),
        ),
        direction,
      );
      expect(tester.takeException(), isNull);

      return <Color>[icon.color!, text.style!.color!];
    }

    final lightColors = await inspect(
      light,
      TextDirection.rtl,
      'اختيار اللون يطبّق هوية التطبيق.',
    );
    final darkColors = await inspect(
      dark,
      TextDirection.ltr,
      'The selected color updates the app identity.',
    );
    expect(darkColors, isNot(lightColors));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
