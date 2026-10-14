import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    testWidgets('R36 social hub keeps readable typography $locale', (tester) async {
      final controller = AppController()..localeCode = locale;
      addTearDown(controller.dispose);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;

      for (final size in [const Size(320, 640), const Size(844, 390)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: R61SocialHubPage(controller: controller)),
        ));
        await tester.pump();

        final heroSubtitle = tester.widget<Text>(find.text(locale == 'ar'
            ? 'أصدقاء ورسائل وأندية وعالم حي من مركز واحد.'
            : 'Friends, messages, clubs and a live world from one hub.'));
        expect(heroSubtitle.style?.fontSize, 12);
        expect(heroSubtitle.style?.color, Colors.white70);

        final portalLabels = locale == 'ar'
            ? ['الأصدقاء', 'العالم', 'الأندية']
            : ['Friends', 'World', 'Clubs'];
        for (final label in portalLabels) {
          final portalLabel = tester.widget<Text>(find.text(label));
          expect(portalLabel.style?.fontSize, 11);
          expect(portalLabel.style?.color, Colors.white70);
          expect(portalLabel.style?.fontWeight, FontWeight.w700);
        }

        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  }
}
