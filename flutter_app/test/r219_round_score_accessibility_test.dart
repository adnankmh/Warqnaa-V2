import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('R219 score announcements describe sign, not winning', () {
    expect(r219RoundDeltaSemantics('Layla', 30, false),
        'Layla: plus 30 points');
    expect(r219RoundDeltaSemantics('Layla', -15, false),
        'Layla: minus 15 points');
    expect(r219RoundDeltaSemantics('Layla', 0, false),
        'Layla: no points change');
    expect(r219RoundDeltaSemantics('ليلى', 30, true),
        'ليلى: زائد 30 نقطة');
    expect(r219RoundDeltaSemantics('ليلى', -15, true),
        'ليلى: ناقص 15 نقطة');
    expect(r219RoundDeltaSemantics('ليلى', 0, true),
        'ليلى: دون تغيير في النقاط');
    expect(r219RoundDeltaSemantics('Layla', 'pending', false),
        'Layla: pending');
  });

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[
      Brightness.light,
      Brightness.dark,
    ]) {
      for (final width in <double>[320, 390]) {
        testWidgets(
          'R219 blue round scores are accessible in $locale $brightness ${width.toInt()}px portrait',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final ar = locale == 'ar';
            final direction = ar ? TextDirection.rtl : TextDirection.ltr;
            final theme = ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff0b8cff),
                brightness: brightness,
              ),
            );
            await tester.pumpWidget(MaterialApp(
              theme: theme,
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  body: Center(
                    child: R52RoundScoreCard(
                      ar: ar,
                      state: const <String, dynamic>{
                        'round_results': <Map<String, dynamic>>[
                          <String, dynamic>{
                            'delta': <String, int>{
                              'user:0': 30,
                              'bot:1': -15,
                              'bot:2': 0,
                            },
                          },
                        ],
                      },
                      players: const <Map<String, dynamic>>[
                        <String, dynamic>{'key': 'user:0', 'name': 'Layla'},
                        <String, dynamic>{'key': 'bot:1', 'name': 'Omar'},
                        <String, dynamic>{'key': 'bot:2', 'name': 'Mira'},
                      ],
                    ),
                  ),
                ),
              ),
            ));
            await tester.pump();

            final card = find.byKey(const ValueKey('r52-round-points'));
            expect(card, findsOneWidget);
            expect(tester.getSize(card).width, lessThanOrEqualTo(width));
            expect(Directionality.of(tester.element(card)), direction);

            final positive = tester.widget<Text>(
                find.byKey(const ValueKey('r52-round-points-user:0')));
            final negative = tester.widget<Text>(
                find.byKey(const ValueKey('r52-round-points-bot:1')));
            final unchanged = tester.widget<Text>(
                find.byKey(const ValueKey('r52-round-points-bot:2')));
            expect(positive.data, 'Layla: +30');
            expect(negative.data, 'Omar: -15');
            expect(unchanged.data, 'Mira: 0');
            expect(positive.semanticsLabel,
                ar ? 'Layla: زائد 30 نقطة' : 'Layla: plus 30 points');
            expect(negative.semanticsLabel,
                ar ? 'Omar: ناقص 15 نقطة' : 'Omar: minus 15 points');
            expect(unchanged.semanticsLabel,
                ar ? 'Mira: دون تغيير في النقاط' : 'Mira: no points change');

            final decoration =
                tester.widget<Container>(card).decoration! as BoxDecoration;
            final colors = R69PlaySurfaceColors.of(tester.element(card));
            expect(decoration.color, colors.surface);
            expect((decoration.border! as Border).top.color,
                colors.accent.withValues(alpha: .72));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
