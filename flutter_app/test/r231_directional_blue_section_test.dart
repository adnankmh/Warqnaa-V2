import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/r9_design_system.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final light in <bool>[true, false]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R231 $locale portrait $width light=$light', (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final direction = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
          final theme = R9Design.theme(
            light: light, accent: R9Design.azure, arabic: locale == 'ar',
          );
          await tester.pumpWidget(MaterialApp(
            theme: theme,
            home: Directionality(
              textDirection: direction,
              child: Scaffold(body: Center(child: SizedBox(
                width: width - 24,
                child: const R9Section(
                  key: ValueKey('r231-panel'),
                  child: Text('Warqnaa'),
                ),
              ))),
            ),
          ));
          final panel = find.byKey(const ValueKey('r231-panel'));
          final decorated = tester.widget<DecoratedBox>(
            find.descendant(of: panel, matching: find.byType(DecoratedBox)).first,
          );
          final decoration = decorated.decoration as BoxDecoration;
          final gradient = decoration.gradient! as LinearGradient;
          expect(Directionality.of(tester.element(panel)), direction);
          expect(gradient.begin.resolve(direction),
              direction == TextDirection.rtl ? Alignment.topRight : Alignment.topLeft);
          expect(gradient.end.resolve(direction),
              direction == TextDirection.rtl ? Alignment.bottomLeft : Alignment.bottomRight);
          expect(gradient.colors.first,
              light ? Colors.white.withValues(alpha: .96)
                    : R9Design.azure.withValues(alpha: .20));
          expect((decoration.border! as Border).top.color,
              light ? theme.colorScheme.outlineVariant.withValues(alpha: .42)
                    : R9Design.sky.withValues(alpha: .32));
          expect(find.text('Warqnaa'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R231 wide RTL section retains blue gradient', (tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: R9Design.theme(light: false, accent: R9Design.azure, arabic: true),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: Center(child: R9Section(
          key: ValueKey('r231-landscape'),
          child: Text('ورقنا'),
        ))),
      ),
    ));
    final decorated = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('r231-landscape')),
        matching: find.byType(DecoratedBox),
      ).first,
    );
    final gradient = (decorated.decoration as BoxDecoration).gradient! as LinearGradient;
    expect(gradient.begin.resolve(TextDirection.rtl), Alignment.topRight);
    expect(gradient.end.resolve(TextDirection.rtl), Alignment.bottomLeft);
    expect(tester.takeException(), isNull);
  });
}
