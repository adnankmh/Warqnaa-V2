import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/premium_v149.dart';

Widget botApp(String locale, Widget child) => MaterialApp(
      locale: Locale(locale),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xff050b12),
        body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(10), child: child)),
      ),
    );

void main() {
  test('R19 Arabic bot identities are deterministic and distinct', () {
    expect(botProfiles.length, greaterThanOrEqualTo(12));
    expect(botProfiles.map((profile) => profile.id).toSet().length, botProfiles.length);
    expect(botProfiles.map((profile) => profile.seed).toSet().length, botProfiles.length);
    expect(botProfiles.every((profile) => profile.nameAr.isNotEmpty && profile.nameEn.isNotEmpty), isTrue);
    expect(botProfiles.every((profile) => profile.styleAr.isNotEmpty && profile.styleEn.isNotEmpty), isTrue);
  });

  for (final locale in <String>['ar', 'en']) {
    for (final size in <Size>[const Size(320, 640), const Size(844, 390), const Size(1280, 800)]) {
      testWidgets('R19 bot identity $locale ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final profile = botProfiles.firstWhere((item) => item.id == 'bayan_ai');
        await tester.pumpWidget(botApp(locale, BotIdentityShowcase(profile: profile, locale: locale)));
        await tester.pump(const Duration(milliseconds: 120));
        expect(find.text(profile.name(locale)), findsOneWidget);
        expect(find.text(profile.style(locale)), findsOneWidget);
        expect(find.text(profile.difficultyLabel(locale)), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'آلي' : 'BOT'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'هوية عربية أصلية' : 'Original Arabic identity'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('R19 bot roster is localized and responsive $locale', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(botApp(locale, BotRosterShowcase(locale: locale, profiles: botProfiles.take(6).toList())));
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text(locale == 'ar' ? 'خصوم ورقنا الآليون' : 'Warqnaa computer players'), findsOneWidget);
      // The phone roster intentionally limits itself to two rows of two cards;
      // wider review surfaces exercise the expanded four/six-column variants.
      expect(find.byType(Bot3DAvatar), findsNWidgets(4));
      expect(find.text(botProfiles.first.style(locale)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
