import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('R38 challenge and reward metadata keeps an 11px type floor', () {
    for (final path in <String>['lib/v175_release.dart', 'lib/v176_release.dart']) {
      final source = File(path).readAsStringSync();
      expect(
        RegExp(r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])')
            .hasMatch(source),
        isFalse,
        reason: '$path must not reintroduce sub-11px copy',
      );
    }
  });

  testWidgets('R38 pack history remains readable on a narrow phone', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
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
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);

    await tester.pumpWidget(MaterialApp(
      theme: r101Theme(controller.themeCode, controller.uiAccentHex),
      home: Scaffold(
        body: SafeArea(
          child: PackInventoryStripV176(
            controller: controller,
            onOpenInventory: () {},
          ),
        ),
      ),
    ));
    await tester.pump();

    final helper = tester.widget<Text>(
      find.text('الجوائز المؤقتة تظهر هنا وفي المتجر مع وقت الانتهاء.'),
    );
    final activeStatus = tester.widget<Text>(find.text('أضيفت مباشرة إلى الرصيد'));
    final expiredStatus = tester.widget<Text>(find.text('انتهت الصلاحية'));
    expect(helper.style?.fontSize, 11);
    expect(
      helper.style?.color,
      Theme.of(tester.element(find.text('الجوائز المؤقتة تظهر هنا وفي المتجر مع وقت الانتهاء.'))).colorScheme.onSurfaceVariant,
    );
    expect(activeStatus.style?.fontSize, 11);
    expect(expiredStatus.style?.fontSize, 11);
    expect(tester.takeException(), isNull);
  });
}
