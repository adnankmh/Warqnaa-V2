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

void reportLayoutErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    debugPrint(details.toString());
    previous?.call(details);
  };
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSounds.enabled = false;
  });

  for (final locale in ['ar', 'en']) {
    for (final size in [
      const Size(320, 640),
      const Size(844, 390),
      const Size(1280, 800),
    ]) {
      testWidgets('home navigation $locale ${size.width}x${size.height}', (
        tester,
      ) async {
        reportLayoutErrors();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        await tester.pumpWidget(app(HomeShell(controller: controller), locale));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(find.byType(R61HomeDashboard), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(HomeShell))),
          locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );

        final navigation = find.byType(
          kIsWeb && size.width >= 1024
              ? R61DesktopNavigation
              : R61BottomNavigation,
        );
        for (final destination in <(String, Type)>[
          (locale == 'ar' ? 'الألعاب' : 'Games', R64PlayHubPage),
          (locale == 'ar' ? 'المجتمع' : 'Social', R61SocialHubPage),
          (locale == 'ar' ? 'المنافسات' : 'Events', R12CompetitiveArenaPage),
        ]) {
          await tester.tap(
            find.descendant(
              of: navigation,
              matching: find.text(destination.$1),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          expect(find.byType(destination.$2), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        controller.dispose();
      });

      testWidgets(
        'local table orientation $locale ${size.width}x${size.height}',
        (tester) async {
          reportLayoutErrors();
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final controller = AppController()..localeCode = locale;
          final game = gamesCatalog.firstWhere((game) => game.id == 'tarneeb');
          await tester.pumpWidget(
            app(TarneebRoomPage(controller: controller, game: game), locale),
          );
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
          expect(find.byType(TarneebRoomPage), findsOneWidget);
          if (locale == 'en') {
            expect(find.text('Professional Tarneeb'), findsOneWidget);
            expect(find.text('طرنيب احترافي'), findsNothing);
            expect(find.textContaining('الكمبيوتر يفكر'), findsNothing);
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 5));
          controller.dispose();
        },
      );

      testWidgets('store localization $locale ${size.width}x${size.height}', (
        tester,
      ) async {
        reportLayoutErrors();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        await tester.pumpWidget(
          app(Scaffold(body: StorePage(controller: controller)), locale),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        if (locale == 'en') {
          final storeScroll = find.byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
            description: 'outer vertical StorePage scrollable',
          ).first;
          Future<void> buildLazyStoreSection(Finder target) async {
            for (var attempt = 0; attempt < 20 && target.evaluate().isEmpty; attempt += 1) {
              await tester.drag(storeScroll, const Offset(0, -250));
              await tester.pump(const Duration(milliseconds: 120));
            }
          }

          // The R19 commerce and booster content makes the outer store list
          // longer, so build lazy sections incrementally before asserting
          // their translated copy. A fixed pump avoids waiting forever on
          // the intentional looping booster previews farther down the grid.
          await buildLazyStoreSection(find.textContaining('Level progress'));
          expect(find.textContaining('Level progress'), findsOneWidget);
          expect(find.textContaining('تقدم المستوى'), findsNothing);
          await buildLazyStoreSection(find.textContaining('premium items'));
          expect(find.textContaining('premium items'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      });
    }
  }
}
