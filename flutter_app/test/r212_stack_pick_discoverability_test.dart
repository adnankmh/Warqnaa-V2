import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[
      Brightness.light, Brightness.dark,
    ]) {
      for (final width in <double>[204, 390]) {
        testWidgets('R212 visible stack pick $locale $brightness width=$width',
            (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          var picks = 0;
          final ar = locale == 'ar';
          final direction = ar ? TextDirection.rtl : TextDirection.ltr;
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff1565c0),
                brightness: brightness,
              ),
            ),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: width,
                    height: 184,
                    child: R44RummyTableOverlay(
                      state: <String, dynamic>{
                        'deck_count': 42,
                        'discard': <String>['4_H', '7_C', '8_S'],
                      },
                      players: const <Map<String, dynamic>>[],
                      ar: ar,
                      partnership: false,
                      cardLabel: (card) => card,
                      onDrawDeck: () {},
                      onDrawDiscard: () {},
                      onDrawStack: () => picks++,
                    ),
                  ),
                ),
              ),
            ),
          ));
          await tester.pump();

          final action = find.byKey(const ValueKey('r44-stack-pick'));
          final caption = find.text(ar ? 'اختر' : 'Pick');
          final piles = find.byKey(const ValueKey('r44-central-rummy-piles'));
          expect(action, findsOneWidget);
          expect(caption, findsOneWidget);
          expect(find.byTooltip(ar
              ? 'اختر ورقة من النار واسحبها مع التي فوقها'
              : 'Take a selected discard with all newer cards'),
              findsOneWidget);
          expect(find.byKey(const ValueKey('r44-stock-pile')), findsOneWidget);
          expect(find.byKey(const ValueKey('r44-fire-pile')), findsOneWidget);

          final colors = R69PlaySurfaceColors.of(tester.element(action));
          final button = tester.widget<IconButton>(action);
          final label = tester.widget<Text>(caption);
          expect(button.style!.foregroundColor!.resolve(<WidgetState>{}),
              colors.accent);
          expect(label.style!.color, colors.onSurface);
          expect(label.style!.fontSize, greaterThanOrEqualTo(11));
          expect(Directionality.of(tester.element(caption)), direction);
          expect(tester.getRect(action).left,
              greaterThanOrEqualTo(tester.getRect(piles).left));
          expect(tester.getRect(action).right,
              lessThanOrEqualTo(tester.getRect(piles).right));
          expect(tester.takeException(), isNull);

          await tester.tap(action);
          await tester.pump();
          expect(picks, 1);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R212 stack pick remains absent without an authorized callback',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: R44RummyTableOverlay(
          state: const <String, dynamic>{'deck_count': 2},
          players: const <Map<String, dynamic>>[],
          ar: false,
          partnership: false,
          cardLabel: (card) => card,
        ),
      ),
    ));
    expect(find.byKey(const ValueKey('r44-stack-pick')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
