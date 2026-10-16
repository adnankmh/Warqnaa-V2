import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R37 competitive arena keeps status and ranking copy legible', () {
    final source = File('lib/r12_competitive.dart').readAsStringSync();

    expect(source, contains("'WARQNAA CHAMPIONS'"));
    expect(source, contains("'SEASON LIFECYCLE'"));
    expect(source, contains("'INTEGRITY REVIEW'"));
    expect(source, contains("'TOURNAMENT BRACKETS'"));
    expect(source, contains('fontSize: 11'));
    expect(source, contains('Colors.white70'));
    expect(
      RegExp(r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])')
          .hasMatch(source),
      isFalse,
    );
  });
}
