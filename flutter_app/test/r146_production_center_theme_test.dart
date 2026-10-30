import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R146 production server metadata follows active theme tokens', () {
    final source = File('lib/production_v153.dart').readAsStringSync();

    for (final key in <String>[
      'r146-production-status',
      'r146-production-api',
      'r146-production-server',
    ]) {
      expect(source, contains("ValueKey('$key')"));
    }

    expect(
      RegExp(
        r"r146-production-(?:status|api|server)'[\s\S]{0,260}"
        r'color: Theme\.of\(context\)\.colorScheme\.onSurfaceVariant',
      ).allMatches(source).length,
      3,
    );
    expect(source, contains("warqnaProductionMode ? 'PRODUCTION' : 'PREVIEW'"));
    expect(source, contains(r"'API: ${c.api.baseUrl}'"));
    expect(source, contains('IconButton(onPressed: _load'));
  });
}
