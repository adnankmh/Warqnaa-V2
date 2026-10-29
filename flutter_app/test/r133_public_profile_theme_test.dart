import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R133 public profile metadata follows theme and locale',
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

    const friend = LocalFriend(
      33,
      'Sara',
      'sara',
      online: false,
      activity: 'Offline',
      level: 8,
      gamesPlayed: 20,
      wins: 12,
      xp: 240,
      xpNext: 500,
      clubName: 'Warqnaa Club',
      clubLogo: '🛡️',
    );
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
    const openKey = ValueKey('r133-open-public-profile');

    Future<List<Color?>> openProfile(ThemeData theme, String locale) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r133-public-profile-$locale'),
        locale: Locale(locale),
        supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: theme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                key: openKey,
                onPressed: () =>
                    showPublicPlayerProfileV170(context, controller, friend),
                child: const Text('Open profile'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.byKey(openKey));
      await tester.pumpAndSettle();

      final privacyFinder =
          find.byKey(const ValueKey('r133-public-profile-privacy'));
      expect(
        Directionality.of(tester.element(privacyFinder)),
        locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );

      final logo = tester.widget<Container>(
        find.byKey(const ValueKey('r133-public-profile-club-logo')),
      );
      final logoDecoration = logo.decoration! as BoxDecoration;
      final colors = <Color?>[
        tester
            .widget<Text>(
              find.byKey(const ValueKey('r133-public-profile-username')),
            )
            .style
            ?.color,
        tester
            .widget<Text>(
              find.byKey(const ValueKey('r133-public-profile-club-label')),
            )
            .style
            ?.color,
        tester.widget<Text>(privacyFinder).style?.color,
        tester
            .widget<Icon>(
              find.byKey(const ValueKey('r133-public-profile-presence')),
            )
            .color,
        logoDecoration.color,
      ];
      Navigator.of(tester.element(privacyFinder)).pop();
      await tester.pumpAndSettle();
      return colors;
    }

    final lightColors = await openProfile(light, 'ar');
    expect(
      lightColors.take(4),
      everyElement(light.colorScheme.onSurfaceVariant),
    );
    expect(lightColors.last, light.colorScheme.surfaceContainerHighest);

    final darkColors = await openProfile(dark, 'en');
    expect(
      darkColors.take(4),
      everyElement(dark.colorScheme.onSurfaceVariant),
    );
    expect(darkColors.last, dark.colorScheme.surfaceContainerHighest);
    expect(darkColors, isNot(equals(lightColors)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
