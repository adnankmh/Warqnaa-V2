import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R131 daily pack dialog follows light and dark themes',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController();
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });

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
    const openKey = ValueKey('r131-open-pack-test');

    Future<BoxDecoration> openDialog(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              key: openKey,
              onPressed: () => showDailyPackV176(context, controller),
              child: const Text('Open pack'),
            ),
          ),
        ),
      ));
      await tester.tap(find.byKey(openKey));
      await tester.pumpAndSettle();

      final helper = tester.widget<Text>(
        find.byKey(const ValueKey('r131-pack-dialog-helper')),
      );
      expect(helper.style?.color, theme.colorScheme.onSurfaceVariant);
      expect(tester.takeException(), isNull);

      final surface = tester.widget<Container>(
        find.byKey(const ValueKey('r131-pack-dialog-surface')),
      );
      return surface.decoration! as BoxDecoration;
    }

    final lightDecoration = await openDialog(light);
    final lightGradient = lightDecoration.gradient! as LinearGradient;
    expect(
      lightGradient.colors,
      <Color>[
        light.colorScheme.surfaceContainerHighest,
        light.colorScheme.surface,
        light.colorScheme.surfaceContainer,
      ],
    );
    expect(
      (lightDecoration.border! as Border).top.color,
      light.colorScheme.tertiary.withValues(alpha: .5),
    );
    expect(
      lightDecoration.boxShadow!.single.color,
      light.colorScheme.primary.withValues(alpha: .24),
    );
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('r131-pack-dialog-surface')), findsNothing);

    final darkDecoration = await openDialog(dark);
    final darkGradient = darkDecoration.gradient! as LinearGradient;
    expect(
      darkGradient.colors,
      <Color>[
        dark.colorScheme.surfaceContainerHighest,
        dark.colorScheme.surface,
        dark.colorScheme.surfaceContainer,
      ],
    );
    expect(darkGradient.colors, isNot(equals(lightGradient.colors)));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
