import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final ar in <bool>[true, false]) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R245 consolidated meld selection feedback ar=$ar $brightness $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

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
              child: Scaffold(body: R36MeldWorkspace(
                ar: ar,
                cards: const <String>['3_C', '4_C', '5_C', '6_D'],
              )),
            ),
          ));
          final counter = find.byKey(
            const ValueKey('r214-meld-selection-status'));
          expect(counter, findsOneWidget);
          String value() => tester.widget<Text>(counter).data!;
          expect(value(), contains(ar ? 'المحدد: 0' : 'Selected: 0'));
          expect(Directionality.of(tester.element(counter)), direction);
          expect(tester.widget<Text>(counter).style!.color,
              R69PlaySurfaceColors.of(tester.element(counter)).onSurface);
          await tester.tap(find.byKey(const ValueKey('r36-meld-card-0')));
          await tester.pump();
          expect(value(), contains(ar ? 'المحدد: 1' : 'Selected: 1'));
          await tester.tap(find.byKey(const ValueKey('r36-meld-card-0')));
          await tester.pump();
          expect(value(), contains(ar ? 'المحدد: 0' : 'Selected: 0'));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
