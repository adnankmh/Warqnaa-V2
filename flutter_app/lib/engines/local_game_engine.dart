import 'dart:math';
import 'r52_rummy_rules.dart';

/// Offline/local fallback engine used by the Flutter Web/PWA build.
///
/// The authoritative online mode remains the Laravel engine. This local engine
/// keeps every curated card game playable when the app is hosted on GitHub
/// Pages or opened without a backend connection.
class LocalGameSession {
  LocalGameSession({required this.gameId, required this.humanName, this.difficulty = 'pro', this.localeCode = 'ar', this.singleRound = true, int playerCount = 4, int? seed})
      : requestedPlayerCount = playerCount,
        _random = Random(seed) {
    _setup();
  }

  final bool singleRound;
  final String gameId;
  final String humanName;
  final String difficulty;
  final String localeCode;
  final int requestedPlayerCount;
  final Random _random;

  bool get _easyAi => difficulty == 'easy';
  bool get _normalAi => difficulty == 'normal';
  bool get _masterAi => difficulty == 'master';

  static const _standardRanks = <String>[
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'J',
    'Q',
    'K',
    'A',
  ];
  static const _balootRanks = <String>['7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
  static const _suits = <String>['C', 'D', 'S', 'H'];
  static const _botNamesAr = <String>[
    'عدنان', 'بيان', 'كنان', 'جميل', 'رعد', 'عاصم', 'معتصم', 'حسام',
    'جنان', 'حور', 'جنات', 'آلاء', 'أفنان', 'شهد', 'حلا', 'شذى', 'قمر',
  ];
  static const _botNamesEn = <String>[
    'Adnan', 'Bayan', 'Kenan', 'Jameel', 'Raad', 'Asem', 'Motasem', 'Hossam',
    'Janan', 'Hoor', 'Jannat', 'Alaa', 'Afnan', 'Shahd', 'Hala', 'Shatha', 'Qamar',
  ];
  List<String> get _botNames => localeCode == 'ar' ? _botNamesAr : _botNamesEn;
  String _t(String ar, String en) => localeCode == 'ar' ? ar : en;

  final List<List<String>> _hands = <List<String>>[];
  final List<String> _deck = <String>[];
  final List<String> _discard = <String>[];
  final List<List<String>> _melds = <List<String>>[];
  final Set<int> _openedRummySeats = <int>{};
  final Map<int, int> _teamOpeningThresholds = <int, int>{0: 51, 1: 51};
  final List<String> _table = <String>[];
  final Map<int, String> _trick = <int, String>{};
  final Map<int, int> _tricksWon = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
  final Map<int, int> _scores = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
  final Map<int, List<String>> _captured = <int, List<String>>{0: <String>[], 1: <String>[]};
  final Map<int, int> _basras = <int, int>{0: 0, 1: 0};
  final List<String> _messages = <String>[];
  final List<int> _meldOwners = <int>[];
  final Map<int, int> _tarneeb400Bids = <int, int>{};
  final Set<String> _trixContractsUsed = <String>{};
  final List<int> _trixFinishOrder = <int>[];
  final Map<String, Map<String, dynamic>> _trixBoard = <String, Map<String, dynamic>>{
    for (final suit in _suits) suit: <String, dynamic>{'started': false, 'low': 11, 'high': 11},
  };
  int _kingdomOwnerSeat = 0;

  String phase = 'playing';
  String enginePhase = 'playing';
  String? trump;
  String? contract;
  int currentSeat = 0;
  int highestBid = 6;
  int? bidWinner;
  int round = 1;
  bool gameOver = false;
  String? winnerKey;
  int _lastCaptureSeat = 0;
  bool _starterDiscardPending = false;
  bool _manualRummyOrder = false;
  bool _balancingRummy = false;
  bool _rummyMustMeld = false;
  bool _rummyOpenedBeforeTurn = false;
  bool _rummyTurnMelded = false;
  bool _rummyTurnLaidOff = false;
  final List<Map<String,dynamic>> _rummyRoundResults = [];
  bool get _rummyFullFinish => !_rummyOpenedBeforeTurn && _rummyTurnMelded && !_rummyTurnLaidOff;
  num _displayScore(int value) => gameId=='banakil' ? value/2 : value;


  bool get _isRummy =>
      gameId == 'hand' ||
      gameId == 'hand_partner' ||
      gameId == 'saudi_hand' ||
      gameId == 'banakil';

  bool get _isBasra => gameId == 'basra';

  bool get _isTrix => gameId == 'trix' || gameId == 'trix_partner' || gameId == 'trix_complex';

  bool get _isTrixPartner => gameId == 'trix_partner';

  bool get _isHandPartner => gameId == 'hand_partner';

  bool get _isSyrianTarneeb => gameId == 'syrian_tarneeb';

  bool get _isTarneeb400 => gameId == 'tarneeb_400';

  bool get _isTarneebVariant => gameId == 'syrian_tarneeb' || gameId == 'tarneeb_400';

  bool get _isBaloot => gameId == 'baloot';

  int get playerCount {
    if (_isBasra) return 2;
    if (_isHandPartner) return 4;
    if (gameId == 'banakil') return requestedPlayerCount <= 2 ? 2 : 4;
    if (_isRummy) return requestedPlayerCount.clamp(2, 5).toInt();
    return 4;
  }

  void _setup() {
    _hands.clear();
    _deck.clear();
    _discard.clear();
    _melds.clear();
    _openedRummySeats.clear();
    _teamOpeningThresholds
      ..clear()
      ..addAll(<int, int>{0: 51, 1: 51});
    _table.clear();
    _trick.clear();
    _messages.clear();
    _meldOwners.clear();
    _tarneeb400Bids.clear();
    _trixContractsUsed.clear();
    _trixFinishOrder.clear();
    _resetTrixBoard();
    _kingdomOwnerSeat = 0;
    _tricksWon.updateAll((_, __) => 0);
    _scores.updateAll((_, __) => 0);
    _captured[0] = <String>[];
    _captured[1] = <String>[];
    _basras[0] = 0;
    _basras[1] = 0;
    currentSeat = 0;
    highestBid = 6;
    bidWinner = null;
    trump = null;
    contract = null;
    gameOver = false;
    winnerKey = null;
    round = 1;
    _rummyRoundResults.clear();
    _rummyMustMeld=false;
    _starterDiscardPending = false;
    _manualRummyOrder = false;

    if (_isRummy) {
      _setupRummy();
    } else if (_isBasra) {
      _setupBasra();
    } else {
      _setupTrickGame();
    }
  }

  List<String> _makeDeck({bool baloot = false, int copies = 1, bool jokers = false}) {
    final ranks = baloot ? _balootRanks : _standardRanks;
    final cards = <String>[];
    for (var copy = 0; copy < copies; copy++) {
      for (final suit in _suits) {
        for (final rank in ranks) {
          cards.add('$rank$suit');
        }
      }
    }
    if (jokers) {
      cards.add('JOKER1');
      cards.add('JOKER2');
    }
    cards.shuffle(_random);
    return cards;
  }

  void _setupTrickGame() {
    _deck.addAll(_makeDeck(baloot: _isBaloot));
    final handSize = _isBaloot ? 8 : 13;
    for (var seat = 0; seat < 4; seat++) {
      _hands.add(<String>[]);
    }
    for (var card = 0; card < handSize; card++) {
      for (var seat = 0; seat < 4; seat++) {
        _hands[seat].add(_deck.removeLast());
      }
    }
    _balancePremiumHands();
    for (final hand in _hands) {
      _sortHand(hand);
    }

    if (_isSyrianTarneeb) {
      final revealedCard = _hands[3].isNotEmpty ? _hands[3].last : 'A_H';
      trump = _oppositeSameColorSuitLocal(_cardSuit(revealedCard));
      phase = 'bidding';
      enginePhase = 'bidding';
      _messages.add(_t(
        'طرنيب سوري 41: الورقة المكشوفة ${_prettyCard(revealedCard)} والحكم ${_suitSymbol(trump!)}. أعلن طلبًا مستقلًا من 2 إلى 13.',
        'Syrian Tarneeb 41: ${_prettyCard(revealedCard)} is revealed and ${_suitSymbol(trump!)} is trump. Bid from 2 to 13.',
      ));
    } else if (_isTarneeb400) {
      phase = 'bidding';
      enginePhase = 'bidding';
      trump = 'H';
      _messages.add(_t('طرنيب 400: أعلن طلبك المستقل من 2 إلى 13، والكبة ♥ هي الحكم الثابت.', 'Tarneeb 400: bid from 2 to 13. Hearts ♥ are permanent trump.'));
    } else if (gameId == 'tarneeb') {
      phase = 'bidding';
      enginePhase = 'bidding';
      _messages.add(_t('طرنيب: ابدأ الطلب من 7 إلى 13 أو مرّر. بعد تثبيت أعلى طلب يختار صاحبه نوع الطرنيب.', 'Tarneeb: bid from 7 to 13 or pass. The highest bidder chooses trump.'));
    } else if (_isTrix) {
      phase = 'choose_contract';
      enginePhase = 'choose_contract';
      _messages.add(_t('اختر عقد الجولة ثم ابدأ اللعب.', 'Choose the round contract, then start playing.'));
    } else if (_isBaloot) {
      phase = 'choose_contract';
      enginePhase = 'choose_contract';
      _messages.add(_t('اختر صن أو حكم.', 'Choose Sun or Hokm.'));
    } else {
      phase = 'playing';
      enginePhase = 'playing';
    }
  }

  void _balancePremiumHands() {
    // Local/offline casual mode may shape a more engaging opening deal, but
    // every seat is evaluated by the same card-quality metrics. Account identity,
    // entitlements and commercial state never participate. Ranked/competition
    // rooms remain server-authoritative and never use this local shaper.
    if (!(gameId == 'tarneeb' || _isSyrianTarneeb || _isTarneeb400)) return;
    // Historical contract anchor: every seat should reach at least two
    // playable honors when a suitable symmetric casual deal is available.
    const minimumQuality = 2;

    List<List<String>>? best;
    var bestScore = -1 << 30;
    for (var attempt = 0; attempt < 512; attempt++) {
      final cards = _makeDeck();
      final candidate = List<List<String>>.generate(4, (_) => <String>[]);
      for (var card = 0; card < 13; card++) {
        for (var seat = 0; seat < 4; seat++) {
          candidate[seat].add(cards.removeLast());
        }
      }

      final honors = candidate.map(_playableHonorQuality).toList(growable: false);
      final controls = candidate.map(_controlQuality).toList(growable: false);
      final shapes = candidate.map(_bidShapeQuality).toList(growable: false);
      final minHonor = honors.reduce(min);
      final minControl = controls.reduce(min);
      final minShape = shapes.reduce(min);
      final strongSeats = <int>[
        for (var seat = 0; seat < 4; seat++)
          if (honors[seat] >= 2 || controls[seat] >= 8 || shapes[seat] >= 8) seat,
      ].length;
      final spread = _qualitySpread(<int>[
        for (var seat = 0; seat < 4; seat++)
          honors[seat] * 4 + controls[seat] * 2 + shapes[seat],
      ]);

      // Rotate a broad set of symmetric table scenarios instead of optimizing
      // one fixed pattern. Each scenario scores the whole table, never a person.
      final totalHonor = honors.fold<int>(0, (sum, value) => sum + value);
      final totalControl = controls.fold<int>(0, (sum, value) => sum + value);
      final totalShape = shapes.fold<int>(0, (sum, value) => sum + value);
      final scenario = attempt % 8;
      final scenarioBonus = switch (scenario) {
        0 => minHonor * 28, // honor-rich across the table
        1 => minShape * 22, // long-suit / bid-ready table
        2 => minControl * 16, // aces/kings/control table
        3 => strongSeats * 24, // mixed competitive table
        4 => totalHonor * 7 - spread * 2, // many playable honors
        5 => totalShape * 5 + minShape * 10, // multiple bidding shapes
        6 => totalControl * 4 + minControl * 10, // broad control strength
        _ => minHonor * 14 + minShape * 11 + minControl * 8 + strongSeats * 18, // hybrid
      };
      final score =
          minHonor * 90 +
          minControl * 24 +
          minShape * 20 +
          strongSeats * 55 +
          scenarioBonus -
          spread * 7;

      if (score > bestScore) {
        bestScore = score;
        best = candidate.map((hand) => List<String>.from(hand)).toList(growable: false);
      }
      if (minHonor >= minimumQuality && minControl >= 6 && strongSeats >= 3 && spread <= 12) {
        best = candidate;
        break;
      }
    }

    if (best == null) return;
    for (var seat = 0; seat < 4; seat++) {
      _hands[seat]
        ..clear()
        ..addAll(best[seat]);
    }
    _deck.clear();
  }

  int _qualitySpread(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce(max) - values.reduce(min);
  }

  int _controlQuality(List<String> hand) {
    var quality = 0;
    for (final suit in _suits) {
      final suited = hand.where((card) => !card.startsWith('JOKER') && _cardSuit(card) == suit).toList();
      final ranks = suited.map(_cardRank).toSet();
      if (ranks.contains('A')) quality += 4;
      if (ranks.contains('K') && suited.length >= 2) quality += 3;
      if (ranks.contains('Q') && suited.length >= 3) quality += 2;
      if (ranks.contains('J') && suited.length >= 4) quality += 1;
      if (suited.length >= 5) quality += suited.length - 4;
    }
    return quality;
  }

  int _bidShapeQuality(List<String> hand) {
    var bestSuit = 0;
    var honors = 0;
    for (final suit in _suits) {
      final suited = hand.where((card) => !card.startsWith('JOKER') && _cardSuit(card) == suit).toList();
      bestSuit = max(bestSuit, suited.length);
      for (final card in suited) {
        final rank = _cardRank(card);
        if (rank == 'A' || rank == 'K') honors += 2;
        if (rank == 'Q' || rank == 'J') honors += 1;
      }
    }
    return bestSuit + honors;
  }

  int _playableHonorQuality(List<String> hand) {
    var quality = 0;
    for (final suit in _suits) {
      final suited = hand.where((card) => !card.startsWith('JOKER') && _cardSuit(card) == suit).toList();
      final ranks = suited.map(_cardRank).toSet();
      final length = suited.length;
      if (ranks.contains('J') && length >= 5) quality++;
      if (ranks.contains('Q') && length >= 4) quality++;
      if (ranks.contains('K') && length >= 3) quality++;
      if (ranks.contains('A') && length >= 2) quality++;
    }
    return quality;
  }

  void _setupRummy() {
    _deck.addAll(_makeDeck(copies: 2, jokers: true));
    for (var seat = 0; seat < playerCount; seat++) {
      _hands.add(<String>[]);
    }
    final cardsEach = gameId == 'banakil' ? 18 : 14;
    _balancingRummy=true;
    _balanceCasualRummyHands(cardsEach);
    _balancingRummy=false;
    // The starter gets one extra card and begins by discarding. Banakil uses 18+19,
    // while Hand uses 14+15. The following turns return to draw -> meld -> discard.
    currentSeat=(round-1)%playerCount;
    _hands[currentSeat].add(_deck.removeLast());
    _rummyMustMeld=false;
    _rummyTurnMelded=false;
    _rummyTurnLaidOff=false;
    _rummyOpenedBeforeTurn=false;
    _starterDiscardPending = true;
    phase = 'discard';
    enginePhase = 'discard';
    if (gameId == 'banakil') {
      _messages.add(_t('بناكل: البادئ معه 19 ورقة ويرمي أولاً. نزّل مجموعات من 3 أوراق فأكثر دون حد أدنى.', 'Banakil: the starter has 19 cards and discards first. Meld groups of 3 or more with no opening minimum.'));
    } else {
      _messages.add(_t('هاند: البادئ معه 15 ورقة ويرمي أولاً. افتح بمجموع مجموعة أو عدة مجموعات قيمتها 51 نقطة على الأقل.', 'Hand: the starter has 15 cards and discards first. Open with one or more melds worth at least 51 points.'));
    }
    for (final hand in _hands) {
      _sortHand(hand);
    }
  }

  void _balanceCasualRummyHands(int cardsEach) {
    // Like the trick-game shaper, this is local/offline only and treats every
    // seat symmetrically. It prefers tables where most players begin with
    // useful pairs/runs/meld potential instead of one seat receiving a jackpot.
    List<List<String>>? bestHands;
    List<String>? bestDeck;
    var bestScore = -1 << 30;

    for (var attempt = 0; attempt < 480; attempt++) {
      final cards = _makeDeck(copies: 2, jokers: true);
      final candidate = List<List<String>>.generate(playerCount, (_) => <String>[]);
      for (var card = 0; card < cardsEach; card++) {
        for (var seat = 0; seat < playerCount; seat++) {
          candidate[seat].add(cards.removeLast());
        }
      }
      final qualities = candidate.map(_rummyDealQuality).toList(growable: false);
      final minimum = qualities.reduce(min);
      final strongSeats = qualities.where((value) => value >= 18).length;
      final spread = _qualitySpread(qualities);
      final totalNearRuns = candidate.fold<int>(0, (sum, hand) => sum + _nearRunQuality(hand));
      final totalPairs = candidate.fold<int>(0, (sum, hand) => sum + _pairQuality(hand));
      final totalMelds = candidate.fold<int>(
        0,
        (sum, hand) => sum + _nonOverlappingMelds(_meldSuggestions(hand),hand).length,
      );
      final totalQuality = qualities.fold<int>(0, (sum, value) => sum + value);
      final scenario = attempt % 8;
      final scenarioBonus = switch (scenario) {
        0 => minimum * 18, // raise the weakest opening hand
        1 => strongSeats * 28, // maximize the number of playable seats
        2 => totalNearRuns * 3, // run-rich table
        3 => totalPairs * 3, // set/pair-rich table
        4 => totalMelds * 16, // ready-meld table
        5 => (totalNearRuns + totalPairs) * 2 + minimum * 10, // mixed rummy shape
        6 => strongSeats * 20 + minimum * 14 - spread * 2, // close competitive table
        _ => totalQuality * 2 + minimum * 12, // broad hybrid quality
      };
      final score = minimum * 75 + strongSeats * 48 + scenarioBonus - spread * 5;
      if (score > bestScore) {
        bestScore = score;
        bestHands = candidate.map((hand) => List<String>.from(hand)).toList(growable: false);
        bestDeck = List<String>.from(cards);
      }
      if (strongSeats >= max(1, playerCount - 1) && minimum >= 14 && spread <= 18) {
        bestHands = candidate;
        bestDeck = cards;
        break;
      }
    }

    if (bestHands == null || bestDeck == null) {
      for (var card = 0; card < cardsEach; card++) {
        for (var seat = 0; seat < playerCount; seat++) {
          _hands[seat].add(_deck.removeLast());
        }
      }
      return;
    }
    for (var seat = 0; seat < playerCount; seat++) {
      _hands[seat]
        ..clear()
        ..addAll(bestHands[seat]);
    }
    _deck
      ..clear()
      ..addAll(bestDeck);
  }

  int _rummyDealQuality(List<String> hand) {
    final melds = _meldSuggestions(hand);
    final nonOverlapping = _nonOverlappingMelds(melds,hand);
    final meldPoints = nonOverlapping.fold<int>(0, (sum, meld) => sum + _rummyPoints(meld));
    final jokers = hand.where((card) => card.startsWith('JOKER')).length;
    return nonOverlapping.length * 6 +
        min(18, meldPoints ~/ 6).toInt() +
        _pairQuality(hand) +
        _nearRunQuality(hand) +
        jokers * 3;
  }

  int _pairQuality(List<String> hand) {
    final counts = <String, int>{};
    for (final card in hand.where((card) => !card.startsWith('JOKER'))) {
      final rank = _cardRank(card);
      counts[rank] = (counts[rank] ?? 0) + 1;
    }
    return counts.values.fold<int>(0, (sum, count) => sum + (count >= 2 ? min(3, count - 1).toInt() : 0));
  }

  int _nearRunQuality(List<String> hand) {
    var quality = 0;
    for (final suit in _suits) {
      final values = hand
          .where((card) => !card.startsWith('JOKER') && _cardSuit(card) == suit)
          .map((card) => _standardRanks.indexOf(_cardRank(card)))
          .where((value) => value >= 0)
          .toSet()
          .toList()
        ..sort();
      for (var i = 1; i < values.length; i++) {
        final gap = values[i] - values[i - 1];
        if (gap == 1) quality += 2;
        if (gap == 2) quality += 1;
      }
    }
    return quality;
  }

  void _setupBasra() {
    _deck.addAll(_makeDeck());
    _hands.add(<String>[]);
    _hands.add(<String>[]);
    _dealBasraHands();
    for (var i = 0; i < 4; i++) {
      _table.add(_deck.removeLast());
    }
    phase = 'playing';
    enginePhase = 'playing';
    _messages.add(_t('التقط الورق المطابق أو مجموعة تساوي قيمة ورقتك.', 'Capture a matching card or a group whose values add up to your card.'));
  }

  void _dealBasraHands() {
    for (var card = 0; card < 4 && _deck.length >= playerCount; card++) {
      for (var seat = 0; seat < 2; seat++) {
        _hands[seat].add(_deck.removeLast());
      }
    }
    _sortHand(_hands[0]);
    _sortHand(_hands[1]);
  }

  Map<String, dynamic> room() {
    return <String, dynamic>{
      'code': 'LOCAL-${gameId.toUpperCase()}',
      'local': true,
      'players': List<Map<String, dynamic>>.generate(playerCount, (index) {
        final name = index == 0 ? humanName : _botNames[index - 1];
        return <String, dynamic>{
          'key': index == 0 ? 'user:0' : 'bot:$index',
          'name': name,
          'bot': index != 0,
          'bot_level': index == 0 ? null : difficulty,
          'avatar': index == 0 ? '🦁' : const <String>['🤖','🦅','🌙','🦁','🐉'][(index - 1) % 5],
          'seat': index,
          'score': _isRummy ? _displayScore(_scores[index] ?? 0) : _scores[index] ?? 0,
        };
      }),
      'state': _publicState(),
    };
  }

  Map<String, dynamic> _publicState() {
    final state = <String, dynamic>{
      'hand': List<String>.from(_hands.isEmpty ? const <String>[] : _hands[0]),
      'legal_cards': currentSeat == 0 ? _legalCardsFor(0) : <String>[],
      'available_actions': currentSeat == 0 ? _availableActions() : <Map<String, dynamic>>[],
      'phase': phase,
      'engine_phase': enginePhase,
      'trump': trump,
      'contract': contract,
      'current_player': currentSeat == 0 ? 'user:0' : 'bot:$currentSeat',
      'trick': <String, String>{
        for (final entry in _trick.entries)
          (entry.key == 0 ? 'user:0' : 'bot:${entry.key}'): entry.value,
      },
      'table': List<String>.from(_table),
      'messages': List<String>.from(_messages.take(30)),
      'scores': <String, num>{
        for (var seat = 0; seat < playerCount; seat++)
          (seat == 0 ? 'user:0' : 'bot:$seat'): _isRummy ? _displayScore(_scores[seat] ?? 0) : _scores[seat] ?? 0,
      },
      'tarneeb400_bids': <String, int>{for (final entry in _tarneeb400Bids.entries) (entry.key == 0 ? 'user:0' : 'bot:${entry.key}'): entry.value},
      'tricks': <String, int>{
        for (var seat = 0; seat < playerCount; seat++)
          (seat == 0 ? 'user:0' : 'bot:$seat'): _tricksWon[seat] ?? 0,
      },
      'round': round,
      'game_over': gameOver,
      'winner': winnerKey,
      'deck_count': _deck.length,
      'deal_policy': 'balanced_casual_local',
      'deal_fairness': 'symmetric_all_seats',
      'discard_pile': List<String>.from(_discard),
      'rummy_must_meld': _rummyMustMeld,
      'round_results': List<Map<String,dynamic>>.from(_rummyRoundResults),
      'next_round_available': _isRummy && phase=='round_end' && !gameOver,
      'opening_required': _isRummy ? _localRummyOpeningRequired(0) : 0,
      'discard_top': _discard.isEmpty ? null : _discard.last,
      'melds': _melds.map((e) => List<String>.from(e)).toList(),
      'meld_owners': List<int>.from(_meldOwners),
      'trix_board': <String, Map<String, dynamic>>{for (final entry in _trixBoard.entries) entry.key: Map<String, dynamic>.from(entry.value)},
      'trix_finish_order': List<int>.from(_trixFinishOrder),
      'contracts_used': _trixContractsUsed.toList(growable: false),
      'basras': <String, int>{'user:0': _basras[0] ?? 0, 'bot:1': _basras[1] ?? 0},
      'captured_count': <String, int>{'user:0': _captured[0]?.length ?? 0, 'bot:1': _captured[1]?.length ?? 0},
    };
    if (_isRummy && _discard.isNotEmpty) {
      state['table'] = <String>[..._melds.expand((meld) => meld), _discard.last];
    }
    return state;
  }

  List<Map<String, dynamic>> _availableActions() {
    if (_isRummy && phase=='round_end' && !gameOver) return [{'type':'next_round'}];
    if (gameOver) {
      return <Map<String, dynamic>>[
        <String, dynamic>{'type': 'new_round', 'label': _t('إعادة اللعب', 'Play again')},
      ];
    }

    if (_isRummy) {
      if (phase == 'draw') {
        return <Map<String, dynamic>>[
          <String, dynamic>{'type': 'draw_deck'},
          if (_discard.isNotEmpty && (gameId=='banakil' || _canTakeFire(0))) <String, dynamic>{'type': 'draw_discard'},
          if (gameId == 'banakil' && _discard.length >= 2)
            <String, dynamic>{'type': 'draw_discard_stack', 'max_count': _discard.length},
          <String, dynamic>{'type': 'organize'},
        ];
      }
      final actions = <Map<String, dynamic>>[
        if (!_rummyMustMeld) for (final card in _hands[0]) <String, dynamic>{'type': 'discard', 'card': card},
        <String, dynamic>{'type': 'organize'},
      ];
      if (_starterDiscardPending) return actions;
      final suggestions = _meldSuggestions(_hands[0]);
      final openingRequired = _localRummyOpeningRequired(0);
      for (final meld in suggestions) {
        if (_localRummyOpened(0) || _rummyPoints(meld) >= openingRequired) {
          actions.add(<String, dynamic>{'type': 'meld', 'cards': meld});
        }
      }
      final multiple = _nonOverlappingMelds(suggestions);
      final multiplePoints = multiple.fold<int>(0, (sum, meld) => sum + _rummyPoints(meld));
      if (multiple.length >= 2 && (_localRummyOpened(0) || multiplePoints >= openingRequired)) {
        actions.add(<String, dynamic>{'type': 'meld_many', 'groups': multiple});
      }
      if (_localRummyOpened(0)) {
        for (var meldIndex = 0; meldIndex < _melds.length; meldIndex++) {
          final owner = _meldOwners.length > meldIndex ? _meldOwners[meldIndex] : 0;
          final sameSide = (!_isHandPartner && gameId!='banakil') || owner == 0 || owner.isEven;
          if (!sameSide) continue;
          for (final replacement in _jokerReplacements(_melds[meldIndex],_hands[0])) {
            actions.add({'type':'replace_wild','meld_index':meldIndex,'card':replacement.first,'cards':replacement});
          }
          for (final card in _hands[0]) {
            final combined = <String>[..._melds[meldIndex], card];
            if (_isValidMeld(combined)) {
              actions.add(<String, dynamic>{'type': 'layoff', 'meld_index': meldIndex, 'cards': <String>[card]});
            }
          }
        }
      }
      return actions;
    }

    if (_isBasra) {
      return <Map<String, dynamic>>[
        for (final card in _hands[0]) <String, dynamic>{'type': 'play_card', 'card': card},
      ];
    }

    if (phase == 'bidding') {
      if (_isTarneeb400 || _isSyrianTarneeb) {
        final minimum = _isSyrianTarneeb ? 2 : _tarneeb400MinimumBidLocal(0);
        return <Map<String, dynamic>>[
          for (var value = minimum; value <= 13; value++)
            <String, dynamic>{'type': 'bid', 'amount': value},
        ];
      }
      return <Map<String, dynamic>>[
        for (var value = max(7, highestBid + 1); value <= 13; value++)
          <String, dynamic>{'type': 'bid', 'amount': value},
        <String, dynamic>{'type': 'pass'},
      ];
    }
    if (phase == 'choose_trump') {
      return <Map<String, dynamic>>[
        for (final suit in _suits) <String, dynamic>{'type': 'choose_trump', 'suit': suit},
      ];
    }
    if (phase == 'choose_contract') {
      if (_isBaloot) {
        return <Map<String, dynamic>>[
          <String, dynamic>{'type': 'choose_contract', 'contract': 'sun'},
          <String, dynamic>{'type': 'choose_contract', 'contract': 'hokm'},
        ];
      }
      final values = gameId == 'trix_complex'
          ? <String>['complex', 'trix']
          : <String>['king_hearts', 'girls', 'diamonds', 'tricks', 'trix'];
      return <Map<String, dynamic>>[
        for (final value in values)
          if (!_trixContractsUsed.contains(value)) <String, dynamic>{'type': 'choose_contract', 'contract': value},
      ];
    }
    if (_isTrix && phase == 'trix_playing') {
      final legal = _legalTrixCards(0);
      return legal.isEmpty
          ? <Map<String, dynamic>>[<String, dynamic>{'type': 'pass_trix'}]
          : <Map<String, dynamic>>[for (final card in legal) <String, dynamic>{'type': 'play_card', 'card': card}];
    }
    return <Map<String, dynamic>>[
      for (final card in _legalCardsFor(0)) <String, dynamic>{'type': 'play_card', 'card': card},
    ];
  }

  Map<String, dynamic> action(String action, Map<String, dynamic>? payload) {
    if (_isRummy && action=='next_round' && phase=='round_end' && !gameOver) {
      _nextRummyRound();return room();
    }
    if (action == 'new_round') {
      _setup();
      return room();
    }
    if (gameOver) {
      return room();
    }
    // Hand/Banakil organization is a presentation action. It must never consume
    // a turn or force bots to play simply because the player rearranged cards.
    if (_isRummy && action == 'organize') {
      _rummyAction(action, payload ?? const <String, dynamic>{});
      return room();
    }
    if (currentSeat != 0) {
      _autoBotsUntilHuman();
    }

    if (_isRummy) {
      _rummyAction(action, payload ?? const <String, dynamic>{});
    } else if (_isBasra) {
      _basraAction(action, payload ?? const <String, dynamic>{});
    } else {
      _trickAction(action, payload ?? const <String, dynamic>{});
    }
    return room();
  }

  Map<String, dynamic> timeout() {
    if (gameOver) return room();
    if (_isRummy && phase=='round_end') {_nextRummyRound();return room();}
    if (currentSeat != 0) {
      _autoBotsUntilHuman();
      return room();
    }
    if (_isRummy) {
      if (phase == 'draw') {
        _rummyAction('draw_deck', const <String, dynamic>{});
      } else if (_rummyMustMeld) {
        final options=_availableActions().where((a)=>a['type']=='meld_many' || a['type']=='meld').toList();
        if(options.isNotEmpty) _rummyAction(options.first['type'] as String,options.first);
      } else if (_hands[0].isNotEmpty) {
        _rummyAction('discard', <String, dynamic>{'card': _highestCard(_hands[0])});
      }
    } else if (_isBasra) {
      if (_hands[0].isNotEmpty) {
        _basraAction('play_card', <String, dynamic>{'card': _bestBasraCard(0)});
      }
    } else if (phase == 'bidding') {
      _trickAction('bid', <String, dynamic>{'amount': _isSyrianTarneeb ? 2 : (_isTarneeb400 ? _tarneeb400MinimumBidLocal(0) : max(7, highestBid + 1))});
    } else if (phase == 'choose_trump') {
      _trickAction('choose_trump', <String, dynamic>{'suit': _bestSuit(_hands[0])});
    } else if (phase == 'choose_contract') {
      final choices = gameId == 'trix_complex'
          ? <String>['complex', 'trix']
          : <String>['tricks', 'girls', 'diamonds', 'king_hearts', 'trix'];
      final nextContract = _isBaloot
          ? 'sun'
          : choices.firstWhere((value) => !_trixContractsUsed.contains(value));
      _trickAction('choose_contract', <String, dynamic>{'contract': nextContract});
    } else {
      final legal = _legalCardsFor(0);
      if (legal.isNotEmpty) {
        _trickAction('play_card', <String, dynamic>{'card': legal.first});
      } else if (_isTrix && phase == 'trix_playing') {
        _trickAction('pass_trix', const <String, dynamic>{});
      }
    }
    return room();
  }

  void _trickAction(String action, Map<String, dynamic> payload) {
    if (phase == 'bidding') {
      if (_isTarneeb400 || _isSyrianTarneeb) {
        if (action != 'bid') throw StateError(_t('هذه اللعبة تتطلب إعلان طلب مستقل من كل لاعب.', 'Each player must make an individual bid in this game.'));
        final amount = int.tryParse(payload['amount']?.toString() ?? '') ?? 0;
        final minimum = _isSyrianTarneeb ? 2 : _tarneeb400MinimumBidLocal(0);
        if (amount < minimum || amount > 13) throw StateError(_t('الطلب المستقل غير قانوني.', 'That individual bid is not legal.'));
        _tarneeb400Bids[0] = amount;
        _messages.add(_t('$humanName أعلن $amount', '$humanName bid $amount'));
        _finishLocalBidding();
        return;
      }
      if (action == 'pass') {
        _messages.add(_t('$humanName: سكون', '$humanName: Pass'));
      } else if (action == 'bid') {
        final amount = int.tryParse(payload['amount']?.toString() ?? '') ?? 0;
        if (amount < max(7, highestBid + 1) || amount > 13) {
          throw StateError(_t('طلب غير قانوني.', 'That bid is not legal.'));
        }
        highestBid = amount;
        bidWinner = 0;
        _messages.add(_t('$humanName طلب $amount', '$humanName bid $amount'));
      } else {
        throw StateError(_t('الحركة غير متاحة في المزايدة.', 'That action is unavailable during bidding.'));
      }
      _finishLocalBidding();
      return;
    }

    if (phase == 'choose_contract') {
      if (action != 'choose_contract') {
        throw StateError(_t('اختر العقد أولاً.', 'Choose a contract first.'));
      }
      final value = payload['contract']?.toString() ?? '';
      if (_isBaloot) {
        if (value != 'sun' && value != 'hokm') {
          throw StateError(_t('اختر صن أو حكم.', 'Choose Sun or Hokm.'));
        }
        contract = value;
        if (value == 'hokm') {
          phase = 'choose_trump';
          enginePhase = 'choose_trump';
          _messages.add(_t('تم اختيار حكم؛ اختر النوع.', 'Hokm selected; choose the trump suit.'));
        } else {
          phase = 'playing';
          enginePhase = 'playing';
          trump = null;
          _messages.add(_t('بدأت جولة الصن.', 'The Sun round has started.'));
        }
      } else {
        final allowed = gameId == 'trix_complex' ? const <String>{'complex', 'trix'} : const <String>{'king_hearts', 'girls', 'diamonds', 'tricks', 'trix'};
        if (!allowed.contains(value) || _trixContractsUsed.contains(value)) {
          throw StateError(_t('العقد غير متاح في المملكة الحالية.', 'That contract is unavailable in the current kingdom.'));
        }
        contract = value;
        phase = value == 'trix' ? 'trix_playing' : 'playing';
        enginePhase = phase;
        currentSeat = _kingdomOwnerSeat;
        _messages.add(_t('العقد: ${_contractLabel(value)}', 'Contract: ${_contractLabel(value)}'));
      }
      return;
    }

    if (phase == 'choose_trump') {
      if (action != 'choose_trump') {
        throw StateError(_t('اختر نوع الحكم أولاً.', 'Choose the trump suit first.'));
      }
      final suit = payload['suit']?.toString() ?? '';
      if (!_suits.contains(suit)) {
        throw StateError(_t('نوع غير صحيح.', 'That suit is invalid.'));
      }
      trump = suit;
      phase = 'playing';
      enginePhase = 'playing';
      currentSeat = bidWinner ?? 0;
      _messages.add(_t('الحكم: ${_suitSymbol(suit)}', 'Trump: ${_suitSymbol(suit)}'));
      _autoBotsUntilHuman();
      return;
    }

    if (_isTrix && phase == 'trix_playing') {
      if (action == 'pass_trix') {
        _passTrix(0);
      } else if (action == 'play_card') {
        _playTrixCard(0, payload['card']?.toString() ?? '');
      } else {
        throw StateError(_t('اختر ورقة قابلة للتركيب أو مرّر عند عدم وجود حركة.', 'Play a legal Trix card, or pass when no move is available.'));
      }
      _autoBotsUntilHuman();
      return;
    }
    if (action != 'play_card') {
      throw StateError(_t('اختر ورقة للعب.', 'Choose a card to play.'));
    }
    final card = payload['card']?.toString() ?? '';
    _playTrickCard(0, card);
    _autoBotsUntilHuman();
  }

  int _tarneeb400MinimumBidLocal(int seat) {
    final score = _scores[seat] ?? 0;
    if (score >= 50) return 5;
    if (score >= 40) return 4;
    if (score >= 30) return 3;
    return 2;
  }

  int _tarneeb400BidPointsLocal(int bid, int currentScore) {
    final normal = <int, int>{2: 2, 3: 3, 4: 4, 5: 10, 6: 12, 7: 14, 8: 16, 9: 27, 10: 40, 11: 40, 12: 40, 13: 40};
    final advanced = <int, int>{2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 14, 8: 16, 9: 27, 10: 40, 11: 40, 12: 40, 13: 40};
    return (currentScore >= 30 ? advanced : normal)[bid] ?? bid;
  }

  void _finishLocalBidding() {
    if (_isTarneeb400 || _isSyrianTarneeb) {
      for (var seat = 1; seat < 4; seat++) {
        final minimum = _isSyrianTarneeb ? 2 : _tarneeb400MinimumBidLocal(seat);
        final strength = _handStrength(_hands[seat]);
        final declared = (minimum + (strength ~/ 70)).clamp(minimum, 8).toInt();
        _tarneeb400Bids[seat] = declared;
        _messages.add(_t('${_botNames[seat - 1]} أعلن $declared', '${_botNames[seat - 1]} bid $declared'));
      }
      var total = _tarneeb400Bids.values.fold<int>(0, (sum, value) => sum + value);
      while (total < 11) {
        final seat = _tarneeb400Bids.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
        if ((_tarneeb400Bids[seat] ?? 13) >= 13) break;
        _tarneeb400Bids[seat] = (_tarneeb400Bids[seat] ?? 2) + 1;
        total++;
      }
      final winnerEntry = _tarneeb400Bids.entries.reduce((a, b) => a.value >= b.value ? a : b);
      bidWinner = winnerEntry.key;
      highestBid = winnerEntry.value;
      if (_isTarneeb400) trump = 'H';
      phase = 'playing';
      enginePhase = 'playing';
      currentSeat = 0;
      _messages.add(_isSyrianTarneeb
          ? _t('بدأ طرنيب سوري 41: كل لاعب يُحاسب على طلبه بصورة مستقلة.', 'Syrian Tarneeb 41 started. Each player is scored against their own bid.')
          : _t('الكبة ♥ هي الحكم الثابت، وكل لاعب يُحاسب على طلبه بصورة مستقلة.', 'Hearts ♥ are permanent trump. Each player is scored against their own bid.'));
      return;
    }
    final biddingOrder = <int>[1, 2, 3];
    for (final seat in biddingOrder) {
      final strength = _handStrength(_hands[seat]);
      final suggested = 7 + (strength ~/ 55);
      if (suggested > highestBid && suggested <= 10 && _random.nextDouble() > .25) {
        highestBid = suggested;
        bidWinner = seat;
        _messages.add(_t('${_botNames[seat - 1]} طلب $suggested', '${_botNames[seat - 1]} bid $suggested'));
      } else {
        _messages.add(_t('${_botNames[seat - 1]}: سكون', '${_botNames[seat - 1]}: Pass'));
      }
    }
    bidWinner ??= _strongestSeat();
    if (highestBid < 7) {
      highestBid = 7;
    }
    if (bidWinner == 0) {
      phase = 'choose_trump';
      enginePhase = 'choose_trump';
      currentSeat = 0;
    } else {
      trump = _bestSuit(_hands[bidWinner!]);
      phase = 'playing';
      enginePhase = 'playing';
      currentSeat = bidWinner!;
      _messages.add(_t('${_botNames[bidWinner! - 1]} اختار ${_suitSymbol(trump!)}', '${_botNames[bidWinner! - 1]} chose ${_suitSymbol(trump!)}'));
      _autoBotsUntilHuman();
    }
  }

  void _playTrickCard(int seat, String card) {
    if (_isTrix && phase == 'trix_playing') {
      if (currentSeat != seat) {
        throw StateError(_t('ليس دور هذا اللاعب.', 'It is not this player’s turn.'));
      }
      _playTrixCard(seat, card);
      return;
    }
    if (phase != 'playing' || currentSeat != seat) {
      throw StateError(_t('ليس دور هذا اللاعب.', 'It is not this player’s turn.'));
    }
    final legal = _legalCardsFor(seat);
    if (!legal.contains(card)) {
      throw StateError(_t('يجب اتباع النوع المتصدر عند توفره.', 'You must follow the lead suit when possible.'));
    }
    _hands[seat].remove(card);
    _trick[seat] = card;
    _messages.add(_t('${_seatName(seat)} رمى ${_prettyCard(card)}', '${_seatName(seat)} played ${_prettyCard(card)}'));

    if (_trick.length == 4) {
      final winner = _trickWinner();
      _tricksWon[winner] = (_tricksWon[winner] ?? 0) + 1;
      _scoreTrixTrick(winner);
      _messages.add(_t('${_seatName(winner)} أخذ اللمّة', '${_seatName(winner)} won the trick'));
      _trick.clear();
      currentSeat = winner;
      if (_hands.every((hand) => hand.isEmpty)) {
        _finishTrickRound();
      }
    } else {
      currentSeat = _nextTrickSeat(seat);
    }
  }

  void _autoBotsUntilHuman() {
    var guard = 0;
    while (!gameOver && currentSeat != 0 && guard < 80) {
      if (_isRummy) {
        _runRummyBot(currentSeat);
      } else if (_isBasra) {
        _playBasraCard(currentSeat, _bestBasraCard(currentSeat));
      } else if (_isTrix && phase == 'trix_playing') {
        final legal = _legalTrixCards(currentSeat);
        if (legal.isEmpty) {
          _passTrix(currentSeat);
        } else {
          legal.sort((a, b) => _standardRanks.indexOf(_cardRank(a)).compareTo(_standardRanks.indexOf(_cardRank(b))));
          _playTrixCard(currentSeat, legal.first);
        }
      } else if (phase == 'playing') {
        final card = _bestBotTrickCard(currentSeat);
        _playTrickCard(currentSeat, card);
      } else if (_isTrix && phase == 'choose_contract') {
        final values = gameId == 'trix_complex' ? <String>['complex', 'trix'] : <String>['tricks', 'girls', 'diamonds', 'king_hearts', 'trix'];
        contract = values.firstWhere((value) => !_trixContractsUsed.contains(value));
        phase = contract == 'trix' ? 'trix_playing' : 'playing';
        enginePhase = phase;
        _messages.add(_t('${_seatName(currentSeat)} اختار ${_contractLabel(contract!)}.', '${_seatName(currentSeat)} chose ${_contractLabel(contract!)}.'));
      } else if (phase == 'choose_trump') {
        trump = _bestSuit(_hands[currentSeat]);
        phase = 'playing';
        enginePhase = 'playing';
      } else {
        break;
      }
      guard++;
    }
  }

  List<String> _legalCardsFor(int seat) {
    if (gameOver || seat >= _hands.length) {
      return <String>[];
    }
    if (_isRummy) {
      return phase == 'discard' && currentSeat == seat ? List<String>.from(_hands[seat]) : <String>[];
    }
    if (_isBasra) {
      return currentSeat == seat ? List<String>.from(_hands[seat]) : <String>[];
    }
    if (_isTrix && phase == 'trix_playing') return currentSeat == seat ? _legalTrixCards(seat) : <String>[];
    if (phase != 'playing' || currentSeat != seat) {
      return <String>[];
    }
    if (_trick.isEmpty) {
      return List<String>.from(_hands[seat]);
    }
    final leadSuit = _cardSuit(_trick.values.first);
    final sameSuit = _hands[seat].where((card) => _cardSuit(card) == leadSuit).toList();
    return sameSuit.isEmpty ? List<String>.from(_hands[seat]) : sameSuit;
  }

  int _trickWinner() {
    final leadSuit = _cardSuit(_trick.values.first);
    var winner = _trick.keys.first;
    var best = _trick.values.first;
    for (final entry in _trick.entries.skip(1)) {
      if (_beats(entry.value, best, leadSuit)) {
        winner = entry.key;
        best = entry.value;
      }
    }
    return winner;
  }

  bool _beats(String challenger, String current, String leadSuit) {
    final challengerSuit = _cardSuit(challenger);
    final currentSuit = _cardSuit(current);
    if (trump != null) {
      if (challengerSuit == trump && currentSuit != trump) {
        return true;
      }
      if (challengerSuit != trump && currentSuit == trump) {
        return false;
      }
    }
    if (challengerSuit == currentSuit) {
      return _rankPower(challenger, trumpSuit: challengerSuit == trump) >
          _rankPower(current, trumpSuit: currentSuit == trump);
    }
    return challengerSuit == leadSuit && currentSuit != leadSuit;
  }

  int _rankPower(String card, {bool trumpSuit = false}) {
    final rank = _cardRank(card);
    if (_isBaloot) {
      final order = trumpSuit && contract == 'hokm'
          ? <String>['7', '8', 'Q', 'K', '10', 'A', '9', 'J']
          : <String>['7', '8', '9', 'J', 'Q', 'K', '10', 'A'];
      return order.indexOf(rank);
    }
    return _standardRanks.indexOf(rank);
  }

  String _bestBotTrickCard(int seat) {
    final legal = _legalCardsFor(seat);
    if (legal.isEmpty) {
      return _hands[seat].first;
    }
    if (_easyAi) {
      return legal[_random.nextInt(legal.length)];
    }
    if (_normalAi && _random.nextDouble() < .18) {
      return legal[_random.nextInt(legal.length)];
    }

    if (_trick.isEmpty) {
      // Professional bots conserve trump and try to establish a long suit.
      final suitCount = <String, int>{for (final suit in _suits) suit: 0};
      for (final card in _hands[seat]) {
        suitCount[_cardSuit(card)] = (suitCount[_cardSuit(card)] ?? 0) + 1;
      }
      final preferredSuit = suitCount.entries
          .where((entry) => entry.key != trump)
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      final preferred = legal.where((card) => _cardSuit(card) == preferredSuit).toList();
      final choices = preferred.isEmpty ? legal : preferred;
      choices.sort((a, b) => _rankPower(b, trumpSuit: _cardSuit(b) == trump)
          .compareTo(_rankPower(a, trumpSuit: _cardSuit(a) == trump)));
      if (_masterAi && choices.length > 2) {
        // Lead a medium-high card to keep the absolute top card as control.
        return choices[1];
      }
      return choices.first;
    }

    final lead = _cardSuit(_trick.values.first);
    var currentWinnerSeat = _trick.keys.first;
    var currentBest = _trick.values.first;
    for (final entry in _trick.entries.skip(1)) {
      if (_beats(entry.value, currentBest, lead)) {
        currentWinnerSeat = entry.key;
        currentBest = entry.value;
      }
    }
    final partner = (seat + 2) % 4;
    final partnerWinning = currentWinnerSeat == partner;

    if (partnerWinning && (_masterAi || difficulty == 'pro')) {
      final safe = List<String>.from(legal)
        ..sort((a, b) => _rankPower(a, trumpSuit: _cardSuit(a) == trump)
            .compareTo(_rankPower(b, trumpSuit: _cardSuit(b) == trump)));
      return safe.first;
    }

    final winning = legal.where((card) => _beats(card, currentBest, lead)).toList();
    if (winning.isNotEmpty) {
      winning.sort((a, b) => _rankPower(a, trumpSuit: _cardSuit(a) == trump)
          .compareTo(_rankPower(b, trumpSuit: _cardSuit(b) == trump)));
      return winning.first;
    }
    legal.sort((a, b) => _rankPower(a, trumpSuit: _cardSuit(a) == trump)
        .compareTo(_rankPower(b, trumpSuit: _cardSuit(b) == trump)));
    return legal.first;
  }

  int _nextTrickSeat(int seat) {
    return (seat + 1) % playerCount;
  }

  void _resetTrixBoard() {
    for (final suit in _suits) {
      _trixBoard[suit] = <String, dynamic>{'started': false, 'low': 11, 'high': 11};
    }
  }

  List<String> _legalTrixCards(int seat) {
    if (!_isTrix || phase != 'trix_playing' || currentSeat != seat) return <String>[];
    return _hands[seat].where((card) {
      final suit = _cardSuit(card);
      final value = _standardRanks.indexOf(_cardRank(card)) + 2;
      final board = _trixBoard[suit] ?? const <String, dynamic>{'started': false, 'low': 11, 'high': 11};
      if (board['started'] != true) return value == 11;
      return value == (board['low'] as int) - 1 || value == (board['high'] as int) + 1;
    }).toList();
  }

  void _playTrixCard(int seat, String card) {
    if (!_legalTrixCards(seat).contains(card)) throw StateError(_t('الورقة لا تركب على سلاسل تركس الحالية.', 'That card does not fit the current Trix sequences.'));
    _hands[seat].remove(card);
    final suit = _cardSuit(card);
    final value = _standardRanks.indexOf(_cardRank(card)) + 2;
    final board = _trixBoard[suit]!;
    if (board['started'] != true) {
      _trixBoard[suit] = <String, dynamic>{'started': true, 'low': 11, 'high': 11};
    } else {
      board['low'] = min(board['low'] as int, value);
      board['high'] = max(board['high'] as int, value);
    }
    _messages.add(_t('${_seatName(seat)} ركّب ${_prettyCard(card)}', '${_seatName(seat)} placed ${_prettyCard(card)}'));
    if (_hands[seat].isEmpty && !_trixFinishOrder.contains(seat)) _trixFinishOrder.add(seat);
    if (_trixFinishOrder.length >= playerCount - 1) {
      for (var i = 0; i < playerCount; i++) {
        if (!_trixFinishOrder.contains(i)) {
          _trixFinishOrder.add(i);
        }
      }
      const awards = <int>[200, 150, 100, 50];
      for (var i = 0; i < _trixFinishOrder.length; i++) {
        final target = _trixFinishOrder[i];
        _scores[target] = (_scores[target] ?? 0) + (i < awards.length ? awards[i] : 0);
      }
      _messages.add(_t('اكتمل عقد تركس: ${_trixFinishOrder.map(_seatName).join('، ')}.', 'Trix contract complete: ${_trixFinishOrder.map(_seatName).join(', ')}.'));
      _completeTrixContract();
      return;
    }
    currentSeat = (seat + 1) % playerCount;
  }

  void _passTrix(int seat) {
    if (_legalTrixCards(seat).isNotEmpty) throw StateError(_t('لديك ورقة قانونية ويجب لعبها.', 'You have a legal card and must play it.'));
    _messages.add(_t('${_seatName(seat)} مرّر.', '${_seatName(seat)} passed.'));
    currentSeat = (seat + 1) % playerCount;
  }

  void _completeTrixContract() {
    if (contract != null) _trixContractsUsed.add(contract!);
    final required = gameId == 'trix_complex' ? 2 : 5;
    if (_trixContractsUsed.length >= required) {
      _trixContractsUsed.clear();
      _kingdomOwnerSeat = (_kingdomOwnerSeat + 1) % 4;
    }
    final maximum = gameId == 'trix_complex' ? 8 : 20;
    if (round >= maximum) {
      gameOver = true;
      phase = 'finished';
      enginePhase = 'finished';
      if (_isTrixPartner) {
        final teamA = (_scores[0] ?? 0) + (_scores[2] ?? 0);
        final teamB = (_scores[1] ?? 0) + (_scores[3] ?? 0);
        winnerKey = teamA >= teamB ? 'user:0' : 'bot:1';
      } else {
        final best = _scores.entries.reduce((a, b) => a.value >= b.value ? a : b);
        winnerKey = best.key == 0 ? 'user:0' : 'bot:${best.key}';
      }
      _messages.add(_t('انتهت جميع ممالك تركس.', 'All Trix kingdoms are complete.'));
      return;
    }
    round++;
    _dealNextTrixContract();
  }

  void _dealNextTrixContract() {
    _deck
      ..clear()
      ..addAll(_makeDeck());
    _hands
      ..clear()
      ..addAll(List<List<String>>.generate(4, (_) => <String>[]));
    for (var card = 0; card < 13; card++) {
      for (var seat = 0; seat < 4; seat++) {
        _hands[seat].add(_deck.removeLast());
      }
    }
    for (final hand in _hands) {
      _sortHand(hand);
    }
    _trick.clear();
    _tricksWon.updateAll((_, __) => 0);
    _trixFinishOrder.clear();
    _resetTrixBoard();
    contract = null;
    currentSeat = _kingdomOwnerSeat;
    phase = 'choose_contract';
    enginePhase = 'choose_contract';
    _messages.add(_t('بدأت الجولة $round من مملكة ${_seatName(_kingdomOwnerSeat)}.', 'Round $round started in ${_seatName(_kingdomOwnerSeat)}’s kingdom.'));
  }

  List<List<String>> _nonOverlappingMelds(List<List<String>> suggestions,[List<String>? sourceHand]) {
    final selected = <List<String>>[];
    final used = <String>[];
    for (final suggestion in suggestions) {
      final trial = <String>[...used, ...suggestion];
      if (_containsAll(sourceHand ?? _hands[0], trial)) {
        selected.add(List<String>.from(suggestion));
        used.addAll(suggestion);
      }
      if (selected.length == 4) break;
    }
    return selected;
  }

  void _scoreTrixTrick(int winner) {
    if (!_isTrix) {
      return;
    }
    var delta = 0;
    final cards = _trick.values.toList();
    if (contract == 'king_hearts' || contract == 'complex') {
      if (cards.contains('KH')) {
        delta -= 75;
      }
    }
    if (contract == 'girls' || contract == 'complex') {
      delta -= cards.where((card) => _cardRank(card) == 'Q').length * 25;
    }
    if (contract == 'diamonds' || contract == 'complex') {
      delta -= cards.where((card) => _cardSuit(card) == 'D').length * 10;
    }
    if (contract == 'tricks' || contract == 'complex') {
      delta -= 15;
    }
    if (contract == 'trix') {
      delta += 10;
    }
    _scores[winner] = (_scores[winner] ?? 0) + delta;
  }

  void _finishTrickRound() {
    gameOver = true;
    phase = 'finished';
    enginePhase = 'finished';
    if (_isSyrianTarneeb) {
      for (var seat = 0; seat < 4; seat++) {
        final declared = _tarneeb400Bids[seat] ?? 2;
        final won = _tricksWon[seat] ?? 0;
        _scores[seat] = (_scores[seat] ?? 0) + (won >= declared ? declared : -declared);
      }
      final teamAQualified = ((_scores[0] ?? 0) >= 41 && (_scores[2] ?? 0) > 0) || ((_scores[2] ?? 0) >= 41 && (_scores[0] ?? 0) > 0);
      final teamBQualified = ((_scores[1] ?? 0) >= 41 && (_scores[3] ?? 0) > 0) || ((_scores[3] ?? 0) >= 41 && (_scores[1] ?? 0) > 0);
      winnerKey = teamAQualified || (!teamBQualified && ((_scores[0] ?? 0) + (_scores[2] ?? 0) >= (_scores[1] ?? 0) + (_scores[3] ?? 0))) ? 'user:0' : 'bot:1';
      _messages.add(_t('طرنيب سوري 41: تم حساب طلب كل لاعب بصورة مستقلة.', 'Syrian Tarneeb 41: every player’s bid was scored independently.'));
    } else if (_isTarneeb400) {
      for (var seat = 0; seat < 4; seat++) {
        final declared = _tarneeb400Bids[seat] ?? 2;
        final won = _tricksWon[seat] ?? 0;
        final points = _tarneeb400BidPointsLocal(declared, _scores[seat] ?? 0);
        _scores[seat] = (_scores[seat] ?? 0) + (won >= declared ? points : -points);
      }
      final teamA = (_scores[0] ?? 0) + (_scores[2] ?? 0);
      final teamB = (_scores[1] ?? 0) + (_scores[3] ?? 0);
      winnerKey = teamA >= teamB ? 'user:0' : 'bot:1';
      _messages.add(_t('طرنيب 400: نقاط فريقك $teamA مقابل $teamB، مع حساب طلب كل لاعب بشكل مستقل.', 'Tarneeb 400: your team $teamA — $teamB, with every player’s bid scored independently.'));
    } else if (_isTarneebVariant && !_isSyrianTarneeb) {
      final teamA = (_tricksWon[0] ?? 0) + (_tricksWon[2] ?? 0);
      final teamB = (_tricksWon[1] ?? 0) + (_tricksWon[3] ?? 0);
      final bidderTeamA = (bidWinner ?? 0).isEven;
      final bidderTricks = bidderTeamA ? teamA : teamB;
      if (bidderTricks >= highestBid) {
        if (bidderTeamA) {
          _scores[0] = teamA;
          _scores[2] = teamA;
        } else {
          _scores[1] = teamB;
          _scores[3] = teamB;
        }
      } else {
        if (bidderTeamA) {
          _scores[0] = -highestBid;
          _scores[2] = -highestBid;
        } else {
          _scores[1] = -highestBid;
          _scores[3] = -highestBid;
        }
      }
      final humanTeamWon = teamA >= teamB;
      winnerKey = humanTeamWon ? 'user:0' : 'bot:1';
      _messages.add(_t('النتيجة: فريقك $teamA مقابل $teamB.', 'Score: your team $teamA — $teamB.'));
    } else if (_isTrix) {
      gameOver = false;
      phase = 'playing';
      enginePhase = 'playing';
      _completeTrixContract();
      return;
    } else {
      final teamA = (_tricksWon[0] ?? 0) + (_tricksWon[2] ?? 0);
      final teamB = (_tricksWon[1] ?? 0) + (_tricksWon[3] ?? 0);
      winnerKey = teamA >= teamB ? 'user:0' : 'bot:1';
      _scores[0] = teamA;
      _scores[2] = teamA;
      _scores[1] = teamB;
      _scores[3] = teamB;
      _messages.add(_t('انتهت الجولة: فريقك $teamA مقابل $teamB.', 'Round complete: your team $teamA — $teamB.'));
    }
  }

  bool _localRummyOpened(int seat) {
    if (_isHandPartner) {
      return _openedRummySeats.any((opened) => opened.isEven == seat.isEven);
    }
    return _openedRummySeats.contains(seat);
  }

  int _localRummyOpeningRequired(int seat) {
    if (gameId == 'banakil') return 0;
    if (_isHandPartner) return _teamOpeningThresholds[seat % 2] ?? 51;
    return 51;
  }

  void _recordLocalRummyOpening(int seat, int value) {
    final wasOpened = _localRummyOpened(seat);
    _openedRummySeats.add(seat);
    if (_isHandPartner && !wasOpened) {
      final otherTeam = seat.isEven ? 1 : 0;
      final current = _teamOpeningThresholds[otherTeam] ?? 51;
      _teamOpeningThresholds[otherTeam] = max(current, value + 1);
    }
  }

  void _rummyAction(String action, Map<String, dynamic> payload) {
    if (action == 'organize') {
      final requested = (payload['cards'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
      if (requested.isNotEmpty) {
        if (requested.length != _hands[0].length || !_containsAll(_hands[0], requested) || !_containsAll(requested, _hands[0])) {
          throw StateError(_t('ترتيب اليد غير صالح. لا يمكن إضافة أو حذف ورق أثناء إعادة الترتيب.', 'Invalid hand order. Cards cannot be added or removed while sorting.'));
        }
        _hands[0]
          ..clear()
          ..addAll(requested);
        _manualRummyOrder = true;
      } else {
        _manualRummyOrder = false;
        _sortHand(_hands[0]);
      }
      return;
    }
    if (phase == 'draw') {
      if (action == 'draw_deck') {
        _ensureDeckForRummy();
        if(_deck.isEmpty) throw StateError(_t('الرزمة فارغة حاليًا.','The stock is currently empty.'));
        _hands[0].add(_deck.removeLast());
      } else if (action == 'draw_discard' && _discard.isNotEmpty) {
        if(gameId!='banakil' && !_canTakeFire(0)) throw StateError(_t('اسحب من الرزمة حتى تتمكن من النزول بعد سحب النار.','Draw from stock until you can meld after taking the discard.'));
        _hands[0].add(_discard.removeLast());
      } else if (action == 'draw_discard_stack' && gameId == 'banakil' && _discard.length >= 2) {
        final requested = int.tryParse(payload['count']?.toString() ?? '') ?? 0;
        if (requested < 2 || requested > _discard.length) {
          throw StateError(_t('اختر عددًا صحيحًا من أوراق النار المتاحة.', 'Choose a valid number of discard-pile cards.'));
        }
        final start = _discard.length - requested;
        final picked = _discard.sublist(start);
        _discard.removeRange(start, _discard.length);
        _hands[0].addAll(picked);
        _messages.add(_t('$humanName سحب $requested أوراق من النار.', '$humanName took $requested cards from the discard pile.'));
      } else {
        throw StateError(_t('يجب السحب أولاً.', 'You must draw first.'));
      }
      _rummyOpenedBeforeTurn=_localRummyOpened(0);
      _rummyTurnMelded=false;_rummyTurnLaidOff=false;
      _rummyMustMeld=action=='draw_discard' && gameId!='banakil';
      phase = 'discard';
      enginePhase = 'discard';
      if (!_manualRummyOrder) _sortHand(_hands[0]);
      return;
    }
    if (_starterDiscardPending && action != 'discard' && action != 'organize') {
      throw StateError(_t('يجب رمي الورقة الإضافية أولاً.', 'Discard the extra card first.'));
    }
    if (action=='replace_wild' || action=='replace_joker') {
      final index=int.tryParse(payload['meld_index']?.toString() ?? '') ?? -1;
      final replacement=payload['cards'] is List ? (payload['cards'] as List).map((e)=>e.toString()).toList() : [payload['card']?.toString() ?? ''];
      if(!_localRummyOpened(0) || index<0 || index>=_melds.length || !_containsAll(_hands[0],replacement)) throw StateError(_t('استبدال الجوكر غير متاح.','Joker replacement is unavailable.'));
      final owner=_meldOwners[index];
      if((_isHandPartner || gameId=='banakil') && owner.isOdd) throw StateError(_t('لا يمكن تغيير مجموعة الخصم.','Cannot change an opponent meld.'));
      final combined=R52RummyRules.replaceJoker(_melds[index],replacement,banakil:gameId=='banakil');
      if(combined==null) throw StateError(_t('الاستبدال غير قانوني؛ مجموعة الورقتين تتطلب الورقتين الناقصتين.','Illegal replacement; a two-card set requires both missing cards.'));
      final joker=_melds[index].firstWhere((c)=>c.startsWith('JOKER'));
      for(final c in replacement) {_hands[0].remove(c);}
      _hands[0].add(joker);_melds[index]=combined;return;
    }
    if (action == 'meld_many') {
      final rawGroups = (payload['groups'] as List?) ?? const <dynamic>[];
      final groups = rawGroups.map((group) => (group as List).map((e) => e.toString()).toList()).toList();
      if (groups.isEmpty || groups.length > 8) throw StateError(_t('اختر مجموعتين قانونيتين على الأقل.', 'Choose at least two legal melds.'));
      final all = <String>[for (final group in groups) ...group];
      if (!_containsAll(_hands[0], all) || groups.any((group) => !_isValidMeld(group))) throw StateError(_t('إحدى مجموعات التنزيل غير قانونية.', 'One of the selected melds is not legal.'));
      final total = groups.fold<int>(0, (sum, group) => sum + _rummyPoints(group));
      final openingRequired = _localRummyOpeningRequired(0);
      if (!_localRummyOpened(0) && total < openingRequired) throw StateError(_t('مجموع النزول الأول يجب أن يبلغ $openingRequired نقطة على الأقل.', 'Your opening melds must be worth at least $openingRequired points.'));
      for (final card in all) {
        _hands[0].remove(card);
      }
      for (final group in groups) { _melds.add(group); _meldOwners.add(0); }
      _recordLocalRummyOpening(0, total);
      _rummyTurnMelded=true;_rummyMustMeld=false;
      _messages.add(_t('$humanName نزّل ${groups.length} مجموعات بقيمة إجمالية $total.', '$humanName melded ${groups.length} sets worth $total points.'));
      if (_hands[0].isEmpty) _finishRummy(0);
      return;
    }
    if (action == 'layoff') {
      final index = int.tryParse(payload['meld_index']?.toString() ?? '') ?? -1;
      final cards = (payload['cards'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
      if (!_localRummyOpened(0) || index < 0 || index >= _melds.length || cards.isEmpty || !_containsAll(_hands[0], cards)) throw StateError(_t('التركيب غير متاح.', 'Adding to that meld is unavailable.'));
      final owner = _meldOwners.length > index ? _meldOwners[index] : 0;
      final sameSide = (!_isHandPartner && gameId!='banakil') || owner == 0 || owner.isEven;
      final combined = <String>[..._melds[index], ...cards];
      if (!sameSide || !_isValidMeld(combined)) throw StateError(_t('لا يمكن تركيب هذه الأوراق على المجموعة المختارة.', 'Those cards cannot be added to the selected meld.'));
      for (final card in cards) {
        _hands[0].remove(card);
      }
      _melds[index] = combined;
      _rummyTurnLaidOff=true;
      _messages.add(_t('$humanName ركّب ${cards.length} ورقة على مجموعة موجودة.', '$humanName added ${cards.length} card(s) to an existing meld.'));
      if (_hands[0].isEmpty) _finishRummy(0);
      return;
    }
    if (action == 'meld') {
      final cards = (payload['cards'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
      if (!_isValidMeld(cards) || !_containsAll(_hands[0], cards)) {
        throw StateError(_t('المجموعة المختارة غير قانونية.', 'The selected meld is not legal.'));
      }
      final openingRequired = _localRummyOpeningRequired(0);
      final meldPoints = _rummyPoints(cards);
      if (!_localRummyOpened(0) && meldPoints < openingRequired) {
        throw StateError(_t('مجموع النزول الأول يجب أن يبلغ $openingRequired نقطة على الأقل.', 'Your opening meld must be worth at least $openingRequired points.'));
      }
      for (final card in cards) {
        _hands[0].remove(card);
      }
      _melds.add(cards);
      _meldOwners.add(0);
      _recordLocalRummyOpening(0, meldPoints);
      _rummyTurnMelded=true;_rummyMustMeld=false;
      _messages.add(_t('$humanName نزّل مجموعة من ${cards.length} أوراق بقيمة $meldPoints.', '$humanName melded ${cards.length} cards worth $meldPoints points.'));
      if (_hands[0].isEmpty) {
        _finishRummy(0);
      }
      return;
    }
    if (action != 'discard') {
      throw StateError(_t('اختر ورقة للرمي.', 'Choose a card to discard.'));
    }
    if(_rummyMustMeld) throw StateError(_t('يجب تنزيل مجموعة بعد السحب من النار قبل الرمي.','Meld after taking the discard before ending your turn.'));
    final card = payload['card']?.toString() ?? '';
    if (!_hands[0].remove(card)) {
      throw StateError(_t('الورقة غير موجودة في يدك.', 'That card is not in your hand.'));
    }
    _discard.add(card);
    _starterDiscardPending = false;
    _messages.add(_t('$humanName رمى ${_prettyCard(card)}', '$humanName discarded ${_prettyCard(card)}'));
    if (_hands[0].isEmpty) {
      _finishRummy(0);
      return;
    }
    currentSeat = 1;
    phase = 'draw';
    enginePhase = 'draw';
    _autoBotsUntilHuman();
  }

  int _rummyBotPotential(List<String> hand) {
    final groups=_nonOverlappingMelds(_meldSuggestions(hand),hand);
    return groups.fold<int>(0,(sum,group)=>sum+group.length)*35 +
      _pairQuality(hand)+_nearRunQuality(hand)-hand.length*12;
  }

  void _runRummyBot(int seat) {
    if(_starterDiscardPending) {
      final card=_smartRummyDiscard(_hands[seat]);_hands[seat].remove(card);_discard.add(card);
      _starterDiscardPending=false;currentSeat=(seat+1)%playerCount;phase='draw';enginePhase='draw';return;
    }
    final openedBefore=_localRummyOpened(seat);
    var meldedThisTurn=false;var attachedThisTurn=false;
    var take=0;
    if (!_easyAi && _discard.isNotEmpty) {
      final baseline=_rummyBotPotential(_hands[seat]);
      var best=baseline;
      for(var count=1;count<=min(gameId=='banakil'?8:1,_discard.length);count++) {
        final candidate=<String>[..._hands[seat],..._discard.sublist(_discard.length-count)];
        final groups=_nonOverlappingMelds(_meldSuggestions(candidate),candidate);
        final canOpen=_localRummyOpened(seat) || groups.fold<int>(0,(sum,group)=>sum+_rummyPoints(group))>=_localRummyOpeningRequired(seat);
        final score=_rummyBotPotential(candidate);
        if (score>best && (gameId=='banakil' || (canOpen && groups.isNotEmpty && groups.any((g)=>g.contains(_discard.last))))) {best=score;take=count;}
      }
    }
    if(take>0) {
      final start=_discard.length-take;
      _hands[seat].addAll(_discard.sublist(start));_discard.removeRange(start,_discard.length);
      _messages.add(_t('${_seatName(seat)} سحب $take من النار.','${_seatName(seat)} took $take discard cards.'));
    } else {
      _ensureDeckForRummy();
      if (_deck.isNotEmpty) _hands[seat].add(_deck.removeLast());
    }
    final groups=_nonOverlappingMelds(_meldSuggestions(_hands[seat]),_hands[seat]);
    final total=groups.fold<int>(0,(sum,group)=>sum+_rummyPoints(group));
    final threshold=_easyAi ? .72 : _normalAi ? .35 : _masterAi ? 0.0 : .10;
    if(groups.isNotEmpty && (_localRummyOpened(seat)||total>=_localRummyOpeningRequired(seat)) &&
      (take>0 || _random.nextDouble()>threshold)) {
      for(final group in groups) {
        for(final card in group) {_hands[seat].remove(card);}
        _melds.add(group);_meldOwners.add(seat);
      }
      _recordLocalRummyOpening(seat,total);
      meldedThisTurn=true;
      _messages.add(_t('${_seatName(seat)} نزّل ${groups.length} مجموعات.','${_seatName(seat)} melded ${groups.length} groups.'));
    }
    if(!_easyAi && _localRummyOpened(seat)) {
      for(final card in List<String>.from(_hands[seat])) {
        for(var index=0;index<_melds.length;index++) {
          final owner=_meldOwners[index];
          final canAttach=(!_isHandPartner && gameId!='banakil') || owner%2==seat%2;
          if(canAttach && _isValidMeld(<String>[..._melds[index],card])) {
            _melds[index].add(card);_hands[seat].remove(card);attachedThisTurn=true;break;
          }
        }
      }
    }
    if (_hands[seat].isEmpty) {_finishRummy(seat,fullHand:!openedBefore && meldedThisTurn && !attachedThisTurn);return;}
    final discard = _easyAi ? _hands[seat][_random.nextInt(_hands[seat].length)] : _smartRummyDiscard(_hands[seat]);
    _hands[seat].remove(discard);_discard.add(discard);_starterDiscardPending=false;
    _messages.add(_t('${_seatName(seat)} رمى ${_prettyCard(discard)}','${_seatName(seat)} discarded ${_prettyCard(discard)}'));
    if (_hands[seat].isEmpty) {_finishRummy(seat,fullHand:!openedBefore && meldedThisTurn && !attachedThisTurn);return;}
    currentSeat=(seat+1)%playerCount;phase='draw';enginePhase='draw';
  }

  bool _canTakeFire(int seat) {
    if(_discard.isEmpty) return false;
    final candidate=[..._hands[seat],_discard.last];
    final groups=_nonOverlappingMelds(_meldSuggestions(candidate),candidate);
    return groups.any((g)=>g.contains(_discard.last)) &&
      (_localRummyOpened(seat) || groups.fold<int>(0,(sum,g)=>sum+_rummyPoints(g))>=_localRummyOpeningRequired(seat));
  }

  List<List<String>> _jokerReplacements(List<String> meld,List<String> hand) {
    final result=<List<String>>[];
    for(final c in hand) {
      if(R52RummyRules.replaceJoker(meld,[c],banakil:gameId=='banakil')!=null) result.add([c]);
    }
    if(meld.length==3 && meld.any((c)=>c.startsWith('JOKER'))) {
      for(var a=0;a<hand.length;a++) {for(var b=a+1;b<hand.length;b++) {
        if(R52RummyRules.replaceJoker(meld,[hand[a],hand[b]],banakil:gameId=='banakil')!=null) result.add([hand[a],hand[b]]);
      }}
    }
    return result;
  }

  void _nextRummyRound() {
    round++;_hands.clear();_deck.clear();_discard.clear();_melds.clear();_meldOwners.clear();
    _openedRummySeats.clear();_teamOpeningThresholds..clear()..addAll({0:51,1:51});
    _setupRummy();_autoBotsUntilHuman();
  }

  void _finishRummy(int winner,{bool? fullHand}) {
    final full=fullHand ?? _rummyFullFinish;
    final delta=List<int>.filled(playerCount,0);
    if(gameId=='banakil') {
      final teams=List<int>.filled(2,0);final winningTeam=winner%2;
      final oppositionOpened=_meldOwners.any((seat)=>seat%2!=winningTeam);
      if(full) {teams[winningTeam]=(oppositionOpened?51:102)*2;}
      else {
        for(var i=0;i<_melds.length;i++) {teams[_meldOwners[i]%2]+=_melds[i].fold<int>(0,(sum,c)=>sum+R52RummyRules.banakilHalfPoints(c));}
        for(var seat=0;seat<playerCount;seat++) {teams[seat%2]-=_hands[seat].fold<int>(0,(sum,c)=>sum+R52RummyRules.banakilHalfPoints(c));}
        teams[winningTeam]+=40;
      }
      for(var seat=0;seat<playerCount;seat++) {delta[seat]=teams[seat%2];}
    } else {
      delta.setAll(0,R52RummyRules.handRound(hands:_hands,opened:_openedRummySeats,winner:winner,fullHand:full,partnership:_isHandPartner));
    }
    for(var seat=0;seat<playerCount;seat++) {_scores[seat]=(_scores[seat] ?? 0)+delta[seat];}
    _rummyRoundResults.add({'round':round,'winner':winner==0?'user:0':'bot:$winner','full_hand':full,
      'delta':{for(var seat=0;seat<playerCount;seat++) (seat==0?'user:0':'bot:$seat'):_displayScore(delta[seat])},
      'scores':{for(var seat=0;seat<playerCount;seat++) (seat==0?'user:0':'bot:$seat'):_displayScore(_scores[seat] ?? 0)}});
    final target=(playerCount==2?150:222)*2;
    gameOver=singleRound || (gameId=='banakil' ? _scores.values.any((v)=>v>=target) : round>=5);
    currentSeat=0;phase=gameOver?'finished':'round_end';enginePhase=phase;
    var best=winner;
    if(gameOver && !singleRound) {
      best=0;
      for(var seat=1;seat<playerCount;seat++) {
        if(gameId=='banakil' ? (_scores[seat] ?? 0)>(_scores[best] ?? 0) : (_scores[seat] ?? 0)<(_scores[best] ?? 0)) best=seat;
      }
    } else {best=winner;}
    winnerKey=(_isHandPartner || gameId=='banakil') ? (best.isEven?'user:0':'bot:1') : best==0?'user:0':'bot:$best';
    _messages.insert(0,_t('انتهت الجولة $round. نقاط الجولة: ${delta.map(_displayScore).join(' / ')}','Round $round complete. Round points: ${delta.map(_displayScore).join(' / ')}'));
  }

  String _smartRummyDiscard(List<String> hand) {
    final suggestions = _meldSuggestions(hand);
    final protected = <String>{for (final meld in suggestions) ...meld};
    final candidates = hand.where((card) => !protected.contains(card)).toList();
    final pool = candidates.isEmpty ? List<String>.from(hand) : candidates;
    int retention(String card) {
      if(card.startsWith('JOKER') || (gameId=='banakil' && _cardRank(card)=='2')) return 1000;
      var score=protected.contains(card)?100:0;
      for(final other in hand) {
        if(other==card)continue;
        if(_cardRank(card)==_cardRank(other))score+=10;
        if(_cardSuit(card)==_cardSuit(other)) {
          final gap=(_standardRanks.indexOf(_cardRank(card))-_standardRanks.indexOf(_cardRank(other))).abs();
          if(gap==1)score+=12;if(gap==2)score+=5;
        }
      }
      return score;
    }
    pool.sort((a,b)=>retention(a).compareTo(retention(b))!=0?retention(a).compareTo(retention(b)):_cardPoints(b).compareTo(_cardPoints(a)));
    return pool.first;
  }

  void _ensureDeckForRummy() {
    if (_deck.isNotEmpty) {
      return;
    }
    if (_discard.length <= 1) {
      return;
    }
    final top = _discard.removeLast();
    _deck.addAll(_discard);
    _deck.shuffle(_random);
    _discard
      ..clear()
      ..add(top);
  }

  List<List<String>> _meldSuggestions(List<String> hand) {
    if(!_balancingRummy) return R52RummyRules.suggestions(hand,banakil:gameId=='banakil');
    final suggestions = <List<String>>[];
    final byRank = <String, List<String>>{};
    for (final card in hand.where((card) => !card.startsWith('JOKER'))) {
      byRank.putIfAbsent(_cardRank(card), () => <String>[]).add(card);
    }
    for (final cards in byRank.values) {
      if (cards.length >= 3) {
        final unique=<String,String>{for(final card in cards)_cardSuit(card):card};
        if(unique.length>=3)suggestions.add(unique.values.take(4).toList());
      }
    }
    for (final suit in _suits) {
      final cards = hand.where((card) => _cardSuit(card) == suit).toList()
        ..sort((a, b) => _standardRanks.indexOf(_cardRank(a)).compareTo(_standardRanks.indexOf(_cardRank(b))));
      var run = <String>[];
      var previous = -2;
      for (final card in cards) {
        final value = _standardRanks.indexOf(_cardRank(card));
        if (value == previous + 1) {
          run.add(card);
        } else if (value != previous) {
          if (run.length >= 3) {
            suggestions.add(List<String>.from(run));
          }
          run = <String>[card];
        }
        previous = value;
      }
      if (run.length >= 3) {
        suggestions.add(List<String>.from(run));
      }
    }
    // Bots refine this list in place by opening threshold, so keep it growable.
    return suggestions.where(_isValidMeld).toList();
  }

  bool _isValidMeld(List<String> cards) => R52RummyRules.validMeld(cards,banakil:gameId=='banakil');

  int _rummyPoints(List<String> cards) => gameId=='banakil'
      ? cards.fold<int>(0,(sum,c)=>sum+R52RummyRules.banakilHalfPoints(c))
      : R52RummyRules.openingValue(cards);

  void _basraAction(String action, Map<String, dynamic> payload) {
    if (action != 'play_card') {
      throw StateError(_t('اختر ورقة للعب.', 'Choose a card to play.'));
    }
    final card = payload['card']?.toString() ?? '';
    _playBasraCard(0, card);
    _autoBotsUntilHuman();
  }

  void _playBasraCard(int seat, String card) {
    if (currentSeat != seat || !_hands[seat].remove(card)) {
      throw StateError(_t('الحركة غير قانونية.', 'That move is not legal.'));
    }
    final captured = _basraCapture(card);
    if (captured.isEmpty) {
      _table.add(card);
      _messages.add(_t('${_seatName(seat)} وضع ${_prettyCard(card)}', '${_seatName(seat)} placed ${_prettyCard(card)}'));
    } else {
      final clearsTable = captured.length == _table.length;
      for (final item in captured) {
        _table.remove(item);
      }
      _captured[seat]!.addAll(captured);
      _captured[seat]!.add(card);
      _lastCaptureSeat = seat;
      if (clearsTable && _cardRank(card) != 'J') {
        _basras[seat] = (_basras[seat] ?? 0) + (card == '7D' ? 2 : 1);
      }
      _messages.add(_t(
        '${_seatName(seat)} التقط ${captured.length} ورقة${clearsTable ? ' وسجّل باصرة' : ''}.',
        '${_seatName(seat)} captured ${captured.length} card(s)${clearsTable ? ' and scored a Basra' : ''}.',
      ));
    }
    currentSeat = (seat + 1) % 2;
    if (_hands[0].isEmpty && _hands[1].isEmpty) {
      if (_deck.isNotEmpty) {
        _dealBasraHands();
      } else {
        _finishBasra();
      }
    }
  }

  List<String> _basraCapture(String card) {
    if (_table.isEmpty) {
      return <String>[];
    }
    if (_cardRank(card) == 'J' || card == '7D') {
      return List<String>.from(_table);
    }
    final same = _table.where((item) => _cardRank(item) == _cardRank(card)).toList();
    if (same.isNotEmpty) {
      return same;
    }
    final target = _numericValue(card);
    if (target <= 10) {
      final subset = _findSubset(_table.where((item) => _numericValue(item) <= 10).toList(), target);
      if (subset.isNotEmpty) {
        return subset;
      }
    }
    return <String>[];
  }

  List<String> _findSubset(List<String> cards, int target) {
    final limit = min(cards.length, 12);
    for (var mask = 1; mask < (1 << limit); mask++) {
      var sum = 0;
      final picked = <String>[];
      for (var i = 0; i < limit; i++) {
        if ((mask & (1 << i)) != 0) {
          sum += _numericValue(cards[i]);
          picked.add(cards[i]);
        }
      }
      if (sum == target) {
        return picked;
      }
    }
    return <String>[];
  }

  String _bestBasraCard(int seat) {
    if (_easyAi) {
      return _hands[seat][_random.nextInt(_hands[seat].length)];
    }
    final ranked = <MapEntry<String, int>>[];
    for (final card in _hands[seat]) {
      final captured = _basraCapture(card);
      var value = captured.length * 10;
      if (captured.length == _table.length && captured.isNotEmpty && _cardRank(card) != 'J') value += 45;
      if (captured.contains('7D')) value += 18;
      if (captured.contains('10D')) value += 16;
      value += captured.where((item) => _cardRank(item) == 'A').length * 8;
      if (_masterAi && card == '7D') value += 6;
      ranked.add(MapEntry(card, value));
    }
    ranked.sort((a, b) => b.value.compareTo(a.value));
    if (ranked.first.value > 0) return ranked.first.key;
    final cards = List<String>.from(_hands[seat]);
    cards.sort((a, b) => _numericValue(a).compareTo(_numericValue(b)));
    return cards.first;
  }

  void _finishBasra() {
    if (_table.isNotEmpty) {
      _captured[_lastCaptureSeat]!.addAll(_table);
      _table.clear();
    }
    for (var seat = 0; seat < 2; seat++) {
      final cards = _captured[seat]!;
      var score = _basras[seat] ?? 0;
      score += cards.where((card) => _cardRank(card) == 'A').length;
      score += cards.contains('7D') ? 1 : 0;
      score += cards.contains('10D') ? 2 : 0;
      _scores[seat] = score;
    }
    if (_captured[0]!.length > _captured[1]!.length) {
      _scores[0] = (_scores[0] ?? 0) + 3;
    } else if (_captured[1]!.length > _captured[0]!.length) {
      _scores[1] = (_scores[1] ?? 0) + 3;
    }
    final diamonds0 = _captured[0]!.where((card) => _cardSuit(card) == 'D').length;
    final diamonds1 = _captured[1]!.where((card) => _cardSuit(card) == 'D').length;
    if (diamonds0 > diamonds1) {
      _scores[0] = (_scores[0] ?? 0) + 1;
    } else if (diamonds1 > diamonds0) {
      _scores[1] = (_scores[1] ?? 0) + 1;
    }
    gameOver = true;
    phase = 'finished';
    enginePhase = 'finished';
    winnerKey = (_scores[0] ?? 0) >= (_scores[1] ?? 0) ? 'user:0' : 'bot:1';
    _messages.add(_t('انتهت الجولة: أنت ${_scores[0]} — الخصم ${_scores[1]}.', 'Round complete: You ${_scores[0]} — Opponent ${_scores[1]}.'));
  }

  void _sortHand(List<String> hand) {
    const suitOrder = <String, int>{'C': 0, 'D': 1, 'S': 2, 'H': 3};
    const rankOrder = <String, int>{
      '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8,
      '9': 9, '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14,
    };
    hand.sort((a, b) {
      final aJoker = a.startsWith('JOKER');
      final bJoker = b.startsWith('JOKER');
      if (aJoker || bJoker) {
        if (aJoker && bJoker) return a.compareTo(b);
        return aJoker ? 1 : -1;
      }
      final suitCompare = (suitOrder[_cardSuit(a)] ?? 99).compareTo(suitOrder[_cardSuit(b)] ?? 99);
      if (suitCompare != 0) return suitCompare;
      return (rankOrder[_cardRank(b)] ?? 0).compareTo(rankOrder[_cardRank(a)] ?? 0);
    });
  }

  bool _containsAll(List<String> source, List<String> values) {
    final copy = List<String>.from(source);
    for (final value in values) {
      if (!copy.remove(value)) {
        return false;
      }
    }
    return true;
  }

  int _handStrength(List<String> hand) => hand.fold<int>(0, (sum, card) => sum + _cardPoints(card));

  int _strongestSeat() {
    var bestSeat = 0;
    var best = -1;
    for (var seat = 0; seat < 4; seat++) {
      final value = _handStrength(_hands[seat]);
      if (value > best) {
        best = value;
        bestSeat = seat;
      }
    }
    return bestSeat;
  }

  String _bestSuit(List<String> hand) {
    final totals = <String, int>{for (final suit in _suits) suit: 0};
    for (final card in hand) {
      if (!card.startsWith('JOKER')) {
        totals[_cardSuit(card)] = (totals[_cardSuit(card)] ?? 0) + _cardPoints(card);
      }
    }
    return totals.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _highestCard(List<String> hand) {
    final copy = List<String>.from(hand);
    copy.sort((a, b) => _cardPoints(b).compareTo(_cardPoints(a)));
    return copy.first;
  }

  int _cardPoints(String card) {
    if (card.startsWith('JOKER')) {
      return 25;
    }
    final rank = _cardRank(card);
    if (rank == 'A') return 15;
    if (rank == 'K' || rank == 'Q' || rank == 'J' || rank == '10') return 10;
    return int.tryParse(rank) ?? 0;
  }

  int _numericValue(String card) {
    final rank = _cardRank(card);
    if (rank == 'A') return 1;
    if (rank == 'J') return 11;
    if (rank == 'Q') return 12;
    if (rank == 'K') return 13;
    return int.tryParse(rank) ?? 0;
  }

  String _cardRank(String card) {
    if (card.startsWith('JOKER')) {
      return 'JOKER';
    }
    return card.substring(0, card.length - 1);
  }

  String _cardSuit(String card) {
    if (card.startsWith('JOKER')) {
      return 'X';
    }
    return card.substring(card.length - 1);
  }

  String _seatName(int seat) => seat == 0 ? humanName : _botNames[seat - 1];

  String _oppositeSameColorSuitLocal(String suit) => switch (suit) {
    'C' => 'S',
    'S' => 'C',
    'D' => 'H',
    'H' => 'D',
    _ => 'H',
  };

  String _suitSymbol(String suit) => switch (suit) {
        'C' => '♣',
        'D' => '♦',
        'S' => '♠',
        'H' => '♥',
        _ => suit,
      };

  String _prettyCard(String card) {
    if (card.startsWith('JOKER')) {
      return _t('جوكر', 'Joker');
    }
    return '${_cardRank(card)}${_suitSymbol(_cardSuit(card))}';
  }

  String _contractLabel(String value) => switch (value) {
        'king_hearts' => _t('شيخ الكبة', 'King of hearts'),
        'girls' => _t('البنات', 'Queens'),
        'diamonds' => _t('الديناري', 'Diamonds'),
        'tricks' => _t('اللطوش', 'Tricks'),
        'trix' => _t('تركس', 'Trix'),
        'complex' => _t('كمبلكس', 'Complex'),
        'sun' => _t('صن', 'Sun'),
        'hokm' => _t('حكم', 'Hokm'),
        _ => value,
      };
}
