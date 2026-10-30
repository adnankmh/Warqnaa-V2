import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets(
      'R142 competition guidance follows theme and stage calculations still update',
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

    Future<Color> openAndInspect(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r142-competition-${theme.brightness}'),
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              key: const ValueKey('r142-open-competition'),
              onPressed: () => showCreateCompetitionV151(context, controller),
              child: const Text('Open competition'),
            ),
          ),
        ),
      ));
      await tester.tap(find.byKey(const ValueKey('r142-open-competition')));
      await tester.pumpAndSettle();

      final guidanceFinder =
          find.byKey(const ValueKey('r142-competition-distribution'));
      final guidance = tester.widget<Text>(guidanceFinder);
      expect(guidance.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(guidance.style!.fontSize, 11);
      expect(find.text('8 لاعب'), findsOneWidget);

      final stages = tester
          .widgetList<DropdownButtonFormField<int>>(
              find.byType(DropdownButtonFormField<int>))
          .singleWhere(
              (field) => field.decoration.labelText == 'عدد المراحل');
      stages.onChanged!(3);
      await tester.pump();
      expect(find.text('16 لاعب'), findsOneWidget);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(guidanceFinder)).pop();
      await tester.pumpAndSettle();
      return guidance.style!.color!;
    }

    final lightColor = await openAndInspect(light);
    final darkColor = await openAndInspect(dark);
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
