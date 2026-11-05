import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R197 compact meld groups follow portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(BoxDecoration, TextDirection)> inspect({
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
                key: const ValueKey('r197-compact-meld-group'),
                width: 82,
                height: 42,
                decoration: compactRummyMeldGroupDecorationR197(context),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final group =
          find.byKey(const ValueKey('r197-compact-meld-group'));
      expect(group, findsOneWidget);
      expect(tester.takeException(), isNull);
      return (
        tester.widget<Container>(group).decoration! as BoxDecoration,
        Directionality.of(tester.element(group)),
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
    expect(
      arabic.$1.color,
      lightScheme.surfaceContainerHighest.withValues(alpha: .72),
    );
    expect((arabic.$1.border! as Border).top.color,
        lightScheme.outlineVariant);
    expect(arabic.$2, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(
      english.$1.color,
      darkScheme.surfaceContainerHighest.withValues(alpha: .72),
    );
    expect((english.$1.border! as Border).top.color,
        darkScheme.outlineVariant);
    expect(english.$2, TextDirection.ltr);
  });
}
