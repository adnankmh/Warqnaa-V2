/// Shared, deterministic offline rummy rules. No opponent hands, random draws,
/// wallet state or UI dependencies enter these calculations.
abstract final class R52RummyRules {
  static const ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
  static String rank(String card) => card.startsWith('JOKER') ? 'JOKER' : card.substring(0, card.length-1);
  static String suit(String card) => card.startsWith('JOKER') ? '' : card.substring(card.length-1);
  static bool wild(String card, bool banakil) => rank(card)=='JOKER' || (banakil && rank(card)=='2');

  static bool validMeld(List<String> cards, {bool banakil=false}) {
    if(cards.length<3 || cards.length>13) return false;
    final jokers=cards.where((c)=>rank(c)=='JOKER').length;
    final twos=banakil ? cards.where((c)=>rank(c)=='2').length : 0;
    if(banakil && (jokers>1 || twos>1)) return false;
    final natural=cards.where((c)=>!wild(c,banakil)).toList();
    if(natural.length<2) return false;
    final wilds=jokers+twos;
    if(natural.every((c)=>rank(c)==rank(natural.first))) {
      return (!banakil || ['3','A'].contains(rank(natural.first))) &&
        natural.map(suit).toSet().length==natural.length && cards.length<=4;
    }
    if(natural.map(suit).toSet().length!=1) return false;
    final values=natural.map((c)=>ranks.indexOf(rank(c))+2).toList();
    if(values.any((v)=>v<2) || values.toSet().length!=values.length) return false;
    for(final aceLow in [false,true]) {
      final ordered=values.map((v)=>aceLow && v==14 ? 1 : v).toList()..sort();
      final gaps=ordered.last-ordered.first+1-ordered.length;
      if(gaps<=wilds && cards.length<=13 && ordered.last-ordered.first+1<=13) return true;
    }
    return false;
  }

  static int handPoints(String card) {
    final r=rank(card);
    if(r=='JOKER') return 15;
    if(r=='A') return 11;
    return int.tryParse(r) ?? 10;
  }

  /// Banakil uses half points; keep integer half-point units internally.
  static int banakilHalfPoints(String card) {
    final r=rank(card);
    if(r=='JOKER') return 8;
    if(r=='2') return 4;
    return ['3','4','5','6'].contains(r) ? 1 : 2;
  }

  static int openingValue(List<String> cards) {
    final natural=cards.where((c)=>rank(c)!='JOKER').toList();
    final jokers=cards.length-natural.length;
    if(jokers==0) return natural.fold(0,(sum,c)=>sum+handPoints(c));
    if(natural.isEmpty) return 0;
    final naturalSum=natural.fold<int>(0,(sum,c)=>sum+handPoints(c));
    if(natural.every((c)=>rank(c)==rank(natural.first))) return naturalSum+jokers*handPoints(natural.first);
    // Select a legal run assignment, so A-2-Joker is valued as A-2-3,
    // while Q-K-Joker is Q-K-A. Wild cards score the rank they represent.
    var best=-1;
    for(final lowAce in [false,true]) {
      final values=natural.map((c){final v=ranks.indexOf(rank(c))+2;return lowAce && v==14 ? 1 : v;}).toSet();
      for(var start=1;start+cards.length-1<=14;start++) {
        final end=start+cards.length-1;
        if(values.any((v)=>v<start || v>end)) continue;
        if(!lowAce && start==1 || lowAce && end==14) continue;
        var total=naturalSum;
        for(var v=start;v<=end;v++) {
          if(!values.contains(v)) total+=v==1 || v==14 ? 11 : v>10 ? 10 : v;
        }
        if(total>best) best=total;
      }
    }
    return best<0 ? naturalSum : best;
  }

  static bool contains(List<String> hand,List<String> selected) {
    final remaining=List<String>.from(hand);
    for(final card in selected) {if(!remaining.remove(card)) return false;}
    return true;
  }

  /// Returns the complete replacement meld; a 2-natural-card set needs BOTH
  /// missing suits before its joker can be recovered.
  static List<String>? replaceJoker(List<String> meld,List<String> cards,{bool banakil=false}) {
    if(cards.isEmpty || cards.any((c)=>wild(c,banakil))) return null;
    final joker=meld.indexWhere((c)=>rank(c)=='JOKER');
    if(joker<0) return null;
    final natural=meld.where((c)=>!wild(c,banakil)).toList();
    final pairSet=meld.length==3 && natural.length==2 && rank(natural[0])==rank(natural[1]);
    if(cards.length!=(pairSet?2:1)) return null;
    final result=List<String>.from(meld);
    if(pairSet) {result.removeAt(joker);result.addAll(cards);}
    else {result[joker]=cards.first;}
    return validMeld(result,banakil:banakil) ? result : null;
  }

  /// Stable, bounded candidate generation includes wild-assisted runs/sets.
  static List<List<String>> suggestions(List<String> hand,{bool banakil=false}) {
    final result=<List<String>>[];
    final seen=<String>{};
    void add(List<String> cards) {
      final sorted=List<String>.from(cards)..sort();
      if(contains(hand,cards) && validMeld(cards,banakil:banakil) && seen.add(sorted.join('|'))) result.add(cards);
    }
    final wilds=hand.where((c)=>wild(c,banakil)).toList();
    final wildChoices=<List<String>>[[]];
    for(final w in wilds) {wildChoices.add([w]);}
    if(wilds.length>1) {
      for(var a=0;a<wilds.length;a++) {for(var b=a+1;b<wilds.length;b++) {wildChoices.add([wilds[a],wilds[b]]);}}
    }
    final naturals=hand.where((c)=>!wild(c,banakil)).toList();
    for(final r in ranks) {
      if(banakil && !['3','A'].contains(r)) continue;
      final unique=<String,String>{for(final c in naturals.where((c)=>rank(c)==r)) suit(c):c}.values.toList();
      for(var mask=1;mask<(1<<unique.length);mask++) {
        final chosen=[for(var i=0;i<unique.length;i++) if((mask & (1<<i))!=0) unique[i]];
        for(final ws in wildChoices) {add([...chosen,...ws]);}
      }
    }
    for(final s in ['C','D','S','H']) {
      for(final aceLow in [false,true]) {
        final byValue=<int,String>{};
        for(final c in naturals.where((c)=>suit(c)==s)) {
          final value=ranks.indexOf(rank(c))+2;
          byValue[aceLow && value==14 ? 1 : value]=c;
        }
        for(var start=aceLow?1:2;start<=12;start++) {
          for(var end=start+2;end<=(aceLow?13:14) && end-start<13;end++) {
            final chosen=[for(var v=start;v<=end;v++) if(byValue.containsKey(v)) byValue[v]!];
            final missing=end-start+1-chosen.length;
            if(missing>2 || chosen.length<2) continue;
            for(final ws in wildChoices.where((w)=>w.length==missing)) {add([...chosen,...ws]);}
          }
        }
      }
    }
    result.sort((a,b)=>b.length.compareTo(a.length));
    return result;
  }

  static List<int> handRound({required List<List<String>> hands,required Set<int> opened,required int winner,bool fullHand=false,bool partnership=false}) {
    final multiplier=fullHand?2:1;
    final scores=List<int>.filled(hands.length,0);
    for(var seat=0;seat<hands.length;seat++) {
      if(partnership && seat%2==winner%2) {scores[seat]=-30*multiplier;continue;}
      scores[seat]=seat==winner ? -30*multiplier :
        (hands[seat].fold<int>(0,(sum,c)=>sum+handPoints(c))+(opened.contains(seat)?0:100))*multiplier;
    }
    if(partnership) {
      for(var team=0;team<2;team++) {
        final total=team==winner%2 ? -30*multiplier :
          [for(var seat=team;seat<hands.length;seat+=2) scores[seat]].fold<int>(0,(sum,s)=>sum+s);
        for(var seat=team;seat<hands.length;seat+=2) {scores[seat]=total;}
      }
    }
    return scores;
  }
}
