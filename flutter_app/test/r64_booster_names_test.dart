import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('Seven XP boosters have the approved Arabic title and unchanged English SKUs', () {
    const expected = <String, String>{
      'booster_yellow_v183': 'Yellow Booster ×1.25',
      'booster_green_v183': 'Green Booster ×1.5',
      'booster_red_v183': 'Red Booster ×2',
      'booster_blue_v183': 'Blue Booster ×2.5',
      'booster_black_v183': 'Black Booster ×3',
      'booster_silver_v183': 'Silver Booster ×4',
      'booster_gold_v183': 'Gold Booster ×5',
    };
    final boosters = products.where((p) => expected.containsKey(p.id)).toList();
    expect(boosters, hasLength(7));
    for (final product in boosters) {
      expect(product.category, 'boost');
      expect(product.nameAr, startsWith('معزز النقاط '));
      expect(product.nameAr, isNot(contains('مسر')));
      expect(product.nameEn, expected[product.id]);
      expect(product.price, greaterThan(0));
      expect(product.multiplier, greaterThan(1));
    }
    final gift = products.firstWhere((p) => p.id == 'daily_pack_xp_15x_6h_v176');
    expect(gift.nameAr, contains('معزز النقاط'));
    expect(gift.nameEn, 'Prize Box: XP Booster ×1.5');
  });
}
