import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R191 game chat messages follow portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const mineColor = Color(0xffbe123c);

    Future<(Color?, Color?, Color, TextDirection)> inspect({
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
              builder: (context) => Column(
                children: [
                  Container(
                    key: const ValueKey('r191-incoming-message'),
                    decoration: gameChatMessageDecorationR191(
                      context,
                      mine: false,
                    ),
                    child: Text(
                      'رسالة',
                      key: const ValueKey('r191-incoming-text'),
                      style: TextStyle(
                        color: gameChatMessageTextColorR191(
                          context,
                          mine: false,
                          mineColor: mineColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    key: const ValueKey('r191-own-message'),
                    decoration: gameChatMessageDecorationR191(
                      context,
                      mine: true,
                    ),
                    child: Text(
                      'Mine',
                      key: const ValueKey('r191-own-text'),
                      style: TextStyle(
                        color: gameChatMessageTextColorR191(
                          context,
                          mine: true,
                          mineColor: mineColor,
                        ),
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

      final incoming =
          find.byKey(const ValueKey('r191-incoming-message'));
      final own = find.byKey(const ValueKey('r191-own-message'));
      expect(incoming, findsOneWidget);
      expect(own, findsOneWidget);
      expect(tester.takeException(), isNull);

      final incomingDecoration =
          tester.widget<Container>(incoming).decoration! as BoxDecoration;
      final ownDecoration =
          tester.widget<Container>(own).decoration! as BoxDecoration;
      expect(incomingDecoration.borderRadius, BorderRadius.circular(13));
      expect(ownDecoration.borderRadius, BorderRadius.circular(13));

      return (
        incomingDecoration.color,
        ownDecoration.color,
        tester
            .widget<Text>(find.byKey(const ValueKey('r191-incoming-text')))
            .style!
            .color!,
        Directionality.of(tester.element(incoming)),
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
    expect(arabic.$1, lightScheme.surfaceContainerHighest);
    expect(arabic.$2, lightScheme.primary.withValues(alpha: .16));
    expect(arabic.$3, lightScheme.onSurface);
    expect(arabic.$4, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$1, darkScheme.surfaceContainerHighest);
    expect(english.$2, darkScheme.primary.withValues(alpha: .16));
    expect(english.$3, darkScheme.onSurface);
    expect(english.$4, TextDirection.ltr);

    final ownText =
        tester.widget<Text>(find.byKey(const ValueKey('r191-own-text')));
    expect(ownText.style!.color, mineColor);
  });
}
