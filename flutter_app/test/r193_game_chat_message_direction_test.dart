import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R193 game chat messages mirror in portrait RTL and LTR',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Rect, Rect, Rect, TextDirection)> inspect({
      required Brightness brightness,
      required TextDirection direction,
    }) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff0f766e),
            brightness: brightness,
          ),
        ),
        themeAnimationDuration: Duration.zero,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: SizedBox(
              key: const ValueKey('r193-chat-frame'),
              width: 200,
              height: 80,
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment:
                          gameChatMessageAlignmentR193(mine: true),
                      child: const SizedBox(
                        key: ValueKey('r193-own-message'),
                        width: 40,
                        height: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment:
                          gameChatMessageAlignmentR193(mine: false),
                      child: const SizedBox(
                        key: ValueKey('r193-incoming-message'),
                        width: 40,
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final frame = find.byKey(const ValueKey('r193-chat-frame'));
      final own = find.byKey(const ValueKey('r193-own-message'));
      final incoming =
          find.byKey(const ValueKey('r193-incoming-message'));
      expect(frame, findsOneWidget);
      expect(own, findsOneWidget);
      expect(incoming, findsOneWidget);
      expect(tester.takeException(), isNull);

      return (
        tester.getRect(frame),
        tester.getRect(own),
        tester.getRect(incoming),
        Directionality.of(tester.element(own)),
      );
    }

    final arabic = await inspect(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
    );
    expect(arabic.$2.left, arabic.$1.left);
    expect(arabic.$3.right, arabic.$1.right);
    expect(arabic.$4, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$2.right, english.$1.right);
    expect(english.$3.left, english.$1.left);
    expect(english.$4, TextDirection.ltr);
  });
}
