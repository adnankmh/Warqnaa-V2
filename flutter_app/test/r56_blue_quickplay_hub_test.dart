import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

void main() {

  test('R56 blue grid respects exact breakpoint and accessibility boundaries', () {
    expect(warqnaaBlueGridColumns(249.9, 1), 1);
    expect(warqnaaBlueGridColumns(250, 1), 2);
    expect(warqnaaBlueGridColumns(349.9, 1), 2);
    expect(warqnaaBlueGridColumns(350, 1), 3);
    expect(warqnaaBlueGridColumns(600, 1.2), 3);
    expect(warqnaaBlueGridColumns(600, 1.21), 2);
    expect(warqnaaBlueGridColumns(600, 1.6), 2);
    expect(warqnaaBlueGridColumns(600, 1.61), 1);
    expect(warqnaaBlueGridColumns(double.nan, 1), 1);
    expect(warqnaaBlueGridColumns(double.infinity, 1), 1);
    expect(warqnaaBlueGridColumns(600, double.nan), 1);
    expect(warqnaaBlueGridColumns(600, 0), 1);
    expect(warqnaaBlueGridColumns(-1, 1), 1);
    expect(warqnaaBlueGridColumns(double.negativeInfinity, 1), 1);
    expect(warqnaaBlueGridColumns(600, double.infinity), 1);
    expect(warqnaaBlueGridColumns(600, -2), 1);
  });
  for (final locale in ['ar', 'en']) {
    for (final width in [320.0, 390.0, 430.0, 600.0]) {
      testWidgets('R56 blue hub routes play and remains responsive $locale $width', (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        var selected = -1;
        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: SingleChildScrollView(child: WarqnaaBlueQuickPlayHub(
            controller: controller, onTab: (tab) => selected = tab,
          ))),
          controller, GlobalKey(),
        ));
        await tester.pump();
        expect(find.byKey(const ValueKey('warqnaa-blue-quickplay-hub')), findsOneWidget);
        expect(find.byKey(const ValueKey('warqnaa-blue-table-preview')), findsOneWidget);
        expect(find.byKey(const ValueKey('warqnaa-blue-play-now')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('warqnaa-blue-play-now')));
        expect(selected, 1);
        // Both entry points must continue routing to the existing games tab.
        final games = find.text(locale == 'ar' ? 'الألعاب' : 'Games');
        await tester.ensureVisible(games);
        await tester.pumpAndSettle();
        selected = -1;
        await tester.tap(games);
        expect(selected, 1);
        final rooms = find.text(locale == 'ar' ? 'الغرف' : 'Rooms');
        await tester.ensureVisible(rooms);
        await tester.pumpAndSettle();
        selected = -1;
        await tester.tap(rooms);
        expect(selected, 1);
        final store = find.text(locale == 'ar' ? 'المتجر' : 'Store');
        await tester.ensureVisible(store);
        await tester.pumpAndSettle();
        selected = -1;
        await tester.tap(store);
        expect(selected, 0);
        final challenges = find.text(locale == 'ar' ? 'التحديات' : 'Challenges');
        await tester.ensureVisible(challenges);
        await tester.pumpAndSettle();
        selected = -1;
        await tester.tap(challenges);
        expect(selected, 2);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final locale in ['ar', 'en']) {
    for (final width in [240.0, 320.0, 390.0, 430.0]) {
      testWidgets('R56 hub remains overflow-free with enlarged text $locale $width', (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        await tester.pumpWidget(review.reviewApp(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.7)),
            child: Scaffold(body: SingleChildScrollView(
              child: WarqnaaBlueQuickPlayHub(controller: controller, onTab: (_) {}),
            )),
          ),
          controller, GlobalKey(),
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('warqnaa-blue-quickplay-hub')), findsOneWidget);
        expect(find.byKey(const ValueKey('warqnaa-blue-play-now')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final locale in ['ar', 'en']) {
    for (final panelWidth in [160.0, 190.0, 220.0, 280.0, 340.0]) {
      testWidgets('R56 preview follows nested panel constraints $locale $panelWidth', (tester) async {
        tester.view.physicalSize = const Size(800, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: Center(
            child: SizedBox(width: panelWidth, child: WarqnaaBlueQuickPlayHub(
              controller: controller, onTab: (_) {},
            )),
          ))),
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('warqnaa-blue-table-preview')), findsOneWidget);
        expect(find.byKey(const ValueKey('warqnaa-blue-play-now')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('R56 original blue gradient supports $brightness theme', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AppController()..localeCode = 'ar';
      addTearDown(controller.dispose);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Scaffold(body: SingleChildScrollView(child:
          WarqnaaBlueQuickPlayHub(controller: controller, onTab: (_) {}),
        )),
      ));
      await tester.pumpAndSettle();
      final panel = tester.widget<Container>(find.byKey(const ValueKey('warqnaa-blue-quickplay-hub')));
      final decoration = panel.decoration! as BoxDecoration;
      final colors = (decoration.gradient! as LinearGradient).colors;
      expect(colors.length, 3);
      expect(colors.first, brightness == Brightness.dark
          ? const Color(0xFF041B42) : const Color(0xFF0659BA));
      expect(tester.takeException(), isNull);
    });
  }
  // Protect the original palette and text direction across both locales and themes.
  for (final locale in ['ar', 'en']) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      for (final width in [320.0, 390.0, 430.0, 600.0]) {
        testWidgets('R56 blue palette and direction $locale $brightness $width', (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final controller = AppController()..localeCode = locale;
          addTearDown(controller.dispose);
          await tester.pumpWidget(MaterialApp(
            // The controller supplies localized copy; Directionality below tests
            // the layout without advertising unsupported MaterialApp delegates.
            theme: ThemeData(brightness: brightness),
            home: Scaffold(body: SingleChildScrollView(child:
              Directionality(
                textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child: WarqnaaBlueQuickPlayHub(controller: controller, onTab: (_) {}),
              ),
            )),
          ));
          await tester.pumpAndSettle();
          final hub = find.byKey(const ValueKey('warqnaa-blue-quickplay-hub'));
          expect(hub, findsOneWidget);
          expect(Directionality.of(tester.element(hub)),
              locale == 'ar' ? TextDirection.rtl : TextDirection.ltr);
          final decoration = tester.widget<Container>(hub).decoration! as BoxDecoration;
          final gradient = decoration.gradient! as LinearGradient;
          expect(gradient.colors, brightness == Brightness.dark
              ? const [Color(0xFF041B42), Color(0xFF074A9A), Color(0xFF0B3573)]
              : const [Color(0xFF0659BA), Color(0xFF087ED2), Color(0xFF064589)]);
          expect(find.byKey(const ValueKey('warqnaa-blue-play-now')), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  test('R56 grid handles narrow and invalid panels without extra columns', () {
    for (final width in [double.negativeInfinity, -10.0, 0.0, 1.0, 9.0, 100.0, 249.0]) {
      expect(warqnaaBlueGridColumns(width, 1), 1);
    }
    for (final scale in [1.61, 2.0, 3.0, 5.0]) {
      expect(warqnaaBlueGridColumns(600, scale), 1);
    }
  });

  test('R56 grid never grows when text scale increases', () {
    for (final width in [220.0, 250.0, 320.0, 350.0, 430.0, 600.0]) {
      var previous = 3;
      for (final scale in [1.0, 1.2, 1.21, 1.6, 1.61, 2.0, 3.0]) {
        final columns = warqnaaBlueGridColumns(width, scale);
        expect(columns, inInclusiveRange(1, 3));
        expect(columns, lessThanOrEqualTo(previous));
        previous = columns;
      }
    }
  });

  test('R56 grid remains single-column at extreme accessibility scale', () {
    for (final width in [220.0, 320.0, 390.0, 600.0]) {
      expect(warqnaaBlueGridColumns(width, 3.0), 1);
    }
  });

  // Regression: screen-reader labels must describe both the action and destination.
  for (final locale in ['ar', 'en']) {
    testWidgets('R56 play CTA exposes localized navigation semantics $locale', (tester) async {
      final semantics = tester.ensureSemantics();
      // Dispose before the test framework checks for leaked semantics handles.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AppController()..localeCode = locale;
      addTearDown(controller.dispose);
      await tester.pumpWidget(review.reviewApp(
        Scaffold(body: SingleChildScrollView(child:
          WarqnaaBlueQuickPlayHub(controller: controller, onTab: (_) {}))),
        controller, GlobalKey(),
      ));
      await tester.pumpAndSettle();
      // Flutter may merge the CTA label with its child text in one semantics node.
      // Match the localized action within that node, not an exact merged label.
      try {
        expect(find.bySemanticsLabel(RegExp(locale == 'ar' ? 'ابدأ اللعب الآن' : 'Play now')), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }

  test('R56 grid columns never decrease as usable width grows', () {
    for (final scale in [1.0, 1.2, 1.21, 1.6, 1.61, 2.0, 3.0]) {
      var previous = 1;
      for (final width in [1.0, 160.0, 249.9, 250.0, 320.0, 349.9, 350.0, 430.0, 600.0]) {
        final columns = warqnaaBlueGridColumns(width, scale);
        expect(columns, inInclusiveRange(1, 3));
        expect(columns, greaterThanOrEqualTo(previous),
            reason: 'Wider panels must not reduce columns at text scale $scale');
        previous = columns;
      }
    }
  });

  test('R56 grid chooses one column for all invalid scale inputs', () {
    for (final scale in [double.nan, double.infinity, double.negativeInfinity, -1.0, 0.0]) {
      for (final width in [1.0, 250.0, 350.0, 600.0]) {
        expect(warqnaaBlueGridColumns(width, scale), 1,
            reason: 'Invalid text scale must fall back safely at width $width');
      }
    }
  });



  // Regression: high text scaling must not break the blue hub in either theme.
  for (final locale in ['ar', 'en']) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      testWidgets('R56 large text remains usable $locale $brightness', (tester) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(body: SingleChildScrollView(
            child: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(3)),
              child: Directionality(
                textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child: WarqnaaBlueQuickPlayHub(controller: controller, onTab: (_) {}),
              ),
            ),
          )),
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('warqnaa-blue-play-now')), findsOneWidget);
        expect(find.byKey(const ValueKey('warqnaa-blue-table-preview')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  test('R56 column selection stays bounded around both breakpoints', () {
    for (final scale in [1.0, 1.2, 1.21, 1.6, 1.61, 3.0]) {
      for (final width in [249.99, 250.0, 250.01, 349.99, 350.0, 350.01]) {
        final columns = warqnaaBlueGridColumns(width, scale);
        expect(columns, inInclusiveRange(1, 3));
        expect(columns, lessThanOrEqualTo(warqnaaBlueGridColumns(width + 0.01, scale)));
      }
    }
  });
  // Verify the actual suit visibility contract, not just absence of exceptions.
  // At high text scaling the decorative suit glyphs must not compete with copy.
  for (final locale in ['ar', 'en']) {
    for (final scale in [1.0, 3.0, 5.0]) {
      testWidgets('R56 preview hides decorative suits as text grows $locale $scale', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Directionality(
              textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: WarqnaaBlueQuickPlayHub(controller: controller, onTab: (_) {}),
            ),
          ))),
        ));
        await tester.pumpAndSettle();
        final preview = find.byKey(const ValueKey('warqnaa-blue-table-preview'));
        expect(preview, findsOneWidget);
        final suits = find.descendant(
          of: preview,
          matching: find.textContaining(RegExp('[♠♥♣♦]')),
        );
        expect(suits, findsNWidgets(scale == 1.0 ? 4 : 0),
            reason: 'At normal scale narrow previews show four suits; at 300%+ none');
        expect(tester.takeException(), isNull);
      });
    }
  }

  // The decorative suits must yield space to the localized message at 500% text.
  for (final locale in ['ar', 'en']) {
    testWidgets('R56 preview prioritizes text at extreme scale $locale', (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AppController()..localeCode = locale;
      addTearDown(controller.dispose);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(5)),
          child: Directionality(
            textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: WarqnaaBlueQuickPlayHub(controller: controller, onTab: (_) {}),
          ),
        ))),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('warqnaa-blue-table-preview')), findsOneWidget);
      expect(find.text(locale == 'ar' ? 'طاولتك بانتظارك' : 'Your table awaits'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

}
