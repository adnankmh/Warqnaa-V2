part of 'main.dart';

const String warqnaaR11Release = '0.6.0+230';
const Color _r11Gold = Color(0xFFF2C96D);
const Color _r11Mint = Color(0xFF55E6A5);
const Color _r11Deep = Color(0xFF06130E);

Map<String, dynamic> _r11Map(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<Map<String, dynamic>> _r11List(dynamic value) => value is List
    ? value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
    : <Map<String, dynamic>>[];
String _r11Localized(dynamic value, String locale, [String fallback = '']) {
  if (value is Map) return value[locale]?.toString() ?? value['ar']?.toString() ?? value['en']?.toString() ?? fallback;
  return value?.toString() ?? fallback;
}

class R11SocialWorldPage extends StatefulWidget {
  const R11SocialWorldPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<R11SocialWorldPage> createState() => _R11SocialWorldPageState();
}

class _R11SocialWorldPageState extends State<R11SocialWorldPage> with AutomaticKeepAliveClientMixin {
  Map<String, dynamic> data = <String, dynamic>{};
  bool loading = true;
  String? error;
  Timer? heartbeat;

  bool get ar => widget.controller.localeCode == 'ar';
  Map<String, dynamic> get world => _r11Map(data['world']);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
    heartbeat = Timer.periodic(const Duration(seconds: 45), (_) {
      if (widget.controller.serverConnected) {
        unawaited(widget.controller.api.socialHeartbeatR11().then<void>((_) {}).catchError((_) {}));
      }
    });
  }

  @override
  void dispose() {
    heartbeat?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!widget.controller.serverConnected) {
      if (mounted) setState(() { loading = false; error = ar ? 'اتصل بالخادم لفتح العالم الحي.' : 'Connect to the server to open the live world.'; });
      return;
    }
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final response = await widget.controller.api.socialWorldR11();
      if (mounted) setState(() => data = response);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _composer() async {
    final text = TextEditingController();
    var type = 'status';
    var audience = 'friends';
    final submitted = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: Text(ar ? '✦ شارك لحظتك' : '✦ Share your moment'),
      content: SizedBox(width: 520, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: text, minLines: 3, maxLines: 7, maxLength: 500, decoration: InputDecoration(hintText: ar ? 'ماذا يحدث في مجلسك؟' : 'What’s happening in your majlis?')),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(initialValue: type, items: const [DropdownMenuItem(value:'status',child:Text('Status')),DropdownMenuItem(value:'looking_for_game',child:Text('Looking for game')),DropdownMenuItem(value:'achievement',child:Text('Achievement'))], onChanged: (value) => setDialogState(() => type = value ?? type))),
          const SizedBox(width: 8),
          Expanded(child: DropdownButtonFormField<String>(initialValue: audience, items: const [DropdownMenuItem(value:'public',child:Text('Public')),DropdownMenuItem(value:'friends',child:Text('Friends')),DropdownMenuItem(value:'followers',child:Text('Followers')),DropdownMenuItem(value:'private',child:Text('Private'))], onChanged: (value) => setDialogState(() => audience = value ?? audience))),
        ]),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(ar ? 'إلغاء' : 'Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, text.text.trim().isNotEmpty), child: Text(ar ? 'نشر' : 'Publish'))],
    )));
    final message = text.text.trim();
    text.dispose();
    if (submitted != true || message.isEmpty) return;
    try {
      await widget.controller.api.publishSocialActivityR11(type: type, text: message, audience: audience);
      if (mounted) showToast(context, ar ? 'تم النشر في عالم ورقنا.' : 'Published to Social World.');
      await _load();
    } catch (exception) {
      if (mounted) showToast(context, exception.toString());
    }
  }

  Future<void> _privacy() async {
    final privacy = _r11Map(data['privacy']);
    if (privacy.isEmpty) return;
    final draft = Map<String, dynamic>.from(privacy);
    final saved = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheetContext) => StatefulBuilder(builder: (context, setSheetState) {
      Widget choice(String key, List<String> values, String label) => DropdownButtonFormField<String>(
        initialValue: values.contains(draft[key]) ? draft[key].toString() : values.first,
        decoration: InputDecoration(labelText: label),
        items: values.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        onChanged: (value) => setSheetState(() => draft[key] = value),
      );
      Widget toggle(String key, String label) => SwitchListTile.adaptive(value: draft[key] == true || draft[key] == 1, onChanged: (value) => setSheetState(() => draft[key] = value), title: Text(label));
      return SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(18, 4, 18, MediaQuery.viewInsetsOf(context).bottom + 18), child: ListView(shrinkWrap: true, children: [
        Text(ar ? '🛡️ مركز خصوصية R11' : '🛡️ R11 Privacy Center', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        choice('profile_visibility', const ['public','friends','private'], ar ? 'الملف الشخصي' : 'Profile'),
        const SizedBox(height: 8), choice('presence_visibility', const ['public','friends','private'], ar ? 'حالة الاتصال' : 'Presence'),
        const SizedBox(height: 8), choice('activity_visibility', const ['public','friends','private'], ar ? 'النشاط' : 'Activity'),
        const SizedBox(height: 8), choice('message_policy', const ['everyone','friends','nobody'], ar ? 'الرسائل' : 'Messages'),
        const SizedBox(height: 8), choice('invite_policy', const ['everyone','friends','nobody'], ar ? 'الدعوات' : 'Invites'),
        toggle('discoverable', ar ? 'الظهور في الاكتشاف' : 'Discoverable'),
        toggle('allow_friend_requests', ar ? 'طلبات الصداقة' : 'Friend requests'),
        toggle('allow_follows', ar ? 'السماح بالمتابعة' : 'Allow follows'),
        toggle('allow_spectators', ar ? 'السماح بالمشاهدين' : 'Allow spectators'),
        toggle('allow_replay_share', ar ? 'مشاركة الإعادات' : 'Replay sharing'),
        toggle('allow_voice', ar ? 'الصوت داخل اللعب' : 'In-game voice'),
        toggle('show_online_status', ar ? 'إظهار الاتصال' : 'Show online status'),
        toggle('show_current_room', ar ? 'إظهار الغرفة الحالية' : 'Show current room'),
        const SizedBox(height: 10), FilledButton.icon(onPressed: () => Navigator.pop(sheetContext, true), icon: const Icon(Icons.verified_user_outlined), label: Text(ar ? 'حفظ الخصوصية' : 'Save privacy')),
      ])));
    }));
    if (saved != true) return;
    try {
      await widget.controller.api.updateSocialPrivacyR11(draft);
      if (mounted) showToast(context, ar ? 'تم حفظ الخصوصية.' : 'Privacy saved.');
      await _load();
    } catch (exception) {
      if (mounted) showToast(context, exception.toString());
    }
  }

  Future<void> _createEvent() async {
    final title = TextEditingController();
    final description = TextEditingController();
    var visibility = 'public';
    var startsAt = DateTime.now().add(const Duration(hours: 2));
    final submitted = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: Text(ar ? '✦ فعالية جديدة' : '✦ New event'),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, maxLength: 140, decoration: InputDecoration(labelText: ar ? 'اسم الفعالية' : 'Event name')),
        TextField(controller: description, minLines: 2, maxLines: 5, maxLength: 2000, decoration: InputDecoration(labelText: ar ? 'الوصف' : 'Description')),
        DropdownButtonFormField<String>(initialValue: visibility, decoration: InputDecoration(labelText: ar ? 'الخصوصية' : 'Visibility'), items: const [DropdownMenuItem(value:'public',child:Text('Public')),DropdownMenuItem(value:'friends',child:Text('Friends')),DropdownMenuItem(value:'private',child:Text('Private'))], onChanged: (value) => setDialogState(() => visibility = value ?? visibility)),
        const SizedBox(height: 10),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule_outlined, color: _r11Gold), title: Text(ar ? 'موعد البداية' : 'Starts at'), subtitle: Text(MaterialLocalizations.of(context).formatFullDate(startsAt) + ' • ' + TimeOfDay.fromDateTime(startsAt).format(context)), onTap: () async {
          final date = await showDatePicker(context: context, initialDate: startsAt, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (date == null || !context.mounted) return;
          final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(startsAt));
          if (time == null) return;
          setDialogState(() => startsAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
        }),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(ar ? 'إلغاء' : 'Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, title.text.trim().isNotEmpty && startsAt.isAfter(DateTime.now())), child: Text(ar ? 'إنشاء' : 'Create'))],
    )));
    final eventTitle = title.text.trim(), eventDescription = description.text.trim();
    title.dispose();
    description.dispose();
    if (submitted != true || eventTitle.isEmpty) return;
    try {
      await widget.controller.api.createSocialEventR11(title: eventTitle, description: eventDescription, visibility: visibility, startsAt: startsAt);
      if (mounted) showToast(context, ar ? 'تم إنشاء الفعالية.' : 'Event created.');
      await _load();
    } catch (exception) {
      if (mounted) showToast(context, exception.toString());
    }
  }

  Future<void> _joinSpectator(Map<String, dynamic> room) async {
    final code = room['code']?.toString() ?? '';
    if (code.isEmpty) return;
    try {
      await widget.controller.api.joinSpectatorR11(code);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => R11SpectatorPage(controller: widget.controller, roomCode: code)));
      await _load();
    } catch (exception) {
      if (mounted) showToast(context, exception.toString());
    }
  }

  Future<void> _openReplay(Map<String, dynamic> replay) async {
    final id = int.tryParse(replay['id']?.toString() ?? '');
    if (id == null) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => R11ReplayViewerPage(controller: widget.controller, replayId: id, seed: replay)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (loading && data.isEmpty) return const Center(child: CircularProgressIndicator());
    final stats = _r11Map(data['stats']);
    final activities = _r11List(world['activities']);
    final liveRooms = _r11List(world['live_rooms']);
    final events = _r11List(world['events']);
    final replays = _r11List(world['recent_replays']);
    return DefaultTabController(
      length: 4,
      child: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(slivers: [
          SliverPadding(padding: const EdgeInsets.fromLTRB(14, 14, 14, 0), sliver: SliverToBoxAdapter(child: _hero(stats))),
          SliverPadding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 0), sliver: SliverToBoxAdapter(child: _stats(stats))),
          if (error != null) SliverPadding(padding: const EdgeInsets.all(14), sliver: SliverToBoxAdapter(child: _R11Notice(text: error!, icon: Icons.cloud_off_outlined))),
          SliverPersistentHeader(pinned: true, delegate: _R11TabHeader(TabBar(isScrollable: true, dividerColor: Colors.transparent, tabs: [Tab(text: ar ? 'الموجز' : 'Feed', icon: const Icon(Icons.dynamic_feed_outlined)),Tab(text: ar ? 'مباشر' : 'Live', icon: const Icon(Icons.stadium_outlined)),Tab(text: ar ? 'الفعاليات' : 'Events', icon: const Icon(Icons.auto_awesome_outlined)),Tab(text: ar ? 'الإعادات' : 'Replays', icon: const Icon(Icons.replay_circle_filled_outlined))]))),
          SliverFillRemaining(hasScrollBody: true, child: TabBarView(children: [
            _feed(activities), _live(liveRooms), _events(events), _replays(replays),
          ])),
        ]),
      ),
    );
  }

  Widget _hero(Map<String, dynamic> stats) => LayoutBuilder(builder: (context, constraints) {
    final wide = constraints.maxWidth > 760;
    final content = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [const _R11LiveDot(), const SizedBox(width: 8), Text('R11 • BUILD 230 • ${ar ? 'مباشر' : 'LIVE'}', style: const TextStyle(color: _r11Gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4))]),
      const SizedBox(height: 12), Text(ar ? 'عالم ورقنا الاجتماعي' : 'Warqnaa Social World', style: TextStyle(fontSize: wide ? 38 : 29, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -.7)),
      const SizedBox(height: 9), Text(ar ? 'مجلس حي يجمع اللاعبين والفعاليات والمدرجات والإعادات — بخصوصية صممت أولًا.' : 'A living majlis for players, events, spectator stands and replays — built privacy-first.', style: TextStyle(color: Colors.white.withValues(alpha: .68), height: 1.5)),
      const SizedBox(height: 16), Wrap(spacing: 8, runSpacing: 8, children: [FilledButton.icon(onPressed: _composer, icon: const Icon(Icons.auto_awesome), label: Text(ar ? 'انشر لحظتك' : 'Share a moment')),OutlinedButton.icon(onPressed: _createEvent, icon: const Icon(Icons.event_available_outlined), label: Text(ar ? 'فعالية' : 'Event')),OutlinedButton.icon(onPressed: _privacy, icon: const Icon(Icons.shield_outlined), label: Text(ar ? 'الخصوصية' : 'Privacy'))]),
    ]);
    return Container(constraints: BoxConstraints(minHeight: wide ? 260 : 250), padding: EdgeInsets.all(wide ? 28 : 20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: _r11Mint.withValues(alpha: .18)), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0B2A1C), _r11Deep, Color(0xFF07100D)]), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 34, offset: Offset(0, 18))]), child: Stack(children: [
      PositionedDirectional(end: -22, top: -30, child: Text('♠\n♥ ♦\n♣', textAlign: TextAlign.center, style: TextStyle(fontSize: wide ? 70 : 54, height: .9, color: Colors.white.withValues(alpha: .035), fontWeight: FontWeight.w900))),
      Align(alignment: AlignmentDirectional.centerStart, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: content)),
    ]));
  });

  Widget _stats(Map<String, dynamic> stats) {
    final items = <(IconData, String, dynamic)>[(Icons.people_alt_outlined, ar ? 'متابع' : 'Followers', stats['followers'] ?? 0),(Icons.person_add_alt, ar ? 'أتابع' : 'Following', stats['following'] ?? 0),(Icons.stadium_outlined, ar ? 'مدرج مباشر' : 'Live stands', stats['live_rooms'] ?? 0),(Icons.auto_awesome_outlined, ar ? 'فعالية' : 'Events', stats['events'] ?? 0)];
    return SizedBox(height: 82, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, index) { final item = items[index]; return Container(width: 145, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: .76), borderRadius: BorderRadius.circular(18), border: Border.all(color: _r11Mint.withValues(alpha: .12))), child: Row(children: [Icon(item.$1, color: index == 0 ? _r11Gold : _r11Mint, size: 21), const SizedBox(width: 9), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('${item.$3}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),Text(item.$2, style: const TextStyle(fontSize: 9, color: Colors.white54))]) ])); }));
  }

  Widget _feed(List<Map<String, dynamic>> items) {
    final suggestions = _r11List(world['suggestions']);
    return ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 100), children: [
      if (suggestions.isNotEmpty) ...[
        Row(children: [Expanded(child: Text(ar ? 'لاعبون قد تعرفهم' : 'People to discover', style: const TextStyle(fontWeight: FontWeight.w900))),const Icon(Icons.travel_explore, color: _r11Mint)]),
        const SizedBox(height: 8),
        SizedBox(height: 96, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: suggestions.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, index) {
          final person = suggestions[index], following = person['following'] == true;
          return SizedBox(width: 225, child: _R11GlassCard(child: Row(children: [
            _R11Avatar(url: person['avatar']?.toString(), label: person['display_name']?.toString() ?? person['username']?.toString() ?? '?'),
            const SizedBox(width: 9),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(person['display_name']?.toString() ?? person['username']?.toString() ?? 'Warqnaa', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),Text('Lv. ${person['level'] ?? 1}', style: const TextStyle(fontSize: 9, color: Colors.white54))])),
            IconButton(onPressed: () => _toggleFollow(person, following), tooltip: following ? (ar ? 'إلغاء المتابعة' : 'Unfollow') : (ar ? 'متابعة' : 'Follow'), icon: Icon(following ? Icons.done_rounded : Icons.person_add_alt_1_rounded, color: following ? _r11Mint : _r11Gold)),
          ])));
        })),
        const SizedBox(height: 14),
      ],
      if (items.isEmpty) Padding(padding: const EdgeInsets.all(26), child: _R11Notice(icon: Icons.auto_awesome_outlined, text: ar ? 'كن أول من يضيء المجلس.' : 'Be the first to light up the majlis.')),
      for (final item in items) ...[
        Builder(builder: (_) { final actor = _r11Map(item['actor']), gifts = _r11List(item['gifts']); return _R11GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_R11Avatar(url: actor['avatar']?.toString(), label: actor['display_name']?.toString() ?? '?'), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(actor['display_name']?.toString() ?? actor['username']?.toString() ?? 'Warqnaa', style: const TextStyle(fontWeight: FontWeight.w900)),Text('${item['type'] ?? 'status'} • ${item['audience'] ?? 'friends'}', style: const TextStyle(color: Colors.white54, fontSize: 9))])),IconButton(onPressed: actor['id'] == null ? null : () => _gift(actor), icon: const Icon(Icons.card_giftcard_rounded, color: _r11Gold))]),
          const SizedBox(height: 12), Text(item['text']?.toString() ?? '', style: const TextStyle(height: 1.55, fontSize: 14)),
          if (gifts.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Wrap(spacing: 4, children: gifts.map((gift) => Text(gift['icon']?.toString() ?? '✨', style: const TextStyle(fontSize: 22))).toList())),
        ])); }),
        const SizedBox(height: 10),
      ],
    ]);
  }

  Future<void> _toggleFollow(Map<String, dynamic> person, bool following) async {
    final id = int.tryParse(person['id']?.toString() ?? '');
    if (id == null) return;
    try {
      if (following) { await widget.controller.api.unfollowPlayerR11(id); } else { await widget.controller.api.followPlayerR11(id); }
      await _load();
    } catch (exception) {
      if (mounted) showToast(context, exception.toString());
    }
  }

  Widget _live(List<Map<String, dynamic>> rooms) => rooms.isEmpty
      ? _empty(Icons.stadium_outlined, ar ? 'لا توجد مدرجات مفتوحة الآن.' : 'No open stands right now.')
      : GridView.builder(padding: const EdgeInsets.fromLTRB(14, 12, 14, 100), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.sizeOf(context).width > 900 ? 2 : 1, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: MediaQuery.sizeOf(context).width > 900 ? 1.8 : 1.62), itemCount: rooms.length, itemBuilder: (_, index) {
          final room = rooms[index], players = _r11List(room['players']);
          return _R11GlassCard(accent: _r11Mint, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [_R11LiveDot(), SizedBox(width: 7), Text('LIVE • READ ONLY', style: TextStyle(color: _r11Mint, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))]),
            const Spacer(), Text(room['name']?.toString() ?? room['code']?.toString() ?? 'Warqnaa', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),Text('${room['game'] ?? ''} • ${players.length} ${ar ? 'لاعبين' : 'players'} • ${room['spectators'] ?? 0} 👁', style: const TextStyle(color: Colors.white60, fontSize: 10)),
            const SizedBox(height: 10), Row(children: [for (final player in players.take(4)) Padding(padding: const EdgeInsetsDirectional.only(end: 4), child: _R11Avatar(url: player['avatar']?.toString(), label: player['name']?.toString() ?? '?', size: 34)), const Spacer(), FilledButton.tonalIcon(onPressed: () => _joinSpectator(room), icon: const Icon(Icons.stadium_outlined, size: 18), label: Text(ar ? 'شاهد' : 'Watch'))]),
            const SizedBox(height: 5), Text(ar ? '🔒 لا أوراق، لا صوت، لا محادثة خاصة' : '🔒 No hands, voice or private chat', style: const TextStyle(color: Colors.white38, fontSize: 8)),
          ]));
        });

  Widget _events(List<Map<String, dynamic>> events) => events.isEmpty
      ? _empty(Icons.auto_awesome_outlined, ar ? 'لا فعاليات مجدولة بعد.' : 'No events scheduled yet.')
      : ListView.separated(padding: const EdgeInsets.fromLTRB(14, 12, 14, 100), itemCount: events.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, index) {
          final event = events[index];
          return _R11GlassCard(accent: event['featured'] == true ? _r11Gold : null, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: _r11Gold.withValues(alpha: .10), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.auto_awesome, color: _r11Gold)), const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_r11Localized(event['title'], widget.controller.localeCode, 'Warqnaa Event'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),const SizedBox(height: 4),Text(_r11Localized(event['description'], widget.controller.localeCode), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 10, height: 1.4)),const SizedBox(height: 7),Text('◷ ${event['starts_at'] ?? '—'}  •  ◎ ${event['going'] ?? 0}', style: const TextStyle(color: _r11Gold, fontSize: 9))])),
            FilledButton.tonal(onPressed: () => _toggleAttendance(event), child: Text(event['attendance'] == 'going' ? (ar ? 'إلغاء' : 'Cancel') : (ar ? 'سأحضر' : 'Going'))),
          ]));
        });

  Widget _replays(List<Map<String, dynamic>> replays) => replays.isEmpty
      ? _empty(Icons.replay_circle_filled_outlined, ar ? 'ستظهر الإعادات بعد اكتمال المباريات.' : 'Replays appear after matches finish.')
      : GridView.builder(padding: const EdgeInsets.fromLTRB(14, 12, 14, 100), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.sizeOf(context).width > 900 ? 2 : 1, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.0), itemCount: replays.length, itemBuilder: (_, index) {
          final replay = replays[index];
          return InkWell(onTap: () => _openReplay(replay), borderRadius: BorderRadius.circular(22), child: _R11GlassCard(child: Row(children: [Container(width: 76, decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), gradient: const RadialGradient(colors: [Color(0xFF1F7650), Color(0xFF092218)])), child: const Center(child: Icon(Icons.play_arrow_rounded, size: 38, color: _r11Gold))),const SizedBox(width: 12),Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('${replay['game'] ?? ''} • ${replay['room_code'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900)),Text('${replay['frames_count'] ?? 0} frames • ${replay['views'] ?? 0} views', style: const TextStyle(color: Colors.white54, fontSize: 9)),const SizedBox(height: 5),const Text('🛡️ Privacy-safe', style: TextStyle(color: _r11Mint, fontSize: 9))]))])));
        });

  Future<void> _toggleAttendance(Map<String, dynamic> event) async {
    final id = int.tryParse(event['id']?.toString() ?? '');
    if (id == null) return;
    try {
      if (event['attendance'] == 'going') { await widget.controller.api.cancelSocialEventR11(id); } else { await widget.controller.api.attendSocialEventR11(id); }
      if (mounted) showToast(context, event['attendance'] == 'going' ? (ar ? 'تم إلغاء الحضور.' : 'Attendance cancelled.') : (ar ? 'تم تأكيد حضورك.' : 'Attendance confirmed.'));
      await _load();
    } catch (e) { if (mounted) showToast(context, e.toString()); }
  }

  Future<void> _gift(Map<String, dynamic> recipient) async {
    final catalog = _r11List(world['gift_catalog']);
    if (catalog.isEmpty) return;
    Map<String, dynamic>? selected;
    selected = await showModalBottomSheet<Map<String, dynamic>>(context: context, showDragHandle: true, builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(ar ? 'هدية إلى ${recipient['display_name']}' : 'Gift to ${recipient['display_name']}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),const SizedBox(height: 12),Wrap(spacing: 8, runSpacing: 8, children: catalog.map((gift) => InkWell(onTap: () => Navigator.pop(context, gift), borderRadius: BorderRadius.circular(16), child: Container(width: 92, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(16), border: Border.all(color: _r11Gold.withValues(alpha: .18))), child: Column(children: [Text(gift['icon']?.toString() ?? '✨', style: const TextStyle(fontSize: 30)),Text(_r11Localized(gift[ar ? 'ar' : 'en'], widget.controller.localeCode, gift[ar ? 'ar' : 'en']?.toString() ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9)),Text('🪙 ${gift['cost']}', style: const TextStyle(color: _r11Gold, fontSize: 9))])))).toList()),const SizedBox(height: 10),const Text('⚖️ Social-only • no competitive advantage', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 9))]))));
    if (selected == null) return;
    final recipientId = int.tryParse(recipient['id']?.toString() ?? '');
    if (recipientId == null) return;
    try {
      await widget.controller.api.sendSocialGiftR11(recipientId: recipientId, giftKey: selected['key'].toString());
      if (mounted) await showDialog<void>(context: context, barrierColor: Colors.black87, builder: (_) => _R11GiftCelebration(icon: selected!['icon']?.toString() ?? '✨', title: _r11Localized(selected![ar ? 'ar' : 'en'], widget.controller.localeCode, ar ? 'هدية وصلت' : 'Gift delivered')));
      await _load();
    } catch (e) { if (mounted) showToast(context, e.toString()); }
  }

  Widget _empty(IconData icon, String text) => ListView(children: [Padding(padding: const EdgeInsets.all(26), child: _R11Notice(icon: icon, text: text))]);
}

class R11SpectatorPage extends StatefulWidget {
  const R11SpectatorPage({super.key, required this.controller, required this.roomCode});
  final AppController controller;
  final String roomCode;
  @override
  State<R11SpectatorPage> createState() => _R11SpectatorPageState();
}

class _R11SpectatorPageState extends State<R11SpectatorPage> {
  Map<String, dynamic> spectator = <String, dynamic>{};
  Timer? timer;
  String? error;

  @override
  void initState() { super.initState(); _load(); timer = Timer.periodic(const Duration(seconds: 2), (_) => _load(silent: true)); }
  @override
  void dispose() {
    timer?.cancel();
    unawaited(widget.controller.api.leaveSpectatorR11(widget.roomCode).then<void>((_) {}).catchError((_) {}));
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    try { final response = await widget.controller.api.spectatorStateR11(widget.roomCode); if (mounted) setState(() { spectator = _r11Map(response['spectator']); error = null; }); }
    catch (e) { if (!silent && mounted) setState(() => error = e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.controller.localeCode == 'ar', room = _r11Map(spectator['room']), state = _r11Map(spectator['state']), players = _r11List(room['players']), handCounts = _r11Map(state['hand_counts']), gifts = _r11List(spectator['gifts']);
    return Scaffold(appBar: AppBar(title: Text('🏟️ ${room['name'] ?? widget.roomCode}'), actions: [Container(margin: const EdgeInsets.all(10), padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: _r11Mint.withValues(alpha: .12), borderRadius: BorderRadius.circular(99)), child: const Row(children: [_R11LiveDot(), SizedBox(width: 6), Text('LIVE', style: TextStyle(color: _r11Mint, fontWeight: FontWeight.w900, fontSize: 9))]))]), body: SafeArea(child: Column(children: [
      Container(width: double.infinity, margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _r11Mint.withValues(alpha: .08), borderRadius: BorderRadius.circular(15), border: Border.all(color: _r11Mint.withValues(alpha: .20))), child: Text(ar ? '🛡️ درع الخصوصية فعال: لا أوراق، لا صوت، ولا محادثة خاصة.' : '🛡️ Privacy Shield: no hands, voice, or private chat.', style: const TextStyle(fontSize: 10, color: _r11Mint))),
      if (error != null) Padding(padding: const EdgeInsets.all(10), child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
      Expanded(child: Container(margin: const EdgeInsets.fromLTRB(12, 0, 12, 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), gradient: const RadialGradient(colors: [Color(0xFF1B6646), Color(0xFF071A12)], radius: .9), border: Border.all(color: _r11Gold.withValues(alpha: .20))), child: Stack(children: [
        Center(child: Container(width: 190, height: 190, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _r11Gold.withValues(alpha: .28)), boxShadow: [BoxShadow(color: _r11Mint.withValues(alpha: .08), blurRadius: 70)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(state['phase']?.toString().toUpperCase() ?? 'PLAYING', style: const TextStyle(color: _r11Gold, fontWeight: FontWeight.w900)),const SizedBox(height: 8),Text(state['turn']?.toString() ?? '—', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),const Text('CURRENT TURN', style: TextStyle(fontSize: 8, color: Colors.white38))]))),
        Positioned.fill(child: Padding(padding: const EdgeInsets.all(16), child: Wrap(alignment: WrapAlignment.spaceAround, runAlignment: WrapAlignment.spaceBetween, spacing: 24, runSpacing: 150, children: players.map((player) { final key = 'user:${player['id']}'; return SizedBox(width: 120, child: Column(mainAxisSize: MainAxisSize.min, children: [_R11Avatar(url: player['avatar']?.toString(), label: player['name']?.toString() ?? '?', size: 52),const SizedBox(height: 4),Text(player['name']?.toString() ?? 'Player', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),Text('🂠 ${handCounts[key] ?? '—'}', style: const TextStyle(color: _r11Gold, fontSize: 9))])); }).toList()))),
      ]))),
      if (gifts.isNotEmpty) SizedBox(height: 48, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 12), scrollDirection: Axis.horizontal, itemCount: gifts.length, separatorBuilder: (_, __) => const SizedBox(width: 7), itemBuilder: (_, index) { final gift = gifts[index]; return Chip(avatar: Text(gift['icon']?.toString() ?? '✨'), label: Text('${gift['sender'] ?? 'Warqnaa'}', style: const TextStyle(fontSize: 9))); })),
      Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), child: Row(children: [Expanded(child: Text('${room['spectators'] ?? 0} 👁  •  Revision ${spectator['state_revision'] ?? '—'}', style: const TextStyle(color: Colors.white54, fontSize: 9))),const Text('VOICE OFF • READ ONLY', style: TextStyle(color: _r11Mint, fontSize: 9, fontWeight: FontWeight.w900))])),
    ])));
  }
}

class R11ReplayViewerPage extends StatefulWidget {
  const R11ReplayViewerPage({super.key, required this.controller, required this.replayId, this.seed = const {}});
  final AppController controller;
  final int replayId;
  final Map<String, dynamic> seed;
  @override
  State<R11ReplayViewerPage> createState() => _R11ReplayViewerPageState();
}

class _R11ReplayViewerPageState extends State<R11ReplayViewerPage> {
  Map<String, dynamic> replay = <String, dynamic>{};
  int frame = 0;
  bool playing = false;
  Timer? timer;
  @override
  void initState() { super.initState(); replay = widget.seed; _load(); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  Future<void> _load() async { try { final response = await widget.controller.api.replayR11(widget.replayId); if (mounted) setState(() => replay = _r11Map(response['replay'])); } catch (e) { if (mounted) showToast(context, e.toString()); } }
  void _toggle() { final frames = _r11List(replay['frames']); if (frames.isEmpty) return; if (playing) { timer?.cancel(); setState(() => playing = false); return; } setState(() => playing = true); timer = Timer.periodic(const Duration(milliseconds: 900), (_) { if (!mounted || frame >= frames.length - 1) { timer?.cancel(); if (mounted) setState(() => playing = false); } else { setState(() => frame++); } }); }
  Future<void> _manage(String action) async {
    try {
      if (action == 'share') {
        final visibility = replay['visibility']?.toString() ?? 'private';
        await widget.controller.api.publishSocialActivityR11(type: 'replay_share', text: widget.controller.localeCode == 'ar' ? 'شاهدوا إعادة مباراتي في عالم ورقنا.' : 'Watch my match replay in Warqnaa Social World.', audience: visibility, replayId: widget.replayId);
        if (mounted) showToast(context, widget.controller.localeCode == 'ar' ? 'تمت مشاركة الإعادة.' : 'Replay shared.');
      } else {
        await widget.controller.api.updateReplayVisibilityR11(widget.replayId, action);
        if (mounted) showToast(context, widget.controller.localeCode == 'ar' ? 'تم تحديث خصوصية الإعادة.' : 'Replay privacy updated.');
      }
      await _load();
    } catch (exception) { if (mounted) showToast(context, exception.toString()); }
  }
  @override
  Widget build(BuildContext context) {
    final frames = _r11List(replay['frames']), current = frames.isEmpty ? <String,dynamic>{} : frames[frame.clamp(0, frames.length - 1).toInt()], state = _r11Map(current['state']), owner = _r11Map(replay['owner']);
    final isOwner = int.tryParse(owner['id']?.toString() ?? '') == widget.controller.currentUserId, canManage = widget.controller.isAdmin || isOwner;
    return Scaffold(appBar: AppBar(title: Text('↻ ${replay['game'] ?? 'Replay'} • ${replay['room_code'] ?? ''}'), actions: [if (canManage) PopupMenuButton<String>(tooltip: widget.controller.localeCode == 'ar' ? 'إدارة الإعادة' : 'Manage replay', onSelected: _manage, itemBuilder: (_) => [const PopupMenuItem(value:'public',child:Text('🌍 Public')),const PopupMenuItem(value:'friends',child:Text('👥 Friends')),const PopupMenuItem(value:'private',child:Text('🔒 Private')),if (isOwner) const PopupMenuDivider(),if (isOwner) const PopupMenuItem(value:'share',child:Text('✦ Share to Social World'))])]), body: SafeArea(child: Column(children: [
      Container(width: double.infinity, margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _r11Mint.withValues(alpha: .08), borderRadius: BorderRadius.circular(15), border: Border.all(color: _r11Mint.withValues(alpha: .20))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('🛡️ PRIVACY-SAFE • NO HANDS • NO VOICE • NO PRIVATE CHAT', style: TextStyle(fontSize: 9, color: _r11Mint, fontWeight: FontWeight.w900)),Padding(padding: const EdgeInsets.only(top: 5), child: Text(replay['integrity_verified'] == true ? '✓ SHA-256 VERIFIED' : '… VERIFYING REPLAY INTEGRITY', style: TextStyle(fontSize: 9, color: replay['integrity_verified'] == true ? _r11Mint : _r11Gold, fontWeight: FontWeight.w900))),if ((replay['sha256']?.toString() ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Text('SHA-256  ${replay['sha256']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'monospace', fontSize: 8, color: Colors.white38)))])),
      Expanded(child: Container(width: double.infinity, margin: const EdgeInsets.fromLTRB(12,0,12,12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const RadialGradient(colors: [Color(0xFF1A5A3F), _r11Deep])), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(current['action']?.toString() ?? 'Ready', style: const TextStyle(fontSize: 24, color: _r11Gold, fontWeight: FontWeight.w900)),const SizedBox(height: 10),Text('${current['phase_after'] ?? '—'}  •  ${current['turn'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w900)),const SizedBox(height: 18),Expanded(child: SingleChildScrollView(child: SelectableText(const JsonEncoder.withIndent('  ').convert(state), style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFFB7D9C5)))))]))),
      Padding(padding: const EdgeInsets.fromLTRB(12,0,12,14), child: Column(children: [Slider(value: frames.isEmpty ? 0 : frame.toDouble(), min: 0, max: math.max(0, frames.length - 1).toDouble(), divisions: frames.length > 1 ? frames.length - 1 : null, onChanged: frames.isEmpty ? null : (value) => setState(() => frame = value.round())),Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(onPressed: frame > 0 ? () => setState(() => frame--) : null, icon: const Icon(Icons.skip_previous)),FilledButton.tonalIcon(onPressed: _toggle, icon: Icon(playing ? Icons.pause : Icons.play_arrow), label: Text('${frames.isEmpty ? 0 : frame + 1} / ${frames.length}')),IconButton(onPressed: frame < frames.length - 1 ? () => setState(() => frame++) : null, icon: const Icon(Icons.skip_next))])]))
    ])));
  }
}

class R11ClubsWorldPage extends StatefulWidget {
  const R11ClubsWorldPage({super.key, required this.controller});
  final AppController controller;
  @override
  State<R11ClubsWorldPage> createState() => _R11ClubsWorldPageState();
}

class _R11ClubsWorldPageState extends State<R11ClubsWorldPage> {
  Map<String, dynamic> data = <String, dynamic>{};
  bool loading = true;
  String? error;
  bool get ar => widget.controller.localeCode == 'ar';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!widget.controller.serverConnected) { if (mounted) setState(() => loading = false); return; }
    if (mounted && data.isEmpty) setState(() => loading = true);
    try {
      final response = await widget.controller.api.clubsWorldR11();
      if (mounted) setState(() { data = response; error = null; });
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.serverConnected && !loading) return ClubsPage(controller: widget.controller);
    final clubs = _r11List(data['clubs']), mine = _r11Map(data['my_club']);
    if (loading && clubs.isEmpty) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(14,14,14,100), children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF132D22), _r11Deep]), border: Border.all(color: _r11Gold.withValues(alpha: .18))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('CLUBS 2.0 • R11', style: TextStyle(color: _r11Gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),const SizedBox(height: 8),Text(ar ? 'راية واحدة، مجلس واحد.' : 'One banner. One majlis.', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),Text(ar ? 'فعاليات النادي، الحضور، الإعلانات، الدوري والنشاط في مكان واحد.' : 'Club events, attendance, announcements, league and activity in one place.', style: const TextStyle(color: Colors.white60, height: 1.5)),if (mine.isEmpty) ...[const SizedBox(height: 14),FilledButton.icon(onPressed: _createClub, icon: const Icon(Icons.add_business_outlined), label: Text(ar ? 'أسّس ناديك' : 'Found your club'))]])),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: _R11Notice(text: error!, icon: Icons.cloud_off_outlined)),
      if (mine.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: InkWell(onTap: () => _openClub(mine), borderRadius: BorderRadius.circular(22), child: _R11GlassCard(accent: _r11Gold, child: ListTile(contentPadding: EdgeInsets.zero, leading: Text(mine['logo']?.toString() ?? '🛡️', style: const TextStyle(fontSize: 36)), title: Text(mine['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('${_r11Localized(mine['league'], widget.controller.localeCode)} • ${mine['members_count']}/${mine['capacity']}'), trailing: const Icon(Icons.chevron_right))))),
      const SizedBox(height: 16), Text(ar ? 'أندية عالم ورقنا' : 'Warqnaa clubs', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),const SizedBox(height: 9),
      ...clubs.map((club) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: InkWell(onTap: () => _openClub(club), borderRadius: BorderRadius.circular(22), child: _R11GlassCard(child: Row(children: [
          Text(club['logo']?.toString() ?? '🛡️', style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(club['name']?.toString() ?? 'Club', style: const TextStyle(fontWeight: FontWeight.w900)),
            Text('${_r11Localized(club['league'], widget.controller.localeCode)} • ${club['members_count']}/${club['capacity']} • ${club['weekly_points']} pts', style: const TextStyle(color: Colors.white54, fontSize: 9)),
          ])),
          FilledButton.tonal(
            onPressed: club['membership'] != null || mine.isNotEmpty ? null : () => _join(club),
            child: Text(club['membership'] != null ? '✓' : (ar ? 'انضم' : 'Join')),
          ),
        ])))),
      ),
    ]));
  }

  Future<void> _join(Map<String, dynamic> club) async { final id = int.tryParse(club['id']?.toString() ?? ''); if (id == null) return; try { final response = await widget.controller.api.joinClubWorldR11(id); if (mounted) showToast(context, response['message']?.toString() ?? 'Done'); await _load(); } catch (e) { if (mounted) showToast(context, e.toString()); } }

  Future<void> _createClub() async {
    final name = TextEditingController(), description = TextEditingController();
    var visibility = 'public';
    final submitted = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: Text(ar ? '🛡️ تأسيس نادي' : '🛡️ Found a club'),
      content: SizedBox(width: 500, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, maxLength: 120, decoration: InputDecoration(labelText: ar ? 'اسم النادي' : 'Club name')),
        TextField(controller: description, maxLength: 1000, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: ar ? 'الوصف' : 'Description')),
        DropdownButtonFormField<String>(initialValue: visibility, decoration: InputDecoration(labelText: ar ? 'نوع الانضمام' : 'Joining'), items: const [DropdownMenuItem(value:'public',child:Text('Public')),DropdownMenuItem(value:'request',child:Text('By request')),DropdownMenuItem(value:'private',child:Text('Private'))], onChanged: (value) => setDialogState(() => visibility = value ?? visibility)),
        const SizedBox(height: 8), Text(ar ? 'يتطلب عضوية الباشا و5,000 توكن.' : 'Requires Pasha membership and 5,000 tokens.', style: const TextStyle(fontSize: 10, color: _r11Gold)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(ar ? 'إلغاء' : 'Cancel')),FilledButton(onPressed: () => Navigator.pop(dialogContext, name.text.trim().length >= 3), child: Text(ar ? 'تأسيس' : 'Create'))],
    )));
    final clubName = name.text.trim(), clubDescription = description.text.trim();
    name.dispose(); description.dispose();
    if (submitted != true || clubName.length < 3) return;
    try {
      final response = await widget.controller.api.createClubWorldR11(name: clubName, description: clubDescription, visibility: visibility);
      if (mounted) showToast(context, response['message']?.toString() ?? (ar ? 'تم تأسيس النادي.' : 'Club created.'));
      await _load();
    } catch (exception) { if (mounted) showToast(context, exception.toString()); }
  }

  Future<void> _openClub(Map<String, dynamic> seed) async {
    final id = int.tryParse(seed['id']?.toString() ?? '');
    if (id == null) return;
    try {
      final response = await widget.controller.api.clubWorldR11(id);
      if (!mounted) return;
      final club = _r11Map(response['club']), membership = _r11Map(response['membership']);
      final members = _r11List(club['members']), announcements = _r11List(response['announcements']), events = _r11List(response['events']), requests = _r11List(response['join_requests']);
      await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheetContext) => DraggableScrollableSheet(expand: false, initialChildSize: .82, maxChildSize: .96, builder: (context, scrollController) => ListView(controller: scrollController, padding: const EdgeInsets.fromLTRB(18,0,18,30), children: [
        Row(children: [Text(club['logo']?.toString() ?? '🛡️', style: const TextStyle(fontSize: 52)),const SizedBox(width: 12),Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(club['name']?.toString() ?? 'Club', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),Text('${_r11Localized(club['league'], widget.controller.localeCode)} • ${club['members_count']}/${club['capacity']} • ${club['weekly_points']} pts', style: const TextStyle(color: _r11Gold, fontSize: 10))]))]),
        if ((club['description']?.toString() ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text(club['description'].toString(), style: const TextStyle(color: Colors.white70, height: 1.5))),
        if (membership.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Wrap(spacing: 8, runSpacing: 8, children: [
          if (membership['can_manage'] == true || const {'owner','moderator'}.contains(membership['role'])) FilledButton.tonalIcon(onPressed: () { Navigator.pop(sheetContext); unawaited(_announce(id)); }, icon: const Icon(Icons.campaign_outlined), label: Text(ar ? 'إعلان' : 'Announce')),
          OutlinedButton.icon(onPressed: () { Navigator.pop(sheetContext); unawaited(_leave(id)); }, icon: const Icon(Icons.logout), label: Text(ar ? 'مغادرة' : 'Leave')),
        ])),
        if (requests.isNotEmpty) ...[const SizedBox(height: 18),Text(ar ? 'طلبات الانضمام' : 'Join requests', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),const SizedBox(height: 8),...requests.map((request) { final person = _r11Map(request['user']); return ListTile(contentPadding: EdgeInsets.zero, leading: _R11Avatar(url: person['avatar']?.toString(), label: person['name']?.toString() ?? '?'), title: Text(person['name']?.toString() ?? 'Player'), trailing: Wrap(spacing: 4, children: [IconButton(onPressed: () => _respondRequest(int.parse(request['id'].toString()), 'accepted', sheetContext), icon: const Icon(Icons.check_circle, color: _r11Mint)),IconButton(onPressed: () => _respondRequest(int.parse(request['id'].toString()), 'rejected', sheetContext), icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent))])); })],
        const SizedBox(height: 18),Text(ar ? 'الإعلانات' : 'Announcements', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),const SizedBox(height: 8),
        if (announcements.isEmpty) const Text('—', style: TextStyle(color: Colors.white38)) else ...announcements.map((item) => _R11GlassCard(accent: item['pinned'] == true ? _r11Gold : null, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${item['pinned'] == true ? '📌 ' : ''}${item['title'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900)),const SizedBox(height: 5),Text(item['body']?.toString() ?? '', style: const TextStyle(color: Colors.white60, height: 1.45)),const SizedBox(height: 5),Text(item['author']?.toString() ?? '', style: const TextStyle(color: _r11Gold, fontSize: 9))]))),
        if (events.isNotEmpty) ...[const SizedBox(height: 18),Text(ar ? 'فعاليات النادي' : 'Club events', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),const SizedBox(height: 8),...events.map((item) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.auto_awesome, color: _r11Gold), title: Text(_r11Localized(item['title'], widget.controller.localeCode, 'Event')), subtitle: Text('${item['starts_at'] ?? ''} • ${item['going'] ?? 0} going')))],
        const SizedBox(height: 18),Text(ar ? 'الأعضاء' : 'Members', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),const SizedBox(height: 8),
        ...members.map((person) => ListTile(contentPadding: EdgeInsets.zero, leading: _R11Avatar(url: person['avatar']?.toString(), label: person['name']?.toString() ?? '?'), title: Text(person['name']?.toString() ?? 'Player'), subtitle: Text('${person['role'] ?? 'member'} • ${person['weekly_points'] ?? 0} pts'), trailing: person['online'] == true ? const _R11LiveDot() : null)),
      ])));
    } catch (exception) { if (mounted) showToast(context, exception.toString()); }
  }

  Future<void> _announce(int clubId) async {
    final title = TextEditingController(), body = TextEditingController();
    var pinned = false;
    final submitted = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(title: Text(ar ? '📣 إعلان النادي' : '📣 Club announcement'), content: SizedBox(width: 500, child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, maxLength: 140, decoration: InputDecoration(labelText: ar ? 'العنوان' : 'Title')),TextField(controller: body, minLines: 3, maxLines: 7, maxLength: 2000, decoration: InputDecoration(labelText: ar ? 'الإعلان' : 'Announcement')),SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, value: pinned, title: Text(ar ? 'تثبيت الإعلان' : 'Pin announcement'), onChanged: (value) => setDialogState(() => pinned = value))])), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(ar ? 'إلغاء' : 'Cancel')),FilledButton(onPressed: () => Navigator.pop(dialogContext, title.text.trim().isNotEmpty && body.text.trim().isNotEmpty), child: Text(ar ? 'نشر' : 'Publish'))])));
    final announcementTitle = title.text.trim(), announcementBody = body.text.trim();
    title.dispose(); body.dispose();
    if (submitted != true || announcementTitle.isEmpty || announcementBody.isEmpty) return;
    try { await widget.controller.api.announceClubWorldR11(clubId, title: announcementTitle, body: announcementBody, pinned: pinned); if (mounted) showToast(context, ar ? 'تم نشر الإعلان.' : 'Announcement published.'); await _load(); } catch (exception) { if (mounted) showToast(context, exception.toString()); }
  }

  Future<void> _leave(int clubId) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: Text(ar ? 'مغادرة النادي؟' : 'Leave club?'), content: Text(ar ? 'إذا كنت المالك الوحيد فسيُغلق النادي.' : 'If you are the only owner, the club will close.'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(ar ? 'إلغاء' : 'Cancel')),FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(ar ? 'مغادرة' : 'Leave'))]));
    if (confirmed != true) return;
    try { final response = await widget.controller.api.leaveClubWorldR11(clubId); if (mounted) showToast(context, response['message']?.toString() ?? 'Done'); await _load(); } catch (exception) { if (mounted) showToast(context, exception.toString()); }
  }

  Future<void> _respondRequest(int requestId, String status, BuildContext sheetContext) async {
    try { await widget.controller.api.respondClubJoinRequestR11(requestId, status); if (sheetContext.mounted) Navigator.pop(sheetContext); await _load(); } catch (exception) { if (mounted) showToast(context, exception.toString()); }
  }
}

class R11AdminSocialWorldPanel extends StatefulWidget {
  const R11AdminSocialWorldPanel({super.key, required this.controller});
  final AppController controller;
  @override
  State<R11AdminSocialWorldPanel> createState() => _R11AdminSocialWorldPanelState();
}

class _R11AdminSocialWorldPanelState extends State<R11AdminSocialWorldPanel> {
  Map<String, dynamic> data = <String, dynamic>{};
  bool loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { if (!widget.controller.serverConnected) { if (mounted) setState(() => loading = false); return; } try { final response = await widget.controller.api.adminSocialWorldR11(); if (mounted) setState(() => data = response); } catch (e) { if (mounted) showToast(context, e.toString()); } finally { if (mounted) setState(() => loading = false); } }
  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final stats = _r11Map(data['stats']), settings = _r11Map(data['settings']), activities = _r11List(data['activities']), events = _r11List(data['events']), replays = _r11List(data['replays']), spectators = _r11List(data['spectators']);
    return RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(12), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF123625), _r11Deep]), border: Border.all(color: _r11Mint.withValues(alpha: .18))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('R11 • BUILD 230 • CONTROL PLANE', style: TextStyle(color: _r11Gold, fontSize: 9, fontWeight: FontWeight.w900)),SizedBox(height: 7),Text('✦ Admin Social World', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),Text('Privacy • Feed • Events • Spectators • Replays • Gifts', style: TextStyle(color: Colors.white54))])),
      const SizedBox(height: 10), Wrap(spacing: 8, runSpacing: 8, children: stats.entries.map((entry) => SizedBox(width: 140, child: _R11GlassCard(child: Column(children: [Text('${entry.value}', style: const TextStyle(fontSize: 20, color: _r11Gold, fontWeight: FontWeight.w900)),Text(entry.key.replaceAll('_',' '), textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: Colors.white54))])))).toList()),
      const SizedBox(height: 10), _R11GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Feature controls', style: TextStyle(fontWeight: FontWeight.w900)),...['social_world_enabled','social_feed_enabled','social_events_enabled','spectator_mode_enabled','replay_system_enabled','animated_gifts_enabled'].map((key) => SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, value: settings[key] == true, title: Text(key.replaceAll('_',' ')), onChanged: (value) async { final next = Map<String,dynamic>.from(settings)..[key] = value; try { await widget.controller.api.adminUpdateSocialWorldSettingsR11(next); await _load(); } catch (e) { if (mounted) showToast(context, e.toString()); } }))])),
      const SizedBox(height: 12), const Text('Moderation queue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),const SizedBox(height: 8),
      ...activities.take(20).map((item) => _adminRow(icon:'◉', title:_r11Map(item['actor'])['username']?.toString() ?? 'Activity', subtitle:'${item['type']} • ${item['audience']}', action:item['hidden']==true?'restore':'hide', onAction:(action)=>widget.controller.api.adminSocialActivityActionR11(int.parse(item['id'].toString()),action))),
      ...events.take(12).map((item) => _adminRow(icon:'✦', title:_r11Localized(item['title'],widget.controller.localeCode,'Event'), subtitle:'${item['status']} • ${item['starts_at']}', action:item['featured']==true?'unfeature':'feature', onAction:(action)=>widget.controller.api.adminSocialEventActionR11(int.parse(item['id'].toString()),action))),
      ...replays.take(12).map((item) => _adminRow(icon:'↻', title:'${_r11Map(item['room'])['code'] ?? ''} • ${_r11Map(item['game'])['key'] ?? ''}', subtitle:'${item['status']} • ${item['frames_count']} frames', action:item['status']=='hidden'?'restore':'hide', onAction:(action)=>widget.controller.api.adminReplayActionR11(int.parse(item['id'].toString()),action))),
      ...spectators.take(12).map((item) => _adminRow(icon:'🏟️', title:_r11Map(item['user'])['username']?.toString() ?? 'Spectator', subtitle:'live spectator • ${item['last_seen_at'] ?? ''}', action:'evict', onAction:(_)=>widget.controller.api.adminEvictSpectatorR11(int.parse(item['id'].toString())))),
    ]));
  }
  Widget _adminRow({required String icon, required String title, required String subtitle, required String action, required Future<Map<String,dynamic>> Function(String) onAction}) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _R11GlassCard(child: Row(children: [Text(icon, style: const TextStyle(fontSize: 24)),const SizedBox(width: 10),Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 9))])),TextButton(onPressed: () async { try { await onAction(action); await _load(); } catch (e) { if (mounted) showToast(context, e.toString()); } }, child: Text(action))])));
}

class _R11GlassCard extends StatelessWidget {
  const _R11GlassCard({required this.child, this.accent});
  final Widget child;
  final Color? accent;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: .78), borderRadius: BorderRadius.circular(22), border: Border.all(color: (accent ?? _r11Mint).withValues(alpha: .14)), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 20, offset: Offset(0, 9))]), child: child);
}

class _R11Avatar extends StatelessWidget {
  const _R11Avatar({this.url, required this.label, this.size = 42});
  final String? url;
  final String label;
  final double size;
  @override
  Widget build(BuildContext context) {
    final initial = label.isEmpty ? '?' : label.substring(0, 1);
    final absoluteUrl = url != null && (url!.startsWith('https://') || url!.startsWith('http://'));
    return Container(width: size, height: size, decoration: BoxDecoration(borderRadius: BorderRadius.circular(size * .31), border: Border.all(color: _r11Gold.withValues(alpha: .32)), color: Colors.white.withValues(alpha: .06)), clipBehavior: Clip.antiAlias, child: absoluteUrl ? Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(initial))) : Center(child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w900))));
  }
}

class _R11LiveDot extends StatefulWidget { const _R11LiveDot(); @override State<_R11LiveDot> createState() => _R11LiveDotState(); }
class _R11LiveDotState extends State<_R11LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override void initState() { super.initState(); controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true); }
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => FadeTransition(opacity: Tween<double>(begin: .35,end:1).animate(controller), child: Container(width: 8,height: 8,decoration: const BoxDecoration(shape:BoxShape.circle,color:_r11Mint,boxShadow:[BoxShadow(color:Color(0x8855E6A5),blurRadius:9,spreadRadius:2)])));
}

class _R11Notice extends StatelessWidget {
  const _R11Notice({required this.text, required this.icon});
  final String text;
  final IconData icon;
  @override Widget build(BuildContext context) => _R11GlassCard(child: Padding(padding: const EdgeInsets.all(22), child: Column(children: [Icon(icon, size: 46, color: _r11Gold),const SizedBox(height: 9),Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, height: 1.5))])));
}

class _R11GiftCelebration extends StatelessWidget {
  const _R11GiftCelebration({required this.icon, required this.title});
  final String icon;
  final String title;
  @override Widget build(BuildContext context) => Dialog(backgroundColor: Colors.transparent, child: TweenAnimationBuilder<double>(tween: Tween(begin:.35,end:1), duration: const Duration(milliseconds: 650), curve: Curves.elasticOut, builder: (_, value, child) => Transform.scale(scale:value, child: child), child: Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const RadialGradient(colors:[Color(0xFF285B42),_r11Deep]), border: Border.all(color:_r11Gold.withValues(alpha:.35)), boxShadow:[BoxShadow(color:_r11Gold.withValues(alpha:.18),blurRadius:60)]), child: Column(mainAxisSize:MainAxisSize.min,children:[Text(icon,style:const TextStyle(fontSize:86)),const SizedBox(height:8),Text(title,textAlign:TextAlign.center,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:5),const Text('Delivered • Social-only • Fair play',style:TextStyle(color:_r11Mint,fontSize:9)),const SizedBox(height:14),FilledButton(onPressed:()=>Navigator.pop(context),child:const Text('✓'))]))));
}

class _R11TabHeader extends SliverPersistentHeaderDelegate {
  const _R11TabHeader(this.tabBar);
  final TabBar tabBar;
  @override double get minExtent => 68;
  @override double get maxExtent => 68;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Material(color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha:.96), child: Padding(padding: const EdgeInsets.symmetric(horizontal:10), child: tabBar));
  @override bool shouldRebuild(covariant _R11TabHeader oldDelegate) => false;
}
