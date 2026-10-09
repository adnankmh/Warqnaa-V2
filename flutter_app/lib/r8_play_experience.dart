part of 'main.dart';

/// R18 luxury lobby for Android/Web. Original Warqnaa visual language:
/// deep navy glass, cyan focus lines and warm gold highlights.
const String warqnaaR18VisualLuxury = 'R18-visual-luxury-1';

class R8HomeLobby extends StatelessWidget {
  const R8HomeLobby({super.key, required this.controller, required this.onTab});
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final games = <GameInfo>[...controller.homeGames, ...customerGamesR101.where((g) => !controller.homeGameIds.contains(g.id))];
    final first = games.first;
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff071827), Color(0xff07131f), Color(0xff090d14)])),
      child: LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 980;
        final pad = box.maxWidth >= 700 ? 24.0 : 14.0;
        return ListView(key: const PageStorageKey('r8-home-scroll'), padding: EdgeInsets.fromLTRB(pad, 12, pad, 28), children: [
          _R18BrandHeader(controller: controller),
          const SizedBox(height: 12),
          _R18Hero(controller: controller, onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R12CompetitiveArenaPage(controller: controller)))),
          const SizedBox(height: 12),
          R9SessionBanner(controller: controller),
          const SizedBox(height: 14),
          if (wide)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 6, child: _R8WelcomeTable(controller: controller, game: first)),
              const SizedBox(width: 12),
              Expanded(flex: 4, child: _R18FeaturePanel(controller: controller, onStore: () => onTab(0))),
            ])
          else ...[
            _R8WelcomeTable(controller: controller, game: first),
            const SizedBox(height: 12),
            _R18FeaturePanel(controller: controller, onStore: () => onTab(0)),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _R8Portal(icon: Icons.meeting_room_outlined, label: ar ? 'الغرف' : 'Rooms', accent: const Color(0xff27d7e9), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R64RoomBrowserPage(controller: controller))))),
            const SizedBox(width: 8),
            Expanded(child: _R8Portal(icon: Icons.group_add_outlined, label: ar ? 'مع الأصدقاء' : 'With friends', accent: const Color(0xffffbd48), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R65PartyPage(controller: controller))))),
            const SizedBox(width: 8),
            Expanded(child: _R8Portal(icon: Icons.storefront_outlined, label: ar ? 'المقتنيات' : 'Collection', accent: const Color(0xffa884ff), onTap: () => onTab(0))),
          ]),
          const SizedBox(height: 14),
          HomeQuickActionsV170(controller: controller, onTab: onTab),
          const SizedBox(height: 20),
          R9GameLibrary(controller: controller, games: games, onAllGames: () => onTab(1)),
          const SizedBox(height: 18),
          _R18DiscoveryShelf(controller: controller, onStore: () => onTab(0), onSocial: () => onTab(3)),
          const SizedBox(height: 14),
          _R61SocialStrip(controller: controller, onOpen: () => onTab(3)),
          const SizedBox(height: 12),
          _R8Portal(icon: Icons.emoji_events_outlined, label: ar ? 'المسابقات والبطولات ولوحة المتصدرين' : 'Competitions, tournaments & leaderboards', accent: const Color(0xffffc04d), onTap: () => onTab(4)),
        ]);
      }),
    );
  }
}

class _R18BrandHeader extends StatelessWidget {
  const _R18BrandHeader({required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final width = MediaQuery.sizeOf(context).width;
    return Row(children: [
      Container(width: 46, height: 46, alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xff22e3d6), Color(0xff1a8df3)]), boxShadow: const [BoxShadow(color: Color(0x5522e3d6), blurRadius: 18)]), child: const Text('W', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xff041421)))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ar ? 'ورقنا' : 'WARQNAA', style: const TextStyle(fontSize: 25, height: 1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(ar ? 'أكثر من لعبة… مجتمع واحد' : 'More than a game — one community', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xff9bb6c8), fontSize: 10.5, fontWeight: FontWeight.w700)),
      ])),
      if (width > 430) _R18Pill(icon: Icons.shield_outlined, label: ar ? 'بيئة آمنة' : 'Safe play', color: const Color(0xff28d7e9)),
      if (width > 700) ...[const SizedBox(width: 6), _R18Pill(icon: Icons.emoji_events_outlined, label: ar ? 'بطولات مستمرة' : 'Tournaments', color: const Color(0xffffc04d))],
    ]);
  }
}

class _R18Pill extends StatelessWidget {
  const _R18Pill({required this.icon, required this.label, required this.color});
  final IconData icon; final String label; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), decoration: BoxDecoration(color: const Color(0xff0c2435), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: .28))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: color), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xffd7e7f0)))]));
}

class _R18Hero extends StatelessWidget {
  const _R18Hero({required this.controller, required this.onTap});
  final AppController controller; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final narrow = MediaQuery.sizeOf(context).width < 380;
    return Container(
      constraints: const BoxConstraints(minHeight: 150), clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd, colors: [Color(0xff201225), Color(0xff7a1d2c), Color(0xffb26117), Color(0xff101f32)], stops: [0, .36, .72, 1]), border: Border.all(color: const Color(0xffffc951).withValues(alpha: .55)), boxShadow: const [BoxShadow(color: Color(0x663d1705), blurRadius: 30, offset: Offset(0, 12))]),
      child: Stack(children: [
        PositionedDirectional(end: -24, top: -38, child: Icon(Icons.emoji_events_rounded, size: 180, color: const Color(0xffffc34b).withValues(alpha: .16))),
        PositionedDirectional(end: 48, bottom: -20, child: Transform.rotate(angle: .20, child: const PlayingCard(label: 'A♠', width: 58, height: 86))),
        PositionedDirectional(end: 92, bottom: -18, child: Transform.rotate(angle: -.18, child: const PlayingCard(label: 'K♥', width: 58, height: 86))),
        Padding(padding: const EdgeInsets.all(18), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(ar ? 'بطولات ورقنا الكبرى' : 'WARQNAA GRAND EVENTS', style: const TextStyle(fontSize: 10.5, color: Color(0xffffd56e), fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(ar ? 'العب • تحدّى • تواصل • استمتع' : 'Play • Compete • Connect • Enjoy', style: TextStyle(fontSize: narrow ? 17 : 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(ar ? 'بطولات يومية وأسبوعية، جوائز، أندية ومواسم تنافسية في مكان واحد.' : 'Daily and weekly events, rewards, clubs and competitive seasons in one place.', style: const TextStyle(fontSize: 10, height: 1.4, color: Color(0xffe8d9cf))),
            const SizedBox(height: 10),
            FilledButton.icon(onPressed: onTap, icon: const Icon(Icons.emoji_events_rounded, size: 17), label: Text(ar ? 'شاهد البطولات' : 'Explore events'), style: FilledButton.styleFrom(backgroundColor: const Color(0xffffc64e), foregroundColor: const Color(0xff251400))),
          ])),
          SizedBox(width: narrow ? 72 : 108),
        ])),
      ]),
    );
  }
}

class _R18FeaturePanel extends StatelessWidget {
  const _R18FeaturePanel({required this.controller, required this.onStore});
  final AppController controller; final VoidCallback onStore;
  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    Widget row(IconData icon, Color color, String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .11), border: Border.all(color: color.withValues(alpha: .25))), child: Icon(icon, size: 16, color: color)), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xffcbdce6))))]));
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xff0b2738), Color(0xff0b1726)]), border: Border.all(color: const Color(0xff22c8df).withValues(alpha: .24))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(ar ? 'أسلوبك داخل ورقنا' : 'Your Warqnaa style', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 9),
      row(Icons.palette_outlined, const Color(0xff2ce0d3), ar ? 'ألوان بروفايل وثيمات متدرجة' : 'Profile gradients & themes'),
      row(Icons.rocket_launch_outlined, const Color(0xffffc34d), ar ? 'مسرعات مضيئة ومكافآت موسمية' : 'Glowing boosters & seasonal rewards'),
      row(Icons.emoji_emotions_outlined, const Color(0xffa781ff), ar ? 'تفاعلات متحركة وصوتية' : 'Animated & voiced reactions'),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: onStore, icon: const Icon(Icons.storefront_outlined), label: Text(ar ? 'افتح المتجر' : 'Open store'))),
    ]));
  }
}

class _R8WelcomeTable extends StatelessWidget {
  const _R8WelcomeTable({required this.controller, required this.game});
  final AppController controller; final GameInfo game;
  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xff0d594b), Color(0xff09352f), Color(0xff081c28)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xff2bd8d0).withValues(alpha: .34)), boxShadow: const [BoxShadow(color: Color(0x50000000), blurRadius: 18, offset: Offset(0, 8))]), child: LayoutBuilder(builder: (context, box) {
      final narrow = box.maxWidth < 340;
      return Padding(padding: EdgeInsets.all(narrow ? 16 : 20), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xff5dffab)), child: SizedBox(width: 7, height: 7)), const SizedBox(width: 6), Text(ar ? 'اللعب السريع' : 'QUICK PLAY', style: const TextStyle(fontSize: 9, color: Color(0xffa4f6d1), fontWeight: FontWeight.w900))]),
          const SizedBox(height: 6), Text(ar ? 'طاولتك بانتظارك' : 'Your table awaits', style: TextStyle(fontSize: narrow ? 19 : 23, fontWeight: FontWeight.w900, color: const Color(0xffffebbf))),
          const SizedBox(height: 6), Text(controller.serverConnected ? (ar ? 'اختر مجلسك وابدأ اللعب مع لاعبين حقيقيين.' : 'Find a room and play with real players.') : (ar ? 'تدرّب مع الكمبيوتر واصقل لعبك.' : 'Practice your next winning hand.'), style: const TextStyle(color: Color(0xffbbd2c6), fontSize: 11, height: 1.4)),
          const SizedBox(height: 12), FilledButton.icon(onPressed: () => showGameLobby(context, controller, game), icon: const Icon(Icons.play_arrow_rounded, size: 20), label: Text('${ar ? 'العب' : 'Play'} ${L.t(controller.localeCode, game.id)}'), style: FilledButton.styleFrom(backgroundColor: const Color(0xffffc84d), foregroundColor: const Color(0xff172319), minimumSize: const Size(0, 44))),
        ])),
        const SizedBox(width: 8), ExcludeSemantics(child: SizedBox(width: narrow ? 82 : 110, height: 116, child: Stack(alignment: Alignment.center, children: [
          Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xff2ce0d3).withValues(alpha: .08), boxShadow: const [BoxShadow(color: Color(0x442ce0d3), blurRadius: 28)])),
          Transform.translate(offset: const Offset(-21, 2), child: Transform.rotate(angle: -.24, child: const PlayingCard(label: 'K♠', width: 55, height: 82))),
          Transform.translate(offset: const Offset(20, 2), child: Transform.rotate(angle: .24, child: const PlayingCard(label: 'Q♦', width: 55, height: 82))),
          Transform.translate(offset: const Offset(0, -8), child: const PlayingCard(label: 'A♥', width: 57, height: 86)),
        ]))),
      ]));
    }));
  }
}

class _R8Portal extends StatelessWidget {
  const _R8Portal({required this.icon, required this.label, required this.onTap, this.accent = const Color(0xff27d7e9)});
  final IconData icon; final String label; final VoidCallback onTap; final Color accent;
  @override
  Widget build(BuildContext context) => Material(color: const Color(0xff0b1c2a), borderRadius: BorderRadius.circular(16), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(constraints: const BoxConstraints(minHeight: 76), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: accent.withValues(alpha: .24)), gradient: LinearGradient(colors: [accent.withValues(alpha: .08), Colors.transparent])), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .10), boxShadow: [BoxShadow(color: accent.withValues(alpha: .18), blurRadius: 16)]), child: Icon(icon, size: 20, color: accent)), const SizedBox(height: 6), Text(label, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900))]))));
}

/// R34 original Warqnaa illustrated game emblems, vector-built for crisp Web/Android.
/// These replace reused stock game thumbnails in prominent discovery surfaces.
class R34GameEmblem extends StatelessWidget {
  const R34GameEmblem({super.key, required this.gameId, this.compact = false});
  final String gameId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final id = gameId.toLowerCase();
    final isTarneeb = id.contains('tarneeb');
    final isTrix = id.contains('trix');
    final isHand = id.contains('hand');
    final isBoard = id.contains('domino') || id.contains('backgammon') || id.contains('chess');
    final accent = isTarneeb ? const Color(0xFFFFC84A)
        : isTrix ? const Color(0xFF31E4F4)
        : isHand ? const Color(0xFFFFB8E0)
        : id.contains('banakil') ? const Color(0xFF65F0BC)
        : id.contains('baloot') ? const Color(0xFFF3D38B)
        : isBoard ? const Color(0xFF7AE6F9)
        : const Color(0xFFA9D9FF);
    final glyph = id.contains('400') ? '400' : id.contains('41') ? '41' : id.contains('61') ? '61'
        : isTarneeb ? '♠' : isTrix ? '♥' : isHand ? '♣'
        : id.contains('banakil') ? '♦' : id.contains('baloot') ? '♠'
        : id.contains('domino') ? '⚁' : id.contains('backgammon') ? '⚄'
        : id.contains('chess') ? '♞' : id.contains('basra') ? '★' : '✦';
    return LayoutBuilder(builder: (context, box) {
      final availableWidth = box.maxWidth.isFinite ? box.maxWidth : 80.0;
      final availableHeight = box.maxHeight.isFinite ? box.maxHeight : 80.0;
      final size = math.min(availableWidth, availableHeight).clamp(24.0, compact ? 64.0 : 162.0).toDouble();
      Widget card({required Color color, required double tilt, required double dx, required double dy}) =>
          Positioned(
            left: size * dx,
            top: size * dy,
            child: Transform.rotate(
              angle: tilt,
              child: Container(
                width: size * .60,
                height: size * .79,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(size * .095),
                  border: Border.all(color: accent.withValues(alpha: .68), width: math.max(1.0, size * .018)),
                  boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: .22), blurRadius: size * .12, offset: Offset(0, size * .06))],
                ),
              ),
            ),
          );
      return Center(
        child: SizedBox.square(
          dimension: size,
          child: Stack(clipBehavior: Clip.hardEdge, children: <Widget>[
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: <Color>[accent.withValues(alpha: .28), accent.withValues(alpha: .02)]),
            ))),
            card(color: const Color(0xFF0B2B47), tilt: -.23, dx: .12, dy: .12),
            card(color: const Color(0xFFF5FCFF), tilt: .17, dx: .30, dy: .10),
            Center(child: Transform.rotate(angle: .17, child: Text(glyph,
              maxLines: 1,
              style: TextStyle(
                fontSize: size * (glyph.length > 2 ? .26 : .49),
                fontWeight: FontWeight.w900,
                color: isTrix || isTarneeb ? const Color(0xFFC72E4C) : const Color(0xFF083858),
                shadows: <Shadow>[Shadow(color: accent.withValues(alpha: .18), blurRadius: 3)],
              ),
            ))),
            Positioned(right: size * .04, bottom: size * .08,
              child: Icon(Icons.auto_awesome_rounded, color: accent, size: size * .20)),
          ]),
        ),
      );
    });
  }
}

class R8GameTile extends StatelessWidget {
  const R8GameTile({super.key, required this.game, required this.locale, required this.onTap});
  final GameInfo game; final String locale; final VoidCallback onTap;
  (Color, Color, String) _palette(bool ar) {
    final id = game.id;
    if (id.contains('tarneeb')) return (const Color(0xff781726), const Color(0xffe33c43), ar ? 'طرنيب' : 'Tarneeb');
    if (id.contains('trix')) return (const Color(0xff062c52), const Color(0xff13b8df), ar ? 'تركس' : 'Trix');
    if (id.contains('hand')) return (const Color(0xff4f155f), const Color(0xffc349d4), ar ? 'هاند' : 'Hand');
    if (id == 'banakil') return (const Color(0xff075233), const Color(0xff18c66f), ar ? 'بناكل' : 'Banakil');
    if (id == 'baloot') return (const Color(0xff412564), const Color(0xff9975e7), ar ? 'بلوت' : 'Baloot');
    if (id == 'basra') return (const Color(0xff5e3210), const Color(0xffe29b31), ar ? 'بصرة' : 'Basra');
    return (game.color.withValues(alpha: .82), const Color(0xff2ccfe0), ar ? 'لعبة ورق' : 'Card game');
  }
  @override
  Widget build(BuildContext context) {
    final ar = locale == 'ar'; final p = _palette(ar);
    return Semantics(button: true, label: L.t(locale, game.id), child: Material(color: const Color(0xff081824), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: p.$2.withValues(alpha: .48))), clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: Stack(fit: StackFit.expand, children: [
      DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [p.$1, p.$2.withValues(alpha: .66), const Color(0xff06111a)]))),
      const SizedBox.expand(child: ColoredBox(color: Colors.transparent)),
       R34GameEmblem(gameId: game.id),,
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x08000000), Color(0x22000000), Color(0xe3071119)], stops: [0, .48, 1]))),
      PositionedDirectional(top: 9, start: 9, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: const Color(0xcc07131e), borderRadius: BorderRadius.circular(99), border: Border.all(color: p.$2.withValues(alpha: .4))), child: Text(p.$3, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: p.$2)))),
      PositionedDirectional(start: 11, end: 11, bottom: 9, child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(L.t(locale, game.id), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black, blurRadius: 8)])), const SizedBox(height: 2), Text(ar ? 'ابدأ اللعب الآن' : 'Play now', style: const TextStyle(fontSize: 9, color: Color(0xffc6d8e3), fontWeight: FontWeight.w700))])), Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: p.$2.withValues(alpha: .16), border: Border.all(color: p.$2.withValues(alpha: .52))), child: Icon(ar ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: p.$2, size: 20))])),
    ]))));
  }
}

class _R18DiscoveryShelf extends StatelessWidget {
  const _R18DiscoveryShelf({required this.controller, required this.onStore, required this.onSocial});
  final AppController controller; final VoidCallback onStore; final VoidCallback onSocial;
  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final data = <(IconData, Color, String, String, VoidCallback)>[
      (Icons.face_retouching_natural_rounded, const Color(0xff27d7e9), ar ? 'شخصيات عربية' : 'Arabic avatars', ar ? 'بوتات وحسابات بأسماء وشخصيات متنوعة.' : 'Distinct named bots and player personas.', onSocial),
      (Icons.emoji_emotions_rounded, const Color(0xffff5e8b), ar ? 'تفاعلات متحركة وصوتية' : 'Animated reactions', ar ? 'مجانية ومميزة داخل المتجر.' : 'Free and premium reaction packs.', onStore),
      (Icons.rocket_launch_rounded, const Color(0xffffc34d), ar ? 'مسرعات لامعة' : 'Glow boosters', ar ? 'ألوان واضحة ومكافآت XP متعددة.' : 'Distinct colors and XP multipliers.', onStore),
    ];
    return LayoutBuilder(builder: (context, box) {
      Widget card((IconData, Color, String, String, VoidCallback) d) => InkWell(onTap: d.$5, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(colors: [d.$2.withValues(alpha: .10), const Color(0xff0a1825)]), border: Border.all(color: d.$2.withValues(alpha: .25))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(d.$1, color: d.$2, size: 24), const Spacer(), Icon(Icons.auto_awesome_rounded, size: 15, color: d.$2)]), const SizedBox(height: 9), Text(d.$3, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(d.$4, style: const TextStyle(fontSize: 9.5, height: 1.4, color: Color(0xff9fb4c2)))])));
      if (box.maxWidth < 660) return Column(children: [for (var i = 0; i < data.length; i++) ...[card(data[i]), if (i < data.length - 1) const SizedBox(height: 8)]]);
      return Row(children: [for (var i = 0; i < data.length; i++) ...[Expanded(child: card(data[i])), if (i < data.length - 1) const SizedBox(width: 8)]]);
    });
  }
}

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
      // R28 invariant: the complete hand always stays inside the visible table.
      // Hand/Banakil can reach 15–19 cards, so overlap adapts instead of
      // introducing horizontal scrolling or pushing edge cards off-screen.
      final viewport = math.max(1.0, constraints.maxWidth);
      final sidePadding = viewport < 360 ? 6.0 : 10.0;
      final usable = math.max(1.0, viewport - sidePadding * 2);
      final preferredWidth = compact
          ? (viewport < 340 ? 46.0 : viewport > 900 ? 54.0 : 50.0)
          : (viewport < 340 ? 52.0 : viewport > 900 ? 68.0 : viewport > 600 ? 64.0 : 58.0);
      final minimumReveal = compact ? 11.0 : 13.0;
      final widthBudget = count <= 1 ? usable : usable - minimumReveal * (count - 1);
      final width = math.min(preferredWidth, math.max(36.0, widthBudget));
      final height = width * 1.48;
      final step = count <= 1 ? 0.0 : math.max(0.0, (usable - width) / (count - 1));
      final span = math.min(usable, width + step * (count - 1));
      final order = <int>[for (var i = 0; i < count; i++) i];
      final cards = SizedBox(
        width: span,
        height: height + 20,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            for (final index in order)
              Positioned(
                key: ValueKey('r8-hand-$index'),
                left: step * index,
                top: selectedIndex == index ? 0 : 12,
                width: width,
                height: height,
                child: cardBuilder(index, width, height),
              ),
          ],
        ),
      );
      return Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: double.infinity,
          height: height + 20,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePadding),
            child: Align(alignment: Alignment.bottomCenter, child: cards),
          ),
        ),
      );
    });
  }
}

class R8TableSeat extends StatelessWidget {
  const R8TableSeat({super.key, required this.name, required this.avatar, required this.detail, required this.active, required this.onTap, this.seconds, this.turnSeconds = 10, this.compact = false});
  final String name; final Widget avatar; final String detail; final bool active; final VoidCallback onTap; final int? seconds; final int turnSeconds; final bool compact;
  @override
  Widget build(BuildContext context) {
    final tight = MediaQuery.sizeOf(context).shortestSide < 360;
    final seatWidth = compact ? (tight ? 72.0 : 80.0) : (tight ? 84.0 : 96.0);
    final avatarSize = compact ? (tight ? 27.0 : 31.0) : (tight ? 34.0 : 40.0);
    final radius = tight ? 13.0 : 16.0;
    return Semantics(
      label: '$name, $detail',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          key: ValueKey<String>('r30-seat-$name'),
          duration: const Duration(milliseconds: 180),
          width: seatWidth,
          padding: EdgeInsets.symmetric(horizontal: tight ? 3 : 5, vertical: tight ? 3 : 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: active
                  ? const [B307SkyLuxury.azure, B307SkyLuxury.royal]
                  : const [Color(0xee07598f), Color(0xee052f54)],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: active ? B307SkyLuxury.goldSoft : B307SkyLuxury.sky.withValues(alpha: .28),
              width: active ? 1.9 : .8,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: active ? B307SkyLuxury.sky.withValues(alpha: .22) : Colors.black.withValues(alpha: .26),
                blurRadius: active ? 15 : 9,
                spreadRadius: active ? .6 : 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox.square(dimension: avatarSize, child: FittedBox(child: avatar)),
            const SizedBox(height: 3),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: B307SkyLuxury.text, fontSize: tight ? 8.5 : (compact ? 9.5 : 11), fontWeight: FontWeight.w900)),
            Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: tight ? 7.5 : (compact ? 8.2 : 9), color: B307SkyLuxury.textMuted)),
            if (active && seconds != null) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (seconds! / math.max(1, turnSeconds)).clamp(0.0, 1.0),
                minHeight: 3,
                borderRadius: BorderRadius.circular(3),
                color: seconds! <= 3 ? Colors.redAccent : B307SkyLuxury.goldSoft,
                backgroundColor: B307SkyLuxury.navy.withValues(alpha: .52),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Rotate presentation only. Engine seat order/team ownership is untouched.
int r8RelativeSeat(List<dynamic> players, int index, String? myKey) {
  if (players.isEmpty || myKey == null || myKey.isEmpty) return index;
  final mine = players.indexWhere((p) => p is Map && (p['key'] ?? p['user_key'])?.toString() == myKey);
  return mine < 0 ? index : (index - mine + players.length) % players.length;
}
