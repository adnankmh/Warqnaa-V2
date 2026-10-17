import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R37 bot and reaction customization copy stays legible', () {
    final source = File('lib/premium_v149.dart').readAsStringSync();

    expect(source, contains('class BotRosterShowcase'));
    expect(source, contains("'Warqnaa computer player'"));
    expect(source, contains("'Reaction sound'"));
    expect(source, contains('constraints: const BoxConstraints(maxWidth: 220)'));
    expect(source, contains('childAspectRatio: columns == 2 ? .70 : .74'));

    final undersized = RegExp(
      r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])',
    );
    expect(
      undersized.hasMatch(source),
      isFalse,
      reason: 'Bot, customization and reaction copy must remain at 11px or above.',
    );
    expect(
      source,
      contains('fontSize: 11, color: Colors.white70'),
      reason: 'Secondary customization copy must retain stronger contrast.',
    );
  });
}
