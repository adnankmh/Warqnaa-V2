import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R202 game entry metadata follows portrait RTL and LTR themes',
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
                    'Room 1234',
                    key: const ValueKey('r202-room-subtitle'),
                    style: gameRoomSubtitleTextStyleR202(context),
                  ),
                  Text(
                    'Server connected',
                    key: const ValueKey('r202-lobby-connection'),
                    style: gameLobbyConnectionTextStyleR202(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final room = find.byKey(const ValueKey('r202-room-subtitle'));
      final connection =
          find.byKey(const ValueKey('r202-lobby-connection'));
      expect(room, findsOneWidget);
      expect(connection, findsOneWidget);
      expect(tester.takeException(), isNull);

      return (
        tester.widget<Text>(room).style!,
        tester.widget<Text>(connection).style!,
        Directionality.of(tester.element(room)),
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
    expect(arabic.$2.fontSize, 11);
    expect(arabic.$1.color, lightScheme.primary);
    expect(arabic.$2.color, lightScheme.onSurfaceVariant);
    expect(arabic.$3, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$1.fontSize, 11);
    expect(english.$2.fontSize, 11);
    expect(english.$1.color, darkScheme.primary);
    expect(english.$2.color, darkScheme.onSurfaceVariant);
    expect(english.$3, TextDirection.ltr);
  });
}
