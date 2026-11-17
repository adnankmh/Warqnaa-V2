import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final ar in <bool>[true, false]) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R244 play surface blue contract ar=$ar $brightness $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final direction = ar ? TextDirection.rtl : TextDirection.ltr;
          final scheme = ColorScheme.fromSeed(
            seedColor: const Color(0xff1565c0),
            brightness: brightness,
          );
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(useMaterial3: true, colorScheme: scheme),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(body: Builder(builder: (context) {
                final colors = R69PlaySurfaceColors.of(context);
                return Column(children: [
                  Text(ar ? 'سطح اللعب' : 'Play surface',
                      key: const ValueKey('r244-surface-label'),
                      style: TextStyle(color: colors.onSurface)),
                  Container(
                    key: const ValueKey('r244-group-preview'),
                    width: 80,
                    height: 40,
                    color: colors.group(0),
                  ),
                ]);
              })),
            ),
          ));
          final label = find.byKey(const ValueKey('r244-surface-label'));
          final preview = find.byKey(const ValueKey('r244-group-preview'));
          expect(label, findsOneWidget);
          expect(preview, findsOneWidget);
          expect(Directionality.of(tester.element(label)), direction);
          final context = tester.element(label);
          final colors = R69PlaySurfaceColors.of(context);
          final activeScheme = Theme.of(context).colorScheme;
          expect(colors.accent, activeScheme.primary);
          expect(colors.secondary, activeScheme.secondary);
          expect(colors.onSurface, activeScheme.onSurface);
          expect(tester.widget<Text>(label).style!.color, colors.onSurface);
          expect(tester.widget<Container>(preview).color, colors.group(0));
          expect(colors.group(0), isNot(colors.group(1)));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
