import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

void main() {
  for (final locale in ['ar', 'en']) {
    for (final width in [320.0, 390.0, 600.0]) {
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
        final store = find.text(locale == 'ar' ? 'المتجر' : 'Store');
        await tester.ensureVisible(store);
        await tester.pumpAndSettle();
        await tester.tap(store);
        expect(selected, 0);
        final challenges = find.text(locale == 'ar' ? 'التحديات' : 'Challenges');
        await tester.ensureVisible(challenges);
        await tester.pumpAndSettle();
        await tester.tap(challenges);
        expect(selected, 2);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final locale in ['ar', 'en']) {
    for (final width in [240.0, 320.0, 390.0]) {
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
    for (final panelWidth in [220.0, 280.0, 340.0]) {
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
}
