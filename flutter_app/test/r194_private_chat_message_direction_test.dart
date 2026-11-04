import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R194 private chat geometry mirrors in portrait RTL and LTR',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Rect, Rect, Rect, BorderRadius, BorderRadius, TextDirection)>
        inspect({
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
              key: const ValueKey('r194-private-chat-frame'),
              width: 200,
              height: 80,
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment:
                          privateChatMessageAlignmentR194(mine: true),
                      child: const SizedBox(
                        key: ValueKey('r194-own-message'),
                        width: 40,
                        height: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment:
                          privateChatMessageAlignmentR194(mine: false),
                      child: const SizedBox(
                        key: ValueKey('r194-incoming-message'),
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

      final frame =
          find.byKey(const ValueKey('r194-private-chat-frame'));
      final own = find.byKey(const ValueKey('r194-own-message'));
      final incoming =
          find.byKey(const ValueKey('r194-incoming-message'));
      expect(frame, findsOneWidget);
      expect(own, findsOneWidget);
      expect(incoming, findsOneWidget);
      expect(tester.takeException(), isNull);

      return (
        tester.getRect(frame),
        tester.getRect(own),
        tester.getRect(incoming),
        privateChatMessageBorderRadiusR194(mine: true)
            .resolve(direction),
        privateChatMessageBorderRadiusR194(mine: false)
            .resolve(direction),
        Directionality.of(tester.element(own)),
      );
    }

    final arabic = await inspect(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
    );
    expect(arabic.$2.left, arabic.$1.left);
    expect(arabic.$3.right, arabic.$1.right);
    expect(arabic.$4.bottomLeft, const Radius.circular(4));
    expect(arabic.$4.bottomRight, const Radius.circular(17));
    expect(arabic.$5.bottomLeft, const Radius.circular(17));
    expect(arabic.$5.bottomRight, const Radius.circular(4));
    expect(arabic.$6, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$2.right, english.$1.right);
    expect(english.$3.left, english.$1.left);
    expect(english.$4.bottomLeft, const Radius.circular(17));
    expect(english.$4.bottomRight, const Radius.circular(4));
    expect(english.$5.bottomLeft, const Radius.circular(4));
    expect(english.$5.bottomRight, const Radius.circular(17));
    expect(english.$6, TextDirection.ltr);
  });
}
