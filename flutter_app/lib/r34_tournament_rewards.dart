/// R34 deterministic tournament reward policy. No payments or cash prizes.
library warqnaa_tournament_rewards;

enum TournamentCadence { daily, weekly, seasonal }
enum TournamentFormat { solo, doubles, team }

class TournamentRewardRule {
  const TournamentRewardRule({
    required this.tournamentId,
    required this.cadence,
    required this.format,
    required this.startUtc,
    required this.endUtc,
    required this.rewardCoins,
    required this.minimumParticipants,
  });

  final String tournamentId;
  final TournamentCadence cadence;
  final TournamentFormat format;
  final DateTime startUtc;
  final DateTime endUtc;
  final int rewardCoins;
  final int minimumParticipants;

  bool get isValid =>
      tournamentId.trim().isNotEmpty &&
      startUtc.isUtc &&
      endUtc.isUtc &&
      endUtc.isAfter(startUtc) &&
      rewardCoins >= 0 &&
      rewardCoins <= 100000 &&
      minimumParticipants >= 2;

  bool accepts(DateTime atUtc, int participants) =>
      isValid &&
      atUtc.isUtc &&
      !atUtc.isBefore(startUtc) &&
      atUtc.isBefore(endUtc) &&
      participants >= minimumParticipants;
}

class TournamentRewardClaim {
  const TournamentRewardClaim({
    required this.tournamentId,
    required this.playerId,
    required this.rank,
    required this.coins,
  });

  final String tournamentId;
  final String playerId;
  final int rank;
  final int coins;

  /// Stable idempotency key for server-side unique constraints.
  String get idempotencyKey => 'tournament:$tournamentId:player:$playerId';

  bool get isValid =>
      tournamentId.trim().isNotEmpty &&
      playerId.trim().isNotEmpty &&
      rank > 0 &&
      coins >= 0 &&
      coins <= 100000;
}

/// Local guard only; server must enforce unique idempotency keys transactionally.
class TournamentRewardLedger {
  final Map<String, TournamentRewardClaim> _claims = {};

  bool grant(TournamentRewardClaim claim) {
    if (!claim.isValid || _claims.containsKey(claim.idempotencyKey)) {
      return false;
    }
    _claims[claim.idempotencyKey] = claim;
    return true;
  }

  int coinsFor(String playerId) => _claims.values
      .where((claim) => claim.playerId == playerId)
      .fold<int>(0, (total, claim) => total + claim.coins);

  List<TournamentRewardClaim> get auditEntries =>
      List<TournamentRewardClaim>.unmodifiable(_claims.values);
}
