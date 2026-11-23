import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  group('Blue world adaptive destination columns', () {
    test('phone widths and standard text use stable columns', () {
      expect(warqnaaBlueGridColumns(240, 1), 1);
      expect(warqnaaBlueGridColumns(320, 1), 2);
      expect(warqnaaBlueGridColumns(390, 1), 3);
      expect(warqnaaBlueGridColumns(600, 1), 3);
    });

    test('large accessibility text reduces columns safely', () {
      expect(warqnaaBlueGridColumns(390, 1.3), 2);
      expect(warqnaaBlueGridColumns(600, 1.7), 1);
      expect(warqnaaBlueGridColumns(320, 2), 1);
    });

    test('invalid constraints always fall back to one column', () {
      expect(warqnaaBlueGridColumns(0, 1), 1);
      expect(warqnaaBlueGridColumns(-5, 1), 1);
      expect(warqnaaBlueGridColumns(double.nan, 1), 1);
      expect(warqnaaBlueGridColumns(double.infinity, 1), 1);
      expect(warqnaaBlueGridColumns(390, 0), 1);
      expect(warqnaaBlueGridColumns(390, double.nan), 1);
    });
  });
}
