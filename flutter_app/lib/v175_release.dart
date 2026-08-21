part of 'main.dart';

/// Exact level-transition XP contract imported from XPs.xlsx for levels 1..100.

/// Returns the authoritative XP required to advance from [currentLevel].
/// Shared by controller logic and top-level profile/card helpers.
int xpNeededForLevelV175(int currentLevel) {
  final safe = currentLevel.clamp(1, 100).toInt();
  final exact = xpRequirementsV175[safe];
  if (exact != null) return exact;
  return xpRequirementsV175[100]!;
}

const Map<int, int> xpRequirementsV175 = <int, int>{
  1: 80,
  2: 98,
  3: 119,
  4: 145,
  5: 177,
  6: 215,
  7: 262,
  8: 319,
  9: 387,
  10: 470,
  11: 570,
  12: 690,
  13: 834,
  14: 1007,
  15: 1213,
  16: 1460,
  17: 1755,
  18: 2105,
  19: 2519,
  20: 3010,
  21: 3588,
  22: 4268,
  23: 5065,
  24: 5996,
  25: 7081,
  26: 8341,
  27: 9798,
  28: 11477,
  29: 13405,
  30: 15610,
  31: 18121,
  32: 20969,
  33: 24185,
  34: 27799,
  35: 31842,
  36: 36343,
  37: 41326,
  38: 46814,
  39: 52825,
  40: 59371,
  41: 66455,
  42: 74074,
  43: 82212,
  44: 90846,
  45: 99936,
  46: 109434,
  47: 119274,
  48: 129379,
  49: 139656,
  50: 150000,
  51: 160627,
  52: 171847,
  53: 183691,
  54: 196194,
  55: 209392,
  56: 223324,
  57: 238035,
  58: 253573,
  59: 269989,
  60: 287341,
  61: 305693,
  62: 325113,
  63: 345677,
  64: 367470,
  65: 390584,
  66: 415120,
  67: 441192,
  68: 468922,
  69: 498450,
  70: 529926,
  71: 563519,
  72: 599416,
  73: 637823,
  74: 678971,
  75: 723116,
  76: 770543,
  77: 821569,
  78: 876548,
  79: 935877,
  80: 4000000,
  81: 4275804,
  82: 4571144,
  83: 4888304,
  84: 5229916,
  85: 5599012,
  86: 5999088,
  87: 6434176,
  88: 6908944,
  89: 7428796,
  90: 9000000,
  91: 10000000,
  92: 11100000,
  93: 12300000,
  94: 13600000,
  95: 15000000,
  96: 16400000,
  97: 17800000,
  98: 19000000,
  99: 20000000,
  100: 20000000,
};

class ChallengeCenterV175 extends StatefulWidget {
  final AppController controller;
  const ChallengeCenterV175({super.key, required this.controller});

  @override
  State<ChallengeCenterV175> createState() => _ChallengeCenterV175State();
}

class _ChallengeCenterV175State extends State<ChallengeCenterV175> {
  bool loading = true;
  String? error;
  String selectedRoadGame = 'tarneeb';
  int selectedRoadStages = 12;
  List<Map<String, dynamic>> challenges = <Map<String, dynamic>>[];

  bool get ar => widget.controller.localeCode == 'ar';
  String bi(String arText, String enText) => ar ? arText : enText;

  static const List<Map<String, dynamic>> fallback = <Map<String, dynamic>>[
    {'key':'daily_wins','icon':'🔥','name_ar':'سلسلة النار','name_en':'Fire Streak','description_ar':'حقق 3 انتصارات اليوم من دون انسحاب','description_en':'Win 3 matches today without leaving.','cadence':'daily','progress':0,'target':3,'reward_tokens':750,'reward_xp':150,'activated':false,'completed':false,'claimed':false},
    {'key':'clean_play','icon':'🛡️','name_ar':'اللعب النظيف','name_en':'Fair Play','description_ar':'أكمل 5 مباريات بلا مغادرة أو بلاغ','description_en':'Complete 5 matches without leaving or receiving a report.','cadence':'daily','progress':0,'target':5,'reward_tokens':900,'reward_xp':180,'activated':false,'completed':false,'claimed':false},
    {'key':'tarneeb_master','icon':'🂡','name_ar':'سيّد الطرنيب','name_en':'Tarneeb Master','description_ar':'اربح جولتين بفارق 10 نقاط','description_en':'Win two Tarneeb rounds by a 10-point margin.','cadence':'weekly','progress':0,'target':2,'reward_tokens':1000,'reward_xp':250,'activated':false,'completed':false,'claimed':false},
    {'key':'social','icon':'🤝','name_ar':'تحدي الأصدقاء','name_en':'Friends Challenge','description_ar':'العب 3 مباريات مع أصدقاء مختلفين','description_en':'Play 3 matches with different friends.','cadence':'weekly','progress':0,'target':3,'reward_tokens':600,'reward_xp':120,'activated':false,'completed':false,'claimed':false},
    {'key':'club','icon':'👥','name_ar':'قوة المجموعة','name_en':'Club Power','description_ar':'اجمع 25 نقطة لمجموعتك خلال أسبوع','description_en':'Earn 25 points for your club this week.','cadence':'weekly','progress':0,'target':25,'reward_tokens':1000,'reward_xp':400,'activated':false,'completed':false,'claimed':false},
    {'key':'legend','icon':'🐉','name_ar':'مسار الأسطورة','name_en':'Legend Path','description_ar':'اربح 10 مباريات مصنفة هذا الموسم','description_en':'Win 10 ranked matches this season.','cadence':'seasonal','progress':0,'target':10,'reward_tokens':1000,'reward_xp':1000,'activated':false,'completed':false,'claimed':false},
  ];

  @override
  void initState() { super.initState(); unawaited(_load()); }

  Future<void> _load() async {
    if (!widget.controller.serverConnected) {
      if (mounted) setState(() {
        challenges = fallback.map(Map<String,dynamic>.from).toList();
        loading = false;
        error = bi('الوضع المحلي فعّال؛ مسار المراحل والمكافآت محفوظ على هذا الجهاز.', 'Local mode is active; stage-road progress and rewards are saved on this device.');
      });
      return;
    }
    try {
      final data = await widget.controller.api.engagementCenterV173();
      final raw = data['challenges'];
      final parsed = raw is List ? raw.whereType<Map>().map((e) => Map<String,dynamic>.from(e)).toList() : <Map<String,dynamic>>[];
      final roadRaw = data['challenge_road'];
      if (roadRaw is Map) widget.controller.syncChallengeRoadV210(Map<String,dynamic>.from(roadRaw));
      if (mounted) setState(() {
        challenges = parsed.isEmpty ? fallback.map(Map<String,dynamic>.from).toList() : parsed;
        loading = false;
        error = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() { loading=false; challenges=fallback.map(Map<String,dynamic>.from).toList(); error=e.message; });
    } catch (_) {
      if (mounted) setState(() { loading=false; challenges=fallback.map(Map<String,dynamic>.from).toList(); error=bi('تعذر تحديث التحديات الآن.','Could not refresh challenges right now.'); });
    }
  }

  Future<void> _action(Map<String,dynamic> item, bool claim) async {
    final key=item['key']?.toString() ?? '';
    if (key.isEmpty) return;
    if (!widget.controller.serverConnected) {
      if (claim) {
        showToast(context, bi('المكافآت المحلية تُضاف تلقائياً عند إكمال التحدي.','Local rewards are granted automatically when the challenge is completed.'));
      } else {
        widget.controller.joinChallenge(key);
        if (mounted) setState(() => item['activated'] = true);
        showToast(context, bi('تم تفعيل التحدي محلياً.','Challenge activated locally.'));
      }
      return;
    }
    setState(() => loading=true);
    try {
      final data = claim ? await widget.controller.api.claimChallengeV175(key) : await widget.controller.api.activateChallengeV175(key);
      final message=data['message']?.toString() ?? bi(claim ? 'تم استلام المكافأة.' : 'تم تفعيل التحدي.', claim ? 'Reward claimed.' : 'Challenge activated.');
      if (mounted) showToast(context,message);
      await _load();
      widget.controller.refreshUi();
    } on ApiException catch(e) { if(mounted) { setState(() => loading=false); showToast(context,e.message); } }
    catch (_) { if(mounted) { setState(() => loading=false); showToast(context,bi('تعذر تنفيذ العملية الآن.','Could not complete the action right now.')); } }
  }

  Future<void> _startRoad() async {
    setState(() => loading = true);
    if (!widget.controller.serverConnected) {
      widget.controller.startChallengeRoad(selectedRoadGame, selectedRoadStages);
      if (mounted) setState(() => loading = false);
      if (mounted) showToast(context, bi('بدأ مسار ${L.t(widget.controller.localeCode, selectedRoadGame)} بـ$selectedRoadStages مرحلة و5 محاولات.', '${L.t(widget.controller.localeCode, selectedRoadGame)} road started: $selectedRoadStages stages and 5 attempts.'));
      return;
    }
    try {
      final data = await widget.controller.api.startChallengeRoadV210(selectedRoadGame, selectedRoadStages);
      final road = data['road'];
      if (road is Map) widget.controller.syncChallengeRoadV210(Map<String,dynamic>.from(road));
      if (mounted) {
        setState(() { loading = false; error = null; });
        showToast(context, bi('بدأ مسار ${L.t(widget.controller.localeCode, selectedRoadGame)} بـ$selectedRoadStages مرحلة و5 محاولات.', '${L.t(widget.controller.localeCode, selectedRoadGame)} road started: $selectedRoadStages stages and 5 attempts.'));
      }
    } on ApiException catch(e) { if(mounted) setState(() {loading=false; error=e.message;}); }
    catch (_) { if(mounted) setState(() {loading=false; error=bi('تعذر بدء مسار التحدي الآن.','Could not start the challenge road.');}); }
  }

  Future<void> _playRoadStage() async {
    final gameId = widget.controller.challengeRoadGame ?? selectedRoadGame;
    final game = gamesCatalog.firstWhere((item) => item.id == gameId, orElse: () => gamesCatalog.first);
    if (!widget.controller.serverConnected) {
      Navigator.pop(context);
      showCreateRoom(context, widget.controller, game);
      return;
    }
    setState(() => loading = true);
    try {
      final data = await widget.controller.api.matchmakeChallengeRoadV210();
      final matchRaw = data['match'];
      if (matchRaw is! Map) throw const ApiException('Invalid challenge matchmaking response.');
      final match = Map<String,dynamic>.from(matchRaw);
      final roadRaw = match['road'];
      if (roadRaw is Map) widget.controller.syncChallengeRoadV210(Map<String,dynamic>.from(roadRaw));
      final code = match['room_code']?.toString().trim() ?? '';
      if (code.isEmpty) throw const ApiException('Challenge room code is missing.');
      final opponent = match['opponent'];
      String opponentName = bi('منافس عشوائي','Random opponent');
      if (opponent is Map) opponentName = opponent['display_name']?.toString() ?? opponent['username']?.toString() ?? opponentName;
      final navigationContext = Navigator.of(context, rootNavigator:true).context;
      if (mounted) showToast(context, bi('تم اختيار $opponentName للمرحلة التالية.','Matched with $opponentName for the next stage.'));
      if (mounted) Navigator.pop(context);
      await openGameRoom(navigationContext, widget.controller, game, options: RoomLaunchOptions(
        roomCode: code,
        roomName: bi('مسار التحدي','Challenge Road'),
        visibility: 'public',
        turnSeconds: 7,
        singleRound: true,
      ));
      if (widget.controller.serverConnected) {
        try {
          final refreshed = await widget.controller.api.engagementCenterV173();
          final road = refreshed['challenge_road'];
          if (road is Map) widget.controller.syncChallengeRoadV210(Map<String,dynamic>.from(road));
        } catch (_) {}
      }
    } on ApiException catch(e) { if(mounted) setState(() {loading=false; error=e.message;}); }
    catch (_) { if(mounted) setState(() {loading=false; error=bi('تعذر العثور على مواجهة الآن. حاول مرة أخرى.','Could not find a match right now. Try again.');}); }
  }

  String _label(dynamic value) {
    if (value is Map) return value[ar ? 'ar' : 'en']?.toString() ?? value['en']?.toString() ?? value['ar']?.toString() ?? '';
    return value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (loading && challenges.isEmpty) return const Padding(padding: EdgeInsets.all(36), child: Center(child:CircularProgressIndicator()));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children:[
      Row(children:[Expanded(child:Text(bi('مركز التحديات الاحترافي','Challenge Center'),style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900))),Chip(label:Text('🔥 ${widget.controller.challengeStreakV173}'))]),
      Text(bi('اختر لعبة واحدة وطول المسار. كل خسارة تستهلك محاولة، وكل فوز يفتح المرحلة التالية ومكافأتها.','Choose one game and a road length. A loss costs one attempt; every win unlocks the next stage and reward.'),style:const TextStyle(color:Colors.white60,height:1.5)),
      const SizedBox(height:10),
      PremiumPanel(child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[const Text('🛤️',style:TextStyle(fontSize:34)),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(bi('مسار المراحل','Stage Road'),style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),Text(widget.controller.challengeRoadGame==null?bi('ابدأ مساراً جديداً','Start a new road'):'${L.t(widget.controller.localeCode,widget.controller.challengeRoadGame!)} • ${bi('المرحلة','Stage')} ${widget.controller.challengeRoadStage + (widget.controller.challengeRoadCompleted?0:1)} ${bi('من','of')} ${widget.controller.challengeRoadTotal}',style:const TextStyle(color:Colors.white60,fontSize:10))])),Text('❤️ ${widget.controller.challengeRoadAttempts}/5',style:const TextStyle(fontWeight:FontWeight.w900,color:Colors.redAccent))]),
        const SizedBox(height:10),
        if(widget.controller.challengeRoadGame==null || widget.controller.challengeRoadCompleted || widget.controller.challengeRoadAttempts==0) ...[
          DropdownButtonFormField<String>(initialValue:selectedRoadGame,isExpanded:true,decoration:InputDecoration(labelText:bi('اللعبة','Game')),items:gamesCatalog.map((game)=>DropdownMenuItem(value:game.id,child:Text('${game.icon} ${L.t(widget.controller.localeCode,game.id)}'))).toList(),onChanged:(value){if(value!=null)setState(()=>selectedRoadGame=value);}),
          const SizedBox(height:8),
          SegmentedButton<int>(segments:[ButtonSegment(value:10,label:Text(bi('10 مراحل','10 stages'))),ButtonSegment(value:12,label:Text(bi('12 مرحلة','12 stages'))),ButtonSegment(value:15,label:Text(bi('15 مرحلة','15 stages')))],selected:<int>{selectedRoadStages},onSelectionChanged:(value)=>setState(()=>selectedRoadStages=value.first)),
          const SizedBox(height:9),
          FilledButton.icon(onPressed:loading?null:_startRoad,icon:const Icon(Icons.flag_rounded),label:Text(bi('بدء المسار بخمس محاولات','Start with five attempts'))),
        ] else ...[
          ClipRRect(borderRadius:BorderRadius.circular(99),child:LinearProgressIndicator(value:(widget.controller.challengeRoadStage/widget.controller.challengeRoadTotal).clamp(0.0,1.0).toDouble(),minHeight:11)),
          const SizedBox(height:7),
          Text('${bi('مكافأة المرحلة القادمة','Next stage reward')}: ${widget.controller.challengeRoadRewardLabel(widget.controller.challengeRoadStage+1)}',style:const TextStyle(color:Colors.amberAccent,fontWeight:FontWeight.w800)),
          const SizedBox(height:8),
          Row(children:[Expanded(child:FilledButton.icon(onPressed:loading?null:_playRoadStage,icon:const Icon(Icons.play_arrow_rounded),label:Text(bi('ابحث عن منافس وابدأ','Find opponent & play')))),const SizedBox(width:7),OutlinedButton(onPressed:loading?null:(){widget.controller.resetChallengeRoad();setState((){});},child:Text(bi('إعادة','Reset')))]),
        ],
      ]))),
      if(error!=null) Padding(padding:const EdgeInsets.only(top:8),child:Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.orange.withValues(alpha:.12),borderRadius:BorderRadius.circular(14),border:Border.all(color:Colors.orangeAccent.withValues(alpha:.35))),child:Text(error!,style:const TextStyle(fontSize:11)))),
      const SizedBox(height:12),
      ...challenges.map((item){
        final progress=int.tryParse(item['progress']?.toString() ?? '') ?? 0;
        final target=math.max(1,int.tryParse(item['target']?.toString() ?? '') ?? 1).toInt();
        final activated=item['activated']==true || progress>0;
        final completed=item['completed']==true || progress>=target;
        final claimed=item['claimed']==true;
        final cadence=item['cadence']?.toString() ?? 'daily';
        final icon=item['icon']?.toString() ?? (cadence=='daily'?'⚡':cadence=='weekly'?'🏆':'🐉');
        final name=item[ar?'name_ar':'name_en']?.toString() ?? _label(item['name']);
        final description=item[ar?'description_ar':'description_en']?.toString() ?? _label(item['description']);
        final tokens=(int.tryParse(item['reward_tokens']?.toString() ?? '') ?? 0).clamp(0,1000).toInt();
        final rewardXp=int.tryParse(item['reward_xp']?.toString() ?? '') ?? 0;
        final cadenceLabel=cadence=='daily'?bi('يومي','Daily'):cadence=='weekly'?bi('أسبوعي','Weekly'):bi('موسمي','Seasonal');
        final actionLabel=claimed?bi('تم الاستلام','Claimed'):completed?bi('استلام','Claim'):activated?bi('متابعة','Continue'):bi('تفعيل','Activate');
        return Padding(padding:const EdgeInsets.only(bottom:10),child:PremiumPanel(child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Row(children:[Text(icon,style:const TextStyle(fontSize:34)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w900)),Text(description,style:const TextStyle(color:Colors.white60,fontSize:10,height:1.4))])),Chip(label:Text(cadenceLabel))]),
          const SizedBox(height:9),
          Row(children:[Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(99),child:LinearProgressIndicator(value:(progress/target).clamp(0.0,1.0).toDouble(),minHeight:9))),const SizedBox(width:8),Text('$progress / $target',style:const TextStyle(fontWeight:FontWeight.w900))]),
          const SizedBox(height:8),
          Row(children:[Expanded(child:Text('🪙 ${formatNumber(tokens)}  •  ⭐ ${formatNumber(rewardXp)} XP',style:const TextStyle(color:Colors.amberAccent,fontWeight:FontWeight.w800,fontSize:11))),FilledButton.tonal(onPressed:claimed||loading?null:() => _action(item,completed),child:Text(actionLabel))]),
        ]))));
      }),
      if(loading) const Padding(padding:EdgeInsets.only(top:4),child:LinearProgressIndicator()),
    ]);
  }
}

void showChallengesV175(BuildContext context, AppController controller) {
  showPremiumSheet(context, child: ChallengeCenterV175(controller: controller));
}
