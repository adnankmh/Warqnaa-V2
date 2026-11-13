import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets(
          'R217 Backgammon blue palette and checker ownership $locale '
          '$brightness at ${width.toInt()}px portrait',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final scheme = ColorScheme.fromSeed(
              seedColor: const Color(0xFF0B8CFF),
              brightness: brightness,
            );
            final direction =
                locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
            await tester.pumpWidget(MaterialApp(
              theme: ThemeData(useMaterial3: true, colorScheme: scheme),
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  body: Center(
                    child: SizedBox(
                      height: 420,
                      child: R41BackgammonBoard(
                        ar: locale == 'ar',
                        points: const <String, dynamic>{
                          '24': <String, dynamic>{
                            'count': 2,
                            'owner': 'user:1',
                          },
                          '13': <String, dynamic>{
                            'count': 5,
                            'owner': 'bot:1',
                          },
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ));
            await tester.pump();

            final even = find.byKey(
              const ValueKey('r217-backgammon-point-24'),
            );
            final odd = find.byKey(
              const ValueKey('r217-backgammon-point-13'),
            );
            expect(even, findsOneWidget);
            expect(odd, findsOneWidget);
            final evenBox = tester.widget<Container>(even);
            final oddBox = tester.widget<Container>(odd);
            expect((evenBox.decoration! as BoxDecoration).color,
                scheme.primaryContainer);
            expect((oddBox.decoration! as BoxDecoration).color,
                scheme.secondaryContainer);
            expect(tester.widget<Text>(find.text('24')).style!.color,
                scheme.onPrimaryContainer);
            expect(tester.widget<Text>(find.text('13')).style!.color,
                scheme.onSecondaryContainer);
            expect(
              find.byWidgetPredicate((widget) =>
                  widget is Semantics &&
                  widget.properties.label ==
                      (locale == 'ar' ? 'أحجار لاعب' : 'Player checkers')),
              findsOneWidget,
            );
            expect(
              find.byWidgetPredicate((widget) =>
                  widget is Semantics &&
                  widget.properties.label ==
                      (locale == 'ar' ? 'أحجار روبوت' : 'Bot checkers')),
              findsOneWidget,
            );
            expect(Directionality.of(tester.element(even)), direction);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
