import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/r34_tournament_rewards.dart';

void main() {
  test('UTC window and minimum entrants are enforced', () {
    final start = DateTime.utc(2026, 10, 10);
    final rule = TournamentRewardRule(
      tournamentId: 'season-1',
      cadence: TournamentCadence.seasonal,
      format: TournamentFormat.doubles,
      startUtc: start,
      endUtc: start.add(const Duration(days: 7)),
      rewardCoins: 500,
      minimumParticipants: 4,
    );
    expect(rule.isValid, isTrue);
    expect(rule.accepts(start, 4), isTrue);
    expect(rule.accepts(start, 3), isFalse);
    expect(rule.accepts(start.subtract(const Duration(seconds: 1)), 4), isFalse);
    expect(rule.accepts(start.add(const Duration(days: 7)), 4), isFalse);
  });

  test('duplicate reward claims cannot mint coins twice', () {
    final ledger = TournamentRewardLedger();
    const claim = TournamentRewardClaim(
      tournamentId: 'daily-1', playerId: 'player-1', rank: 1, coins: 120);
    expect(ledger.grant(claim), isTrue);
    expect(ledger.grant(claim), isFalse);
    expect(ledger.coinsFor('player-1'), 120);
    expect(ledger.auditEntries.length, 1);
    expect(() => ledger.auditEntries.clear(), throwsUnsupportedError);
  });

  test('invalid claims and reward limits are rejected', () {
    final ledger = TournamentRewardLedger();
    const claim = TournamentRewardClaim(
      tournamentId: 'daily-1', playerId: '', rank: 0, coins: -1);
    expect(ledger.grant(claim), isFalse);
    expect(ledger.auditEntries, isEmpty);
  });
}
