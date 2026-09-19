part of 'main.dart';

/// R6.4 merges R6.2 (play/rooms), R6.3 (store/inventory), and R6.4
/// (community/competitive) into one additive, server-authoritative release.
const String warqnaaR64Release = '1.7.0+640-world-championship';

class R64PlayHubPage extends StatefulWidget {
  const R64PlayHubPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<R64PlayHubPage> createState() => _R64PlayHubPageState();
}

class _R64PlayHubPageState extends State<R64PlayHubPage> {
  bool busy = false;

  bool get ar => widget.controller.localeCode == 'ar';

  void _quickMatch() {
    final game = widget.controller.homeGames.firstOrNull ?? customerGamesR101.first;
    showGameLobby(context, widget.controller, game);
  }

  Future<void> _openRooms() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => R64RoomBrowserPage(controller: widget.controller),
      ),
    );
  }

  Future<void> _createParty() async {
    await Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => R65PartyPage(controller: widget.controller)));
  }

  void _open(Widget page) => Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      _R64PlayCommandBar(
        controller: widget.controller,
        busy: busy,
        onQuickMatch: _quickMatch,
        onRooms: _openRooms,
        onParty: _createParty,
        onWatch: () => _open(R11SocialWorldPage(controller: widget.controller)),
        onRanked: () => _open(R12CompetitiveArenaPage(controller: widget.controller)),
      ),
      Expanded(child: GamesPage(controller: widget.controller)),
    ]);
  }
}

class _R64PlayCommandBar extends StatelessWidget {
  const _R64PlayCommandBar({
    required this.controller,
    required this.busy,
    required this.onQuickMatch,
    required this.onRooms,
    required this.onParty,
    required this.onWatch,
    required this.onRanked,
  });

  final AppController controller;
  final bool busy;
  final VoidCallback onQuickMatch;
  final VoidCallback onRooms;
  final VoidCallback onParty;
  final VoidCallback onWatch;
  final VoidCallback onRanked;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final actions = <(IconData, String, VoidCallback)>[
      (Icons.bolt_rounded, ar ? 'لعب سريع' : 'Quick match', onQuickMatch),
      (Icons.meeting_room_outlined, ar ? 'الغرف' : 'Rooms', onRooms),
      (Icons.groups_2_outlined, ar ? 'مجموعة' : 'Party', onParty),
      (Icons.visibility_outlined, ar ? 'شاهد' : 'Watch', onWatch),
      (Icons.workspace_premium_outlined, 'Ranked', onRanked),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 3),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: <Color>[Color(0xff193b2b), Color(0xff321f2a), Color(0xff171717)]),
        border: Border.all(color: const Color(0xffffcf58).withValues(alpha: .22)),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x44000000), blurRadius: 22, offset: Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          const Icon(Icons.public_rounded, color: Color(0xffffcf58)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(ar ? 'مركز اللعب العالمي' : 'World play center', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(ar ? 'غرف • مجموعات • مشاهدة • منافسة' : 'ROOMS • PARTY • LIVE • RANKED', style: TextStyle(color: Colors.white.withValues(alpha: .52), fontSize: 8, letterSpacing: 1.1)),
            ]),
          ),
          _R64NetworkBadge(online: controller.serverConnected, ar: ar),
        ]),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: actions.map((action) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 7),
              child: ActionChip(
                avatar: busy && action.$2 == (ar ? 'مجموعة' : 'Party')
                    ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(action.$1, size: 17),
                label: Text(action.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                onPressed: busy ? null : action.$3,
              ),
            )).toList(growable: false),
          ),
        ),
      ]),
    );
  }
}

class _R64NetworkBadge extends StatelessWidget {
  const _R64NetworkBadge({required this.online, required this.ar});
  final bool online;
  final bool ar;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: (online ? const Color(0xff55e68a) : Colors.orangeAccent).withValues(alpha: .12),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: (online ? const Color(0xff55e68a) : Colors.orangeAccent).withValues(alpha: .24)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Icon(online ? Icons.cloud_done_outlined : Icons.offline_bolt_outlined, size: 13, color: online ? const Color(0xff55e68a) : Colors.orangeAccent),
      const SizedBox(width: 4),
      Text(online ? (ar ? 'متصل' : 'Online') : (ar ? 'محلي' : 'Local'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
    ]),
  );
}

class R64RoomBrowserPage extends StatefulWidget {
  const R64RoomBrowserPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<R64RoomBrowserPage> createState() => _R64RoomBrowserPageState();
}

class _R64RoomBrowserPageState extends State<R64RoomBrowserPage> {
  String gameId = customerGamesR101.first.id;
  List<Map<String, dynamic>> rooms = <Map<String, dynamic>>[];
  bool loading = true;
  String? error;
  int _requestGeneration = 0;
  bool _joining = false;

  bool get ar => widget.controller.localeCode == 'ar';
  GameInfo get game => gamesCatalog.where((item) => item.id == gameId).firstOrNull ?? customerGamesR101.first;

  @override
  void initState() {
    super.initState();
    gameId = (widget.controller.homeGames.firstOrNull ?? customerGamesR101.first).id;
    unawaited(_load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final generation = ++_requestGeneration;
    final requestedGame = gameId;
    setState(() { loading = true; error = null; rooms = <Map<String, dynamic>>[]; });
    if (!widget.controller.serverConnected) {
      setState(() { loading = false; error = ar ? 'شغّل خادم Laravel لعرض الغرف العامة.' : 'Start the Laravel server to browse public rooms.'; });
      return;
    }
    try {
      final response = await widget.controller.api.availableRooms(requestedGame);
      if (!mounted || generation != _requestGeneration) return;
      final raw = response['rooms'];
      rooms = raw is List ? raw.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList(growable: false) : <Map<String, dynamic>>[];
    } catch (exception) {
      if (!mounted || generation != _requestGeneration) return;
      error = friendlyErrorMessage(exception, widget.controller.localeCode);
    }
    if (mounted && generation == _requestGeneration) setState(() => loading = false);
  }

  Future<void> _join(Map<String, dynamic> room) async {
    final code = room['code']?.toString() ?? '';
    if (code.isEmpty || _joining) return;
    final selectedGame = gamesCatalog.where((item) => item.id == (room['game'] ?? gameId)).firstOrNull ?? game;
    setState(() => _joining = true);
    try {
      // The room page owns admission. Do not send a duplicate join here.
      await openGameRoom(context, widget.controller, selectedGame, options: RoomLaunchOptions(
        roomCode: code,
        roomName: room['name']?.toString() ?? 'Warqnaa',
        playerCount: int.tryParse('${room['max_players']}') ?? 4,
        turnSeconds: int.tryParse('${room['turn_seconds']}') ?? 10,
        singleRound: room['single_round'] == true,
        voiceEnabled: room['voice_enabled'] == true,
        visibility: room['visibility']?.toString() ?? 'public',
      ));
      await _load();
    } catch (exception) {
      if (mounted) showToast(context, friendlyErrorMessage(exception, widget.controller.localeCode));
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(ar ? 'الغرف المباشرة' : 'Live rooms', style: const TextStyle(fontWeight: FontWeight.w900)),
      actions: <Widget>[IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => showCreateRoom(context, widget.controller, game),
      icon: const Icon(Icons.add_rounded),
      label: Text(ar ? 'أنشئ غرفة' : 'Create room'),
    ),
    body: SafeArea(
      child: Column(children: <Widget>[
        SizedBox(
          height: 54,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            scrollDirection: Axis.horizontal,
            children: customerGamesR101.map((item) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: ChoiceChip(
                selected: gameId == item.id,
                label: Text('${item.icon} ${L.t(widget.controller.localeCode, item.id)}'),
                onSelected: (_) { setState(() => gameId = item.id); unawaited(_load()); },
              ),
            )).toList(growable: false),
          ),
        ),
        if (loading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              children: <Widget>[
                if (error != null) _R64StateCard(icon: Icons.cloud_off_outlined, text: error!),
                if (!loading && error == null && rooms.isEmpty) _R64StateCard(icon: Icons.meeting_room_outlined, text: ar ? 'لا توجد غرف عامة الآن. كن أول من ينشئ مجلسًا.' : 'No public rooms yet. Create the first table.'),
                ...rooms.map((room) => _R64RoomCard(room: room, ar: ar, onJoin: () => _join(room))),
              ],
            ),
          ),
        ),
      ]),
    ),
  );
}

class _R64RoomCard extends StatelessWidget {
  const _R64RoomCard({required this.room, required this.ar, required this.onJoin});
  final Map<String, dynamic> room;
  final bool ar;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final players = room['players_count'] ?? room['players'] ?? 0;
    final capacity = room['max_players'] ?? room['player_count'] ?? room['capacity'] ?? 4;
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xffffcf58).withValues(alpha: .12),
          child: Icon(room['voice_enabled'] == true ? Icons.mic_rounded : Icons.style_rounded, color: const Color(0xffffcf58)),
        ),
        title: Text(room['name']?.toString() ?? '${ar ? 'غرفة' : 'Room'} ${room['code'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('$players/$capacity • ${room['turn_seconds'] ?? 10}s • ${room['code'] ?? ''}'),
        trailing: FilledButton(onPressed: onJoin, child: Text(ar ? 'دخول' : 'Join')),
      ),
    );
  }
}

class _R64StateCard extends StatelessWidget {
  const _R64StateCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .035), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: .07))),
    child: Column(children: <Widget>[Icon(icon, size: 42, color: Colors.white38), const SizedBox(height: 10), Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, height: 1.5))]),
  );
}
