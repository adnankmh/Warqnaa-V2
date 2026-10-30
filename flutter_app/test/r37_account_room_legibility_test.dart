import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R37 account, store, room and challenge copy stays legible', () {
    final source = File('lib/v170_global.dart').readAsStringSync();
    final bidStart = source.indexOf('class TarneebBidButtonV170');
    final bidEnd = source.indexOf('\n}', bidStart);
    final bidSource = source.substring(bidStart, bidEnd + 2);

    expect(source, contains('class ResponsiveAccountStatsV170'));
    expect(source, contains('class ProductCardV170'));
    expect(source, contains('class OpenRoomCardV170'));
    expect(source, contains('showChallengesV170'));
    expect(source, contains('class GroupInnovationHubV170'));
    expect(bidStart, greaterThanOrEqualTo(0));
    expect(bidSource, contains('fontSize:11'));
    expect(bidSource, contains('scheme.surfaceContainerHighest'));
    expect(bidSource, contains('scheme.outlineVariant'));
    expect(bidSource, contains('scheme.onSurfaceVariant'));
    expect(
      RegExp(r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])')
          .hasMatch(source),
      isFalse,
    );
  });
}
