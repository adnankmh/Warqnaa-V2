import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R195 private chat metadata follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(TextStyle, TextStyle, TextDirection)> inspect({
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
            body: Builder(
              builder: (context) => Column(
                children: [
                  Text(
                    'متصل الآن',
                    key: const ValueKey('r195-highlighted-metadata'),
                    style: privateChatMetadataTextStyleR195(
                      context,
                      highlighted: true,
                    ),
                  ),
                  Text(
                    '12:45',
                    key: const ValueKey('r195-secondary-metadata'),
                    style: privateChatMetadataTextStyleR195(
                      context,
                      highlighted: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final highlighted =
          find.byKey(const ValueKey('r195-highlighted-metadata'));
      final secondary =
          find.byKey(const ValueKey('r195-secondary-metadata'));
      expect(highlighted, findsOneWidget);
      expect(secondary, findsOneWidget);
      expect(tester.takeException(), isNull);

      return (
        tester.widget<Text>(highlighted).style!,
        tester.widget<Text>(secondary).style!,
        Directionality.of(tester.element(highlighted)),
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
    expect(arabic.$1.color, lightScheme.primary);
    expect(arabic.$2.color, lightScheme.onSurfaceVariant);
    expect(arabic.$1.fontSize, 11);
    expect(arabic.$2.fontSize, 11);
    expect(arabic.$3, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$1.color, darkScheme.primary);
    expect(english.$2.color, darkScheme.onSurfaceVariant);
    expect(english.$1.fontSize, 11);
    expect(english.$2.fontSize, 11);
    expect(english.$3, TextDirection.ltr);
  });
}
