import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

Widget _profileApp(AppController controller) => MaterialApp(
      locale: Locale(controller.localeCode),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: r101Theme(controller.themeCode, controller.uiAccentHex),
      home: R61ProfilePage(controller: controller),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    testWidgets('R19 Pasha profile hero is responsive in $locale', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      AppSounds.enabled = false;
      final controller = AppController()
        ..localeCode = locale
        ..selectedPashaStyle = 'blue'
        ..selectedProfileColorB304 = 'r19_profile_sapphire_pasha_30d'
        ..vipDays = 12
        ..username = 'Adnan'
        ..countryName = locale == 'ar' ? 'فلسطين' : 'Palestinian Territory';
      addTearDown(() {
        controller.connectivityTimerV173?.cancel();
        controller.dispose();
      });
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;

      for (final size in <Size>[const Size(320, 640), const Size(844, 390)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(_profileApp(controller));
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.byType(R19PashaProfileHero), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.label == 'r19-pasha-profile-hero',
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('r19-pasha-membership')), findsOneWidget);
        expect(find.byKey(const Key('r19-pasha-style')), findsOneWidget);
        expect(find.byKey(const Key('r19-server-state')), findsOneWidget);
        expect(find.byKey(const Key('r19-profile-gradient')), findsOneWidget);
        final identity = tester.widget<Text>(
          find.byKey(const Key('r19-profile-identity')),
        );
        expect(
          identity.data,
          '@Adnan • ${controller.countryFlag} ${locale == 'ar' ? 'فلسطين' : 'Palestinian Territory'}',
        );
        expect(identity.maxLines, size.width < 350 ? 2 : 1);
        expect(find.text(locale == 'ar' ? 'أزرق' : 'Blue'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
