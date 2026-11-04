import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R190 game chat panel follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, Color?, TextDirection)> inspect({
      required Brightness brightness,
      required TextDirection direction,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0f766e),
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        themeAnimationDuration: Duration.zero,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Builder(
              builder: (context) => Container(
                key: const ValueKey('r190-chat-panel'),
                decoration: gameChatPanelDecorationR190(context),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final finder = find.byKey(const ValueKey('r190-chat-panel'));
      expect(finder, findsOneWidget);
      expect(tester.takeException(), isNull);

      final container = tester.widget<Container>(finder);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20));
      final border = decoration.border! as Border;
      return (
        decoration.color,
        border.top.color,
        Directionality.of(tester.element(finder)),
      );
    }

    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff0f766e),
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff0f766e),
      brightness: Brightness.dark,
    );

    final arabic = await inspect(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
    );
    expect(arabic.$1, lightScheme.surface);
    expect(
      arabic.$2,
      lightScheme.outlineVariant.withValues(alpha: .55),
    );
    expect(arabic.$3, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$1, darkScheme.surface);
    expect(
      english.$2,
      darkScheme.outlineVariant.withValues(alpha: .55),
    );
    expect(english.$3, TextDirection.ltr);
  });
}
