part of 'main.dart';

String r52CardLabel(String raw) => WarqnaaCardIdentity.parse(raw)?.label ?? raw;

bool r52PlayerWon(Map<String,dynamic> state,{required String you,required List<dynamic> players}) {
  final winner=state['overall_winner'] ?? state['winner'];
  if(winner is List && winner.contains(you))return true;
  if(winner?.toString()==you)return true;
  final rawTeam=(state['overall_winner_team'] ?? state['winner_team'] ?? winner)?.toString();
  final team=switch(rawTeam){'0'=>'teamA','1'=>'teamB','teamA'||'teamB'=>rawTeam,_=>null};
  if(team==null)return false;
  final teams=state['teams'];
  if(teams is Map && teams[team] is List)return (teams[team] as List).contains(you);
  for(var i=0;i<players.length;i++) {
    final player=players[i];
    if(player is Map && player['key']?.toString()==you) {
      final seat=int.tryParse(player['seat']?.toString() ?? '') ?? i;
      return (seat.isEven?'teamA':'teamB')==team;
    }
  }
  return false;
}

// V173 source tables are 1280x720/683. The explicit R48 card-back variants
// and original V021 card backs are already portrait and stay upright.
int r52CardBackQuarterTurns(String asset) => asset.startsWith('assets/optimized/r10/tables/v173/') ? 1 : 0;

/// Catalogue art is clipped at the playing surface, never placed on an opaque
/// rectangular felt backdrop. R48's approved alpha artwork keeps its own path.
class R52CatalogTableArt extends StatelessWidget {
  const R52CatalogTableArt({super.key,required this.image,required this.showcase});
  final ImageProvider image;
  final bool showcase;
  @override
  Widget build(BuildContext context)=>LayoutBuilder(builder:(context,box)=>ClipPath(
    key:const ValueKey('r52-catalog-table-cutout'),
    clipper:R52TableOutline(showcase:showcase),
    child:Image(image:image,fit:box.maxHeight>box.maxWidth ? BoxFit.cover : BoxFit.fill,
      filterQuality:FilterQuality.high,excludeFromSemantics:true)));
}

class R52TableOutline extends CustomClipper<Path> {
  const R52TableOutline({required this.showcase});
  final bool showcase;
  @override
  Path getClip(Size size) {
    final vertical=size.height>size.width;
    final inset=math.min(size.width,size.height)*.006;
    // Showcase source sheets contain a thin neighbouring strip above the table.
    final top=showcase && !vertical ? size.height*.085 : inset;
    final radius=math.min(size.width,size.height)*(showcase ? .40 : .045);
    return Path()..addRRect(RRect.fromRectAndRadius(
      Rect.fromLTRB(inset,top,size.width-inset,size.height-inset),Radius.circular(radius)));
  }
  @override bool shouldReclip(covariant R52TableOutline oldClipper)=>showcase!=oldClipper.showcase;
}

Future<void> watchVerifiedRewardedAdR52(BuildContext context,AppController controller) async {
  final ar=controller.localeCode=='ar';
  if(kIsWeb || controller.activeGame!=null) {
    showToast(context,ar?'الإعلان المكافئ متاح في تطبيق الهاتف خارج المباراة.':'Rewarded ads are available in the mobile app outside a match.');return;
  }
  try {
    final session=await controller.api.startRewardedAdR52();
    final id=session['session_id']?.toString();final user=session['user_id']?.toString();
    if(id==null || user==null) throw StateError(ar?'تعذّر بدء الإعلان.':'Unable to start the ad.');
    final earned=await RewardedAds.show(userId:user,customData:id);
    if(!context.mounted)return;
    if(!earned) {showToast(context,ar?'الإعلان غير متاح الآن.':'The ad is unavailable right now.');return;}
    Map<String,dynamic> result={};
    for(var attempt=0;attempt<5;attempt++) {
      result=await controller.api.rewardedAdStatusR52(id);
      if(result['status']!='pending')break;
      await Future<void>.delayed(const Duration(seconds:1));
      if(!context.mounted)return;
    }
    if(!context.mounted)return;
    if(result['status']=='rewarded') {
      final wallet=result['wallet'];final profile=result['profile'];
      if(wallet is Map) controller.coins=BigInt.tryParse(wallet['tokens']?.toString() ?? '') ?? controller.coins;
      if(profile is Map) {
        controller.level=int.tryParse(profile['level']?.toString() ?? '') ?? controller.level;
        final total=int.tryParse(profile['xp']?.toString() ?? '');
        if(total!=null)controller.xp=controller.xpProgressFromTotal(total,controller.level);
        controller.xpNext=controller.xpNeededForLevel(controller.level);
      }
      await controller._save();controller.refreshUi();
      if(context.mounted)showToast(context,ar?'تم التحقق: 50 توكن و15 XP.':'Verified: 50 tokens and 15 XP.');
    } else {
      showToast(context,ar?'المكافأة قيد التحقق على الخادم؛ ستظهر في رصيدك عند اعتمادها.':'Your reward is awaiting server verification and will appear in your balance once confirmed.');
    }
  } catch(error) {
    if(context.mounted)showToast(context,friendlyErrorMessage(error,controller.localeCode));
  }
}

class R52RoundScoreCard extends StatelessWidget {
  const R52RoundScoreCard({super.key,required this.state,required this.players,required this.ar});
  final Map<String,dynamic> state;
  final List<dynamic> players;
  final bool ar;
  @override
  Widget build(BuildContext context) {
    final colors=R69PlaySurfaceColors.of(context);
    final results=state['round_results'];
    final last=results is List && results.isNotEmpty && results.last is Map ? results.last as Map : const {};
    final raw=last['delta'] ?? state['player_round_score_delta'];
    if(raw is! Map || raw.isEmpty) return const SizedBox.shrink();
    final names=<String,String>{for(final p in players.whereType<Map>())
      if(p['key']!=null) p['key'].toString():p['name']?.toString() ?? p['key'].toString()};
    return Container(key:const ValueKey('r52-round-points'),margin:const EdgeInsets.symmetric(horizontal:10,vertical:5),
      padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:colors.surface,
        borderRadius:BorderRadius.circular(14),border:Border.all(color:colors.accent.withValues(alpha:.72))),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(ar?'نقاط الجولة السابقة':'Previous round points',style:TextStyle(color:colors.accent,fontSize:14,fontWeight:FontWeight.w900)),
        Wrap(spacing:12,runSpacing:6,children:[for(final entry in raw.entries)
          Text('${names[entry.key.toString()] ?? entry.key}: ${entry.value is num && (entry.value as num)>0 ? '+' : ''}${entry.value}',
            key:ValueKey('r52-round-points-${entry.key}'),style:TextStyle(color:colors.onSurface,fontSize:14,fontWeight:FontWeight.w800))]),
      ]));
  }
}

/// Reachable rewards routes share the existing authoritative opening/spin code.
class R52RewardsHomePanel extends StatelessWidget {
  const R52RewardsHomePanel({super.key,required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) {
    final ar=controller.localeCode=='ar';
    return R35ReferencePanel(
      key:const ValueKey('r52-rewards-center'),
      title:ar?'الدولاب وصناديق الجوائز':'Wheel and prize boxes',icon:Icons.card_giftcard_rounded,
      child:Wrap(spacing:10,runSpacing:10,children:[
        FilledButton.icon(key:const ValueKey('r52-open-wheel'),
          onPressed:()=>Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>LuckyWheelPageV182(controller:controller))),
          icon:const Icon(Icons.casino_rounded),label:Text(ar?'دولاب الحظ':'Lucky wheel'),
          style:FilledButton.styleFrom(minimumSize:const Size(140,48))),
        FilledButton.tonalIcon(key:const ValueKey('r52-open-boxes'),
          onPressed:()=>Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>PrizeBoxesPageV02(controller:controller))),
          icon:const Icon(Icons.inventory_2_rounded),label:Text(ar?'صناديقي':'My prize boxes'),
          style:FilledButton.styleFrom(minimumSize:const Size(140,48))),
        Text(ar?'جوائز داخل اللعبة • تدويرة مجانية كل 12 ساعة':'In-game rewards • one free spin every 12 hours',
          style:const TextStyle(color:R35ReferenceColors.white,fontSize:13,height:1.4)),
      ]),
    );
  }
}

class R52MatchResult extends StatelessWidget {
  const R52MatchResult({super.key,required this.ar,required this.won,required this.onExit,this.onReplay,this.points});
  final bool ar,won;
  final VoidCallback onExit;
  final VoidCallback? onReplay;
  final String? points;
  @override
  Widget build(BuildContext context) {
    final colors=R69PlaySurfaceColors.of(context);
    final resultAccent=won ? B307SkyLuxury.goldSoft : colors.accent;
    return Container(
      key:const ValueKey('r52-match-result'),padding:const EdgeInsets.all(12),
      decoration:BoxDecoration(color:colors.surface,borderRadius:BorderRadius.circular(18),
        border:Border.all(color:resultAccent,width:2)),
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        TweenAnimationBuilder<double>(tween:Tween(begin:won ? .65 : 1.0,end:1.0),
          duration:MediaQuery.disableAnimationsOf(context)?Duration.zero:const Duration(milliseconds:650),
          curve:Curves.easeOutBack,builder:(_,scale,child)=>Transform.scale(scale:scale,child:child),
          child:Icon(won?Icons.emoji_events_rounded:Icons.sports_esports_rounded,size:38,color:resultAccent)),
        Text(won?(ar?'مبارك الفوز!':'Victory!'):(ar?'انتهت المباراة — فرصة جديدة بانتظارك':'Match complete — another chance awaits'),
          textAlign:TextAlign.center,style:TextStyle(color:colors.onSurface,fontSize:17,fontWeight:FontWeight.w900)),
        if(points!=null) Text(points!,textAlign:TextAlign.center,style:TextStyle(color:colors.onSurface.withValues(alpha:.78),fontSize:14)),
        const SizedBox(height:8),
        Wrap(alignment:WrapAlignment.center,spacing:10,runSpacing:8,children:[
          FilledButton.icon(key:const ValueKey('r52-exit-finished-game'),onPressed:onExit,
            icon:const Icon(Icons.exit_to_app_rounded),label:Text(ar?'العودة للألعاب':'Back to games')),
          if(onReplay!=null) OutlinedButton.icon(key:const ValueKey('r52-replay-finished-game'),
            onPressed:onReplay,icon:const Icon(Icons.replay_rounded),
            style:OutlinedButton.styleFrom(foregroundColor:colors.onSurface,
              side:BorderSide(color:colors.accent),minimumSize:const Size(0,48),
              textStyle:(Theme.of(context).textTheme.labelLarge ?? const TextStyle()).copyWith(fontSize:14,fontWeight:FontWeight.w800)),
            label:Text(ar?'العب مجددًا':'Play again')),
        ]),
      ]),
    );
  }
}
