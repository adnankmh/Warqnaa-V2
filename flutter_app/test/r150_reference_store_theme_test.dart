import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R150 reference store header follows theme and direction',
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
        seedColor: const Color(0xff147d71),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff147d71),
        brightness: Brightness.dark,
      ),
    );

    Future<({Color surface, Color title, Color subtitle})> inspect(
      ThemeData theme,
      String locale,
      TextDirection direction,
    ) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r150-reference-store-${theme.brightness}-$locale'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: R35StoreTreasureStrip(controller: controller),
          ),
        ),
      ));
      await tester.pump();

      final panelFinder =
          find.byKey(const ValueKey('r35-reference-store-specials'));
      final titleFinder =
          find.byKey(const ValueKey('r150-reference-store-title'));
      final subtitleFinder =
          find.byKey(const ValueKey('r150-reference-store-subtitle'));
      final panel = tester.widget<Container>(panelFinder);
      final decoration = panel.decoration! as BoxDecoration;
      final title = tester.widget<Text>(titleFinder);
      final subtitle = tester.widget<Text>(subtitleFinder);

      expect(decoration.color, theme.colorScheme.surfaceContainer);
      expect(decoration.border!.top.color, theme.colorScheme.outlineVariant);
      expect(title.style!.color, theme.colorScheme.onSurface);
      expect(subtitle.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(title.style!.fontSize, 17);
      expect(subtitle.style!.fontSize, 11.5);
      expect(
        title.data,
        locale == 'ar'
            ? 'مقتنيات وعروض خاصة'
            : 'Premium items and special offers',
      );
      expect(Directionality.of(tester.element(titleFinder)), direction);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);

      return (
        surface: decoration.color!,
        title: title.style!.color!,
        subtitle: subtitle.style!.color!,
      );
    }

    final lightColors = await inspect(light, 'ar', TextDirection.rtl);
    final darkColors = await inspect(dark, 'en', TextDirection.ltr);
    expect(darkColors, isNot(lightColors));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
