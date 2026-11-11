import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final themeCode in <String>['sky', 'ocean']) {
      for (final width in <double>[320, 390]) {
        testWidgets('R232 blue home hero $locale $themeCode portrait $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final theme = r101Theme(
            themeCode,
            '#24C8FF',
            localeCode: locale,
          );
          final status = r232HomeConnectionLabel(locale, false);
          await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: theme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: R232BlueHomeHeroSurface(
                  wide: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(status),
                      const SizedBox(height: 120),
                      const Text('Warqnaa'),
                    ],
                  ),
                ),
              ),
            ),
          ));
          await tester.pump();

          final hero = find.byKey(const ValueKey('r232-blue-home-hero'));
          expect(hero, findsOneWidget);
          expect(tester.getSize(hero).width, closeTo(width, .01));
          expect(tester.getSize(hero).height, greaterThanOrEqualTo(270));
          expect(
            Directionality.of(tester.element(hero)),
            locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          );
          final decoration =
              tester.widget<Container>(hero).decoration! as BoxDecoration;
          final gradient = decoration.gradient! as LinearGradient;
          expect(gradient.begin, AlignmentDirectional.topStart);
          expect(gradient.end, AlignmentDirectional.bottomEnd);
          expect(gradient.colors.length, 3);
          for (final color in gradient.colors) {
            expect(color.b, greaterThan(color.r));
            expect(color.b, greaterThan(color.g));
          }
          expect(
            (decoration.border! as Border).top.color,
            R9Design.sky.withValues(alpha: .28),
          );
          expect(find.text(status), findsOneWidget);
          expect(
            DefaultTextStyle.of(tester.element(find.text(status))).style.color,
            Colors.white,
          );
          expect(
            r232HomeConnectionLabel(locale, true),
            locale == 'ar' ? 'متصل • API' : 'ONLINE • API',
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R232 blue home hero remains directional on landscape',
      (tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: r101Theme('ocean', '#24C8FF', localeCode: 'ar'),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: R232BlueHomeHeroSurface(
            wide: true,
            child: SizedBox(height: 120, child: Text('Warqnaa')),
          ),
        ),
      ),
    ));
    final hero = find.byKey(const ValueKey('r232-blue-home-hero'));
    expect(tester.getSize(hero).width, closeTo(844, .01));
    expect(tester.getSize(hero).height, greaterThanOrEqualTo(320));
    expect(Directionality.of(tester.element(hero)), TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });
}
