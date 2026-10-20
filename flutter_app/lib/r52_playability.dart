part of 'main.dart';

String r52CardLabel(String raw) => WarqnaaCardIdentity.parse(raw)?.label ?? raw;

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
  Widget build(BuildContext context) => Container(
    key:const ValueKey('r52-match-result'),padding:const EdgeInsets.all(12),
    decoration:BoxDecoration(color:R35ReferenceColors.navy,borderRadius:BorderRadius.circular(18),
      border:Border.all(color:won?R35ReferenceColors.gold:R35ReferenceColors.cyan,width:2)),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Icon(won?Icons.emoji_events_rounded:Icons.sports_esports_rounded,size:32,
        color:won?R35ReferenceColors.gold:R35ReferenceColors.cyan),
      Text(won?(ar?'مبارك الفوز!':'Victory!'):(ar?'انتهت المباراة — فرصة جديدة بانتظارك':'Match complete — another chance awaits'),
        textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:17,fontWeight:FontWeight.w900)),
      if(points!=null) Text(points!,textAlign:TextAlign.center,style:const TextStyle(color:R35ReferenceColors.paleGold,fontSize:14)),
      const SizedBox(height:8),
      Wrap(alignment:WrapAlignment.center,spacing:10,runSpacing:8,children:[
        FilledButton.icon(key:const ValueKey('r52-exit-finished-game'),onPressed:onExit,
          icon:const Icon(Icons.exit_to_app_rounded),label:Text(ar?'العودة للألعاب':'Back to games')),
        if(onReplay!=null) OutlinedButton.icon(onPressed:onReplay,icon:const Icon(Icons.replay_rounded),
          label:Text(ar?'العب مجددًا':'Play again')),
      ]),
    ]),
  );
}
