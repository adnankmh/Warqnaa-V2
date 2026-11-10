import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R218 tournament navigation $locale $brightness ${width.toInt()} portrait',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final rtl = locale == 'ar';
          final title = rtl ? 'بطولة اليوم' : 'Daily tournament';
          final detail = rtl ? 'العب مع أصدقائك' : 'Play with your friends';
          var opened = 0;

          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0B8CFF),
                brightness: brightness,
              ),
            ),
            home: Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(12),
                  child: R35TournamentRow(
                    title: title,
                    detail: detail,
                    icon: Icons.emoji_events_rounded,
                    color: R35ReferenceColors.gold,
                    onTap: () => opened++,
                  ),
                ),
              ),
            ),
          ));
          await tester.pump();

          final row = find.byType(R35TournamentRow);
          final arrow = rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;
          final wrongArrow = rtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded;
          expect(find.descendant(of: row, matching: find.byIcon(arrow)), findsOneWidget);
          expect(find.descendant(of: row, matching: find.byIcon(wrongArrow)), findsNothing);

          final semantics = tester.widget<Semantics>(
            find.descendant(of: row, matching: find.byType(Semantics)).first,
          );
          expect(semantics.properties.button, isTrue);
          expect(semantics.properties.label, '$title. $detail');
          expect(semantics.properties.onTap, isNotNull);

          final bluePanel = tester.widgetList<Container>(
            find.descendant(of: row, matching: find.byType(Container)),
          ).firstWhere((element) =>
              element.decoration is BoxDecoration &&
              (element.decoration as BoxDecoration).gradient != null);
          final gradient =
              (bluePanel.decoration as BoxDecoration).gradient! as LinearGradient;
          expect(gradient.colors,
              const <Color>[Color(0xFF1260A8), Color(0xFF084788)]);

          await tester.tap(find.text(title));
          expect(opened, 1);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
