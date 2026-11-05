import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R198 compact meld table follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(BoxDecoration, BoxDecoration, TextStyle, TextDirection)> inspect({
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
              builder: (context) => Container(
                key: const ValueKey('r198-meld-table'),
                width: 276,
                height: 126,
                decoration: compactRummyMeldTableDecorationR198(context),
                child: Center(
                  child: Container(
                    key: const ValueKey('r198-overflow-badge'),
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration:
                        compactRummyMeldOverflowDecorationR198(context),
                    child: Text(
                      '+3',
                      key: const ValueKey('r198-overflow-text'),
                      style:
                          compactRummyMeldOverflowTextStyleR198(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final table = find.byKey(const ValueKey('r198-meld-table'));
      final badge = find.byKey(const ValueKey('r198-overflow-badge'));
      final text = find.byKey(const ValueKey('r198-overflow-text'));
      expect(table, findsOneWidget);
      expect(badge, findsOneWidget);
      expect(text, findsOneWidget);
      expect(tester.takeException(), isNull);

      return (
        tester.widget<Container>(table).decoration! as BoxDecoration,
        tester.widget<Container>(badge).decoration! as BoxDecoration,
        tester.widget<Text>(text).style!,
        Directionality.of(tester.element(table)),
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
    expect(arabic.$1.color, lightScheme.surface.withValues(alpha: .92));
    expect((arabic.$1.border! as Border).top.color,
        lightScheme.primary.withValues(alpha: .32));
    expect(arabic.$2.color,
        lightScheme.primaryContainer.withValues(alpha: .88));
    expect(arabic.$3.color, lightScheme.onPrimaryContainer);
    expect(arabic.$3.fontSize, 11);
    expect(arabic.$4, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$1.color, darkScheme.surface.withValues(alpha: .92));
    expect((english.$1.border! as Border).top.color,
        darkScheme.primary.withValues(alpha: .32));
    expect(english.$2.color,
        darkScheme.primaryContainer.withValues(alpha: .88));
    expect(english.$3.color, darkScheme.onPrimaryContainer);
    expect(english.$3.fontSize, 11);
    expect(english.$4, TextDirection.ltr);
  });
}
