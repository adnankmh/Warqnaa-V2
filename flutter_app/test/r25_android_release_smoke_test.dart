import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R25 cumulative Android release keeps core room player contracts', () {
    expect(v170AllowedPlayerCounts('tarneeb'), const <int>[4]);
    expect(v170AllowedPlayerCounts('hand_partner'), const <int>[4]);
    expect(v170AllowedPlayerCounts('banakil'), const <int>[2, 4]);
  });
}
