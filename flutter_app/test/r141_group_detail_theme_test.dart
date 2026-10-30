import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R141 group detail follows theme and preserves presence semantics',
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

    Future<List<Color>> openAndInspect(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r141-group-detail-${theme.brightness}'),
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              key: const ValueKey('r141-open-group-detail'),
              onPressed: () => showGroupDetailV151(
                context,
                controller,
                'r141_group',
                '🛡️',
                'مجموعة الاختبار',
                20,
                5,
                12345,
              ),
              child: const Text('Open group detail'),
            ),
          ),
        ),
      ));
      await tester.tap(find.byKey(const ValueKey('r141-open-group-detail')));
      await tester.pumpAndSettle();

      final leagueFinder = find.byKey(const ValueKey('r141-group-league'));
      final league = tester.widget<Text>(leagueFinder);
      final offlineDot = tester.widget<Container>(
        find.byKey(const ValueKey('r141-group-status-dot-Jameel')),
      );
      final offlineLabel = tester.widget<Text>(
        find.byKey(const ValueKey('r141-group-status-label-Jameel')),
      );
      final onlineDot = tester.widget<Container>(
        find.byKey(const ValueKey('r141-group-status-dot-Samer')),
      );
      final onlineLabel = tester.widget<Text>(
        find.byKey(const ValueKey('r141-group-status-label-Samer')),
      );
      final offlineDecoration = offlineDot.decoration! as BoxDecoration;
      final onlineDecoration = onlineDot.decoration! as BoxDecoration;

      expect(league.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(offlineDecoration.color, theme.colorScheme.outline);
      expect(offlineLabel.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(offlineLabel.style!.fontSize, 11);
      expect(onlineDecoration.color, Colors.greenAccent);
      expect(onlineLabel.style!.color, Colors.greenAccent);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(leagueFinder)).pop();
      await tester.pumpAndSettle();
      return <Color>[
        league.style!.color!,
        offlineDecoration.color!,
        offlineLabel.style!.color!,
      ];
    }

    final lightColors = await openAndInspect(light);
    final darkColors = await openAndInspect(dark);
    expect(darkColors, isNot(equals(lightColors)));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
