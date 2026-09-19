import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('offline operations shows an error instead of invented server metrics', (tester) async {
    final controller = AppController()..localeCode = 'en';
    await tester.pumpWidget(MaterialApp(home: R65OperationsPage(controller: controller)));
    await tester.pumpAndSettle();
    expect(find.text('Active rooms'), findsNothing);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('room browser handles a narrow offline screen without a crash', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AppController()..localeCode = 'en';
    await tester.pumpWidget(MaterialApp(home: R64RoomBrowserPage(controller: controller)));
    await tester.pumpAndSettle();
    expect(find.text('Live rooms'), findsOneWidget);
    expect(find.text('Start the Laravel server to browse public rooms.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
