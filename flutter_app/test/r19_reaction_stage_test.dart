import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/premium_v149.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

Widget reactionApp(String locale, Widget child) => MaterialApp(
      locale: Locale(locale),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUp(() => AppSounds.enabled = false);

  test('R19 reaction categories select one presentation sound cue', () {
    expect(reactionCatalog.firstWhere((item) => item.id == 'r91_card_storm').soundCue, 'reaction_power');
    expect(reactionCatalog.firstWhere((item) => item.id == 'r91_neon_crown').soundCue, 'reaction_victory');
    expect(reactionCatalog.firstWhere((item) => item.id == 'r91_majlis_salute').soundCue, 'reaction_friendly');
  });

  for (final locale in <String>['ar', 'en']) {
    for (final size in <Size>[const Size(320, 640), const Size(844, 390)]) {
      testWidgets('R19 reaction dock $locale ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        ReactionItem? selected;
        await tester.pumpWidget(reactionApp(
          locale,
          SizedBox(
            width: size.width,
            height: 330,
            child: ReactionDock(
              locale: locale,
              soundEnabled: true,
              onSelected: (reaction) => selected = reaction,
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 120));
        expect(tester.takeException(), isNull);
        expect(find.text(locale == 'ar' ? 'تفاعلات ورقنا' : 'Warqnaa reactions'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'صوت وحركة' : 'Sound & motion'), findsOneWidget);
        await tester.tap(find.text(locale == 'ar' ? 'تصفيق' : 'Applause'));
        await tester.pump(const Duration(milliseconds: 80));
        expect(selected?.id, 'clap');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('R19 floating reaction is localized and reduced-motion safe $locale', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var completed = false;
      final reaction = reactionCatalog.firstWhere((item) => item.id == 'r91_good_game');
      await tester.pumpWidget(reactionApp(
        locale,
        FloatingReaction(
          reaction: reaction,
          locale: locale,
          soundEnabled: false,
          reduceMotion: true,
          onCompleted: () => completed = true,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 260));
      expect(find.text(locale == 'ar' ? 'لعبة جميلة' : 'Good game'), findsOneWidget);
      expect(find.text(locale == 'ar' ? 'حركة فقط' : 'Motion only'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 900));
      expect(completed, isTrue);
    });
  }
}
