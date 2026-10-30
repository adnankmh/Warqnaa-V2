import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R139 legacy challenge sheet follows active theme and still opens',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()..localeCode = 'ar';
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.dark,
      ),
    );

    Future<Color> openAndRead(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r139-legacy-challenges-${theme.brightness}'),
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              key: const ValueKey('r139-open-legacy-challenges'),
              onPressed: () => showChallengesV170(context, controller),
              child: const Text('Open challenges'),
            ),
          ),
        ),
      ));
      await tester.tap(find.byKey(const ValueKey('r139-open-legacy-challenges')));
      await tester.pumpAndSettle();

      final introFinder =
          find.byKey(const ValueKey('r139-legacy-challenge-intro'));
      expect(introFinder, findsOneWidget);
      final intro = tester.widget<Text>(introFinder);
      expect(intro.style!.fontSize, 11);
      expect(intro.style!.color, theme.colorScheme.onSurfaceVariant);

      Navigator.of(tester.element(introFinder)).pop();
      await tester.pumpAndSettle();
      expect(introFinder, findsNothing);
      expect(tester.takeException(), isNull);
      return intro.style!.color!;
    }

    final lightColor = await openAndRead(light);
    final darkColor = await openAndRead(dark);
    expect(darkColor, isNot(equals(lightColor)));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
