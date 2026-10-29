import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R116 short landscape table uses the shared viewport policy', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(
      source,
      contains("key: const ValueKey('r116-short-local-table-viewport')"),
    );
    expect(source, contains('final shortTableWidth = proportionalTableWidthV186('));
    expect(
      source,
      contains('availableWidth: tableArea.maxWidth'),
    );
    expect(
      source,
      contains('desktop: isDesktopWebV183(MediaQuery.sizeOf(context).width)'),
    );
  });

  testWidgets('R116 landscape phone keeps the full board share', (tester) async {
    tester.view.physicalSize = const Size(844, 390);
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

    final viewport =
        find.byKey(const ValueKey('r116-short-local-table-viewport'));
    expect(viewport, findsOneWidget);
    final width = tester.getSize(viewport).width;
    expect(width, greaterThanOrEqualTo(530));
    expect(width, lessThanOrEqualTo(544));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });
}
