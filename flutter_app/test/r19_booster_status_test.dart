import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

Widget _boosterApp(AppController controller, VoidCallback onBrowse) => MaterialApp(
      locale: Locale(controller.localeCode),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: r101Theme(controller.themeCode, controller.uiAccentHex),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: R19BoosterStatus(controller: controller, onBrowse: onBrowse),
        ),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    testWidgets('R19 booster status is honest and responsive in $locale', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      AppSounds.enabled = false;
      var browseCount = 0;
      final controller = AppController()
        ..localeCode = locale
        ..activeXpMultiplier = 2.5
        ..boosterExpiresAtV173 = DateTime.now().add(const Duration(hours: 4, minutes: 15));
      addTearDown(() {
        controller.connectivityTimerV173?.cancel();
        controller.dispose();
      });
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;

      for (final size in <Size>[const Size(320, 640), const Size(844, 390)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(_boosterApp(controller, () => browseCount += 1));
        await tester.pump();

        expect(find.byKey(const Key('r19-premium-booster-status')), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'مسرّعات التقدّم' : 'Progress boosters'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'لا أفضلية داخل اللعب' : 'No in-match advantage'), findsOneWidget);
        expect(find.textContaining(locale == 'ar' ? 'ترتيب الأدوار' : 'turn order'), findsOneWidget);
        expect(find.text('×2.5'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      await tester.ensureVisible(find.byKey(const Key('r19-browse-boosters')));
      await tester.tap(find.byKey(const Key('r19-browse-boosters')));
      expect(browseCount, 1);
    });
  }
}
