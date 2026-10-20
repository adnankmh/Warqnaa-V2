import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/engines/r52_rummy_rules.dart';
import 'package:warqna_mobile/engines/local_game_engine.dart';
import 'package:warqna_mobile/models/card_identity.dart';

void main() {
  test('R52 long wild-assisted runs agree with server meld and layoff validation',() {
    const run=['2C','3C','4C','5C','6C','7C','8C','9C','10C','JC','JOKER1','KC','AC'];
    for(final banakil in [false,true]) {
      expect(R52RummyRules.validMeld(run,banakil:banakil),isTrue);
      expect(R52RummyRules.validMeld([...run,'QC'],banakil:banakil),isFalse);
      expect(R52RummyRules.validMeld(['5C','5C','6C','JOKER1'],banakil:banakil),isFalse);
      expect(R52RummyRules.validMeld(['KC','AC','3C'],banakil:banakil),isFalse);
      expect(R52RummyRules.validMeld(['AC','3C','JOKER1'],banakil:banakil),isTrue);
      final short=run.where((card)=>card!='KC').toList();
      expect(R52RummyRules.validMeld([...short,'KC'],banakil:banakil),isTrue);
    }
  });
  for(final suit in ['C','D','S','H']) {
    final long={'C':'clubs','D':'diamonds','S':'spades','H':'hearts'}[suit]!;
    for(final rank in R52RummyRules.ranks) {
      test('R52 server/local/visible $rank $suit preserve identity',(){
        final short=WarqnaaCardIdentity.parse('$rank$suit')!;
        expect(WarqnaaCardIdentity.parse('${rank}_$long')?.label,short.label);
        expect(WarqnaaCardIdentity.parse(short.label)?.suit,suit);
      });
    }
  }
  test('R52 malformed card strings do not become a false suit',(){
    for(final bad in ['', 'A<script>', '14_spades', 'JOKER99']) {expect(WarqnaaCardIdentity.parse(bad),isNull);}
    expect(WarqnaaCardIdentity.parse('JOKER1')?.label,'🃏');
  });
  test('R52 Hand opening values represent jokers and low/high aces',(){
    expect(R52RummyRules.openingValue(['AC','2C','JOKER1']),16);
    expect(R52RummyRules.openingValue(['QC','KC','JOKER1']),31);
    expect(R52RummyRules.openingValue(['KH','KD','JOKER2']),30);
    expect(R52RummyRules.validMeld(['AC','2C','3C']),isTrue);
    expect(R52RummyRules.validMeld(['KC','AC','2C']),isFalse);
  });
  test('R52 Banakil allows one joker plus one two but rejects duplicate wilds',(){
    expect(R52RummyRules.validMeld(['5C','8C','2H','JOKER1'],banakil:true),isTrue);
    expect(R52RummyRules.validMeld(['5C','8C','2H','2D'],banakil:true),isFalse);
    expect(R52RummyRules.validMeld(['5C','8C','JOKER1','JOKER2'],banakil:true),isFalse);
    expect(R52RummyRules.validMeld(['7C','7H','7S'],banakil:true),isFalse);
    expect(R52RummyRules.validMeld(['3C','3H','3S'],banakil:true),isTrue);
  });
  test('R52 recovering a pair-set joker consumes both missing natural suits',(){
    const meld=['7C','7D','JOKER1'];
    expect(R52RummyRules.replaceJoker(meld,['7H']),isNull);
    expect(R52RummyRules.replaceJoker(meld,['7H','7S']),['7C','7D','7H','7S']);
    expect(R52RummyRules.replaceJoker(meld,['7H','7H']),isNull);
    expect(R52RummyRules.replaceJoker(['4C','JOKER1','6C'],['5C']),['4C','5C','6C']);
    expect(R52RummyRules.replaceJoker(['4C','2H','6C'],['5C'],banakil:true),isNull);
  });
  test('R52 Hand penalties, winner award and full-hand multiplier follow round rules',(){
    const hands=<List<String>>[[],['AH','JOKER1'],['2S'],['KD']];
    expect(R52RummyRules.handRound(hands:hands,opened:{0,1,3},winner:0),[-30,26,102,10]);
    expect(R52RummyRules.handRound(hands:hands,opened:{0,1,3},winner:0,fullHand:true),[-60,52,204,20]);
    expect(R52RummyRules.handRound(hands:hands,opened:{0,1,3},winner:0,partnership:true),[-30,36,-30,36]);
    expect(['3C','6H','7D','AC','2S','JOKER1'].map(R52RummyRules.banakilHalfPoints).toList(),[1,1,2,2,4,8]);
  });
  test('R52 wild-assisted bot candidates are legal and use held physical cards only',(){
    const hand=['4C','6C','JOKER1','3H','3S','2D','3H'];
    final groups=R52RummyRules.suggestions(hand,banakil:true);
    expect(groups.any((g)=>g.contains('4C') && g.contains('6C') && g.contains('JOKER1')),isTrue);
    for(final group in groups) {
      expect(R52RummyRules.contains(hand,group),isTrue);
      expect(R52RummyRules.validMeld(group,banakil:true),isTrue);
    }
  });
  test('R52 full local Hand uses five scored rounds and does not auto-replay a finished match',(){
    final session=LocalGameSession(gameId:'hand',humanName:'Player',difficulty:'master',playerCount:2,seed:52,singleRound:false);
    var actions=0;
    while(!session.gameOver && actions++<2500) {
      if(session.phase=='round_end') {session.action('next_round',{});}
      else {session.timeout();}
    }
    expect(session.gameOver,isTrue,reason:'A full local Hand match must terminate within the bounded playthrough.');
    final state=session.room()['state'] as Map;
    expect(state['round_results'],hasLength(5));
    expect(session.round,5);
    final last=session.room();
    session.timeout();
    expect(session.room(),last,reason:'The completed result must wait for an explicit exit/replay choice.');
  });
}
