import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets(
      'R144 admin store navigation and empty search state follow theme',
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

    Future<List<Color>> inspect(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r144-admin-store-${theme.brightness}'),
        theme: theme,
        home: Scaffold(
          body: AdminStoreStudioV151(
            key: ValueKey('r144-admin-store-body-${theme.brightness}'),
            controller: controller,
          ),
        ),
      ));
      await tester.pump();

      final shell = tester.widget<Container>(
        find.byKey(const ValueKey('r144-admin-store-category-shell')),
      );
      final decoration = shell.decoration! as BoxDecoration;
      expect(
        decoration.color,
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: .35),
      );
      expect(decoration.border!.top.color, theme.colorScheme.outlineVariant);
      expect(find.text('0 عنصر'), findsNothing);

      await tester.enterText(find.byType(TextField), 'r144-no-match');
      await tester.pump();

      final emptyFinder =
          find.byKey(const ValueKey('r144-admin-store-empty'));
      final empty = tester.widget<Text>(emptyFinder);
      expect(empty.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(find.text('0 عنصر'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(emptyFinder, findsNothing);
      expect(find.text('0 عنصر'), findsNothing);
      expect(tester.takeException(), isNull);

      return <Color>[
        decoration.color!,
        decoration.border!.top.color,
        empty.style!.color!,
      ];
    }

    final lightColors = await inspect(light);
    final darkColors = await inspect(dark);
    expect(darkColors, isNot(equals(lightColors)));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
