import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets(
      'R143 pasha status follows theme, locale direction, and preserves tap',
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
    var taps = 0;

    Future<Color> inspect(
      ThemeData theme,
      String locale,
      TextDirection direction,
    ) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r143-pasha-${theme.brightness}-$locale'),
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: PashaStatCardV151(
                  controller: controller,
                  onTap: () => taps += 1,
                ),
              ),
            ),
          ),
        ),
      ));

      final labelFinder =
          find.byKey(const ValueKey('r143-pasha-stat-label'));
      final label = tester.widget<Text>(labelFinder);
      expect(label.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(label.style!.fontSize, 11);
      expect(Directionality.of(tester.element(labelFinder)), direction);

      final goldStatus = tester.widgetList<Text>(find.byType(Text)).singleWhere(
            (text) => text.style?.color == const Color(0xffffcf67),
          );
      expect(goldStatus.style!.fontSize, 12);

      final before = taps;
      await tester.tap(find.byType(PashaStatCardV151));
      await tester.pump();
      expect(taps, before + 1);
      expect(tester.takeException(), isNull);
      return label.style!.color!;
    }

    final lightAr =
        await inspect(light, 'ar', TextDirection.rtl);
    final darkAr =
        await inspect(dark, 'ar', TextDirection.rtl);
    expect(darkAr, isNot(lightAr));

    final lightEn =
        await inspect(light, 'en', TextDirection.ltr);
    final darkEn =
        await inspect(dark, 'en', TextDirection.ltr);
    expect(darkEn, isNot(lightEn));
    expect(taps, 4);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
