import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R37 account, store, room and challenge copy stays legible', () {
    final source = File('lib/v170_global.dart').readAsStringSync();

    expect(source, contains('class ResponsiveAccountStatsV170'));
    expect(source, contains('class ProductCardV170'));
    expect(source, contains('class OpenRoomCardV170'));
    expect(source, contains('showChallengesV170'));
    expect(source, contains('class GroupInnovationHubV170'));
    expect(source, contains('fontSize:11,color:Colors.white70'));
    expect(
      RegExp(r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])')
          .hasMatch(source),
      isFalse,
    );
  });
}
