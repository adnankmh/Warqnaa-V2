import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R37 production center status and session copy stays legible', () {
    final source = File('lib/production_v153.dart').readAsStringSync();

    expect(source, contains("t('productionCenter')"));
    expect(source, contains("warqnaProductionMode ? 'PRODUCTION' : 'PREVIEW'"));
    expect(source, contains("'API: ${c.api.baseUrl}'"));
    expect(source, contains("'الجلسات النشطة'"));
    expect(source, contains('fontSize: 11, color: Colors.white70'));

    final undersized = RegExp(
      r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])',
    );
    expect(
      undersized.hasMatch(source),
      isFalse,
      reason: 'Production status, API and session copy must remain at 11px or above.',
    );
  });
}
