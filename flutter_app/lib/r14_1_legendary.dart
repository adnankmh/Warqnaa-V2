part of 'main.dart';

/// R14.1 Build 261 keeps every R8–R14 surface and gives the primary
/// home/game-discovery journey one coherent premium visual language.
const String warqnaaR141Release = '1.0.1+261';

abstract final class R141Palette {
  static const Color ink = Color(0xff08110e);
  static const Color panel = Color(0xff0d1b16);
  static const Color panel2 = Color(0xff12261e);
  static const Color gold = Color(0xfff0c45c);
  static const Color goldDeep = Color(0xffc98b2f);
  static const Color emerald = Color(0xff45d69e);
  static const Color cyan = Color(0xff5dd7e8);
  static const Color rose = Color(0xfff27788);
}

class R141LegendaryHomeDashboard extends StatelessWidget {
  const R141LegendaryHomeDashboard({super.key, required this.controller, required this.onTab});
  final AppController controller;
  final ValueChanged<int> onTab;
  bool get ar => controller.localeCode == 'ar';

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final width = constraints.maxWidth;
    final wide = width >= 980;
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(.7, -1), radius: 1.5, colors: <Color>[Color(0x221e9b6b), Colors.transparent])),
      child: ListView(
        padding: EdgeInsets.fromLTRB(wide ? 24 : 13, 14, wide ? 24 : 13, 34),
        children: <Widget>[
          _R141Hero(controller: controller),
          const SizedBox(height: 13),
          _metrics(context, wide),
          const SizedBox(height: 24),
          _games(context, width),
          const SizedBox(height: 24),
          _worlds(context, wide),
          const SizedBox(height: 24),
          _quality(context, wide),
        ],
      ),
    );
  });

  Widget _metrics(BuildContext context, bool wide) {
    final items = <({IconData icon, String value, String ar, String en, Color color})>[
      (icon: Icons.military_tech_rounded, value: 'LV.' + controller.level.toString(), ar: 'مستواك', en: 'Your level', color: R141Palette.gold),
      (icon: Icons.monetization_on_rounded, value: formatNumber(controller.coins), ar: 'توكن', en: 'Tokens', color: R141Palette.gold),
      (icon: Icons.local_fire_department_rounded, value: controller.challengeStreakV173.toString(), ar: 'سلسلة', en: 'Streak', color: R141Palette.rose),
      (icon: Icons.shield_rounded, value: controller.vipDays.toString(), ar: 'أيام باشا', en: 'Pasha days', color: R141Palette.emerald),
    ];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: R141Palette.panel.withValues(alpha: .84), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: .08))),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: wide ? 4 : 2, mainAxisSpacing: 5, crossAxisSpacing: 5, childAspectRatio: wide ? 3.2 : 2.25),
        itemBuilder: (_, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .025), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: .045))),
            child: Row(children: <Widget>[
              Container(width: 36, height: 36, decoration: BoxDecoration(color: item.color.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Icon(item.icon, size: 19, color: item.color)),
              const SizedBox(width: 10),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(item.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                Text(ar ? item.ar : item.en, style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ])),
            ]),
          );
        },
      ),
    );
  }

  Widget _games(BuildContext context, double width) {
    final games = controller.homeGames;
    final columns = width >= 1320 ? 4 : width >= 760 ? 3 : 2;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      _R141SectionHeader(eyebrow: ar ? 'اختر طاولتك' : 'CHOOSE YOUR TABLE', title: ar ? 'ألعابك المفضلة' : 'Your favorite games', action: ar ? 'تخصيص' : 'Customize', onTap: () => showHomeGamesSelector(context, controller)),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: games.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: math.min(columns, games.length).clamp(1, 4).toInt(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: width >= 1000 ? 1.25 : .78),
        itemBuilder: (_, index) => R141LegendaryGameCard(game: games[index], lang: controller.localeCode, featured: index == 0, onTap: () => showGameLobby(context, controller, games[index])),
      ),
    ]);
  }

  Widget _worlds(BuildContext context, bool wide) {
    final cards = <({IconData icon, String overline, String ar, String en, String arBody, String enBody, Color color, VoidCallback tap})>[
      (icon: Icons.public_rounded, overline: 'SOCIAL WORLD', ar: 'مجتمع يلعب معك', en: 'A world that plays with you', arBody: 'أصدقاء، أندية، مشاهدة مباشرة، إعادات وأحداث اجتماعية ضمن خصوصية كاملة.', enBody: 'Friends, clubs, live spectating, replays and social events with complete privacy.', color: R141Palette.emerald, tap: () => onTab(4)),
      (icon: Icons.workspace_premium_rounded, overline: 'COMPETITIVE ARENA', ar: 'مكانك بين الأساطير', en: 'Your place among legends', arBody: 'تصنيف MMR، مواسم ومستويات وطوابير عادلة وبطولات موثقة.', enBody: 'MMR, seasons, tiers, fair queues and auditable tournaments.', color: R141Palette.gold, tap: () => showCompetitions(context, controller)),
      (icon: Icons.auto_awesome_rounded, overline: 'REWARDS & STYLE', ar: 'هوية خاصة بك', en: 'An identity of your own', arBody: 'مكافآت وصناديق وطاولات وثيمات تجميلية لا تغيّر عدالة اللعب.', enBody: 'Rewards, boxes, tables and themes that never change fair play.', color: R141Palette.cyan, tap: () => showRewards(context, controller)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      _R141SectionHeader(eyebrow: ar ? 'أكثر من مجرد لعبة' : 'MORE THAN A GAME', title: ar ? 'عالم ورقنا' : 'The Warqnaa world'),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: wide ? 3 : 1, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: wide ? 1.35 : 2.1),
        itemBuilder: (_, index) {
          final item = cards[index];
          return InkWell(
            onTap: item.tap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[R141Palette.panel2, R141Palette.ink]), borderRadius: BorderRadius.circular(28), border: Border.all(color: item.color.withValues(alpha: .18))),
              child: Stack(children: <Widget>[
                PositionedDirectional(end: -8, bottom: -18, child: Icon(item.icon, size: 112, color: item.color.withValues(alpha: .035))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Container(width: 46, height: 46, decoration: BoxDecoration(color: item.color.withValues(alpha: .09), borderRadius: BorderRadius.circular(15), border: Border.all(color: item.color.withValues(alpha: .20))), child: Icon(item.icon, color: item.color)),
                  const Spacer(),
                  Text(item.overline, style: TextStyle(color: item.color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text(ar ? item.ar : item.en, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(ar ? item.arBody : item.enBody, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, height: 1.55, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ]),
              ]),
            ),
          );
        },
      ),
    ]);
  }

  Widget _quality(BuildContext context, bool wide) {
    final quality = <({IconData icon, String ar, String en})>[
      (icon: Icons.gpp_good_rounded, ar: 'محركات خادمية عادلة', en: 'Fair server engines'),
      (icon: Icons.devices_rounded, ar: 'هاتف وويب وAndroid وiOS', en: 'Phone, web, Android and iOS'),
      (icon: Icons.language_rounded, ar: 'عربي وإنجليزي', en: 'Arabic and English'),
    ];
    final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      const Text('ENGINE GOLD • R14.1', style: TextStyle(color: R141Palette.gold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      const SizedBox(height: 7),
      Text(ar ? 'قوي في الداخل. راقٍ في الخارج.' : 'Powerful inside. Refined outside.', style: const TextStyle(fontSize: 24, height: 1.08, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(ar ? 'تجربة عالمية تحافظ على روح ألعابنا العربية.' : 'A global experience that preserves the spirit of Arab games.', style: const TextStyle(fontSize: 10, color: Colors.white60)),
    ]);
    final list = Column(children: quality.map((item) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: <Widget>[
        Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .045), borderRadius: BorderRadius.circular(12)), child: Icon(item.icon, size: 19, color: R141Palette.emerald)),
        const SizedBox(width: 11),
        Expanded(child: Text(ar ? item.ar : item.en, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
        const Icon(Icons.check_circle_rounded, size: 18, color: R141Palette.emerald),
      ]),
    )).toList(growable: false));
    return Container(
      padding: EdgeInsets.all(wide ? 28 : 19),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: <Color>[Color(0xff10291f), Color(0xff09140f)]), borderRadius: BorderRadius.circular(30), border: Border.all(color: R141Palette.gold.withValues(alpha: .16))),
      child: wide ? Row(children: <Widget>[Expanded(child: copy), const SizedBox(width: 30), Expanded(child: list)]) : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[copy, const SizedBox(height: 18), list]),
    );
  }
}

class _R141Hero extends StatelessWidget {
  const _R141Hero({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 820;
      final copy = Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(color: R141Palette.gold.withValues(alpha: .065), borderRadius: BorderRadius.circular(99), border: Border.all(color: R141Palette.gold.withValues(alpha: .22))),
          child: const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[_R141LiveDot(), SizedBox(width: 7), Text('GLOBAL EXPERIENCE • R14.1', style: TextStyle(fontSize: 8, color: R141Palette.gold, fontWeight: FontWeight.w900, letterSpacing: 1))]),
        ),
        const SizedBox(height: 18),
        Text(ar ? 'كل طاولة.\nعالمٌ كامل.' : 'Every table.\nA whole world.', style: TextStyle(fontSize: wide ? 46 : 34, height: .98, fontWeight: FontWeight.w900, letterSpacing: -1.4)),
        const SizedBox(height: 12),
        Text(ar ? 'ألعابك العربية المفضلة، مجتمع حيّ ومنافسات موسمية بهوية فاخرة وسريعة.' : 'Your favorite Arab games, a living community and seasonal competition in one refined experience.', style: const TextStyle(fontSize: 12, height: 1.65, color: Colors.white60)),
        const SizedBox(height: 19),
        Wrap(spacing: 9, runSpacing: 9, children: <Widget>[
          R141LegendaryButton.primary(icon: Icons.play_arrow_rounded, label: ar ? 'العب الآن' : 'Play now', onPressed: () => showGameLobby(context, controller, controller.homeGames.first)),
          R141LegendaryButton.glass(icon: Icons.workspace_premium_rounded, label: ar ? 'الساحة' : 'Arena', onPressed: () => showCompetitions(context, controller)),
        ]),
      ]);
      return Container(
        constraints: BoxConstraints(minHeight: wide ? 340 : 520),
        padding: EdgeInsets.all(wide ? 30 : 21),
        decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xff102a20), Color(0xff07120e), Color(0xff171609)]), borderRadius: BorderRadius.circular(34), border: Border.all(color: R141Palette.gold.withValues(alpha: .20)), boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x55000000), blurRadius: 45, offset: Offset(0, 22))]),
        child: ClipRect(child: Stack(children: <Widget>[
          PositionedDirectional(end: -22, bottom: -42, child: Text('WARQNAA', style: TextStyle(fontSize: wide ? 104 : 64, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: .018), letterSpacing: -5))),
          if (wide) Row(children: <Widget>[Expanded(flex: 6, child: copy), const SizedBox(width: 24), const Expanded(flex: 4, child: _R141CardStage())])
          else Column(children: <Widget>[Expanded(child: copy), const SizedBox(height: 18), const SizedBox(height: 190, child: _R141CardStage())]),
        ])),
      );
    });
  }
}

class _R141CardStage extends StatelessWidget {
  const _R141CardStage();
  @override
  Widget build(BuildContext context) => Stack(alignment: Alignment.center, children: <Widget>[
    Container(width: 205, height: 205, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: R141Palette.gold.withValues(alpha: .17)))),
    Transform.rotate(angle: -.23, child: const _R141PlayingCard(rank: 'A', suit: '♠', color: Colors.black, offset: Offset(-43, 8))),
    Transform.rotate(angle: .04, child: const _R141PlayingCard(rank: 'K', suit: '♥', color: Color(0xffb8202f), offset: Offset(0, -9))),
    Transform.rotate(angle: .27, child: const _R141PlayingCard(rank: 'Q', suit: '♦', color: Color(0xffb8202f), offset: Offset(43, 9))),
    Container(width: 76, height: 76, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: <Color>[Color(0xffffefae), R141Palette.gold, Color(0xff99621b)]), border: Border.all(color: R141Palette.ink, width: 4), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black54, blurRadius: 22, offset: Offset(0, 12))]), child: const Text('W', style: TextStyle(color: Color(0xff191307), fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'serif'))),
  ]);
}

class _R141PlayingCard extends StatelessWidget {
  const _R141PlayingCard({required this.rank, required this.suit, required this.color, required this.offset});
  final String rank;
  final String suit;
  final Color color;
  final Offset offset;
  @override
  Widget build(BuildContext context) => Transform.translate(offset: offset, child: Container(
    width: 90, height: 130, padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: const Color(0xfff8f5ed), borderRadius: BorderRadius.circular(13), border: Border.all(color: Colors.white), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, 12))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(rank, style: TextStyle(color: color, fontSize: 21, height: .9, fontWeight: FontWeight.w900, fontFamily: 'serif')), Expanded(child: Center(child: Text(suit, style: TextStyle(color: color, fontSize: 43, fontFamily: 'serif'))))]),
  ));
}

class _R141LiveDot extends StatelessWidget {
  const _R141LiveDot();
  @override
  Widget build(BuildContext context) => Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: R141Palette.emerald, boxShadow: <BoxShadow>[BoxShadow(color: R141Palette.emerald, blurRadius: 10)]));
}

class _R141SectionHeader extends StatelessWidget {
  const _R141SectionHeader({required this.eyebrow, required this.title, this.action, this.onTap});
  final String eyebrow;
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(eyebrow, style: const TextStyle(color: R141Palette.gold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.4)), const SizedBox(height: 5), Text(title, style: const TextStyle(fontSize: 25, height: 1.05, fontWeight: FontWeight.w900))])),
    if (action != null) TextButton(onPressed: onTap, child: Text(action!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
  ]);
}

class R141LegendaryButton extends StatelessWidget {
  const R141LegendaryButton._({required this.icon, required this.label, required this.onPressed, required this.primary});
  factory R141LegendaryButton.primary({required IconData icon, required String label, required VoidCallback onPressed}) => R141LegendaryButton._(icon: icon, label: label, onPressed: onPressed, primary: true);
  factory R141LegendaryButton.glass({required IconData icon, required String label, required VoidCallback onPressed}) => R141LegendaryButton._(icon: icon, label: label, onPressed: onPressed, primary: false);
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;
  @override
  Widget build(BuildContext context) => Semantics(button: true, child: Material(color: Colors.transparent, child: InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(16),
    child: Ink(
      height: 50, padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(gradient: primary ? const LinearGradient(colors: <Color>[Color(0xffffefaa), R141Palette.gold, R141Palette.goldDeep]) : null, color: primary ? null : Colors.white.withValues(alpha: .055), borderRadius: BorderRadius.circular(16), border: Border.all(color: primary ? const Color(0xffffe99b) : Colors.white.withValues(alpha: .13)), boxShadow: primary ? const <BoxShadow>[BoxShadow(color: Color(0x33c98b2f), blurRadius: 22, offset: Offset(0, 10))] : const <BoxShadow>[]),
      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(icon, size: 19, color: primary ? const Color(0xff171206) : Colors.white), const SizedBox(width: 8), Text(label, style: TextStyle(color: primary ? const Color(0xff171206) : Colors.white, fontSize: 12, fontWeight: FontWeight.w900))]),
    ),
  )));
}

class R141LegendaryGameCard extends StatelessWidget {
  const R141LegendaryGameCard({super.key, required this.game, required this.lang, required this.onTap, this.featured = false});
  final GameInfo game;
  final String lang;
  final VoidCallback onTap;
  final bool featured;
  @override
  Widget build(BuildContext context) => Semantics(button: true, label: L.t(lang, game.id), child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Ink(
      decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[R141Palette.panel2, R141Palette.ink]), borderRadius: BorderRadius.circular(24), border: Border.all(color: featured ? R141Palette.gold.withValues(alpha: .34) : Colors.white.withValues(alpha: .08)), boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x33000000), blurRadius: 25, offset: Offset(0, 13))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(23), child: Stack(fit: StackFit.expand, children: <Widget>[
        Image.asset(r101GameArtAsset(game.id), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(game.icon, style: const TextStyle(fontSize: 54)))),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Colors.transparent, Color(0x22000000), Color(0xf2050a08)]))),
        PositionedDirectional(start: 10, top: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: featured ? R141Palette.gold : const Color(0xcc07120e), borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white.withValues(alpha: .15))), child: Text(featured ? (lang == 'ar' ? 'مميزة' : 'FEATURED') : (lang == 'ar' ? 'جاهزة' : 'READY'), style: TextStyle(color: featured ? R141Palette.ink : Colors.white, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: .8)))),
        if (game.serverOnly) PositionedDirectional(end: 10, top: 10, child: Container(width: 29, height: 29, decoration: BoxDecoration(color: const Color(0xdd07120e), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.cloud_done_rounded, size: 15, color: R141Palette.emerald))),
        PositionedDirectional(start: 13, end: 13, bottom: 12, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text(L.t(lang, game.id), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 8)])),
          const SizedBox(height: 4),
          Row(children: <Widget>[const Icon(Icons.groups_2_rounded, size: 13, color: R141Palette.gold), const SizedBox(width: 4), Expanded(child: Text(formatNumber(game.players) + ' ' + (lang == 'ar' ? 'لاعب' : 'players'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w700))), Container(width: 27, height: 27, decoration: const BoxDecoration(shape: BoxShape.circle, color: R141Palette.gold), child: const Icon(Icons.arrow_back_rounded, size: 15, color: R141Palette.ink))]),
        ])),
      ])),
    ),
  ));
}
