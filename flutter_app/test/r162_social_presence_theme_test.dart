import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R162 social presence follows theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<List<Color>> inspect(
      ThemeData theme,
      TextDirection direction,
      bool online,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: SocialPresenceIndicatorV151(
              online: online,
              showLabel: true,
              onlineLabel: direction == TextDirection.rtl ? 'متصل' : 'Online',
              offlineLabel:
                  direction == TextDirection.rtl ? 'غير متصل' : 'Offline',
            ),
          ),
        ),
      ));
      await tester.pump();

      final dot = tester.widget<Container>(
        find.byKey(const ValueKey('r162-social-presence-dot')),
      );
      final decoration = dot.decoration! as BoxDecoration;
      final label = tester.widget<Text>(
        find.byKey(const ValueKey('r162-social-presence-label')),
      );
      final expectedDot =
          online ? theme.colorScheme.tertiary : theme.colorScheme.outline;
      final expectedLabel = online
          ? theme.colorScheme.tertiary
          : theme.colorScheme.onSurfaceVariant;

      expect(decoration.color, expectedDot);
      expect(label.style?.color, expectedLabel);
      expect(label.style?.fontSize, 11);
      expect(label.style?.fontWeight, FontWeight.w700);
      expect(label.data, online
          ? (direction == TextDirection.rtl ? 'متصل' : 'Online')
          : (direction == TextDirection.rtl ? 'غير متصل' : 'Offline'));
      expect(
        Directionality.of(tester.element(
          find.byKey(const ValueKey('r162-social-presence-label')),
        )),
        direction,
      );
      expect(tester.takeException(), isNull);
      return <Color>[decoration.color!, label.style!.color!];
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

    final lightOnline =
        await inspect(light, TextDirection.rtl, true);
    final darkOffline =
        await inspect(dark, TextDirection.ltr, false);
    expect(darkOffline, isNot(lightOnline));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
