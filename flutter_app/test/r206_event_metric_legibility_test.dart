import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets(
      'R206 event and profile metrics keep the 11px floor in portrait RTL and LTR',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> verify({
      required String locale,
      required TextDirection direction,
      required Brightness brightness,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0a8f62),
          brightness: brightness,
        ),
      );
      final controller = AppController()..localeCode = locale;

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Column(
              children: [
                LevelCard(controller: controller),
                StatCard(
                  icon: '🏆',
                  label: locale == 'ar' ? 'المباريات' : 'Matches',
                  value: '12',
                  onTap: () {},
                ),
                Expanded(child: EventsPage(controller: controller)),
              ],
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final labels = <Text>[
        tester.widget<Text>(
          find.byKey(const ValueKey('r123-level-card-label')),
        ),
        tester.widget<Text>(
          find.byKey(const ValueKey('r123-stat-card-label')),
        ),
        tester.widget<Text>(
          find.byKey(const ValueKey('r123-event-meta-champions')),
        ),
      ];
      for (final label in labels) {
        expect(label.style!.fontSize, greaterThanOrEqualTo(11));
        expect(label.style!.color, theme.colorScheme.onSurfaceVariant);
      }
      expect(
        Directionality.of(
          tester.element(
            find.byKey(const ValueKey('r123-level-card-label')),
          ),
        ),
        direction,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }

    await verify(
      locale: 'ar',
      direction: TextDirection.rtl,
      brightness: Brightness.light,
    );
    await verify(
      locale: 'en',
      direction: TextDirection.ltr,
      brightness: Brightness.dark,
    );
  });
}
