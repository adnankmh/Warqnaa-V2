import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R180 club leave action follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, TextDirection)> inspect({
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
        home: Directionality(
          textDirection: direction,
          child: const Scaffold(body: ClubLeaveIconR180()),
        ),
      ));
      await tester.pumpAndSettle();

      final finder = find.byKey(
        const ValueKey('r180-club-leave-icon'),
      );
      expect(finder, findsOneWidget);
      final icon = tester.widget<Icon>(finder);
      expect(icon.icon, Icons.logout);
      expect(icon.color, theme.colorScheme.error);
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.takeException(), isNull);

      return (
        icon.color,
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
  });
}
