import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R129 challenge metadata follows light and dark themes',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()..localeCode = 'en';
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

    Future<List<Color?>> metadataColors(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ChallengeCenterV175(controller: controller),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      return <Color?>[
        tester
            .widget<Text>(find.byKey(const ValueKey('r129-challenge-intro')))
            .style
            ?.color,
        tester
            .widget<Text>(find.byKey(const ValueKey('r129-road-status')))
            .style
            ?.color,
        tester
            .widget<Text>(
              find.byKey(
                const ValueKey('r129-challenge-description-daily_wins'),
              ),
            )
            .style
            ?.color,
      ];
    }

    final lightColors = await metadataColors(light);
    expect(lightColors, everyElement(light.colorScheme.onSurfaceVariant));

    final darkColors = await metadataColors(dark);
    expect(darkColors, everyElement(dark.colorScheme.onSurfaceVariant));
    expect(darkColors.first, isNot(equals(lightColors.first)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
