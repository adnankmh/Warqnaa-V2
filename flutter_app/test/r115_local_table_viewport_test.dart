import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R115 local training table uses the shared desktop viewport policy', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains("key: const ValueKey('r115-local-table-viewport')"));
    expect(source, contains('final localTableWidth = proportionalTableWidthV186('));
    expect(
      source,
      contains('desktop: isDesktopWebV183(MediaQuery.sizeOf(context).width)'),
    );
  });

  testWidgets('R115 portrait phone keeps the local table at full safe width',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()..localeCode = 'ar';
    addTearDown(controller.dispose);
    final game = gamesCatalog.firstWhere((item) => item.id == 'tarneeb');

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: TarneebRoomPage(controller: controller, game: game),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    final viewport = find.byKey(const ValueKey('r115-local-table-viewport'));
    expect(viewport, findsOneWidget);
    final width = tester.getSize(viewport).width;
    expect(width, greaterThanOrEqualTo(380));
    expect(width, lessThanOrEqualTo(390));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });
}
