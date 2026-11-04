import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R187 room voice hearing follows portrait RTL and LTR themes',
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
                RoomVoiceHearingIconR187(deafened: false),
                RoomVoiceHearingIconR187(deafened: true),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final liveFinder = find.byKey(
        const ValueKey('r187-room-voice-hearing-live'),
      );
      final mutedFinder = find.byKey(
        const ValueKey('r187-room-voice-hearing-muted'),
      );
      expect(liveFinder, findsOneWidget);
      expect(mutedFinder, findsOneWidget);

      final live = tester.widget<Icon>(liveFinder);
      final muted = tester.widget<Icon>(mutedFinder);
      expect(live.icon, Icons.headphones_rounded);
      expect(live.color, theme.colorScheme.primary);
      expect(muted.icon, Icons.headset_off_rounded);
      expect(muted.color, theme.colorScheme.error);
      expect(Directionality.of(tester.element(liveFinder)), direction);
      expect(Directionality.of(tester.element(mutedFinder)), direction);
      expect(tester.takeException(), isNull);

      return (
        live.color,
        muted.color,
        Directionality.of(tester.element(liveFinder)),
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
