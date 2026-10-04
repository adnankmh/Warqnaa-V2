import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/premium_v149.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    testWidgets('R20 stable account metrics and profile counters $locale', (tester) async {
      SharedPreferences.setMockInitialValues({});
      AppSounds.enabled = false;
      final controller = AppController()..localeCode = locale..vipDays = 0;
      addTearDown(() { controller.connectivityTimerV173?.cancel(); controller.dispose(); });
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      var selectedTab = -1;
      final semantics = tester.ensureSemantics();
      try {
      for (final size in [const Size(320, 640), const Size(844, 390), const Size(1280, 800)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(MaterialApp(
          locale: Locale(locale), supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: r101Theme('midnight_cyan', '#25e4df'),
          home: Scaffold(body: ListView(children: [
            ResponsiveAccountStatsV170(controller: controller),
            HomeQuickActionsV170(controller: controller, onTab: (tab) => selectedTab = tab),
            R20ProfileCounter(icon: Icons.track_changes_rounded, label: locale == 'ar' ? 'نقاط الجولات' : 'Round points', value: 42),
          ])),
        ));
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
        expect(find.byIcon(Icons.monetization_on_rounded), findsOneWidget);
        expect(find.byIcon(Icons.diamond_rounded), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'الرصيد المتاح' : 'Available balance'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'اضغط للترقية' : 'Tap to upgrade'), findsOneWidget);
        await tester.ensureVisible(find.byType(R20ProfileCounter));
        await tester.pump();
        expect(find.bySemanticsLabel(locale == 'ar' ? 'نقاط الجولات: 42' : 'Round points: 42'), findsOneWidget);
        await tester.ensureVisible(find.byIcon(Icons.shield_rounded));
        await tester.tap(find.byIcon(Icons.shield_rounded));
        expect(selectedTab, 3);
        expect(tester.takeException(), isNull);
      }
      } finally { semantics.dispose(); }
    });
  }
  testWidgets('R20 cover respects reduced motion without losing content', (tester) async {
    Future<void> cover(bool reduced) => tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: const Scaffold(body: ProfileCover(coverId: 'default', child: Text('Warqnaa'))),
    )));
    await cover(true);
    expect(find.byType(AmbientTableFX), findsNothing);
    expect(find.text('Warqnaa'), findsOneWidget);
    await cover(false);
    expect(find.byType(AmbientTableFX), findsOneWidget);
    await cover(true);
    await tester.pumpAndSettle();
    expect(find.byType(AmbientTableFX), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
