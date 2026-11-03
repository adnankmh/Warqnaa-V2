import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R163 public profile presence follows theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<Color> inspect(
      ThemeData theme,
      TextDirection direction,
      bool online,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: PublicProfilePresenceIconV170(online: online),
          ),
        ),
      ));
      await tester.pump();

      final finder =
          find.byKey(const ValueKey('r133-public-profile-presence'));
      final icon = tester.widget<Icon>(finder);
      final scheme = Theme.of(tester.element(finder)).colorScheme;

      expect(icon.icon, online ? Icons.circle : Icons.circle_outlined);
      expect(icon.size, 13);
      expect(
        icon.color,
        online ? scheme.tertiary : scheme.onSurfaceVariant,
      );
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.takeException(), isNull);
      return icon.color!;
    }

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245f80),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245f80),
        brightness: Brightness.dark,
      ),
    );

    final lightOnline = await inspect(light, TextDirection.rtl, true);
    final darkOffline = await inspect(dark, TextDirection.ltr, false);
    expect(darkOffline, isNot(lightOnline));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
