import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R37 R10.1 profile, booster and offer copy stays legible', () {
    final source = File('lib/r10_1_release.dart').readAsStringSync();

    expect(source, contains("key: const Key('r19-profile-identity')"));
    expect(source, contains("Text('XP'"));
    expect(source, contains('class R101CommerceShowcase'));
    expect(source, contains('class _R19StorePill'));
    expect(source, contains('fontSize: 11, color: scheme.onSurface.withValues(alpha: .68)'));

    final undersized = RegExp(
      r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])',
    );
    expect(
      undersized.hasMatch(source),
      isFalse,
      reason: 'R10.1 profile, booster, offer and store copy must remain at 11px or above.',
    );
  });
}
