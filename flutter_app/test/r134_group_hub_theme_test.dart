import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R134 group hub follows theme and RTL/LTR locale',
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

    Future<List<Color?>> pumpHub(ThemeData theme, String locale) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r134-group-hub-$locale'),
        locale: Locale(locale),
        supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: theme,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: GroupInnovationHubV170(controller: controller),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final first =
          find.byKey(const ValueKey('r134-group-hub-subtitle-0'));
      expect(
        Directionality.of(tester.element(first)),
        locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      return List<Color?>.generate(
        6,
        (index) => tester
            .widget<Text>(
              find.byKey(ValueKey('r134-group-hub-subtitle-$index')),
            )
            .style
            ?.color,
      );
    }

    final lightColors = await pumpHub(light, 'ar');
    expect(
      lightColors,
      everyElement(light.colorScheme.onSurfaceVariant),
    );
    expect(find.text('مركز المجموعة الاحترافي'), findsOneWidget);
    expect(find.text('مركز النزاهة'), findsOneWidget);

    final darkColors = await pumpHub(dark, 'en');
    expect(
      darkColors,
      everyElement(dark.colorScheme.onSurfaceVariant),
    );
    expect(darkColors.first, isNot(equals(lightColors.first)));
    expect(find.text('Professional group center'), findsOneWidget);
    expect(find.text('Integrity center'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
