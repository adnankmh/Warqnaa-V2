import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R37 social world keeps user-facing typography legible', () {
    final source = File('lib/r11_social_world.dart').readAsStringSync();

    expect(source, contains("fontSize: 12, height: 1.35, color: _r11Mint"));
    expect(source, contains("fontSize: 11, height: 1.2, color: Colors.white70"));
    expect(source, contains("fontWeight: FontWeight.w900, fontSize: 12"));
    expect(source, contains("fontFamily: 'monospace', fontSize: 11, height: 1.3"));
    expect(
      RegExp(r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])')
          .hasMatch(source),
      isFalse,
    );
  });
}
