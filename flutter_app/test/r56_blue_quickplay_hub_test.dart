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
      });
    }
  }
}
