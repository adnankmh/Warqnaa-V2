import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final themeCode in <String>['sky', 'ocean']) {
      for (final width in <double>[320, 390]) {
        testWidgets('R233 store collections $locale $themeCode portrait $width',
            (tester) async {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          AppSounds.enabled = false;
          final controller = AppController()..localeCode = locale;
          addTearDown(() {
            controller.connectivityTimerV173?.cancel();
            controller.dispose();
          });
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();

          await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: r101Theme(themeCode, '#24C8FF', localeCode: locale),
            home: Scaffold(body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: R20StoreCollections(controller: controller),
              ),
            )),
          ));
          await tester.pump();

          const firstKey = ValueKey('r20-collection-pasha');
          const secondKey = ValueKey('r20-collection-themes');
          final first = find.byKey(firstKey);
          final second = find.byKey(secondKey);
          expect(first, findsOneWidget);
          expect(second, findsOneWidget);
          final direction = locale == 'ar'
              ? TextDirection.rtl : TextDirection.ltr;
          expect(Directionality.of(tester.element(first)), direction);
          final firstPosition = tester.getTopLeft(first);
          final secondPosition = tester.getTopLeft(second);
          if (width == 320) {
            expect(firstPosition.dy, lessThan(secondPosition.dy));
            expect(firstPosition.dx, closeTo(secondPosition.dx, 1));
            expect(tester.getSize(first).width, greaterThan(290));
          } else {
            expect(firstPosition.dy, closeTo(secondPosition.dy, 1));
            expect(tester.getSize(first).width, lessThan(190));
            expect(
              locale == 'ar'
                  ? firstPosition.dx > secondPosition.dx
                  : firstPosition.dx < secondPosition.dx,
              isTrue,
            );
          }
          expect(tester.getSize(first).height, greaterThanOrEqualTo(120));
          expect(find.bySemanticsLabel(RegExp(
            locale == 'ar' ? r'^الباشا، ' : r'^Pasha, ',
          )), findsOneWidget);
          semantics.dispose();
          final ink = tester.widget<Ink>(find.ancestor(
            of: first, matching: find.byType(Ink),
          ).first);
          final decoration = ink.decoration! as BoxDecoration;
          expect(decoration.color, const Color(0xff103d62));
          expect((decoration.border! as Border).top.color,
              B307SkyLuxury.sky.withValues(alpha: .42));

          final coins = controller.coins;
          await tester.tap(first);
          await tester.pumpAndSettle();
          expect(find.text(locale == 'ar'
              ? 'اختر عنصرًا للمعاينة. الشراء أو التفعيل يتم بعد التأكيد.'
              : 'Choose an item to preview. Purchase or activation requires confirmation.'),
              findsOneWidget);
          expect(controller.coins, coins);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R233 landscape keeps three blue collection cards per row',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
    final controller = AppController()..localeCode = 'ar';
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      theme: r101Theme('ocean', '#24C8FF', localeCode: 'ar'),
      home: Scaffold(body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: R20StoreCollections(controller: controller),
        ),
      )),
    ));
    final first = tester.getTopLeft(
        find.byKey(const ValueKey('r20-collection-pasha')));
    final third = tester.getTopLeft(
        find.byKey(const ValueKey('r20-collection-cards')));
    final fourth = tester.getTopLeft(
        find.byKey(const ValueKey('r20-collection-profile_colors')));
    expect(first.dy, closeTo(third.dy, 1));
    expect(fourth.dy, greaterThan(first.dy));
    expect(tester.takeException(), isNull);
  });
}
