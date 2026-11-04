import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R192 friend status follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, Color?, Rect, Rect, TextDirection)> inspect({
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
            body: SizedBox(
              key: const ValueKey('r192-status-stack'),
              width: 40,
              height: 40,
              child: const Stack(
                children: [
                  CircleAvatar(radius: 20, child: Text('A')),
                  GameChatFriendOnlineIndicatorR192(),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final stack = find.byKey(const ValueKey('r192-status-stack'));
      final indicator =
          find.byKey(const ValueKey('r192-game-chat-friend-online'));
      expect(stack, findsOneWidget);
      expect(indicator, findsOneWidget);
      expect(tester.takeException(), isNull);

      final outer = tester.widget<CircleAvatar>(indicator);
      final innerFinder = find.descendant(
        of: indicator,
        matching: find.byType(CircleAvatar),
      );
      expect(innerFinder, findsOneWidget);
      final inner = tester.widget<CircleAvatar>(innerFinder);

      return (
        outer.backgroundColor,
        inner.backgroundColor,
        tester.getRect(stack),
        tester.getRect(indicator),
        Directionality.of(tester.element(indicator)),
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
    expect(arabic.$1, lightScheme.primary);
    expect(arabic.$2, lightScheme.surface);
    expect(arabic.$4.left, arabic.$3.left);
    expect(arabic.$5, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$1, darkScheme.primary);
    expect(english.$2, darkScheme.surface);
    expect(english.$4.right, english.$3.right);
    expect(english.$5, TextDirection.ltr);
  });
}
