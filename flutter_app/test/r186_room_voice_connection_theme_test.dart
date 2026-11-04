import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R186 room voice connection follows portrait RTL and LTR themes',
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
          seedColor: const Color(0xff0f766e),
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: const Scaffold(
            body: Row(
              children: [
                RoomVoiceConnectionIconR186(connected: true),
                RoomVoiceConnectionIconR186(connected: false),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final connectedFinder = find.byKey(
        const ValueKey('r186-room-voice-connected'),
      );
      final connectingFinder = find.byKey(
        const ValueKey('r186-room-voice-connecting'),
      );
      expect(connectedFinder, findsOneWidget);
      expect(connectingFinder, findsOneWidget);

      final connected = tester.widget<Icon>(connectedFinder);
      final connecting = tester.widget<Icon>(connectingFinder);
      expect(connected.icon, Icons.graphic_eq_rounded);
      expect(connected.color, theme.colorScheme.primary);
      expect(connecting.icon, Icons.graphic_eq_rounded);
      expect(connecting.color, theme.colorScheme.tertiary);
      expect(Directionality.of(tester.element(connectedFinder)), direction);
      expect(Directionality.of(tester.element(connectingFinder)), direction);
      expect(tester.takeException(), isNull);

      return (
        connected.color,
        connecting.color,
        Directionality.of(tester.element(connectedFinder)),
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
