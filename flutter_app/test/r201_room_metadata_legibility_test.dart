import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R201 room metadata stays legible in portrait RTL and LTR',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(TextStyle, TextStyle, TextStyle, TextDirection)> inspect({
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
            body: Column(
              children: [
                const R125VoiceRoomNotice(message: 'Voice connected'),
                R126VoiceParticipantTile(
                  avatarText: 'A',
                  label: 'Adnan',
                  online: true,
                  muted: false,
                  onTap: () {},
                ),
                const R127TarneebStatusItem(
                  label: 'Contract',
                  value: '7',
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pump();

      final notice =
          find.byKey(const ValueKey('r125-voice-room-notice'));
      final participant = find.text('Adnan');
      final status = find.text('Contract');
      expect(notice, findsOneWidget);
      expect(participant, findsOneWidget);
      expect(status, findsOneWidget);
      expect(tester.takeException(), isNull);

      return (
        tester.widget<Text>(notice).style!,
        tester.widget<Text>(participant).style!,
        tester.widget<Text>(status).style!,
        Directionality.of(tester.element(notice)),
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
    expect(arabic.$3.fontSize, 11);
    expect(arabic.$1.color, lightScheme.onSurfaceVariant);
    expect(arabic.$3.color, lightScheme.onSurfaceVariant);
    expect(arabic.$4, TextDirection.rtl);

    final english = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    expect(english.$1.fontSize, 11);
    expect(english.$2.fontSize, 11);
    expect(english.$3.fontSize, 11);
    expect(english.$1.color, darkScheme.onSurfaceVariant);
    expect(english.$3.color, darkScheme.onSurfaceVariant);
    expect(english.$4, TextDirection.ltr);
  });
}
