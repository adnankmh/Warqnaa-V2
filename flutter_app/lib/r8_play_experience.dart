part of 'main.dart';

/// Shared native lobby and card interaction components for Android and Web.
/// Activity labels describe capabilities; player counts require server data.
class R8HomeLobby extends StatelessWidget {
  const R8HomeLobby({super.key, required this.controller, required this.onTab});
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final featured = <GameInfo>[
      ...controller.homeGames,
      ...customerGamesR101.where((game) => !controller.homeGameIds.contains(game.id)),
    ].take(6).toList();
    final first = featured.first;
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 600 ? 3 : 2;
      return ListView(
        key: const PageStorageKey('r8-home-scroll'),
        padding: EdgeInsets.fromLTRB(constraints.maxWidth > 700 ? 24 : 14, 12, constraints.maxWidth > 700 ? 24 : 14, 24),
        children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ar ? 'ورقنا' : 'WARQNAA', style: const TextStyle(fontSize: 25, height: 1.1, fontWeight: FontWeight.w900, color: Color(0xffffdf91))),
              const SizedBox(height: 5),
              Text(ar ? 'لمّة حلوة… وورقة رابحة' : 'Good company. Great games.', style: const TextStyle(color: Color(0xffa8b8b0), fontSize: 12)),
            ])),
            ActionChip(
              avatar: const Icon(Icons.military_tech_rounded, size: 18, color: Color(0xffffd276)),
              label: Text('${ar ? 'المستوى' : 'Level'} ${controller.level}'),
              onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R61ProfilePage(controller: controller))),
            ),
          ]),
          const SizedBox(height: 16),
          _R8WelcomeTable(controller: controller, game: first),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _R8Portal(icon: Icons.meeting_room_outlined, label: ar ? 'الغرف' : 'Rooms', onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R64RoomBrowserPage(controller: controller))))),
            const SizedBox(width: 8),
            Expanded(child: _R8Portal(icon: Icons.group_add_outlined, label: ar ? 'مع الأصدقاء' : 'With friends', onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R65PartyPage(controller: controller))))),
            const SizedBox(width: 8),
            Expanded(child: _R8Portal(icon: Icons.storefront_outlined, label: ar ? 'المقتنيات' : 'Collection', onTap: () => onTab(0))),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Text(ar ? 'اختر لعبتك' : 'Choose your game', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
            IconButton(tooltip: ar ? 'تخصيص ألعابك' : 'Customize your games', onPressed: () => showHomeGamesSelector(context, controller), icon: const Icon(Icons.tune_rounded, size: 20)),
            TextButton(onPressed: () => onTab(1), child: Text(ar ? 'كل الألعاب' : 'All games')),
          ]),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featured.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: constraints.maxWidth < 360 ? 158 : 174),
            itemBuilder: (context, index) => R8GameTile(game: featured[index], locale: controller.localeCode, onTap: () => showGameLobby(context, controller, featured[index])),
          ),
          const SizedBox(height: 20),
          _R61SocialStrip(controller: controller, onOpen: () => onTab(3)),
          const SizedBox(height: 12),
          _R8Portal(icon: Icons.emoji_events_outlined, label: ar ? 'المنافسات ولوحة المتصدرين' : 'Competitions & leaderboards', onTap: () => onTab(4)),
        ],
      );
    });
  }
}

class _R8WelcomeTable extends StatelessWidget {
  const _R8WelcomeTable({required this.controller, required this.game});
  final AppController controller;
  final GameInfo game;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xff175b48), Color(0xff0b3029), Color(0xff15251f)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffc8a65d).withValues(alpha: .45)),
        boxShadow: const [BoxShadow(color: Color(0x50000000), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: LayoutBuilder(builder: (context, box) {
        final narrow = box.maxWidth < 340;
        return Padding(
          padding: EdgeInsets.all(narrow ? 16 : 20),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ar ? 'طاولتك بانتظارك' : 'Your table awaits', style: TextStyle(fontSize: narrow ? 19 : 23, fontWeight: FontWeight.w900, color: const Color(0xffffebbf))),
              const SizedBox(height: 6),
              Text(controller.serverConnected ? (ar ? 'اختر مجلسك وابدأ اللعب' : 'Find a room and join the game') : (ar ? 'تدرّب مع الكمبيوتر واصقل لعبك' : 'Practice your next winning hand'), style: const TextStyle(color: Color(0xffbbd2c6), fontSize: 12, height: 1.4)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => showGameLobby(context, controller, game),
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: Text('${ar ? 'العب' : 'Play'} ${L.t(controller.localeCode, game.id)}'),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xffefce7b), foregroundColor: const Color(0xff19291f), minimumSize: const Size(0, 44)),
              ),
            ])),
            const SizedBox(width: 8),
            ExcludeSemantics(child: SizedBox(
              width: narrow ? 82 : 110, height: 116,
              child: Stack(alignment: Alignment.center, children: [
                Transform.translate(offset: const Offset(-21, 2), child: Transform.rotate(angle: -.24, child: const PlayingCard(label: 'K♠', width: 55, height: 82))),
                Transform.translate(offset: const Offset(20, 2), child: Transform.rotate(angle: .24, child: const PlayingCard(label: 'Q♦', width: 55, height: 82))),
                Transform.translate(offset: const Offset(0, -8), child: const PlayingCard(label: 'A♥', width: 57, height: 86)),
              ]),
            )),
          ]),
        );
      }),
    );
  }
}

class _R8Portal extends StatelessWidget {
  const _R8Portal({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xff1c2b24),
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(15),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 23, color: const Color(0xffe4c47f)),
        const SizedBox(height: 6),
        Text(label, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ])),
    ),
  );
}

class R8GameTile extends StatelessWidget {
  const R8GameTile({super.key, required this.game, required this.locale, required this.onTap});
  final GameInfo game;
  final String locale;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final ar = locale == 'ar';
    return Semantics(
      button: true, label: L.t(locale, game.id),
      child: Material(
        color: const Color(0xff1b2822),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: const Color(0xffc6ab74).withValues(alpha: .23))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: Stack(fit: StackFit.expand, children: [
              Image.asset(r101GameArtAsset(game.id), fit: BoxFit.cover, excludeFromSemantics: true,
                errorBuilder: (_, __, ___) => ColoredBox(color: game.color, child: const Icon(Icons.style_rounded, color: Color(0xffffe5a9), size: 44))),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x60101c16)]))),
            ])),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(L.t(locale, game.id), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(ar ? 'ابدأ اللعب' : 'Start playing', style: const TextStyle(fontSize: 10, color: Color(0xffacbeb2))),
              ])),
              Icon(ar ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: const Color(0xffe6c57c), size: 21),
            ])),
          ]),
        ),
      ),
    );
  }
}

/// Card ranks remain legible with 13+ cards. Large rummy hands scroll instead
/// of shrinking every card to a tiny unreadable thumbnail.
class R8CardHand extends StatelessWidget {
  const R8CardHand({super.key, required this.count, required this.cardBuilder, this.selectedIndex, this.compact = false});
  final int count;
  final int? selectedIndex;
  final bool compact;
  final Widget Function(int index, double width, double height) cardBuilder;
  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      final width = compact ? 48.0 : 58.0;
      final height = width * 1.48;
      final available = math.max(width, constraints.maxWidth - 16);
      final step = count <= 1 ? 0.0 : ((available - width) / (count - 1)).clamp(24.0, width + 5).toDouble();
      final span = width + step * (count - 1);
      final order = [for (var i = 0; i < count; i++) if (i != selectedIndex) i, if (selectedIndex != null && selectedIndex! < count && selectedIndex! >= 0) selectedIndex!];
      final cards = SizedBox(width: span, height: height + 20, child: Stack(clipBehavior: Clip.none, children: [
        for (final index in order)
          Positioned(key: ValueKey('r8-hand-$index'), left: step * index, top: selectedIndex == index ? 0 : 12, width: width, height: height,
            child: cardBuilder(index, width, height)),
      ]));
      return Directionality(textDirection: TextDirection.ltr, child: SizedBox(height: height + 20, child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(width: math.max(available, span), child: Center(child: cards)),
      )));
    });
  }
}

class R8TableSeat extends StatelessWidget {
  const R8TableSeat({super.key, required this.name, required this.avatar, required this.detail, required this.active, required this.onTap, this.seconds, this.turnSeconds = 10, this.compact = false});
  final String name;
  final Widget avatar;
  final String detail;
  final bool active;
  final VoidCallback onTap;
  final int? seconds;
  final int turnSeconds;
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$name, $detail', button: true,
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: compact ? 78 : 92,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: active ? const Color(0xff214b3b) : const Color(0xe619241f), borderRadius: BorderRadius.circular(15), border: Border.all(color: active ? const Color(0xffffd780) : const Color(0xff54634f), width: active ? 1.8 : .7)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox.square(dimension: compact ? 29 : 38, child: FittedBox(child: avatar)),
        const SizedBox(height: 3),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 9 : 11, fontWeight: FontWeight.w800)),
        Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 8 : 9, color: const Color(0xffd7c89d))),
        if (active && seconds != null) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(value: (seconds! / math.max(1, turnSeconds)).clamp(0.0, 1.0), minHeight: 3, borderRadius: BorderRadius.circular(3), color: seconds! <= 3 ? Colors.redAccent : const Color(0xffefd18a), backgroundColor: Colors.black26),
        ],
      ]),
    )),
  );
}

/// Rotate presentation only. Engine seat order/team ownership is untouched.
int r8RelativeSeat(List<dynamic> players, int index, String? myKey) {
  if (players.isEmpty || myKey == null || myKey.isEmpty) return index;
  final mine = players.indexWhere((p) => p is Map && (p['key'] ?? p['user_key'])?.toString() == myKey);
  return mine < 0 ? index : (index - mine + players.length) % players.length;
}
