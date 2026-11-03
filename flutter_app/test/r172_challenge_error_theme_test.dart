import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R172 challenge error follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, Color?, Color?, TextDirection)> inspect({
      required Brightness brightness,
      required TextDirection direction,
      required String message,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff6d28d9),
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: ChallengeErrorNoticeR172(message: message),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final notice = find.byKey(const ValueKey('r172-challenge-error'));
      expect(notice, findsOneWidget);
      final container = tester.widget<Container>(notice);
      final decoration = container.decoration! as BoxDecoration;
      final border = decoration.border! as Border;
      final text = tester.widget<Text>(find.descendant(
        of: notice,
        matching: find.text(message),
      ));

      expect(decoration.color, theme.colorScheme.errorContainer);
      expect(
        border.top.color,
        theme.colorScheme.error.withValues(alpha: .35),
      );
      expect(text.style?.color, theme.colorScheme.onErrorContainer);
      expect(text.style?.fontSize, 11);
      expect(Directionality.of(tester.element(notice)), direction);
      expect(tester.takeException(), isNull);

      return (
        decoration.color,
        border.top.color,
        text.style?.color,
        Directionality.of(tester.element(notice)),
      );
    }

    final lightRtl = await inspect(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
      message: 'تعذر تحميل التحديات',
    );
    final darkLtr = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
      message: 'Unable to load challenges',
    );

    expect(darkLtr.$1, isNot(lightRtl.$1));
    expect(darkLtr.$3, isNot(lightRtl.$3));
  });
}
