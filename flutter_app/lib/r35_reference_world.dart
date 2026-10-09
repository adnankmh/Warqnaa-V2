part of 'main.dart';

/// R35: screenshot-guided original Warqnaa world. Each highlighted action
/// routes into a real existing feature; artwork never promises invented prizes.
const String warqnaaR35ReferenceWorld = 'r35-sky-gold-responsive-world';

abstract final class R35ReferenceColors {
  static const sky = Color(0xFF1AB8FF);
  static const royal = Color(0xFF0559B4);
  static const deep = Color(0xFF053B86);
  static const navy = Color(0xFF052D63);
  static const gold = Color(0xFFFFCB45);
  static const paleGold = Color(0xFFFFEC9C);
  static const cyan = Color(0xFF82F0FF);
  static const white = Color(0xFFFFFFFF);
}

class R35ReferenceWorldDashboard extends StatelessWidget {
  const R35ReferenceWorldDashboard({super.key, required this.controller, required this.onTab});
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return LayoutBuilder(builder: (context, viewport) {
      final columns = viewport.maxWidth >= 1140 ? 4 : viewport.maxWidth >= 760 ? 3 : 2;
      final games = customerGamesR101.take(8).toList(growable: false);
      return Container(
        key: const ValueKey('r35-reference-world-dashboard'),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF4FC9FF), Color(0xFF279FE5), Color(0xFF73D9F8)],
          ),
        ),
        child: ListView(
          key: const PageStorageKey('r35-reference-scroll'),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
          children: <Widget>[
            R35ChampionBanner(controller: controller),
            const SizedBox(height: 13),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Expanded(
                flex: 11,
                child: R35ReferencePanel(
                  title: ar ? 'جميع الألعاب' : 'All games',
                  icon: Icons.style_rounded,
                  actionLabel: ar ? 'عرض الكل' : 'View all',
                  onAction: () => onTab(1),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: games.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns == 4 ? 4 : 3,
                      crossAxisSpacing: 9,
                      mainAxisSpacing: 9,
                      childAspectRatio: .84,
                    ),
                    itemBuilder: (context, index) => R35ArtGameCard(
                      game: games[index],
                      locale: controller.localeCode,
                      onTap: () => showGameLobby(context, controller, games[index]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 7,
                child: R35ReferencePanel(
                  title: ar ? 'البطولات' : 'Tournaments',
                  icon: Icons.emoji_events_rounded,
                  actionLabel: ar ? 'المنافسات' : 'Competitions',
                  onAction: () => Navigator.push(context, MaterialPageRoute<void>(
                    builder: (_) => R12CompetitiveArenaPage(controller: controller),
                  )),
                  child: Column(
                    children: <Widget>[
                      R35TournamentRow(
                        title: ar ? 'البطولات اليومية' : 'Daily tournaments',
                        detail: ar ? 'منافسات متجددة وجوائز افتراضية حسب الشروط' : 'Daily challenges with rule-based virtual rewards',
                        icon: Icons.wb_sunny_rounded,
                        color: R35ReferenceColors.gold,
                        onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                          builder: (_) => R12CompetitiveArenaPage(controller: controller),
                        )),
                      ),
                      const SizedBox(height: 9),
                      R35TournamentRow(
                        title: ar ? 'البطولات الأسبوعية' : 'Weekly tournaments',
                        detail: ar ? 'ترتيب، مراحل وتأهل' : 'Rankings, stages and qualification',
                        icon: Icons.calendar_month_rounded,
                        color: R35ReferenceColors.cyan,
                        onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                          builder: (_) => R12CompetitiveArenaPage(controller: controller),
                        )),
                      ),
                      const SizedBox(height: 9),
                      R35TournamentRow(
                        title: ar ? 'البطولات الكبرى' : 'Grand championships',
                        detail: ar ? 'استعرض اللوائح والبطولات المتاحة' : 'Explore available rules and events',
                        icon: Icons.workspace_premium_rounded,
                        color: R35ReferenceColors.paleGold,
                        onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                          builder: (_) => R12CompetitiveArenaPage(controller: controller),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 13),
            LayoutBuilder(builder: (context, box) {
              final compact = box.maxWidth < 900;
              final cards = <Widget>[
                R35ReferencePanel(
                  title: ar ? 'الأندية' : 'Clubs',
                  icon: Icons.shield_rounded,
                  actionLabel: ar ? 'استكشف' : 'Explore',
                  onAction: () => Navigator.push(context, MaterialPageRoute<void>(
                    builder: (_) => ClubsPage(controller: controller),
                  )),
                  child: Column(children: <Widget>[
                    R35FeatureLine(icon: Icons.groups_2_rounded, title: ar ? 'الأندية والمجموعات' : 'Clubs and groups', detail: ar ? 'انضم وتواصل مع اللاعبين' : 'Join and connect with players'),
                    const SizedBox(height: 8),
                    R35FeatureLine(icon: Icons.military_tech_rounded, title: ar ? 'التصنيف والإنجازات' : 'Rankings and achievements', detail: ar ? 'مساهمات الفريق والبطولات' : 'Team achievements and tournaments'),
                    const SizedBox(height: 9),
                    R35GoldAction(label: ar ? 'استعرض الأندية' : 'Browse clubs', icon: Icons.arrow_forward_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                        builder: (_) => ClubsPage(controller: controller),
                      ))),
                  ]),
                ),
                R35ReferencePanel(
                  title: ar ? 'المتجر والجوائز' : 'Store and rewards',
                  icon: Icons.storefront_rounded,
                  actionLabel: ar ? 'فتح المتجر' : 'Open store',
                  onAction: () => onTab(0),
                  child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      const Icon(Icons.monetization_on_rounded, color: R35ReferenceColors.gold, size: 29),
                      const SizedBox(width: 8),
                      Expanded(child: Text(formatNumber(controller.coins),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: R35ReferenceColors.white, fontWeight: FontWeight.w900, fontSize: 18))),
                    ]),
                    const SizedBox(height: 9),
                    R35FeatureLine(icon: Icons.card_giftcard_rounded, title: ar ? 'حزم ومقتنيات فاخرة' : 'Premium bundles and collectibles', detail: ar ? 'طاولات وأوراق وأطر وعروض' : 'Tables, card backs, frames and offers'),
                    const SizedBox(height: 9),
                    R35GoldAction(label: ar ? 'استكشف المقتنيات' : 'Discover items', icon: Icons.shopping_bag_rounded, onTap: () => onTab(0)),
                  ]),
                ),
                R35ReferencePanel(
                  title: ar ? 'الملف الشخصي' : 'Profile studio',
                  icon: Icons.person_rounded,
                  actionLabel: ar ? 'تعديل' : 'Customize',
                  onAction: () => showProfile(context, controller),
                  child: Column(children: <Widget>[
                    Center(child: SizedBox.square(
                      dimension: 82,
                      child: DecoratedBox(
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          border: Border.all(color: R35ReferenceColors.paleGold, width: 3)),
                        child: Padding(padding: const EdgeInsets.all(3),
                          child: AccountAvatar(controller: controller, size: 72)),
                      ),
                    )),
                    const SizedBox(height: 5),
                    Text(controller.displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: R35ReferenceColors.white)),
                    const SizedBox(height: 5),
                    Text(ar ? 'الصورة الدائرية • الإطار • الغلاف • الباشا' : 'Round avatar • frame • cover • Pasha',
                      textAlign: TextAlign.center, style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 10)),
                    const SizedBox(height: 8),
                    R35GoldAction(label: ar ? 'تخصيص الآن' : 'Customize now', icon: Icons.auto_fix_high_rounded,
                      onTap: () => showAvatarPicker(context, controller)),
                  ]),
                ),
              ];
              return compact
                  ? Column(children: <Widget>[
                      cards[0], const SizedBox(height: 11), cards[1],
                      const SizedBox(height: 11), cards[2],
                    ])
                  : Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Expanded(child: cards[0]), const SizedBox(width: 11),
                      Expanded(child: cards[1]), const SizedBox(width: 11),
                      Expanded(child: cards[2]),
                    ]);
            }),
            const SizedBox(height: 13),
            R35ReferencePanel(
              title: ar ? 'عالم التخصيص والمجتمع' : 'Customization and community',
              icon: Icons.auto_awesome_rounded,
              child: Wrap(spacing: 10, runSpacing: 10, children: <Widget>[
                R35CategoryAction(
                  icon: Icons.emoji_emotions_rounded, color: R35ReferenceColors.gold,
                  title: ar ? 'الإيموجي وردود الفعل' : 'Reactions and emoji',
                  subtitle: ar ? 'تفاعلات اجتماعية' : 'Social expressions',
                  onTap: () => onTab(0),
                ),
                R35CategoryAction(
                  icon: Icons.smart_toy_rounded, color: R35ReferenceColors.cyan,
                  title: ar ? 'الروبوتات الذكية' : 'Smart bots',
                  subtitle: ar ? 'شاهد أوضاع اللعب' : 'Explore play modes',
                  onTap: () => onTab(1),
                ),
                R35CategoryAction(
                  icon: Icons.style_rounded, color: R35ReferenceColors.paleGold,
                  title: ar ? 'خلفيات الأوراق' : 'Card backs',
                  subtitle: ar ? 'مجموعات حصرية' : 'Original collections',
                  onTap: () => onTab(0),
                ),
                R35CategoryAction(
                  icon: Icons.bolt_rounded, color: const Color(0xFF6EF9AD),
                  title: ar ? 'المعززات والمميزات' : 'Boosters and perks',
                  subtitle: ar ? 'تخصيص ومكافآت' : 'Customization and rewards',
                  onTap: () => onTab(0),
                ),
                R35CategoryAction(
                  icon: Icons.account_balance_wallet_rounded, color: R35ReferenceColors.gold,
                  title: ar ? 'المحفظة' : 'Wallet',
                  subtitle: ar ? 'رصيدك وسجلك' : 'Balance and history',
                  onTap: () => showWallet(context, controller),
                ),
                R35CategoryAction(
                  icon: Icons.people_alt_rounded, color: R35ReferenceColors.cyan,
                  title: ar ? 'الأصدقاء' : 'Friends',
                  subtitle: ar ? 'دعوات ومحادثات' : 'Invites and chat',
                  onTap: () => showFriends(context, controller),
                ),
              ]),
            ),
          ],
        ),
      );
    });
  }
}

class R35ReferencePanel extends StatelessWidget {
  const R35ReferencePanel({
    super.key, required this.title, required this.icon, required this.child,
    this.actionLabel, this.onAction,
  });
  final String title;
  final IconData icon;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF0F9DEB), Color(0xFF086FC8), Color(0xFF084D99)]),
      border: Border.all(color: R35ReferenceColors.cyan.withValues(alpha: .84), width: 1.5),
      boxShadow: <BoxShadow>[
        BoxShadow(color: R35ReferenceColors.deep.withValues(alpha: .34),
          blurRadius: 18, offset: const Offset(0, 7)),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Row(children: <Widget>[
          Icon(icon, size: 22, color: R35ReferenceColors.paleGold),
          const SizedBox(width: 7),
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: R35ReferenceColors.white, fontSize: 15, fontWeight: FontWeight.w900))),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: R35ReferenceColors.paleGold,
                minimumSize: const Size(0, 35), padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: Text(actionLabel!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    ),
  );
}

class R35ChampionBanner extends StatelessWidget {
  const R35ChampionBanner({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return Semantics(
      container: true,
      label: ar ? 'بطولات ورقنا الكبرى' : 'Warqnaa grand championships',
      child: Container(
        key: const ValueKey('r35-sky-grand-tournament-banner'),
        height: 212,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: R35ReferenceColors.paleGold, width: 2),
          boxShadow: <BoxShadow>[BoxShadow(
            color: R35ReferenceColors.deep.withValues(alpha: .36), blurRadius: 23, offset: const Offset(0, 8))],
        ),
        child: Stack(fit: StackFit.expand, children: <Widget>[
          const CustomPaint(painter: R35CoastalBannerPainter()),
          Container(decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xEE07376E), Color(0xBB0C5EA8), Color(0x2000B9FF)],
              stops: <double>[0, .55, 1],
            ),
          )),
          PositionedDirectional(
            end: 9, bottom: 3,
            child: SizedBox(width: 184, height: 194,
              child: CustomPaint(painter: R35GoldTrophyPainter())),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(19, 17, 188, 17),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(ar ? '🏆 بطولات ورقنا الكبرى' : '🏆 WARQNAA CHAMPIONSHIPS',
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: R35ReferenceColors.paleGold,
                  fontSize: 24, fontWeight: FontWeight.w900, height: 1.2)),
              const SizedBox(height: 7),
              Text(ar ? 'نافس، اربح الجوائز الافتراضية، واصنع تاريخك!'
                      : 'Compete for virtual rewards and make your mark!',
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              Text(ar ? 'اطّلع على البطولات الحالية وشروط المشاركة قبل التسجيل.'
                      : 'Review available tournaments and their rules before entering.',
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 10, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Align(alignment: AlignmentDirectional.centerStart,
                child: R35GoldAction(
                  label: ar ? 'شارك الآن' : 'Explore tournaments',
                  icon: Icons.emoji_events_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                    builder: (_) => R12CompetitiveArenaPage(controller: controller),
                  )),
                )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class R35ArtGameCard extends StatelessWidget {
  const R35ArtGameCard({super.key, required this.game, required this.locale, required this.onTap});
  final GameInfo game;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: L.t(locale, game.id),
    child: InkWell(
      key: ValueKey('r35-game-${game.id}'),
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: R35ReferenceColors.paleGold.withValues(alpha: .88), width: 1.3),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF23BAFF), Color(0xFF0B74D2), Color(0xFF052C75)]),
          boxShadow: <BoxShadow>[BoxShadow(
            color: const Color(0xFF032F70).withValues(alpha: .32),
            blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
              child: Image.asset(
                r101GameArtAsset(game.id),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => R34GameEmblem(gameId: game.id, compact: true),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
            color: const Color(0xD9042D75),
            child: Text(L.t(locale, game.id), textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ]),
      ),
    ),
  );
}

class R35TournamentRow extends StatelessWidget {
  const R35TournamentRow({
    super.key, required this.title, required this.detail,
    required this.icon, required this.color, required this.onTap,
  });
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(13),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: <Color>[Color(0xFF1260A8), Color(0xFF084788)]),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: R35ReferenceColors.cyan.withValues(alpha: .46)),
      ),
      child: Row(children: <Widget>[
        Container(width: 42, height: 42,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: color.withValues(alpha: .18),
            border: Border.all(color: color.withValues(alpha: .85))),
          child: Icon(icon, color: color, size: 26)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 4),
          Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: R35ReferenceColors.cyan, fontWeight: FontWeight.w600, fontSize: 9.2)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: R35ReferenceColors.paleGold),
      ]),
    ),
  );
}

class R35FeatureLine extends StatelessWidget {
  const R35FeatureLine({super.key, required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
    Icon(icon, color: R35ReferenceColors.gold, size: 27),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
      Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 9)),
    ])),
  ]);
}

class R35GoldAction extends StatelessWidget {
  const R35GoldAction({super.key, required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 18),
    label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
    style: FilledButton.styleFrom(
      backgroundColor: R35ReferenceColors.gold,
      foregroundColor: R35ReferenceColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    ),
  );
}

class R35CategoryAction extends StatelessWidget {
  const R35CategoryAction({
    super.key, required this.title, required this.subtitle, required this.icon,
    required this.color, required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 176,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: <Color>[Color(0xFF177BC5), Color(0xFF054486)]),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: color.withValues(alpha: .6)),
        ),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(children: <Widget>[
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 6),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 9)),
          ])),
      ),
    ),
  );
}

/// Illustrated coastline instead of a flat dark rectangle. Scenic background
/// stays ornamental: all text sits over the dark contrast-preserving overlay.
class R35CoastalBannerPainter extends CustomPainter {
  const R35CoastalBannerPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: <Color>[Color(0xFF63D9FF), Color(0xFFBCEEFF), Color(0xFF05A5DD)],
    ).createShader(bounds));
    final sun = Offset(size.width * .82, size.height * .24);
    canvas.drawCircle(sun, size.height * .20,
      Paint()..color = const Color(0x80FFF2AF)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22));
    canvas.drawCircle(sun, size.height * .12, Paint()..color = const Color(0xFFFFF4C7));
    final seaTop = size.height * .69;
    canvas.drawRect(Rect.fromLTWH(0, seaTop, size.width, size.height - seaTop),
      Paint()..shader = const LinearGradient(colors: <Color>[Color(0xFF27BFD4), Color(0xFF0379C4)])
        .createShader(Rect.fromLTWH(0, seaTop, size.width, size.height - seaTop)));
    final skyline = Paint()..color = const Color(0xFF61A7BD).withValues(alpha: .55);
    final skylineDark = Paint()..color = const Color(0xFF1B779E).withValues(alpha: .55);
    for (var i = 0; i < 24; i++) {
      final x = size.width * (.44 + i * .025);
      final tall = size.height * (.13 + (i * 13 % 11) * .015);
      canvas.drawRect(Rect.fromLTWH(x, seaTop - tall, size.width * .018, tall),
        i.isEven ? skyline : skylineDark);
    }
    final wave = Paint()..color = const Color(0x66FFFFFF)..strokeWidth = 1.5;
    for (var i = 0; i < 17; i++) {
      final x = size.width * ((i * 13 % 17) / 18);
      final y = seaTop + 9 + (i * 7 % 5) * 8;
      canvas.drawLine(Offset(x, y), Offset(x + size.width * .035, y), wave);
    }
  }
  @override
  bool shouldRepaint(covariant R35CoastalBannerPainter oldDelegate) => false;
}

/// A custom gold trophy, drawn in resolution-independent vector geometry.
class R35GoldTrophyPainter extends CustomPainter {
  const R35GoldTrophyPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final golden = Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: <Color>[Color(0xFFFFF6B3), Color(0xFFFFCE40), Color(0xFFD77700), Color(0xFFFFEE8B)],
      stops: <double>[0, .35, .72, 1],
    ).createShader(rect);
    final edge = Paint()..color = const Color(0xFF965106)..style = PaintingStyle.stroke..strokeWidth = 2.3;
    final bowl = Path()
      ..moveTo(size.width * .28, size.height * .20)
      ..lineTo(size.width * .75, size.height * .20)
      ..cubicTo(size.width * .75, size.height * .53,
          size.width * .65, size.height * .59, size.width * .52, size.height * .60)
      ..cubicTo(size.width * .37, size.height * .58,
          size.width * .28, size.height * .48, size.width * .28, size.height * .20)
      ..close();
    final leftHandle = Path()
      ..moveTo(size.width * .29, size.height * .29)
      ..cubicTo(size.width * .05, size.height * .20, size.width * .09, size.height * .47, size.width * .35, size.height * .49);
    final rightHandle = Path()
      ..moveTo(size.width * .75, size.height * .29)
      ..cubicTo(size.width * .97, size.height * .19, size.width * .94, size.height * .48, size.width * .67, size.height * .49);
    final handle = Paint()..shader = golden.shader..style = PaintingStyle.stroke..strokeWidth = size.width * .085..strokeCap = StrokeCap.round;
    canvas.drawPath(leftHandle, handle);
    canvas.drawPath(rightHandle, handle);
    canvas.drawPath(bowl, golden);
    canvas.drawPath(bowl, edge);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(
      size.width * .47, size.height * .56, size.width * .10, size.height * .22), const Radius.circular(4)), golden);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(
      size.width * .34, size.height * .77, size.width * .36, size.height * .07), const Radius.circular(6)), golden);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(
      size.width * .29, size.height * .82, size.width * .46, size.height * .07), const Radius.circular(5)), golden);
    final diamond = Path()
      ..moveTo(size.width * .52, size.height * .30)
      ..lineTo(size.width * .59, size.height * .40)
      ..lineTo(size.width * .52, size.height * .50)
      ..lineTo(size.width * .45, size.height * .40)
      ..close();
    canvas.drawPath(diamond, Paint()..color = const Color(0xFF17CB91));
    canvas.drawPath(diamond, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFFFFF6C4));
    for (final point in <Offset>[
      Offset(size.width * .13, size.height * .15),
      Offset(size.width * .87, size.height * .12),
      Offset(size.width * .91, size.height * .67),
    ]) {
      final star = Paint()..color = const Color(0xFFFFF7C8)..strokeWidth = 2;
      canvas.drawLine(point.translate(-6, 0), point.translate(6, 0), star);
      canvas.drawLine(point.translate(0, -6), point.translate(0, 6), star);
    }
  }
  @override
  bool shouldRepaint(covariant R35GoldTrophyPainter oldDelegate) => false;
}


/// Screenshot-guided virtual storefront: prices are read from the live
/// controller catalogue and every offer opens the real product preview.
class R35StoreTreasureStrip extends StatelessWidget {
  const R35StoreTreasureStrip({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final samples = products.where((product) =>
      controller.isStoreProductVisible(product) &&
      <String>{'tables', 'cards', 'boost', 'pasha', 'covers'}.contains(product.category)
    ).take(3).toList(growable: false);
    return Container(
      key: const ValueKey('r35-reference-store-specials'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1389DA), Color(0xFF0759AE), Color(0xFF042F7E)]),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: R35ReferenceColors.paleGold.withValues(alpha: .88), width: 1.5),
        boxShadow: <BoxShadow>[BoxShadow(color: R35ReferenceColors.deep.withValues(alpha: .28),
          blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Row(children: <Widget>[
          const Icon(Icons.local_offer_rounded, color: R35ReferenceColors.gold, size: 26),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(ar ? 'مقتنيات وعروض خاصة' : 'Premium items and special offers',
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
            Text(ar ? 'مقتنيات المتجر الحقيقية بأسعارها الفعلية' : 'Actual catalogue items with verified prices',
              style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 10)),
          ])),
          IconButton(
            tooltip: ar ? 'المحفظة' : 'Wallet',
            onPressed: () => showWallet(context, controller),
            icon: const Icon(Icons.account_balance_wallet_rounded, color: R35ReferenceColors.paleGold)),
        ]),
        const SizedBox(height: 12),
        if (samples.isEmpty)
          Padding(padding: const EdgeInsets.all(12),
            child: Text(ar ? 'لا توجد عروض متاحة حاليًا' : 'No offers available right now',
              style: const TextStyle(color: Colors.white70)))
        else Row(children: <Widget>[
          for (var i = 0; i < samples.length; i++) ...<Widget>[
            if (i != 0) const SizedBox(width: 8),
            Expanded(child: R35StoreTreasureTile(
              product: samples[i],
              controller: controller,
              onTap: () => showProductPreview(context, controller, samples[i]),
            )),
          ],
        ]),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => showRewards(context, controller),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[Color(0xFF0A9FE3), Color(0xFF0E5BB5)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: R35ReferenceColors.cyan.withValues(alpha: .66)),
            ),
            child: Row(children: <Widget>[
              const Icon(Icons.card_giftcard_rounded, size: 27, color: R35ReferenceColors.paleGold),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(ar ? 'صناديق الجوائز والمكافآت' : 'Prize boxes and rewards',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                Text(ar ? 'اطّلع على المكافآت المتاحة وشروطها' : 'View available rewards and their terms',
                  style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 10)),
              ])),
              const Icon(Icons.chevron_right_rounded, color: R35ReferenceColors.gold),
            ]),
          ),
        ),
      ]),
    );
  }
}

class R35StoreTreasureTile extends StatelessWidget {
  const R35StoreTreasureTile({
    super.key, required this.product, required this.controller, required this.onTap,
  });
  final StoreProduct product;
  final AppController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = controller.priceFor(product);
    return Semantics(
      button: true,
      label: product.name(controller.localeCode),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.fromLTRB(5, 11, 5, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: const LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF1E91E5), Color(0xFF074C9D)]),
            border: Border.all(color: R35ReferenceColors.cyan.withValues(alpha: .76)),
          ),
          child: Column(children: <Widget>[
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(colors: <Color>[
                  Color(0xFFFFECA2), Color(0xFFFFC447), Color(0xFFAD6500)]),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: R35ReferenceColors.gold.withValues(alpha: .31), blurRadius: 12),
                ],
              ),
              child: Center(child: Text(product.icon, maxLines: 1,
                style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 8),
            Text(product.name(controller.localeCode), textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: R35ReferenceColors.gold,
                borderRadius: BorderRadius.circular(9)),
              child: Text('🪙 ' + formatNumber(price), maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: R35ReferenceColors.navy,
                  fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ]),
        ),
      ),
    );
  }
}
