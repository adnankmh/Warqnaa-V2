import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  final rooms = <Map<String, dynamic>>[
    {'code': 'A1', 'name': 'هاند الأصدقاء', 'game': 'Hand', 'spectators': 2},
    {'code': 'B2', 'name': 'Blue Table', 'game': 'Tarneeb', 'spectators': '9'},
    {'code': 'C3', 'name': 'Blue Friends', 'game': 'Hand', 'spectators': 9},
    {'code': 'D4', 'name': 'Room', 'game': 'Banakil', 'spectators': 'invalid'},
  ];
  Iterable<dynamic> codes(List<Map<String, dynamic>> items) =>
      items.map((item) => item['code']);

  test('live search matches Arabic, case-insensitive English and room codes', () {
    expect(codes(r287DiscoverMatches(rooms, 'هاند', replays: false)), ['A1']);
    expect(codes(r287DiscoverMatches(rooms, ' BLUE  hand ', replays: false)), ['C3']);
    expect(codes(r287DiscoverMatches(rooms, 'b2', replays: false)), ['B2']);
    expect(r287DiscoverMatches(rooms, 'missing', replays: false), isEmpty);
  });

  test('most watched is numeric, stable and leaves server order intact', () {
    expect(codes(r287DiscoverMatches(rooms, '', replays: false,
        mostWatched: true)), ['B2', 'C3', 'A1', 'D4']);
    expect(codes(rooms), ['A1', 'B2', 'C3', 'D4']);
    expect(codes(r287DiscoverMatches(rooms, '  ', replays: false)),
        ['A1', 'B2', 'C3', 'D4']);
  });

  test('replay search uses only game and room code, not private fields', () {
    final replays = <Map<String, dynamic>>[
      {'id': 1, 'game': 'Hand', 'room_code': 'R1', 'views': 3,
        'private_note': 'hidden marker'},
      {'id': 2, 'game': 'ترنيب', 'room_code': 'R2', 'views': 8},
    ];
    expect(r287DiscoverMatches(replays, 'ترنيب R2', replays: true).single['id'], 2);
    expect(r287DiscoverMatches(replays, 'hidden marker', replays: true), isEmpty);
    expect(r287DiscoverMatches(replays, '', replays: true, mostWatched: true)
        .map((item) => item['id']), [2, 1]);
  });

  test('empty records remain empty in both catalogue modes', () {
    expect(r287DiscoverMatches([], '', replays: false), isEmpty);
    expect(r287DiscoverMatches([], '', replays: true, mostWatched: true), isEmpty);
  });
}
