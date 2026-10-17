import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('R39 premium club, store and designer copy keeps an 11px type floor', () {
    for (final path in <String>[
      'lib/premium_v151.dart',
      'lib/v183_overhaul.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(
        RegExp(r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])')
            .hasMatch(source),
        isFalse,
        reason: '$path must not reintroduce sub-11px copy',
      );
    }
  });

  testWidgets('R39 designer guidance remains readable on a narrow phone', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
    final controller = AppController();
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
          child: SingleChildScrollView(
            child: DesignerQuickControlsV183(controller: controller),
          ),
        ),
      ),
    ));
    await tester.pump();

    final guidance = tester.widget<Text>(
      find.text(
        'تعديل الأسعار، الإتاحة، النصوص، الألوان، المدة، المعاينات، المسرعات، الإيموت والأصوات مع حفظ محلي ومزامنة الخادم.',
      ),
    );
    expect(guidance.style?.fontSize, 11);
    expect(guidance.style?.fontWeight, FontWeight.w600);
    expect(tester.takeException(), isNull);
  });
}
