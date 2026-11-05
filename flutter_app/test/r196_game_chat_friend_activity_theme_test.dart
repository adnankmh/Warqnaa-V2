import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R196 friend activity follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(TextStyle, TextDirection)> inspect({
      required Brightness brightness,
      required TextDirection direction,
      required double scale,
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
            body: Builder(
              builder: (context) => Text(
                'داخل غرفة لعب',
                key: const ValueKey('r196-friend-activity'),
                style: gameChatFriendActivityTextStyleR196(
                  context,
                  scale: scale,
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final activity =
          find.byKey(const ValueKey('r196-friend-activity'));
      expect(activity, findsOneWidget);
      expect(tester.takeException(), isNull);
      return (
        tester.widget<Text>(activity).style!,
        Directionality.of(tester.element(activity)),
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
      scale: .75,
    );
    expect(arabic.$1.color, lightScheme.onSurfaceVariant);
    expect(arabic.$1.fontSize, 11);
    expect(arabic.$2, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
      scale: 1.25,
    );
    expect(english.$1.color, darkScheme.onSurfaceVariant);
    expect(english.$1.fontSize, 13.75);
    expect(english.$2, TextDirection.ltr);
  });
}
