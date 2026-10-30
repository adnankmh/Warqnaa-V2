import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R135 top bar follows theme and RTL/LTR locale',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()..serverConnected = false;
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

    Future<Color?> pumpTopBar(ThemeData theme, String locale) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r135-topbar-$locale'),
        locale: Locale(locale),
        supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => buildV170TopBar(context, controller),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final status = find.byKey(const ValueKey('r135-topbar-status'));
      expect(status, findsOneWidget);
      expect(
        Directionality.of(tester.element(status)),
        locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      return tester.widget<Text>(status).style?.color;
    }

    final lightColor = await pumpTopBar(light, 'ar');
    expect(lightColor, light.colorScheme.onSurfaceVariant);
    expect(find.textContaining('محلي'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('r135-topbar-menu')));
    await tester.pumpAndSettle();
    expect(find.text('تدوير الشاشة'), findsOneWidget);
    expect(find.text('فحص الاتصال'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);

    final darkColor = await pumpTopBar(dark, 'en');
    expect(darkColor, dark.colorScheme.onSurfaceVariant);
    expect(darkColor, isNot(equals(lightColor)));
    expect(find.textContaining('Local'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('r135-topbar-menu')));
    await tester.pumpAndSettle();
    expect(find.text('Rotate screen'), findsOneWidget);
    expect(find.text('Connection diagnostics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
