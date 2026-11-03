import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R174 connection diagnostics follow portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, Color?, TextDirection)> inspect({
      required Brightness brightness,
      required TextDirection direction,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2563eb),
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: const Scaffold(
            body: Row(
              children: <Widget>[
                ConnectionDiagnosticStatusIconR174(ok: true),
                ConnectionDiagnosticStatusIconR174(ok: false),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final okFinder = find.byKey(
        const ValueKey('r174-connection-diagnostic-ok'),
      );
      final errorFinder = find.byKey(
        const ValueKey('r174-connection-diagnostic-error'),
      );
      expect(okFinder, findsOneWidget);
      expect(errorFinder, findsOneWidget);

      final okIcon = tester.widget<Icon>(okFinder);
      final errorIcon = tester.widget<Icon>(errorFinder);
      expect(okIcon.icon, Icons.check_circle);
      expect(okIcon.color, theme.colorScheme.primary);
      expect(errorIcon.icon, Icons.error_outline);
      expect(errorIcon.color, theme.colorScheme.error);
      expect(Directionality.of(tester.element(okFinder)), direction);
      expect(tester.takeException(), isNull);

      return (
        okIcon.color,
        errorIcon.color,
        Directionality.of(tester.element(okFinder)),
      );
    }

    final lightRtl = await inspect(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
    );
    final darkLtr = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );

    expect(darkLtr.$1, isNot(lightRtl.$1));
    expect(darkLtr.$2, isNot(lightRtl.$2));
  });
}
