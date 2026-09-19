import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

Widget app(Widget child, String locale) => MaterialApp(
  locale: Locale(locale),
  supportedLocales: const [Locale('ar'), Locale('en')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: ThemeData.dark(useMaterial3: true),
  home: child,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSounds.enabled = false;
  });

  for (final locale in ['ar', 'en']) {
    for (final size in [const Size(320, 640), const Size(844, 390), const Size(1280, 800)]) {
      testWidgets('home navigation $locale ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        await tester.pumpWidget(app(HomeShell(controller: controller), locale));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(find.byType(R61HomeDashboard), findsOneWidget);
        expect(Directionality.of(tester.element(find.byType(HomeShell))), locale == 'ar' ? TextDirection.rtl : TextDirection.ltr);

        final navigation = find.byType(kIsWeb && size.width >= 1024 ? R61DesktopNavigation : R61BottomNavigation);
        for (final destination in <(String, Type)>[
          (locale == 'ar' ? 'الألعاب' : 'Games', R64PlayHubPage),
          (locale == 'ar' ? 'المجتمع' : 'Social', R61SocialHubPage),
          (locale == 'ar' ? 'المنافسات' : 'Events', R12CompetitiveArenaPage),
        ]) {
          await tester.tap(find.descendant(of: navigation, matching: find.text(destination.$1)));
          await tester.pump(const Duration(milliseconds: 300));
          expect(find.byType(destination.$2), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        controller.dispose();
      });

      testWidgets('local table orientation $locale ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        final game = gamesCatalog.firstWhere((game) => game.id == 'tarneeb');
        await tester.pumpWidget(app(TarneebRoomPage(controller: controller, game: game), locale));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        expect(find.byType(TarneebRoomPage), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 5));
        controller.dispose();
      });
    }
  }
}
