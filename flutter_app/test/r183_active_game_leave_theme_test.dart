import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R183 active-game leave action follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, Color?, TextDirection)> inspect({
      required Brightness brightness,
      required TextDirection direction,
    }) async {
      var pressed = false;
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0f766e),
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: ActiveGameLeaveButtonR183(
              onPressed: () => pressed = true,
              label: direction == TextDirection.rtl
                  ? 'مغادرة اللعبة الآن'
                  : 'Leave game now',
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final finder = find.byKey(
        const ValueKey('r183-active-game-leave-button'),
      );
      expect(finder, findsOneWidget);
      final button = tester.widget<FilledButton>(finder);
      expect(
        button.style?.backgroundColor?.resolve({}),
        theme.colorScheme.error,
      );
      expect(
        button.style?.foregroundColor?.resolve({}),
        theme.colorScheme.onError,
      );
      expect(Directionality.of(tester.element(finder)), direction);

      await tester.tap(finder);
      await tester.pump();
      expect(pressed, isTrue);
      expect(tester.takeException(), isNull);

      return (
        button.style?.backgroundColor?.resolve({}),
        button.style?.foregroundColor?.resolve({}),
        Directionality.of(tester.element(finder)),
      );
    }

    final lightRtl = await inspect(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
    );
    final darkLtr = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );

    expect(darkLtr.$1, isNot(lightRtl.$1));
    expect(darkLtr.$2, isNot(lightRtl.$2));
  });
}
