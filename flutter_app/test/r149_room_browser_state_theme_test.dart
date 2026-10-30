import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  testWidgets('R149 room browser state follows theme and direction',
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
        seedColor: const Color(0xff176b87),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff176b87),
        brightness: Brightness.dark,
      ),
    );

    Future<Color> inspect(
      ThemeData theme,
      String locale,
      TextDirection direction,
    ) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r149-room-state-${theme.brightness}-$locale'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: R64RoomBrowserPage(controller: controller),
      ));
      await tester.pump();

      final cardFinder =
          find.byKey(const ValueKey('r149-room-state-card'));
      final iconFinder =
          find.byKey(const ValueKey('r149-room-state-icon'));
      final textFinder =
          find.byKey(const ValueKey('r149-room-state-text'));
      final card = tester.widget<Container>(cardFinder);
      final decoration = card.decoration! as BoxDecoration;
      final icon = tester.widget<Icon>(iconFinder);
      final message = tester.widget<Text>(textFinder);

      expect(decoration.color, theme.colorScheme.surfaceContainerLow);
      expect(decoration.border!.top.color, theme.colorScheme.outlineVariant);
      expect(icon.color, theme.colorScheme.outline);
      expect(message.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(message.style!.height, 1.5);
      expect(
        message.data,
        locale == 'ar'
            ? 'شغّل خادم Laravel لعرض الغرف العامة.'
            : 'Start the Laravel server to browse public rooms.',
      );
      expect(Directionality.of(tester.element(textFinder)), direction);
      expect(tester.takeException(), isNull);
      return message.style!.color!;
    }

    final lightColor = await inspect(light, 'ar', TextDirection.rtl);
    final darkColor = await inspect(dark, 'en', TextDirection.ltr);
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
