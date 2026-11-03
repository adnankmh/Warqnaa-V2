import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R173 voice diagnostics error follows portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, TextDirection)> inspect({
      required Brightness brightness,
      required TextDirection direction,
      required String message,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0a8f62),
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: VoiceDiagnosticsErrorTextR173(message: message),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final finder = find.byKey(
        const ValueKey('r173-voice-diagnostics-error'),
      );
      expect(finder, findsOneWidget);
      final text = tester.widget<Text>(finder);
      expect(text.data, message);
      expect(text.style?.color, theme.colorScheme.error);
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.takeException(), isNull);

      return (
        text.style?.color,
        Directionality.of(tester.element(finder)),
      );
    }

    final lightRtl = await inspect(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
      message: 'تعذر الاتصال بالغرفة الصوتية',
    );
    final darkLtr = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
      message: 'Could not connect to the voice room',
    );

    expect(darkLtr.$1, isNot(lightRtl.$1));
  });
}
