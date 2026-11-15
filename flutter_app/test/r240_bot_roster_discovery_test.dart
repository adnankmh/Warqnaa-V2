import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/premium_v149.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets(
          'R240 bot roster expands and collapses in $locale $brightness ${width.toInt()}px portrait',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final direction = locale == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr;
            final profiles = botProfiles.take(6).toList();
            await tester.pumpWidget(MaterialApp(
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xff0878cf),
                  brightness: brightness,
                ),
              ),
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: BotRosterShowcase(
                      locale: locale,
                      profiles: profiles,
                    ),
                  ),
                ),
              ),
            ));
            await tester.pump();

            const toggleKey = ValueKey<String>('r240-bot-roster-toggle');
            final toggle = find.byKey(toggleKey);
            expect(find.byType(Bot3DAvatar), findsNWidgets(4));
            expect(toggle, findsOneWidget);
            expect(
              find.text(locale == 'ar'
                  ? 'عرض جميع اللاعبين (6)'
                  : 'Show all players (6)'),
              findsOneWidget,
            );
            expect(Directionality.of(tester.element(toggle)), direction);

            // Each original avatar card keeps Warqnaa's deep-blue surface.
            final panel = tester.widget<Container>(
              find.byKey(const ValueKey<String>('r30-bot-identity-11')),
            );
            final gradient = (panel.decoration! as BoxDecoration).gradient!
                as LinearGradient;
            expect(gradient.colors, contains(const Color(0xff064777)));
            final button = tester.widget<TextButton>(toggle);
            expect(
              button.style!.foregroundColor!.resolve(<WidgetState>{}),
              brightness == Brightness.dark
                  ? const Color(0xff24c8ff)
                  : const Color(0xff064777),
            );
            expect(tester.takeException(), isNull);

            await tester.ensureVisible(toggle);
            await tester.tap(toggle);
            await tester.pumpAndSettle();
            expect(find.byType(Bot3DAvatar), findsNWidgets(6));
            expect(
              find.text(locale == 'ar' ? 'عرض أقل' : 'Show fewer'),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);

            await tester.ensureVisible(toggle);
            await tester.tap(toggle);
            await tester.pumpAndSettle();
            expect(find.byType(Bot3DAvatar), findsNWidgets(4));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('R240 hides the toggle when the complete roster fits', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BotRosterShowcase(
            locale: 'en',
            profiles: botProfiles.take(4).toList(),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(Bot3DAvatar), findsNWidgets(4));
    expect(find.byKey(const ValueKey<String>('r240-bot-roster-toggle')),
        findsNothing);
    expect(tester.takeException(), isNull);
  });
}
