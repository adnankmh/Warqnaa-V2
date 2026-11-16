import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/r9_design_system.dart';

Widget _tableHost({
  required String locale,
  required bool light,
  required String design,
  required double width,
  required double height,
}) {
  return MaterialApp(
    locale: Locale(locale),
    theme: R9Design.theme(
      light: light,
      accent: R9Design.azure,
      arabic: locale == 'ar',
    ),
    home: Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: R48ApprovedTableArt(design: design),
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final light in <bool>[true, false]) {
      for (final width in <double>[320, 390]) {
        testWidgets(
          'R221 original blue portrait table keeps image proportions '
          '$locale light=$light width=$width',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(_tableHost(
              locale: locale,
              light: light,
              design: 'ocean',
              width: width - 24,
              height: 520,
            ));
            await tester.pumpAndSettle();

            final image = tester.widget<Image>(
              find.byKey(const ValueKey('r48-table-ocean-portrait')),
            );
            expect(image.fit, BoxFit.cover);
            expect(image.alignment, Alignment.center);
            expect(image.excludeFromSemantics, isTrue);
            expect(
              (image.image as AssetImage).assetName,
              'assets/optimized/r48/ocean_portrait.webp',
            );
            expect(
              find.byKey(const ValueKey('r221-table-art-fallback')),
              findsNothing,
            );

            final surface = tester.widget<DecoratedBox>(
              find.byKey(const ValueKey('r221-table-art-blue-backdrop')),
            );
            final gradient =
                (surface.decoration as BoxDecoration).gradient! as LinearGradient;
            expect(gradient.colors,
                <Color>[R9Design.skyPanel, R9Design.midnight]);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('R221 landscape art uses its own asset without stretching',
      (tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_tableHost(
      locale: 'en',
      light: false,
      design: 'purple',
      width: 680,
      height: 260,
    ));
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(
      find.byKey(const ValueKey('r48-table-purple-landscape')),
    );
    expect(image.fit, BoxFit.cover);
    expect((image.image as AssetImage).assetName,
        'assets/optimized/r48/purple_landscape.webp');
    expect(find.byKey(const ValueKey('r221-table-art-fallback')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('R221 unavailable art stays on a blue table, not a blank screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_tableHost(
      locale: 'ar',
      light: false,
      design: 'unavailable_original_art',
      width: 296,
      height: 520,
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('r221-table-art-blue-backdrop')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('r221-table-art-fallback')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
