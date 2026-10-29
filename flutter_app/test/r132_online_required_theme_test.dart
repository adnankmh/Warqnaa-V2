import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'R132 online required screen follows theme and RTL/LTR locale',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
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

    Future<List<Color?>> pumpScreen({
      required ThemeData theme,
      required String locale,
      required TextDirection direction,
    }) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: OnlineRequiredScreenV173(controller: controller),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        Directionality.of(
          tester.element(
            find.byKey(const ValueKey('r132-online-required-title')),
          ),
        ),
        direction,
      );
      return <Color?>[
        tester
            .widget<Text>(
              find.byKey(const ValueKey('r132-online-required-title')),
            )
            .style
            ?.color,
        tester
            .widget<Text>(
              find.byKey(const ValueKey('r132-online-required-helper')),
            )
            .style
            ?.color,
      ];
    }

    final lightColors = await pumpScreen(
      theme: light,
      locale: 'ar',
      direction: TextDirection.rtl,
    );
    expect(lightColors.first, light.colorScheme.onSurface);
    expect(lightColors.last, light.colorScheme.onSurfaceVariant);
    expect(find.text('إعادة الاتصال'), findsOneWidget);
    expect(find.text('العودة لتسجيل الدخول'), findsOneWidget);

    final darkColors = await pumpScreen(
      theme: dark,
      locale: 'en',
      direction: TextDirection.ltr,
    );
    expect(darkColors.first, dark.colorScheme.onSurface);
    expect(darkColors.last, dark.colorScheme.onSurfaceVariant);
    expect(darkColors, isNot(equals(lightColors)));
    expect(find.text('Reconnect'), findsOneWidget);
    expect(find.text('Back to sign in'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
