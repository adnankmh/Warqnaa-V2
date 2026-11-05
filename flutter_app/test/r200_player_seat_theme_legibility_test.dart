import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R200 player seats follow portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(BoxDecoration, TextStyle, TextStyle, TextStyle, Rect,
        TextDirection)> inspect({
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
          child: const Scaffold(
            body: Center(
              child: PlayerSeat(
                name: 'A player with a deliberately long display name',
                letter: 'A',
                bid: '7',
                meta: 'Connected and ready',
                lastCardLabel: 'A_H',
                vertical: true,
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final panel = find.byKey(const ValueKey('r200-player-seat-info'));
      final primary =
          find.byKey(const ValueKey('r200-player-seat-primary'));
      final meta = find.byKey(const ValueKey('r200-player-seat-meta'));
      final last =
          find.byKey(const ValueKey('r200-player-seat-last-label'));
      expect(panel, findsOneWidget);
      expect(primary, findsOneWidget);
      expect(meta, findsOneWidget);
      expect(last, findsOneWidget);
      expect(tester.takeException(), isNull);

      return (
        tester.widget<Container>(panel).decoration! as BoxDecoration,
        tester.widget<Text>(primary).style!,
        tester.widget<Text>(meta).style!,
        tester.widget<Text>(last).style!,
        tester.getRect(panel),
        Directionality.of(tester.element(panel)),
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
    expect(arabic.$1.color,
        lightScheme.surfaceContainerHighest.withValues(alpha: .92));
    expect((arabic.$1.border! as Border).top.color,
        lightScheme.outlineVariant);
    expect(arabic.$2.color, lightScheme.onSurface);
    expect(arabic.$3.color, lightScheme.onSurfaceVariant);
    expect(arabic.$4.color, lightScheme.onSurfaceVariant);
    expect(arabic.$2.fontSize, 11);
    expect(arabic.$3.fontSize, 11);
    expect(arabic.$4.fontSize, 11);
    expect(arabic.$5.width, lessThanOrEqualTo(150));
    expect(arabic.$6, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$1.color,
        darkScheme.surfaceContainerHighest.withValues(alpha: .92));
    expect((english.$1.border! as Border).top.color,
        darkScheme.outlineVariant);
    expect(english.$2.color, darkScheme.onSurface);
    expect(english.$3.color, darkScheme.onSurfaceVariant);
    expect(english.$4.color, darkScheme.onSurfaceVariant);
    expect(english.$2.fontSize, 11);
    expect(english.$3.fontSize, 11);
    expect(english.$4.fontSize, 11);
    expect(english.$5.width, lessThanOrEqualTo(150));
    expect(english.$6, TextDirection.ltr);
  });
}
