/// One parser for the server's `A_spades`, local `AS` and visible `A♠` forms.
class WarqnaaCardIdentity {
  const WarqnaaCardIdentity(this.rank,this.suit);
  final String rank;
  final String suit;
  bool get joker => rank=='JOKER';
  String get symbol => const {'S':'♠','H':'♥','D':'♦','C':'♣'}[suit] ?? '';
  String get label => joker ? '🃏' : '$rank$symbol';
  static WarqnaaCardIdentity? parse(String input) {
    final raw=input.trim().toUpperCase();
    if(raw=='🃏' || RegExp(r'^JOKER(?:[12]|_[RB])?$').hasMatch(raw)) return const WarqnaaCardIdentity('JOKER','');
    final match=RegExp(r'^(10|[2-9AJQK])_?(SPADES|HEARTS|DIAMONDS|CLUBS|[SHDC♠♥♦♣])$').firstMatch(raw);
    if(match==null) return null;
    final suffix=match[2]!;
    final suit=const {'SPADES':'S','HEARTS':'H','DIAMONDS':'D','CLUBS':'C','♠':'S','♥':'H','♦':'D','♣':'C'}[suffix] ?? suffix;
    return WarqnaaCardIdentity(match[1]!,suit);
  }
}
