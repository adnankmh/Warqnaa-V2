import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R130 pack inventory follows light and dark themes',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()
      ..dailyPackHistoryV176.addAll(<Map<String, dynamic>>[
        <String, dynamic>{'label_ar': 'جائزة دائمة', 'icon': '🎨'},
        <String, dynamic>{
          'label_ar': 'جائزة منتهية',
          'icon': '🎁',
          'expires_at': '2020-01-01T00:00:00Z',
        },
      ]);
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
    var inventoryOpened = false;

    Future<Map<String, Color?>> snapshot(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: PackInventoryStripV176(
            controller: controller,
            onOpenInventory: () => inventoryOpened = true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final active = tester.widget<Container>(
        find.byKey(const ValueKey('r130-pack-reward-0')),
      );
      final expired = tester.widget<Container>(
        find.byKey(const ValueKey('r130-pack-reward-1')),
      );
      final activeDecoration = active.decoration! as BoxDecoration;
      final expiredDecoration = expired.decoration! as BoxDecoration;

      return <String, Color?>{
        'helper': tester
            .widget<Text>(
              find.byKey(const ValueKey('r130-pack-inventory-helper')),
            )
            .style
            ?.color,
        'surface': activeDecoration.color,
        'activeBorder':
            (activeDecoration.border! as Border).top.color,
        'expiredBorder':
            (expiredDecoration.border! as Border).top.color,
        'activeStatus': tester
            .widget<Text>(find.byKey(const ValueKey('r130-pack-status-0')))
            .style
            ?.color,
        'expiredStatus': tester
            .widget<Text>(find.byKey(const ValueKey('r130-pack-status-1')))
            .style
            ?.color,
      };
    }

    final lightSnapshot = await snapshot(light);
    expect(lightSnapshot['helper'], light.colorScheme.onSurfaceVariant);
    expect(
      lightSnapshot['surface'],
      light.colorScheme.surfaceContainerHighest.withValues(alpha: .58),
    );
    expect(
      lightSnapshot['activeBorder'],
      light.colorScheme.tertiary.withValues(alpha: .45),
    );
    expect(lightSnapshot['expiredBorder'], light.colorScheme.outlineVariant);
    expect(lightSnapshot['activeStatus'], light.colorScheme.tertiary);
    expect(lightSnapshot['expiredStatus'], light.colorScheme.error);

    await tester.tap(find.text('عرض الكل'));
    expect(inventoryOpened, isTrue);

    final darkSnapshot = await snapshot(dark);
    expect(darkSnapshot['helper'], dark.colorScheme.onSurfaceVariant);
    expect(
      darkSnapshot['surface'],
      dark.colorScheme.surfaceContainerHighest.withValues(alpha: .58),
    );
    expect(darkSnapshot['activeStatus'], dark.colorScheme.tertiary);
    expect(darkSnapshot['expiredStatus'], dark.colorScheme.error);
    expect(darkSnapshot['surface'], isNot(equals(lightSnapshot['surface'])));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
