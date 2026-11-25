import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

StoreProduct item(String id, String ar, String en, int price) => StoreProduct(
  id: id, category: 'cards', icon: '✦', nameAr: ar, nameEn: en,
  descriptionAr: '', descriptionEn: '', price: price,
);

void main() {
  final a = item('a', 'الأزرق', 'Ocean blue', 80);
  final b = item('b', 'الفضي', 'Silver', 20);
  final c = item('c', 'الذهبي', 'Gold', 80);
  final catalogue = [a, b, c];
  List<String> ids({String query = '',
    R286CollectionFilter filter = R286CollectionFilter.all,
    R286CollectionSort sort = R286CollectionSort.catalogue,
  }) => r286FilterCollection(
    items: catalogue, query: query, filter: filter, sort: sort,
    quantity: (p) => p.id == 'b' ? 2 : 0,
    price: (p) => p.price,
  ).map((p) => p.id).toList();

  test('collection searches both languages and trims whitespace', () {
    expect(ids(query: '  OCEAN '), ['a']);
    expect(ids(query: 'الفضي'), ['b']);
    expect(ids(query: 'unknown'), isEmpty);
  });

  test('collection filters owned and not-owned products from quantities', () {
    expect(ids(filter: R286CollectionFilter.owned), ['b']);
    expect(ids(filter: R286CollectionFilter.available), ['a', 'c']);
    expect(ids(query: 'Ocean', filter: R286CollectionFilter.owned), isEmpty);
  });

  test('collection sorts by authoritative prices and preserves source order', () {
    expect(ids(sort: R286CollectionSort.priceLow), ['b', 'a', 'c']);
    expect(ids(sort: R286CollectionSort.priceHigh), ['a', 'c', 'b']);
    expect(ids(), ['a', 'b', 'c']);
    expect(catalogue.map((p) => p.id), ['a', 'b', 'c']);
  });

  test('collection sorts by injected effective price, not list price', () {
    final result = r286FilterCollection(
      items: catalogue, query: '', filter: R286CollectionFilter.all,
      sort: R286CollectionSort.priceLow,
      quantity: (_) => 0, price: (p) => p.id == 'c' ? 1 : p.price,
    );
    expect(result.map((p) => p.id), ['c', 'b', 'a']);
  });
}
