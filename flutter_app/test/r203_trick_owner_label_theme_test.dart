import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R203 trick owner labels follow portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(TextStyle, Rect, TextOverflow?, TextDirection)> inspect({
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
            body: Center(
              child: Builder(
                builder: (context) => SizedBox(
                  width: 62,
                  child: Text(
                    'A deliberately long player name',
                    key: const ValueKey('r203-trick-owner'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: trickOwnerLabelTextStyleR203(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final owner = find.byKey(const ValueKey('r203-trick-owner'));
      expect(owner, findsOneWidget);
      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(owner);
      return (
        text.style!,
        tester.getRect(owner),
        text.overflow,
        Directionality.of(tester.element(owner)),
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
    expect(arabic.$1.fontSize, 11);
    expect(arabic.$1.color, lightScheme.onSurfaceVariant);
    expect(arabic.$2.width, lessThanOrEqualTo(62));
    expect(arabic.$3, TextOverflow.ellipsis);
    expect(arabic.$4, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$1.fontSize, 11);
    expect(english.$1.color, darkScheme.onSurfaceVariant);
    expect(english.$2.width, lessThanOrEqualTo(62));
    expect(english.$3, TextOverflow.ellipsis);
    expect(english.$4, TextDirection.ltr);
  });
}
