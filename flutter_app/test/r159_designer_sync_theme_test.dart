import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R159 designer sync icons follow theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    Future<List<Color>> inspect(
      ThemeData theme,
      TextDirection direction,
      bool ar,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r159-designer-sync-${theme.brightness}'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: Row(
            children: <Widget>[
              const DesignerSyncStatusIconV173(connected: true),
              Text(ar ? 'متصل' : 'Connected'),
              const DesignerSyncStatusIconV173(connected: false),
              Text(ar ? 'غير متصل' : 'Offline'),
            ],
          ),
        ),
      ));
      await tester.pump();

      final connectedFinder =
          find.byKey(const ValueKey('r159-designer-sync-connected'));
      final offlineFinder =
          find.byKey(const ValueKey('r159-designer-sync-offline'));
      final connectedIcon = tester.widget<Icon>(connectedFinder);
      final offlineIcon = tester.widget<Icon>(offlineFinder);

      expect(connectedIcon.icon, Icons.cloud_done_rounded);
      expect(connectedIcon.color, theme.colorScheme.tertiary);
      expect(offlineIcon.icon, Icons.cloud_off_rounded);
      expect(offlineIcon.color, theme.colorScheme.error);
      expect(Directionality.of(tester.element(connectedFinder)), direction);
      expect(find.text(ar ? 'متصل' : 'Connected'), findsOneWidget);
      expect(find.text(ar ? 'غير متصل' : 'Offline'), findsOneWidget);
      expect(tester.takeException(), isNull);
      return <Color>[connectedIcon.color!, offlineIcon.color!];
    }

    final lightColors = await inspect(light, TextDirection.rtl, true);
    final darkColors = await inspect(dark, TextDirection.ltr, false);
    expect(darkColors, isNot(lightColors));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
