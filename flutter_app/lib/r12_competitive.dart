part of 'main.dart';

const String warqnaaR12Release = '0.7.0+240';
const Color _r12Gold = Color(0xFFF5C85B);
const Color _r12Mint = Color(0xFF61DDAE);
const Color _r12Deep = Color(0xFF071A13);
const Color _r12Panel = Color(0xFF10271F);

Map<String, dynamic> _r12Map(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<Map<String, dynamic>> _r12List(dynamic value) => value is List ? value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList() : <Map<String, dynamic>>[];
int _r12Int(dynamic value, [int fallback = 0]) => int.tryParse(value?.toString() ?? '') ?? fallback;
List<int> _r12SeatOptions(String game) => switch (game) {
  'banakil' => const [2, 4],
  'hand' || 'saudi_hand' => const [2, 3, 4],
  'basra' => const [2],
  _ => const [4],
};
String _r12Local(dynamic value, String locale, [String fallback = '']) {
  if (value is Map) return value[locale]?.toString() ?? value['ar']?.toString() ?? value['en']?.toString() ?? fallback;
  return value?.toString() ?? fallback;
}
Color _r12Color(dynamic value, [Color fallback = _r12Gold]) {
  final hex = value?.toString().replaceAll('#', '') ?? '';
  return Color(int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16) ?? fallback.toARGB32());
}

class R12CompetitiveArenaPage extends StatefulWidget {
  const R12CompetitiveArenaPage({super.key, required this.controller});
  final AppController controller;
  @override State<R12CompetitiveArenaPage> createState() => _R12CompetitiveArenaPageState();
}

class _R12CompetitiveArenaPageState extends State<R12CompetitiveArenaPage> with SingleTickerProviderStateMixin {
  late final TabController tabs;
  Map<String, dynamic> data = <String, dynamic>{};
  List<Map<String, dynamic>> leaders = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> history = <Map<String, dynamic>>[];
  Timer? queueTimer;
  bool loading = true;
  String? error;

  bool get ar => widget.controller.localeCode == 'ar';
  Map<String, dynamic> get rating => _r12Map(data['rating']);
  Map<String, dynamic> get tier => _r12Map(rating['tier']);
  Map<String, dynamic> get season => _r12Map(data['season']);
  Map<String, dynamic> get queue => _r12Map(data['queue']);

  @override void initState() { super.initState(); tabs = TabController(length: 4, vsync: this); _load(); }
  @override void dispose() { queueTimer?.cancel(); tabs.dispose(); super.dispose(); }

  Future<void> _load({bool quiet = false}) async {
    if (!quiet && mounted) setState(() { loading = true; error = null; });
    try {
      if (widget.controller.serverConnected) {
        final dashboard = await widget.controller.api.competitiveR12();
        final ladder = await widget.controller.api.competitiveLeaderboardR12(limit: 100);
        final matches = await widget.controller.api.competitiveHistoryR12();
        data = _r12Map(dashboard['competitive']);
        leaders = _r12List(_r12Map(ladder['leaderboard'])['rows']);
        history = _r12List(matches['matches']);
      } else {
        data = _offlineCompetitive(); leaders = _offlineLeaders(); history = const <Map<String, dynamic>>[];
      }
      _armQueuePolling();
    } catch (e) {
      error = e.toString();
      if (data.isEmpty) { data = _offlineCompetitive(); leaders = _offlineLeaders(); }
    }
    if (mounted) setState(() => loading = false);
  }

  void _armQueuePolling() {
    queueTimer?.cancel();
    if (!widget.controller.serverConnected || !['waiting','matching'].contains(queue['status'])) return;
    queueTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      try {
        final response = await widget.controller.api.rankedQueueR12(token: queue['token']?.toString());
        final next = _r12Map(response['queue']);
        if (!mounted) return;
        setState(() => data['queue'] = next);
        if (next['status'] == 'matched' && (next['room_code']?.toString() ?? '').isNotEmpty) { queueTimer?.cancel(); await _enterMatch(next); }
      } catch (_) {}
    });
  }

  Future<void> _joinQueue() async {
    if (!widget.controller.serverConnected) {
      showToast(context, ar ? 'Ranked يحتاج اتصالاً بخادم Laravel.' : 'Ranked requires the Laravel server.');
      return;
    }
    final gameOptions = customerGamesR101;
    String game = gameOptions.first.id;
    String region = 'mena';
    List<int> seatOptions = _r12SeatOptions(game);
    int seats = seatOptions.first;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 8, 18, 18 + MediaQuery.viewInsetsOf(context).bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(ar ? 'بوابة Ranked' : 'Ranked gateway', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                const Text('Server-authoritative • MMR • Integrity review', style: TextStyle(color: _r12Mint, fontSize: 9)),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: game,
                  decoration: InputDecoration(labelText: ar ? 'اللعبة' : 'Game'),
                  items: gameOptions
                      .map((item) => DropdownMenuItem(value: item.id, child: Text('${item.icon} ${L.t(widget.controller.localeCode, item.id)}')))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setSheet(() {
                      game = value;
                      seatOptions = _r12SeatOptions(value);
                      seats = seatOptions.first;
                    });
                  },
                ),
                const SizedBox(height: 9),
                DropdownButtonFormField<int>(
                  key: ValueKey('$game:$seats'),
                  initialValue: seats,
                  decoration: InputDecoration(labelText: ar ? 'عدد اللاعبين' : 'Players'),
                  items: seatOptions.map((value) => DropdownMenuItem(value: value, child: Text('$value'))).toList(),
                  onChanged: (value) {
                    if (value != null) setSheet(() => seats = value);
                  },
                ),
                const SizedBox(height: 9),
                DropdownButtonFormField<String>(
                  initialValue: region,
                  decoration: InputDecoration(labelText: ar ? 'المنطقة' : 'Region'),
                  items: const ['mena', 'levant', 'gcc', 'global']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value.toUpperCase())))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setSheet(() => region = value);
                  },
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(sheet, true),
                  icon: const Icon(Icons.swords),
                  label: Text(ar ? 'ابدأ البحث العادل' : 'Start fair matchmaking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    try { setState(()=>loading=true); final response=await widget.controller.api.joinRankedQueueR12(game:game,preferredSeats:seats,region:region); data['queue']=_r12Map(response['queue']); if(mounted)showToast(context,ar?'دخلت طابور Ranked.':'Ranked search started.'); _armQueuePolling(); }
    catch(e){if(mounted)showToast(context,e.toString());} finally {if(mounted)setState(()=>loading=false);}
  }

  Future<void> _cancelQueue() async {
    try { await widget.controller.api.cancelRankedQueueR12(token:queue['token']?.toString()); if(mounted)setState(()=>data['queue']=null); queueTimer?.cancel(); }
    catch(e){if(mounted)showToast(context,e.toString());}
  }

  Future<void> _enterMatch(Map<String,dynamic> current) async {
    final code=current['room_code']?.toString()??'', key=current['game']?.toString()??'tarneeb'; if(code.isEmpty)return;
    GameInfo game=gamesCatalog.first; for(final item in gamesCatalog){if(item.id==key){game=item;break;}}
    if(!mounted)return; await openGameRoom(context,widget.controller,game,options:RoomLaunchOptions(roomCode:code,voiceEnabled:false)); await _load(quiet:true);
  }

  Future<void> _claim(int id) async { try{await widget.controller.api.claimCompetitiveRewardR12(id);if(mounted)showToast(context,ar?'تم استلام مكافأة الموسم.':'Season reward claimed.');await _load(quiet:true);}catch(e){if(mounted)showToast(context,e.toString());} }

  @override Widget build(BuildContext context) {
    final tierColor=_r12Color(tier['color']);
    return Scaffold(backgroundColor:_r12Deep,appBar:AppBar(backgroundColor:_r12Deep,title:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('♛ Competitive Arena',style:TextStyle(fontWeight:FontWeight.w900)),Text('R12 • BUILD 240',style:TextStyle(fontSize:8,color:_r12Gold,letterSpacing:1.4))]),actions:[IconButton(onPressed:()=>_load(),icon:const Icon(Icons.refresh_rounded))],bottom:TabBar(controller:tabs,isScrollable:true,tabs:[Tab(text:ar?'الساحة':'Arena'),Tab(text:ar?'البطولات':'Cups'),Tab(text:ar?'التصنيف':'Ladder'),Tab(text:ar?'الجوائز':'Rewards')])),
      body:loading&&data.isEmpty?const Center(child:CircularProgressIndicator()):Container(decoration:const BoxDecoration(gradient:RadialGradient(center:Alignment(1,-1),radius:1.4,colors:[Color(0xFF153D2F),_r12Deep])),child:TabBarView(controller:tabs,children:[_arena(tierColor),_cups(),_ladder(),_rewards()])),
    );
  }

  Widget _arena(Color tierColor) => RefreshIndicator(onRefresh:_load,child:ListView(padding:const EdgeInsets.all(13),children:[
    if(error!=null)_R12Notice(text:ar?'تعذر الاتصال؛ تُعرض معاينة آمنة حتى يعود الخادم.':'Connection unavailable; showing a safe preview.',color:Colors.orangeAccent),
    Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(30),gradient:LinearGradient(colors:[tierColor.withValues(alpha:.20),_r12Panel,_r12Deep]),border:Border.all(color:tierColor.withValues(alpha:.3)),boxShadow:[BoxShadow(color:tierColor.withValues(alpha:.1),blurRadius:45)]),child:LayoutBuilder(builder:(context,c){final details=Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('SEASON RANK',style:TextStyle(color:_r12Gold,fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1.5)),Text(_r12Local(tier,widget.controller.localeCode,'Bronze'),style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900)),Text(_r12Local(season['name'],widget.controller.localeCode,'Warqnaa Season'),style:const TextStyle(color:Colors.white60)),const SizedBox(height:13),Wrap(spacing:8,runSpacing:8,children:[_R12Metric(label:'WINS',value:'${rating['wins']??0}',color:_r12Mint),_R12Metric(label:'PEAK',value:'${rating['peak']??1000}',color:_r12Gold),_R12Metric(label:'RANK',value:'#${rating['rank']??1}',color:Colors.lightBlueAccent)])]);return c.maxWidth>570?Row(children:[_R12RankEmblem(tier:tier,rating:_r12Int(rating['rating'],1000)),const SizedBox(width:22),Expanded(child:details)]):Column(children:[_R12RankEmblem(tier:tier,rating:_r12Int(rating['rating'],1000)),const SizedBox(height:16),details]);})),const SizedBox(height:12),
    _queueCard(),const SizedBox(height:12),
    const _R12Notice(text:'🛡️ Every move, winner and MMR delta is verified on the server. Suspicious results pause for review before rating or rewards.',color:_r12Mint),
    const SizedBox(height:16),Text(ar?'آخر المواجهات':'Recent battles',style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:8),
    if(history.isEmpty)_R12Empty(text:ar?'ستظهر مبارياتك المصنفة هنا.':'Your Ranked history will appear here.') else ...history.take(8).map((match){final events=_r12List(match['rating_events']);final overall=events.where((e)=>e['scope']=='overall').toList();final delta=overall.isEmpty?0:_r12Int(overall.first['delta']);return Padding(padding:const EdgeInsets.only(bottom:8),child:_R12Glass(child:ListTile(contentPadding:EdgeInsets.zero,leading:CircleAvatar(backgroundColor:(delta>=0?_r12Mint:Colors.redAccent).withValues(alpha:.12),child:Text(delta>=0?'↗':'↘',style:TextStyle(color:delta>=0?_r12Mint:Colors.redAccent))),title:Text('${match['game']??'Game'} • ${match['mode']??'ranked'}',style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('${match['status']??''} • ${match['room_code']??'—'}',style:const TextStyle(fontSize:9)),trailing:Text('${delta>=0?'+':''}$delta',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:delta>=0?_r12Mint:Colors.redAccent)))));}),
  ]));

  Widget _queueCard() {
    if(queue.isEmpty||!['waiting','matching','matched'].contains(queue['status'])) return _R12Glass(accent:_r12Gold,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Row(children:[const Icon(Icons.swords,color:_r12Gold,size:32),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(ar?'مواجهة Ranked':'Ranked battle',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),Text(ar?'خصوم مناسبون، لا بوتات، ولا نتيجة من العميل.':'Matched opponents, no bots, no client-trusted result.',style:const TextStyle(color:Colors.white54,fontSize:10))]))]),const SizedBox(height:13),FilledButton.icon(onPressed:_joinQueue,icon:const Icon(Icons.radar),label:Text(ar?'ابحث عن منافسين':'Find opponents'))]));
    final matched=queue['status']=='matched',code=queue['room_code']?.toString()??'';
    return _R12Glass(accent:_r12Mint,child:Column(children:[Row(children:[const _R12Radar(),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(matched?(ar?'وجدنا منافستك!':'Match found!'):(ar?'جارٍ البحث…':'Searching…'),style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),Text('${queue['game']} • ${queue['region']} • ±${queue['search_window']??100} MMR',style:const TextStyle(color:_r12Mint,fontSize:9))]))]),const SizedBox(height:12),Row(children:[if(matched&&code.isNotEmpty)Expanded(child:FilledButton(onPressed:()=>_enterMatch(queue),child:Text(ar?'ادخل الآن':'Enter now')))else Expanded(child:OutlinedButton(onPressed:_cancelQueue,child:Text(ar?'إلغاء البحث':'Cancel search')))])]));
  }

  Widget _cups() { final cups=_r12List(data['tournaments']); return RefreshIndicator(onRefresh:_load,child:ListView(padding:const EdgeInsets.all(13),children:[_R12SectionHero(icon:'♜',eyebrow:'LEAGUES • CUPS • CHAMPIONSHIPS',title:ar?'طريقك إلى الكأس':'Your road to the cup',subtitle:ar?'عالمي، أندية، ودول — جداول خادمية وجائزة نهائية موثقة.':'Global, club and country brackets with verified final payouts.'),const SizedBox(height:12),if(cups.isEmpty)_R12Empty(text:ar?'لا توجد بطولة مفتوحة الآن.':'No open championship right now.')else ...cups.map((cup)=>Padding(padding:const EdgeInsets.only(bottom:10),child:_R12CupCard(cup:cup,locale:widget.controller.localeCode,onTap:()=>_openCup(cup))))])); }

  Future<void> _openCup(Map<String,dynamic> cup) async {
    Map<String,dynamic> details=cup; final id=_r12Int(cup['id']);
    if(widget.controller.serverConnected&&id>0){try{final r=await widget.controller.api.competitiveTournamentR12(id);details=_r12Map(r['tournament']);}catch(e){if(mounted)showToast(context,e.toString());}}
    if(!mounted)return; final rounds=_r12List(_r12Map(details['bracket'])['rounds']);
    await showModalBottomSheet<void>(context:context,isScrollControlled:true,showDragHandle:true,builder:(sheet)=>DraggableScrollableSheet(expand:false,initialChildSize:.78,maxChildSize:.94,builder:(context,scroll)=>ListView(controller:scroll,padding:const EdgeInsets.fromLTRB(16,0,16,26),children:[Text(_r12Local(details['name'],widget.controller.localeCode,details['key']?.toString()??'Cup'),style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),Text('${details['format']??'single_elimination'} • ${details['scope']??'global'} • 🪙 ${details['prize_pool']??0}',style:const TextStyle(color:_r12Gold)),const SizedBox(height:13),if(rounds.isEmpty)const _R12Empty(text:'Bracket locks when registration reaches capacity.')else ...rounds.map((round)=>_R12BracketRound(round:round,locale:widget.controller.localeCode)),const SizedBox(height:13),if(details['registered']!=true&&details['status']=='open')FilledButton.icon(onPressed:widget.controller.serverConnected?()async{try{await widget.controller.api.joinCompetitiveTournamentR12(id);if(sheet.mounted)Navigator.pop(sheet);if(mounted)showToast(context,ar?'تم التسجيل في البطولة.':'Tournament registration complete.');await _load(quiet:true);}catch(e){if(mounted)showToast(context,e.toString());}}:null,icon:const Icon(Icons.how_to_reg),label:Text(ar?'سجّل في البطولة':'Register'))])));
  }

  Widget _ladder() => RefreshIndicator(onRefresh:_load,child:ListView(padding:const EdgeInsets.all(13),children:[_R12SectionHero(icon:'♛',eyebrow:'GLOBAL RANKED LADDER',title:ar?'صالة المتصدرين':'Hall of contenders',subtitle:_r12Local(season['name'],widget.controller.localeCode,'Warqnaa Season')),const SizedBox(height:10),...leaders.asMap().entries.map((entry)=>_R12LeaderRow(row:entry.value,rank:entry.key+1,locale:widget.controller.localeCode,isMe:_r12Int(entry.value['user_id'])==(widget.controller.currentUserId??-1))) ]));

  Widget _rewards() {
    final claims = _r12List(data['rewards']);
    final tiers = _r12List(data['tiers']);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(13),
        children: [
          _R12SectionHero(
            icon: '✦',
            eyebrow: 'SEASON REWARD VAULT',
            title: ar ? 'جوائز تستحقها' : 'Rewards you earn',
            subtitle: ar
                ? 'لا تُصرف إلا بعد إغلاق الموسم واعتماد التصنيف النهائي.'
                : 'Unlocked only after season finalization and verified standings.',
          ),
          const SizedBox(height: 12),
          if (claims.isNotEmpty)
            ...claims.map(
              (claim) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _R12Glass(
                  accent: _r12Gold,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Text('🎁', style: TextStyle(fontSize: 34)),
                    title: Text(
                      '${claim['tier']}'.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('🪙 ${claim['tokens']} • ${claim['xp']} XP'),
                    trailing: claim['status'] == 'pending'
                        ? FilledButton(
                            onPressed: () => _claim(_r12Int(claim['id'])),
                            child: const Text('CLAIM'),
                          )
                        : const Icon(Icons.verified, color: _r12Mint),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 6),
          ...tiers.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _R12Glass(
                accent: _r12Color(item['color']),
                child: Row(
                  children: [
                    Text(
                      item['icon']?.toString() ?? '◆',
                      style: TextStyle(fontSize: 28, color: _r12Color(item['color'])),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _r12Local(item, widget.controller.localeCode, item['key']?.toString() ?? ''),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text('${item['min']}+ MMR', style: const TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String,dynamic> _offlineCompetitive()=> <String,dynamic>{'enabled':true,'release':warqnaaR12Release,'season':<String,dynamic>{'key':'r12_preview','name':<String,dynamic>{'ar':'موسم أبطال ورقنا','en':'Warqnaa Champions Season'},'placement_games':10},'rating':<String,dynamic>{'rating':1248,'peak':1310,'rank':37,'games':28,'wins':18,'losses':10,'streak':3,'placement_complete':true,'tier':<String,dynamic>{'key':'gold','ar':'ذهبي','en':'Gold','color':'#F5C85B','icon':'✦'}},'queue':null,'tiers':<Map<String,dynamic>>[{'key':'bronze','ar':'برونزي','en':'Bronze','min':0,'color':'#B7794B','icon':'◆'},{'key':'silver','ar':'فضي','en':'Silver','min':900,'color':'#C7D2E0','icon':'◇'},{'key':'gold','ar':'ذهبي','en':'Gold','min':1100,'color':'#F5C85B','icon':'✦'},{'key':'platinum','ar':'بلاتيني','en':'Platinum','min':1300,'color':'#67E8F9','icon':'✧'},{'key':'diamond','ar':'ماسي','en':'Diamond','min':1500,'color':'#7DD3FC','icon':'◈'},{'key':'master','ar':'ماستر','en':'Master','min':1750,'color':'#C084FC','icon':'♛'},{'key':'grandmaster','ar':'جراند ماستر','en':'Grandmaster','min':2000,'color':'#FB7185','icon':'♚'},{'key':'legend','ar':'أسطورة ورقنا','en':'Warqnaa Legend','min':2300,'color':'#FDE68A','icon':'★'}],'tournaments':<Map<String,dynamic>>[{'id':1,'key':'champions','name':{'ar':'بطولة الأبطال','en':'Champions Cup'},'game':'tarneeb','format':'single_elimination','scope':'global','players':24,'max_players':32,'prize_pool':50000,'status':'open'},{'id':2,'key':'clubs_war','name':{'ar':'حرب الأندية','en':'Club Championship'},'game':'tarneeb','format':'group_playoffs','scope':'club','players':20,'max_players':32,'prize_pool':200000,'status':'open'},{'id':3,'key':'country_cup','name':{'ar':'كأس الدول','en':'Nations Cup'},'game':'trix','format':'league_playoffs','scope':'country','players':48,'max_players':64,'prize_pool':350000,'status':'open'}],'rewards':<Map<String,dynamic>>[]};
  List<Map<String,dynamic>> _offlineLeaders()=>List.generate(14,(i)=><String,dynamic>{'rank':i+1,'user_id':i+1,'display_name':['Adnan','Janan','Kenan','Shahd','Raad','Samer','Lina'][i%7],'country_code':['PS','JO','SA','AE'][i%4],'club':'Warqnaa Elite','rating':2180-(i*67),'wins':52-i*2,'losses':12+i,'streak':i%5,'tier':{'ar':i<3?'جراند ماستر':'ماستر','en':i<3?'Grandmaster':'Master','icon':i<3?'♚':'♛','color':i<3?'#FB7185':'#C084FC'}});
}

class R12AdminCompetitivePanel extends StatefulWidget { const R12AdminCompetitivePanel({super.key,required this.controller}); final AppController controller; @override State<R12AdminCompetitivePanel> createState()=>_R12AdminCompetitivePanelState(); }
class _R12AdminCompetitivePanelState extends State<R12AdminCompetitivePanel> {
  Map<String, dynamic> data = <String, dynamic>{};
  bool loading = true;

  Future<void> _load() async {
    if (!widget.controller.serverConnected) {
      if (mounted) setState(() => loading = false);
      return;
    }
    try {
      final response = await widget.controller.api.adminCompetitiveR12();
      if (mounted) setState(() => data = response);
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _setting(String key, bool value) async {
    try {
      await widget.controller.api.adminUpdateCompetitiveSettingsR12({key: value});
      await _load();
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    }
  }

  Future<void> _createSeason() async {
    final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final key = TextEditingController(text: 'season_$stamp');
    final name = TextEditingController(text: 'موسم أبطال ورقنا');
    final days = TextEditingController(text: '90');
    final placements = TextEditingController(text: '10');
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Create competitive season'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: key, decoration: const InputDecoration(labelText: 'Season key')),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Arabic name')),
              TextField(controller: days, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (days)')),
              TextField(controller: placements, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Placement games')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Create'))],
      ),
    );
    final payload = <String, dynamic>{
      'key': key.text.trim(), 'name_ar': name.text.trim(), 'name_en': name.text.trim(),
      'starts_at': DateTime.now().toUtc().add(const Duration(minutes: 5)).toIso8601String(),
      'ends_at': DateTime.now().toUtc().add(Duration(days: _r12Int(days.text, 90))).toIso8601String(),
      'placement_games': _r12Int(placements.text, 10), 'rating_soft_reset_factor': .75,
    };
    key.dispose(); name.dispose(); days.dispose(); placements.dispose();
    if (accepted != true) return;
    try { await widget.controller.api.adminCreateCompetitiveSeasonR12(payload); await _load(); if (mounted) showToast(context, '✓ Season created with audit trail'); }
    catch (error) { if (mounted) showToast(context, error.toString()); }
  }

  Future<void> _createTournament() async {
    final games = _r12List(data['games']);
    if (games.isEmpty) { showToast(context, 'No customer game is available.'); return; }
    final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final key = TextEditingController(text: 'cup_$stamp');
    final name = TextEditingController(text: 'كأس أبطال ورقنا');
    final stages = TextEditingController(text: '3');
    final entry = TextEditingController(text: '0');
    final prize = TextEditingController(text: '25000');
    final club = TextEditingController();
    final country = TextEditingController(text: 'PS');
    int gameId = _r12Int(games.first['id']);
    String gameKey = games.first['key']?.toString() ?? 'tarneeb';
    List<int> seatsAvailable = _r12SeatOptions(gameKey);
    int seats = seatsAvailable.first;
    String format = 'single_elimination';
    String scope = 'global';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Create championship'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: key, decoration: const InputDecoration(labelText: 'Tournament key')),
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Arabic name')),
                  DropdownButtonFormField<int>(
                    initialValue: gameId,
                    decoration: const InputDecoration(labelText: 'Game'),
                    items: games.map((game) => DropdownMenuItem(value: _r12Int(game['id']), child: Text('${game['key']}'))).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      final selected = games.firstWhere((game) => _r12Int(game['id']) == value);
                      setDialog(() { gameId = value; gameKey = selected['key']?.toString() ?? 'tarneeb'; seatsAvailable = _r12SeatOptions(gameKey); seats = seatsAvailable.first; });
                    },
                  ),
                  DropdownButtonFormField<int>(key: ValueKey('$gameKey:$seats'), initialValue: seats, decoration: const InputDecoration(labelText: 'Seats per match'), items: seatsAvailable.map((value) => DropdownMenuItem(value: value, child: Text('$value'))).toList(), onChanged: (value) { if (value != null) setDialog(() => seats = value); }),
                  DropdownButtonFormField<String>(initialValue: format, decoration: const InputDecoration(labelText: 'Format'), items: const ['single_elimination','league_playoffs','group_playoffs'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) { if (value != null) setDialog(() => format = value); }),
                  DropdownButtonFormField<String>(initialValue: scope, decoration: const InputDecoration(labelText: 'Scope'), items: const ['global','club','country'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) { if (value != null) setDialog(() => scope = value); }),
                  if (scope == 'club') TextField(controller: club, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Club ID')),
                  if (scope == 'country') TextField(controller: country, maxLength: 2, decoration: const InputDecoration(labelText: 'Country code')),
                  TextField(controller: stages, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stages')),
                  TextField(controller: entry, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Entry tokens')),
                  TextField(controller: prize, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prize pool')),
                ],
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Create'))],
        ),
      ),
    );
    final now = DateTime.now().toUtc();
    final payload = <String, dynamic>{
      'key': key.text.trim(), 'name_ar': name.text.trim(), 'name_en': name.text.trim(), 'game_id': gameId,
      'format': format, 'scope': scope, 'stages': _r12Int(stages.text, 3), 'seats_per_match': seats,
      'entry_fee': _r12Int(entry.text), 'prize_pool': _r12Int(prize.text),
      'starts_at': now.add(const Duration(days: 7)).toIso8601String(), 'registration_closes_at': now.add(const Duration(days: 6)).toIso8601String(),
      if (scope == 'club') 'club_id': _r12Int(club.text), if (scope == 'country') 'country_code': country.text.trim().toUpperCase(),
    };
    key.dispose(); name.dispose(); stages.dispose(); entry.dispose(); prize.dispose(); club.dispose(); country.dispose();
    if (accepted != true) return;
    try { await widget.controller.api.adminCreateCompetitiveTournamentR12(payload); await _load(); if (mounted) showToast(context, '✓ Championship created with server capacity'); }
    catch (error) { if (mounted) showToast(context, error.toString()); }
  }

  Future<void> _adjustRating() async {
    final games = _r12List(data['games']);
    if (games.isEmpty) { showToast(context, 'No customer game is available.'); return; }
    final user = TextEditingController(); final delta = TextEditingController(text: '25'); final reason = TextEditingController(text: 'Verified support settlement');
    int gameId = _r12Int(games.first['id']);
    final accepted = await showDialog<bool>(context: context, builder: (dialog) => StatefulBuilder(builder: (context, setDialog) => AlertDialog(
      title: const Text('Audited MMR adjustment'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children:[
        TextField(controller:user,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'User ID')),
        DropdownButtonFormField<int>(initialValue:gameId,decoration:const InputDecoration(labelText:'Game'),items:games.map((game)=>DropdownMenuItem(value:_r12Int(game['id']),child:Text('${game['key']}'))).toList(),onChanged:(value){if(value!=null)setDialog(()=>gameId=value);}),
        TextField(controller:delta,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Delta (-500..500)')),
        TextField(controller:reason,maxLines:2,decoration:const InputDecoration(labelText:'Audit reason')),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(dialog,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(dialog,true),child:const Text('Apply'))],
    )));
    final userId=_r12Int(user.text); final payload=<String,dynamic>{'game_id':gameId,'delta':_r12Int(delta.text),'reason':reason.text.trim()};
    user.dispose();delta.dispose();reason.dispose();
    if(accepted!=true)return;
    try{await widget.controller.api.adminAdjustCompetitiveRatingR12(userId,payload);await _load();if(mounted)showToast(context,'✓ Immutable MMR event created');}
    catch(error){if(mounted)showToast(context,error.toString());}
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final stats = _r12Map(data['stats']);
    final settings = _r12Map(data['settings']);
    final reviews = _r12List(data['review_matches']);
    final tournaments = _r12List(data['tournaments']);
    final seasons = _r12List(data['seasons']);
    const settingKeys = [
      'competitive_enabled',
      'ranked_matchmaking_enabled',
      'season_rewards_enabled',
      'club_championships_enabled',
      'country_championships_enabled',
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(13),
        children: [
          const _R12SectionHero(
            icon: '♛',
            eyebrow: 'R12 • BUILD 240 • CONTROL PLANE',
            title: 'Admin Competitive Arena',
            subtitle: 'Seasons • MMR • Queues • Integrity • Brackets • Rewards',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(onPressed: _createSeason, icon: const Icon(Icons.event_available), label: const Text('New season')),
              FilledButton.icon(onPressed: _createTournament, icon: const Icon(Icons.emoji_events), label: const Text('New championship')),
              OutlinedButton.icon(onPressed: _adjustRating, icon: const Icon(Icons.tune), label: const Text('Adjust MMR')),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.entries
                .map(
                  (entry) => SizedBox(
                    width: 145,
                    child: _R12Glass(
                      child: Column(
                        children: [
                          Text('${entry.value}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _r12Gold)),
                          Text(entry.key.replaceAll('_', ' '), textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _R12Glass(
            child: Column(
              children: settingKeys
                  .map(
                    (key) => SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: settings[key] == true,
                      title: Text(key.replaceAll('_', ' ')),
                      onChanged: (value) => _setting(key, value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('SEASON LIFECYCLE', style: TextStyle(color: _r12Gold, fontWeight: FontWeight.w900, fontSize: 10)),
          ...seasons.take(10).map(
            (season) => ListTile(
              leading: const Icon(Icons.calendar_month, color: _r12Gold),
              title: Text(_r12Local(season['name'], widget.controller.localeCode, season['key']?.toString() ?? '')),
              subtitle: Text('${season['status']} • ${season['ratings_count']} ratings • ${season['matches_count']} matches'),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'activate', child: Text('Activate')),
                  PopupMenuItem(value: 'finalize', child: Text('Finalize + rewards')),
                  PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                ],
                onSelected: (action) async {
                  try {
                    await widget.controller.api.adminCompetitiveSeasonActionR12(_r12Int(season['id']), action);
                    await _load();
                  } catch (error) {
                    if (mounted) showToast(context, error.toString());
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('INTEGRITY REVIEW', style: TextStyle(color: _r12Gold, fontWeight: FontWeight.w900, fontSize: 10)),
          if (reviews.isEmpty)
            const _R12Notice(text: '✓ No matches waiting for review.', color: _r12Mint)
          else
            ...reviews.map(
              (match) => _R12Glass(
                accent: Colors.orangeAccent,
                child: ListTile(
                  leading: const Icon(Icons.gpp_maybe, color: Colors.orangeAccent),
                  title: Text('${_r12Map(match['game'])['key'] ?? 'Game'} • ${_r12Map(match['room'])['code'] ?? '—'}'),
                  subtitle: Text('${match['match_key']}'),
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'approve', child: Text('Approve result')),
                      PopupMenuItem(value: 'void', child: Text('Void match')),
                    ],
                    onSelected: (action) async {
                      try {
                        await widget.controller.api.adminCompetitiveMatchActionR12(
                          _r12Int(match['id']),
                          action,
                          'Mobile control-plane integrity review',
                        );
                        await _load();
                      } catch (error) {
                        if (mounted) showToast(context, error.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text('TOURNAMENT BRACKETS', style: TextStyle(color: _r12Gold, fontWeight: FontWeight.w900, fontSize: 10)),
          ...tournaments.take(16).map(
            (tournament) => ListTile(
              leading: const Text('♜', style: TextStyle(fontSize: 27, color: _r12Gold)),
              title: Text(_r12Local(tournament['name'], widget.controller.localeCode, tournament['key']?.toString() ?? 'Tournament')),
              subtitle: Text('${tournament['scope']} • round ${tournament['current_round']}/${tournament['stages']} • ${tournament['status']}'),
              trailing: IconButton(
                onPressed: () async {
                  try {
                    await widget.controller.api.adminBuildCompetitiveBracketR12(_r12Int(tournament['id']));
                    await _load();
                  } catch (error) {
                    if (mounted) showToast(context, error.toString());
                  }
                },
                icon: const Icon(Icons.account_tree_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _R12Glass extends StatelessWidget { const _R12Glass({required this.child,this.accent}); final Widget child; final Color? accent; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:const LinearGradient(colors:[Color(0xEB10271F),Color(0xF2071812)]),border:Border.all(color:(accent??_r12Mint).withValues(alpha:.18)),boxShadow:const [BoxShadow(color:Color(0x28000000),blurRadius:25,offset:Offset(0,10))]),child:child); }
class _R12RankEmblem extends StatelessWidget { const _R12RankEmblem({required this.tier,required this.rating});final Map<String,dynamic> tier;final int rating;@override Widget build(BuildContext context){final color=_r12Color(tier['color']);return Container(width:150,height:150,decoration:BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(colors:[color.withValues(alpha:.62),_r12Deep]),border:Border.all(color:color.withValues(alpha:.5),width:2),boxShadow:[BoxShadow(color:color.withValues(alpha:.18),blurRadius:42)]),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(tier['icon']?.toString()??'◆',style:TextStyle(fontSize:38,color:color)),Text('$rating',style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const Text('MMR',style:TextStyle(fontSize:8,letterSpacing:2,color:Colors.white54))]));}}
class _R12Metric extends StatelessWidget { const _R12Metric({required this.label,required this.value,required this.color});final String label,value;final Color color;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),decoration:BoxDecoration(color:color.withValues(alpha:.08),borderRadius:BorderRadius.circular(13),border:Border.all(color:color.withValues(alpha:.15))),child:Column(children:[Text(value,style:TextStyle(color:color,fontWeight:FontWeight.w900)),Text(label,style:const TextStyle(fontSize:7,color:Colors.white54))]));}
class _R12Notice extends StatelessWidget { const _R12Notice({required this.text,required this.color});final String text;final Color color;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:color.withValues(alpha:.07),borderRadius:BorderRadius.circular(16),border:Border.all(color:color.withValues(alpha:.18))),child:Text(text,style:TextStyle(color:color,fontSize:10,height:1.5)));}
class _R12Empty extends StatelessWidget { const _R12Empty({required this.text});final String text;@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.all(28),child:Column(children:[const Icon(Icons.hourglass_empty_rounded,size:45,color:Colors.white24),const SizedBox(height:8),Text(text,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white54))]));}
class _R12Radar extends StatefulWidget { const _R12Radar();@override State<_R12Radar> createState()=>_R12RadarState();}
class _R12RadarState extends State<_R12Radar> with SingleTickerProviderStateMixin {late final AnimationController c;@override void initState(){super.initState();c=AnimationController(vsync:this,duration:const Duration(seconds:2))..repeat();}@override void dispose(){c.dispose();super.dispose();}@override Widget build(BuildContext context)=>RotationTransition(turns:c,child:Container(width:58,height:58,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:_r12Mint.withValues(alpha:.5)),gradient:SweepGradient(colors:[_r12Mint.withValues(alpha:.5),Colors.transparent,Colors.transparent])),child:const Center(child:Text('W',style:TextStyle(color:_r12Gold,fontWeight:FontWeight.w900)))));}
class _R12SectionHero extends StatelessWidget { const _R12SectionHero({required this.icon,required this.eyebrow,required this.title,required this.subtitle});final String icon,eyebrow,title,subtitle;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(27),gradient:const LinearGradient(colors:[Color(0xFF17372B),_r12Deep]),border:Border.all(color:_r12Gold.withValues(alpha:.18))),child:Row(children:[Text(icon,style:const TextStyle(fontSize:49,color:_r12Gold)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(eyebrow,style:const TextStyle(color:_r12Gold,fontSize:8,fontWeight:FontWeight.w900,letterSpacing:1.1)),Text(title,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),Text(subtitle,style:const TextStyle(color:Colors.white54,fontSize:10,height:1.4))]))]));}
class _R12CupCard extends StatelessWidget { const _R12CupCard({required this.cup,required this.locale,required this.onTap});final Map<String,dynamic> cup;final String locale;final VoidCallback onTap;@override Widget build(BuildContext context)=>_R12Glass(accent:_r12Gold,child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(16),child:Row(children:[Container(width:70,height:82,decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),gradient:const RadialGradient(colors:[Color(0x557DE6B4),Color(0x11000000)])),child:const Center(child:Text('♜',style:TextStyle(fontSize:43,color:_r12Gold)))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Wrap(spacing:5,children:[Chip(label:Text('${cup['scope']??'global'}',style:const TextStyle(fontSize:7))),Chip(label:Text('${cup['format']??'cup'}',style:const TextStyle(fontSize:7)))]),Text(_r12Local(cup['name'],locale,cup['key']?.toString()??'Cup'),style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),Text('${cup['game']??'Game'} • ${cup['players']??0}/${cup['max_players']??0}',style:const TextStyle(fontSize:9,color:Colors.white54)),Text('🪙 ${cup['prize_pool']??0}',style:const TextStyle(color:_r12Gold,fontWeight:FontWeight.w900))])),const Icon(Icons.chevron_right)])));}
class _R12LeaderRow extends StatelessWidget { const _R12LeaderRow({required this.row,required this.rank,required this.locale,required this.isMe});final Map<String,dynamic> row;final int rank;final String locale;final bool isMe;@override Widget build(BuildContext context){final tier=_r12Map(row['tier']),color=_r12Color(tier['color']);return Container(margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:isMe?_r12Gold.withValues(alpha:.08):Colors.white.withValues(alpha:.035),borderRadius:BorderRadius.circular(18),border:Border.all(color:isMe?_r12Gold.withValues(alpha:.3):Colors.white.withValues(alpha:.06))),child:Row(children:[SizedBox(width:31,child:Text('#$rank',style:TextStyle(fontWeight:FontWeight.w900,color:rank<=3?_r12Gold:Colors.white54))),CircleAvatar(radius:20,backgroundColor:color.withValues(alpha:.14),backgroundImage:(row['avatar']?.toString()??'').startsWith('http')?NetworkImage(row['avatar'].toString()):null,child:(row['avatar']?.toString()??'').startsWith('http')?null:Text((row['display_name']?.toString()??row['username']?.toString()??'?').substring(0,1))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(row['display_name']?.toString()??row['username']?.toString()??'Player',style:const TextStyle(fontWeight:FontWeight.w900)),Text('${row['country_code']??'--'} • ${row['club']??'Warqnaa'}',style:const TextStyle(fontSize:8,color:Colors.white54))])),Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text('${row['rating']??1000}',style:TextStyle(color:color,fontWeight:FontWeight.w900,fontSize:17)),Text('${tier['icon']??'◆'} ${_r12Local(tier,locale,tier['key']?.toString()??'')}',style:const TextStyle(fontSize:8,color:Colors.white54))]) ]));}}
class _R12BracketRound extends StatelessWidget {
  const _R12BracketRound({required this.round, required this.locale});
  final Map<String, dynamic> round;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final matches = _r12List(round['matches']);
    final label = _r12Local(round['label'], locale, 'Round');
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label • ${round['status'] ?? ''}',
            style: const TextStyle(color: _r12Gold, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          ...matches.map(
            (match) => Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    match['status'] == 'completed' ? '✓' : '◷',
                    style: TextStyle(color: match['status'] == 'completed' ? _r12Mint : _r12Gold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${match['id']} • room ${match['room_code'] ?? '—'}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Text(
                    '${match['player_ids'] is List ? (match['player_ids'] as List).length : 0}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
