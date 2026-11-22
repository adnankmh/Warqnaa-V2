import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R282 blue grid uses one column for very narrow panels', () {
    expect(warqnaaBlueGridColumns(220, 1), 1);
    expect(warqnaaBlueGridColumns(249, 1), 1);
    expect(warqnaaBlueGridColumns(250, 1), 2);
  });

  test('R282 blue grid keeps normal phone and tablet layouts', () {
    expect(warqnaaBlueGridColumns(320, 1), 2);
    expect(warqnaaBlueGridColumns(390, 1), 3);
    expect(warqnaaBlueGridColumns(600, 1), 3);
  });

  test('R282 large text reduces columns without hiding destinations', () {
    expect(warqnaaBlueGridColumns(390, 1.3), 2);
    expect(warqnaaBlueGridColumns(600, 1.7), 1);
    expect(warqnaaBlueGridColumns(240, 1.7), 1);
  });

  test('R282 invalid dimensions safely use a single column', () {
    expect(warqnaaBlueGridColumns(0, 1), 1);
    expect(warqnaaBlueGridColumns(-1, 1), 1);
    expect(warqnaaBlueGridColumns(double.nan, 1), 1);
    expect(warqnaaBlueGridColumns(double.infinity, 1), 1);
    expect(warqnaaBlueGridColumns(390, double.nan), 1);
    expect(warqnaaBlueGridColumns(390, 0), 1);
  });
}
