import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/engines/local_game_engine.dart';

void main() {
  test('Syrian Tarneeb deals 13 cards and starts bidding', () {
    final game = LocalGameSession(gameId: 'syrian_tarneeb', humanName: 'Adnan', seed: 7);
    final room = game.room();
    final state = Map<String, dynamic>.from(room['state'] as Map);
    expect((state['hand'] as List).length, 13);
    expect(state['phase'], 'bidding');
    expect((state['available_actions'] as List).isNotEmpty, isTrue);
  });

  test('Hand family starts with 15 cards, discards once, then draws normally', () {
    for (final id in <String>['hand', 'hand_partner', 'saudi_hand']) {
      final game = LocalGameSession(gameId: id, humanName: 'Adnan', seed: 11);
      final initial = Map<String, dynamic>.from(game.room()['state'] as Map);
      expect((initial['hand'] as List).length, 15, reason: id);
      expect(initial['phase'], 'discard', reason: id);
      final initialActions = initial['available_actions'] as List;
      expect(
        initialActions.any((action) => action is Map && action['type'] == 'discard'),
        isTrue,
        reason: id,
      );

      final afterStarterDiscard = Map<String, dynamic>.from(game.timeout()['state'] as Map);
      expect((afterStarterDiscard['hand'] as List).length, 14, reason: id);
      expect(afterStarterDiscard['phase'], 'draw', reason: id);
    }
  });

  test('Banakil starts with 19 cards, discards once, then returns with 18', () {
    final game = LocalGameSession(gameId: 'banakil', humanName: 'Adnan', seed: 12);
    final initial = Map<String, dynamic>.from(game.room()['state'] as Map);
    expect((initial['hand'] as List).length, 19);
    expect(initial['phase'], 'discard');

    final afterStarterDiscard = Map<String, dynamic>.from(game.timeout()['state'] as Map);
    expect((afterStarterDiscard['hand'] as List).length, 18);
    expect(afterStarterDiscard['phase'], 'draw');
  });

  test('Banakil draw and meld flow exposes one combined-meld control', () {
    Map<String, dynamic>? meldState;
    LocalGameSession? selectedGame;
    for (var seed = 0; seed < 400 && meldState == null; seed++) {
      final game = LocalGameSession(gameId: 'banakil', humanName: 'Adnan', seed: seed);
      var state = Map<String, dynamic>.from(game.room()['state'] as Map);
      final discard = (state['available_actions'] as List)
          .cast<Map>()
          .firstWhere((action) => action['type'] == 'discard');
      state = Map<String, dynamic>.from(
        game.action('discard', <String, dynamic>{'card': discard['card']})['state'] as Map,
      );
      if (state['game_over'] == true) continue;
      expect(state['phase'], 'draw');
      state = Map<String, dynamic>.from(
        game.action('draw_deck', const <String, dynamic>{})['state'] as Map,
      );
      final melds = (state['available_actions'] as List)
          .cast<Map>()
          .where((action) => action['type'] == 'meld')
          .toList();
      if (melds.isNotEmpty) {
        selectedGame = game;
        meldState = state;
      }
    }
    expect(selectedGame, isNotNull, reason: 'A deterministic Banakil hand should expose a legal meld');
    final actions = (meldState!['available_actions'] as List).cast<Map>();
    expect(
      actions.where((action) => action['type'] == 'meld_many').length,
      lessThanOrEqualTo(1),
      reason: 'The table must not render duplicate combined-meld controls',
    );

    final meld = actions.firstWhere((action) => action['type'] == 'meld');
    final beforeHand = (meldState['hand'] as List).length;
    final beforeMelds = (meldState['melds'] as List).length;
    final after = Map<String, dynamic>.from(
      selectedGame!.action('meld', <String, dynamic>{'cards': meld['cards']})['state'] as Map,
    );
    expect((after['hand'] as List).length, beforeHand - (meld['cards'] as List).length);
    expect((after['melds'] as List).length, beforeMelds + 1);
    expect(after['phase'], anyOf('discard', 'finished'));
  });

  test('Basra deals four cards to the player and four to table', () {
    final game = LocalGameSession(gameId: 'basra', humanName: 'Adnan', seed: 15);
    final state = Map<String, dynamic>.from(game.room()['state'] as Map);
    expect((state['hand'] as List).length, 4);
    expect((state['table'] as List).length, 4);
  });

  test('Trix starts with contract selection', () {
    final game = LocalGameSession(gameId: 'trix', humanName: 'Adnan', seed: 19);
    final state = Map<String, dynamic>.from(game.room()['state'] as Map);
    expect((state['hand'] as List).length, 13);
    expect(state['phase'], 'choose_contract');
  });

  test('Trix exposes and accepts an explicit pass only when no card is legal', () {
    LocalGameSession? passingGame;
    Map<String, dynamic>? passingState;
    for (var seed = 0; seed < 500 && passingGame == null; seed++) {
      final game = LocalGameSession(gameId: 'trix', humanName: 'Adnan', seed: seed);
      var room = game.action('choose_contract', const <String, dynamic>{'contract': 'trix'});
      for (var step = 0; step < 160 && room['state']['game_over'] != true; step++) {
        final state = Map<String, dynamic>.from(room['state'] as Map);
        final actions = (state['available_actions'] as List).cast<Map>();
        if (actions.any((action) => action['type'] == 'pass_trix')) {
          passingGame = game;
          passingState = state;
          break;
        }
        room = game.timeout();
      }
    }

    expect(passingGame, isNotNull, reason: 'A deterministic Trix deal must reach a blocked player');
    expect(passingState!['phase'], 'trix_playing');
    expect(passingState['legal_cards'], isEmpty);
    expect(
      (passingState['available_actions'] as List).cast<Map>().where((action) => action['type'] == 'pass_trix'),
      hasLength(1),
    );

    final beforeMessages = (passingState['messages'] as List).length;
    final after = Map<String, dynamic>.from(
      passingGame!.action('pass_trix', const <String, dynamic>{})['state'] as Map,
    );
    expect((after['messages'] as List).length, greaterThan(beforeMessages));
    expect((after['messages'] as List).join(' '), contains('مرّر'));
  });

  test('Baloot deals eight cards and offers sun or hokm', () {
    final game = LocalGameSession(gameId: 'baloot', humanName: 'Adnan', seed: 23);
    final state = Map<String, dynamic>.from(game.room()['state'] as Map);
    expect((state['hand'] as List).length, 8);
    final actions = state['available_actions'] as List;
    expect(actions.length, 2);
  });

  test('all curated non-Tarneeb engines initialize and accept a safe timeout', () {
    const ids = <String>[
      'syrian_tarneeb',
      'tarneeb_400',
      'trix',
      'trix_partner',
      'trix_complex',
      'hand',
      'hand_partner',
      'saudi_hand',
      'banakil',
      'baloot',
      'basra',
    ];
    for (var index = 0; index < ids.length; index++) {
      final game = LocalGameSession(gameId: ids[index], humanName: 'Tester', seed: 100 + index);
      final before = Map<String, dynamic>.from(game.room()['state'] as Map);
      expect(before['hand'], isA<List>());
      expect((before['hand'] as List).isNotEmpty, isTrue, reason: ids[index]);
      final after = Map<String, dynamic>.from(game.timeout()['state'] as Map);
      expect(after['phase'], isNotNull, reason: ids[index]);
      expect(after['messages'], isA<List>(), reason: ids[index]);
    }
  });

  test('English local engines keep gameplay messages in English', () {
    const ids = <String>[
      'syrian_tarneeb',
      'tarneeb_400',
      'trix',
      'trix_partner',
      'trix_complex',
      'hand',
      'hand_partner',
      'saudi_hand',
      'banakil',
      'baloot',
      'basra',
    ];
    final arabic = RegExp(r'[\u0600-\u06FF]');
    for (var index = 0; index < ids.length; index++) {
      final game = LocalGameSession(
        gameId: ids[index],
        humanName: 'Adnan',
        localeCode: 'en',
        seed: 200 + index,
      );
      var state = Map<String, dynamic>.from(game.room()['state'] as Map);
      expect(
        (state['messages'] as List).join(' '),
        isNot(matches(arabic)),
        reason: '${ids[index]} startup',
      );
      state = Map<String, dynamic>.from(game.timeout()['state'] as Map);
      expect(
        (state['messages'] as List).join(' '),
        isNot(matches(arabic)),
        reason: '${ids[index]} after action',
      );
    }

    final trix = LocalGameSession(
      gameId: 'trix',
      humanName: 'Adnan',
      localeCode: 'en',
      seed: 319,
    );
    final state = Map<String, dynamic>.from(
      trix.action('choose_contract', const {'contract': 'king_hearts'})['state'] as Map,
    );
    expect((state['messages'] as List).join(' '), contains('King of hearts'));
    expect((state['messages'] as List).join(' '), isNot(matches(arabic)));
  });

  test('Tarneeb 400 uses Hearts as the fixed trump after bidding', () {
    final game = LocalGameSession(gameId: 'tarneeb_400', humanName: 'Adnan', seed: 31);
    final state = Map<String, dynamic>.from(game.timeout()['state'] as Map);
    expect(state['trump'], 'H');
    expect(state['phase'], 'playing');
  });


  test('all AI difficulty levels initialize safely for every curated engine', () {
    const ids = <String>[
      'syrian_tarneeb', 'tarneeb_400', 'trix', 'trix_partner', 'trix_complex',
      'hand', 'hand_partner', 'saudi_hand', 'banakil', 'baloot', 'basra',
    ];
    const difficulties = <String>['easy', 'normal', 'pro', 'master'];
    for (final difficulty in difficulties) {
      for (var index = 0; index < ids.length; index++) {
        final game = LocalGameSession(gameId: ids[index], humanName: 'Tester', difficulty: difficulty, seed: 1490 + index);
        final state = Map<String, dynamic>.from(game.room()['state'] as Map);
        expect(state['hand'], isA<List>(), reason: '${ids[index]} / $difficulty');
        expect((state['hand'] as List).isNotEmpty, isTrue, reason: '${ids[index]} / $difficulty');
      }
    }
  });

  test('every curated local game can finish and restart a complete match', () {
    const ids = <String>[
      'tarneeb',
      'syrian_tarneeb',
      'tarneeb_400',
      'trix',
      'trix_partner',
      'trix_complex',
      'hand',
      'hand_partner',
      'saudi_hand',
      'banakil',
      'baloot',
      'basra',
    ];
    for (var index = 0; index < ids.length; index++) {
      final game = LocalGameSession(
        gameId: ids[index],
        humanName: 'Adnan',
        localeCode: 'en',
        difficulty: 'master',
        seed: 2400 + index,
      );
      var room = game.room();
      var steps = 0;
      while (room['state']['game_over'] != true && steps < 8000) {
        final state = Map<String, dynamic>.from(room['state'] as Map);
        if (const <String>{'hand', 'hand_partner', 'saudi_hand', 'banakil'}.contains(ids[index])) {
          final actions = (state['available_actions'] as List).cast<Map>();
          if (state['phase'] == 'draw') {
            room = game.action('draw_deck', const <String, dynamic>{});
          } else {
            final playable = actions.where(
              (action) => const <String>{'meld_many', 'meld', 'layoff'}.contains(action['type']),
            );
            final selected = playable.isNotEmpty
                ? playable.first
                : actions.firstWhere((action) => action['type'] == 'discard');
            room = game.action(
              selected['type'].toString(),
              Map<String, dynamic>.from(selected),
            );
          }
        } else {
          room = game.timeout();
        }
        steps++;
      }
      expect(room['state']['game_over'], isTrue, reason: '${ids[index]} stalled after $steps actions');
      expect(room['state']['winner'], isNotNull, reason: '${ids[index]} must publish a winner');

      final restarted = game.action('new_round', const <String, dynamic>{});
      final state = Map<String, dynamic>.from(restarted['state'] as Map);
      expect(state['game_over'], isFalse, reason: '${ids[index]} restart');
      expect(state['round'], 1, reason: '${ids[index]} restart round');
      expect(state['winner'], isNull, reason: '${ids[index]} restart winner');
      expect((state['hand'] as List).isNotEmpty, isTrue, reason: '${ids[index]} restart hand');
    }
  });

}
