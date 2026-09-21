import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final leaveAfter in [1, 2, 3]) {
    testWidgets('competitive load stops after disposal at request $leaveAfter', (tester) async {
      final requests = <String>[];
      final pending = Completer<http.Response>();
      final controller = AppController()..serverConnected = true;
      controller.api.token = 'synthetic-lifecycle-test';
      final client = MockClient((request) async {
        requests.add(request.url.path);
        if (requests.length == leaveAfter) return pending.future;
        return http.Response('{}', 200);
      });
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp(home: R12CompetitiveArenaPage(controller: controller)));
        await tester.pump();
        expect(requests.length, leaveAfter);
        await tester.pumpWidget(const SizedBox.shrink());
        pending.complete(http.Response('{"competitive":{"queue":{"status":"waiting"}}}', 200));
        await tester.pump();
        expect(requests.length, leaveAfter);
        expect(tester.takeException(), isNull);
      }, () => client);
      controller.dispose();
      client.close();
    });
  }
}
