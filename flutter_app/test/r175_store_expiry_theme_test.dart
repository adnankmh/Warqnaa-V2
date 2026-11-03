import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R175 store expiry badge follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, Color?, Color?, TextDirection)> inspect({
      required Brightness brightness,
      required TextDirection direction,
      required String label,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff7c3aed),
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(body: StoreExpiryBadgeR175(label: label)),
        ),
      ));
      await tester.pumpAndSettle();

      final finder = find.byKey(const ValueKey('r175-store-expiry-badge'));
      expect(finder, findsOneWidget);
      final container = tester.widget<Container>(finder);
      final decoration = container.decoration! as BoxDecoration;
      final border = decoration.border! as Border;
      final text = tester.widget<Text>(find.descendant(
        of: finder,
        matching: find.text('⌛ $label'),
      ));

      expect(decoration.color, theme.colorScheme.tertiaryContainer);
      expect(
        border.top.color,
        theme.colorScheme.tertiary.withValues(alpha: .35),
      );
      expect(text.style?.color, theme.colorScheme.onTertiaryContainer);
      expect(text.style?.fontSize, 11);
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.takeException(), isNull);

      return (
        decoration.color,
        border.top.color,
        text.style?.color,
        Directionality.of(tester.element(finder)),
      );
    }

    final lightRtl = await inspect(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
      label: 'متبقٍ يومان',
    );
    final darkLtr = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
      label: '2 days left',
    );

    expect(darkLtr.$1, isNot(lightRtl.$1));
    expect(darkLtr.$3, isNot(lightRtl.$3));
  });
}
