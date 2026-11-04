import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R189 empty game chat follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, TextDirection, String)> inspect({
      required Brightness brightness,
      required TextDirection direction,
      required String message,
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
            body: Center(
              child: GameChatEmptyStateR189(message: message),
            ),
          ),
        ),
      ));
      await tester.pump();

      final textFinder = find.text(message);
      expect(textFinder, findsOneWidget);
      expect(tester.takeException(), isNull);

      final text = tester.widget<Text>(textFinder);
      return (
        text.style?.color,
        Directionality.of(tester.element(textFinder)),
        text.data!,
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
      message: 'ابدأ المحادثة مع لاعبي الغرفة.',
    );
    expect(arabic.$1, lightScheme.onSurfaceVariant);
    expect(arabic.$2, TextDirection.rtl);
    expect(arabic.$3, 'ابدأ المحادثة مع لاعبي الغرفة.');

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
      message: 'Start chatting with the room players.',
    );
    expect(english.$1, darkScheme.onSurfaceVariant);
    expect(english.$2, TextDirection.ltr);
    expect(english.$3, 'Start chatting with the room players.');
  });
}
