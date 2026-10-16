import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R37 world and championship hubs keep compact copy legible', () {
    const paths = <String>[
      'lib/r5_world_class.dart',
      'lib/r6_4_world_championship.dart',
      'lib/r9_release.dart',
      'lib/v300_world_experience.dart',
    ];
    final sources = paths.map((path) => File(path).readAsStringSync()).toList();

    expect(sources[0], contains("'Primary Administrator'"));
    expect(sources[1], contains("'World play center'"));
    expect(sources[2], contains('class R9HomeDashboard'));
    expect(sources[2], contains("'ONLINE • API'"));
    expect(sources[3], contains('_V300HubCard'));
    expect(sources[3], contains('withValues(alpha:.74)'));

    final undersized = RegExp(
      r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])',
    );
    for (var index = 0; index < sources.length; index += 1) {
      expect(
        undersized.hasMatch(sources[index]),
        isFalse,
        reason: '${paths[index]} must keep user-facing text at 11px or above.',
      );
    }
  });
}
