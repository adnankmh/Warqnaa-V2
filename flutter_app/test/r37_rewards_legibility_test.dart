import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('R37 rewards and club surfaces keep compact copy legible', () {
    final source = File('lib/v182_rewards.dart').readAsStringSync();

    expect(source, contains("'دولاب الحظ الملكي'"));
    expect(source, contains('class LuckyWheelPageV182'));
    expect(source, contains('class ClubManagementPageV182'));
    expect(source, contains('fontSize:11'));
    expect(source, contains('fontWeight:FontWeight.w700'));
    expect(
      RegExp(r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])')
          .hasMatch(source),
      isFalse,
    );
  });
}
