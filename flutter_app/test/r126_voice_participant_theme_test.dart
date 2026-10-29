import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R126 voice participant tile follows theme and keeps actions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.dark,
      ),
    );

    var taps = 0;
    var longPresses = 0;
    const tileKey = ValueKey('r126-test-tile');
    const surfaceKey = ValueKey('r126-test-surface');

    Future<BoxDecoration> pumpTile(
      ThemeData theme, {
      required bool online,
      required bool muted,
    }) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: R126VoiceParticipantTile(
              key: tileKey,
              surfaceKey: surfaceKey,
              avatarText: 'A',
              label: 'Adnan',
              online: online,
              muted: muted,
              onTap: () => taps++,
              onLongPress: () => longPresses++,
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Adnan'), findsOneWidget);
      expect(
        find.byIcon(muted ? Icons.mic_off_rounded : Icons.mic_rounded),
        findsOneWidget,
      );
      final surface = tester.widget<Container>(find.byKey(surfaceKey));
      expect(tester.takeException(), isNull);
      return surface.decoration! as BoxDecoration;
    }

    final lightDecoration = await pumpTile(light, online: false, muted: true);
    expect(
      lightDecoration.color,
      light.colorScheme.surfaceContainerHighest.withValues(alpha: .72),
    );
    expect((lightDecoration.border! as Border).top.color, light.colorScheme.outlineVariant);
    await tester.tap(find.byKey(tileKey));
    expect(taps, 1);
    await tester.longPress(find.byKey(tileKey));
    expect(longPresses, 1);

    final darkDecoration = await pumpTile(dark, online: true, muted: false);
    expect(
      darkDecoration.color,
      dark.colorScheme.surfaceContainerHighest.withValues(alpha: .72),
    );
    expect(
      (darkDecoration.border! as Border).top.color,
      Colors.greenAccent.withValues(alpha: .35),
    );
    expect(darkDecoration.color, isNot(equals(lightDecoration.color)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
