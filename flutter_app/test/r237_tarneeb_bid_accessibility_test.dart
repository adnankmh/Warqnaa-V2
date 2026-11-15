import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/r9_design_system.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final dark in <bool>[false, true]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R237 bid $locale dark=$dark portrait $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();
          final rtl = locale == 'ar';
          final theme = R9Design.theme(
            light: !dark,
            accent: R9Design.azure,
            arabic: rtl,
          );
          var presses = 0;
          await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            theme: theme,
            home: Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 92,
                    child: TarneebBidButtonV170(
                      label: '7',
                      subtitle: rtl ? 'قلوب' : 'Hearts',
                      selected: true,
                      onPressed: () => presses++,
                    ),
                  ),
                ),
              ),
            ),
          ));
          await tester.pumpAndSettle();

          final semantic = tester.widget<Semantics>(
            find.byKey(const ValueKey('r237-tarneeb-bid-semantics')),
          );
          expect(semantic.properties.button, isTrue);
          expect(semantic.properties.selected, isTrue);
          expect(semantic.properties.enabled, isTrue);
          expect(semantic.properties.onTap, isNotNull);
          expect(
            semantic.properties.label,
            rtl ? 'المزايدة: 7، قلوب' : 'Bid: 7, Hearts',
          );
          final surface = find.byKey(
            const ValueKey('r137-tarneeb-bid-surface'),
          );
          final decoration =
              tester.widget<AnimatedContainer>(surface).decoration!
                  as BoxDecoration;
          final gradient = decoration.gradient! as LinearGradient;
          expect(gradient.begin, AlignmentDirectional.topStart);
          expect(gradient.end, AlignmentDirectional.bottomEnd);
          expect(gradient.colors.first, theme.colorScheme.primary);
          expect(
            gradient.colors.last,
            Color.lerp(theme.colorScheme.primary,
                theme.colorScheme.primaryContainer, .16),
          );
          expect(tester.getSize(surface).height, greaterThanOrEqualTo(48));
          expect(
            Directionality.of(tester.element(surface)),
            rtl ? TextDirection.rtl : TextDirection.ltr,
          );
          await tester.tap(find.byKey(const ValueKey('r137-tarneeb-bid-label')));
          expect(presses, 1);
          semantics.dispose();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R237 disabled bid stays non-actionable on landscape',
      (tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: R9Design.theme(light: false, accent: R9Design.azure),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: TarneebBidButtonV170(
              label: '8',
              selected: false,
            ),
          ),
        ),
      ),
    ));
    final semantic = tester.widget<Semantics>(
      find.byKey(const ValueKey('r237-tarneeb-bid-semantics')),
    );
    expect(semantic.properties.enabled, isFalse);
    expect(semantic.properties.selected, isFalse);
    expect(semantic.properties.onTap, isNull);
    final surface = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('r137-tarneeb-bid-surface')),
    );
    final gradient = (surface.decoration! as BoxDecoration).gradient!
        as LinearGradient;
    expect(gradient.colors.first,
        Theme.of(tester.element(find.byType(TarneebBidButtonV170)))
            .colorScheme.surfaceContainerHighest);
    semantics.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('R237 long bid text remains clipped within narrow portrait',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 88,
              child: TarneebBidButtonV170(
                label: 'مزايدة طويلة جدا جدا',
                subtitle: 'وصف مزايدة طويل للاختبار',
                selected: true,
              ),
            ),
          ),
        ),
      ),
    ));
    expect(
      tester.widget<Text>(
        find.byKey(const ValueKey('r137-tarneeb-bid-label')),
      ).overflow,
      TextOverflow.ellipsis,
    );
    expect(tester.takeException(), isNull);
  });
}
