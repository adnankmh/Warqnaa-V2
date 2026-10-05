import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/engines/local_game_engine.dart';

void main() {
  const gameIds = <String>[
    'tarneeb',
    'tarneeb_400',
    'syrian_tarneeb',
    'trix',
    'trix_complex',
    'trix_partner',
    'hand',
    'hand_partner',
    'saudi_hand',
    'banakil',
    'baloot',
    'basra',
  ];

  test('R26 matrix initializes all 12 games with deterministic public state', () {
    for (var index = 0; index < gameIds.length; index++) {
      final game = LocalGameSession(
        gameId: gameIds[index],
        humanName: 'R26 QA',
        localeCode: 'en',
        seed: 2600 + index,
      );
      final state = Map<String, dynamic>.from(game.room()['state'] as Map);
      expect(state['phase'], isNotNull, reason: gameIds[index]);
      expect(state['engine_phase'], isNotNull, reason: gameIds[index]);
      expect(state['hand'], isA<List>(), reason: gameIds[index]);
      expect((state['hand'] as List), isNotEmpty, reason: gameIds[index]);
      expect(state['available_actions'], isA<List>(), reason: gameIds[index]);
      expect(state['game_over'], isFalse, reason: gameIds[index]);
    }
  });

  test('trick-game matrix rejects actions that are illegal for the current phase', () {
    for (final id in <String>['tarneeb', 'tarneeb_400', 'syrian_tarneeb']) {
      final game = LocalGameSession(gameId: id, humanName: 'R26 QA', localeCode: 'en', seed: 2620);
      expect(
        () => game.action('play_card', const <String, dynamic>{'card': 'AS'}),
        throwsA(isA<StateError>()),
        reason: '$id must not accept card play while bidding',
      );
    }

    for (final id in <String>['trix', 'trix_complex', 'trix_partner', 'baloot']) {
      final game = LocalGameSession(gameId: id, humanName: 'R26 QA', localeCode: 'en', seed: 2621);
      expect(
        () => game.action('play_card', const <String, dynamic>{'card': 'AS'}),
        throwsA(isA<StateError>()),
        reason: '$id must require contract selection before card play',
      );
    }
  });

  test('rummy matrix rejects draw before the mandatory starter discard', () {
    for (final id in <String>['hand', 'hand_partner', 'saudi_hand', 'banakil']) {
      final game = LocalGameSession(gameId: id, humanName: 'R26 QA', localeCode: 'en', seed: 2630);
      expect(
        () => game.action('draw_deck', const <String, dynamic>{}),
        throwsA(isA<StateError>()),
        reason: '$id must preserve discard-before-draw turn order',
      );
    }
  });

  test('Basra rejects a card that is not in the human hand', () {
    final game = LocalGameSession(gameId: 'basra', humanName: 'R26 QA', localeCode: 'en', seed: 2640);
    expect(
      () => game.action('play_card', const <String, dynamic>{'card': 'NOT_A_CARD'}),
      throwsA(isA<StateError>()),
    );
  });

  test('Tarneeb variants reject out-of-range bids', () {
    final tarneeb = LocalGameSession(gameId: 'tarneeb', humanName: 'R26 QA', localeCode: 'en', seed: 2650);
    expect(
      () => tarneeb.action('bid', const <String, dynamic>{'amount': 6}),
      throwsA(isA<StateError>()),
    );

    for (final id in <String>['tarneeb_400', 'syrian_tarneeb']) {
      final game = LocalGameSession(gameId: id, humanName: 'R26 QA', localeCode: 'en', seed: 2651);
      expect(
        () => game.action('bid', const <String, dynamic>{'amount': 14}),
        throwsA(isA<StateError>()),
        reason: id,
      );
    }
  });
}
