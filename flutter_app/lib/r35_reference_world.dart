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
            R51FeaturedGamesAndTournaments(controller: controller, onTab: onTab),
            const SizedBox(height:12),
            R52RewardsHomePanel(controller:controller),
            const SizedBox(height: 12),
            R43ReferenceQuickDestinations(controller: controller, onTab: onTab),
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
                      textAlign: TextAlign.center, style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 12, height: 1.35, fontWeight: FontWeight.w700)),
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

/// The same live game/tournament composition is used by both Home routes.
/// Breakpoints follow the space left by the shell, including desktop sidebars.
class R51FeaturedGamesAndTournaments extends StatelessWidget {
  const R51FeaturedGamesAndTournaments({super.key, required this.controller, required this.onTab});
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final games = customerGamesR101.take(6).toList(growable: false);
    return LayoutBuilder(builder: (context, featured) {
      final stacked = featured.maxWidth < 760;
      final gameColumns = stacked
          ? (featured.maxWidth < 350 ? 2 : featured.maxWidth < 600 ? 3 : 4)
          : (featured.maxWidth >= 1140 ? 4 : 3);
      final gamesPanel = R35ReferencePanel(
        key: const ValueKey('r51-games-panel'),
        title: ar ? 'جميع الألعاب' : 'All games',
        icon: Icons.style_rounded,
        actionLabel: ar ? 'عرض الكل' : 'View all',
        onAction: () => onTab(1),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: games.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gameColumns,
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
      );
      final tournamentsPanel = R35ReferencePanel(
        key: const ValueKey('r51-tournaments-panel'),
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
      );
      return stacked
          ? Column(
              key: const ValueKey('r51-featured-stacked'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                gamesPanel,
                const SizedBox(height: 12),
                tournamentsPanel,
              ],
            )
          : Row(
              key: const ValueKey('r51-featured-wide'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 11, child: gamesPanel),
                const SizedBox(width: 12),
                Expanded(flex: 7, child: tournamentsPanel),
              ],
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
            style: const TextStyle(color: R35ReferenceColors.white, fontSize: 16.5, fontWeight: FontWeight.w900))),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: R35ReferenceColors.paleGold,
                minimumSize: const Size(44, 44), padding: const EdgeInsets.symmetric(horizontal: 10)),
              child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
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
    final viewport = MediaQuery.sizeOf(context);
    final compact = viewport.width < 600 || viewport.height < 480;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final bannerHeight = (compact ? 188.0 : 240.0) * (textScale < 1 ? 1 : textScale);
    return Semantics(
      container: true,
      label: ar ? 'بطولات ورقنا الكبرى' : 'Warqnaa grand championships',
      child: Container(
        key: const ValueKey('r35-sky-grand-tournament-banner'),
        height: bannerHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: R35ReferenceColors.paleGold, width: 2),
          boxShadow: <BoxShadow>[BoxShadow(
            color: R35ReferenceColors.deep.withValues(alpha: .36), blurRadius: 23, offset: const Offset(0, 8))],
        ),
        child: Stack(fit: StackFit.expand, children: <Widget>[
          Image.asset('assets/optimized/r36/championship_hero.webp',
            key: const ValueKey('r36-championship-art'),
            fit: BoxFit.cover, alignment: Alignment.centerLeft,
            filterQuality: FilterQuality.high, excludeFromSemantics: true,
            errorBuilder: (_, __, ___) => const CustomPaint(painter: R35CoastalBannerPainter())),
          Container(decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight, end: Alignment.centerLeft,
              colors: <Color>[Color(0xD903285F), Color(0x70043E80), Color(0x00043E80)],
              stops: <double>[0, .55, 1],
            ),
          )),
          Align(alignment: Alignment.centerRight, child: FractionallySizedBox(
            widthFactor: compact ? .65 : .60,
            child: Padding(
            padding: EdgeInsets.fromLTRB(8, 13, compact ? 11 : 19, 13),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(ar ? '🏆 بطولات ورقنا الكبرى' : '🏆 WARQNAA CHAMPIONSHIPS',
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: R35ReferenceColors.paleGold,
                  fontSize: compact ? 16 : 24, fontWeight: FontWeight.w900, height: 1.2)),
              const SizedBox(height: 7),
              Text(ar ? 'نافس، اربح الجوائز الافتراضية، واصنع تاريخك!'
                      : 'Compete for virtual rewards and make your mark!',
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: compact ? 11.5 : 13.5, height: 1.35, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              if (!compact) Text(ar ? 'اطّلع على البطولات الحالية وشروط المشاركة قبل التسجيل.'
                      : 'Review available tournaments and their rules before entering.',
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 11.5, height: 1.35, fontWeight: FontWeight.w700)),
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
          ))),
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
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            color: const Color(0xD9042D75),
            child: Text(L.t(locale, game.id), textAlign: TextAlign.center,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.25, fontWeight: FontWeight.w900)),
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5)),
          const SizedBox(height: 4),
          Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: R35ReferenceColors.cyan, fontWeight: FontWeight.w700, fontSize: 11.5, height: 1.3)),
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
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 11, height: 1.3, fontWeight: FontWeight.w700)),
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
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
    style: FilledButton.styleFrom(
      backgroundColor: R35ReferenceColors.gold,
      foregroundColor: R35ReferenceColors.navy,
      minimumSize: const Size(44, 44),
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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5, height: 1.2)),
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 12, height: 1.25, fontWeight: FontWeight.w700)),
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
        color: r48StorePanel,
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
              style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 11.5, height: 1.35, fontWeight: FontWeight.w700)),
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
        else LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 420) {
            return SizedBox(
              key: const ValueKey('r45-store-treasure-scroll'),
              height: 166,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: samples.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => SizedBox(
                  key: ValueKey('r45-store-item-${samples[i].id}'),
                  width: 136,
                  child: R35StoreTreasureTile(
                    product: samples[i],
                    controller: controller,
                    onTap: () => showProductPreview(context, controller, samples[i]),
                  ),
                ),
              ),
            );
          }
          return Row(
            key: const ValueKey('r45-store-treasure-grid'),
            children: <Widget>[
              for (var i = 0; i < samples.length; i++) ...<Widget>[
                if (i != 0) const SizedBox(width: 8),
                Expanded(child: R35StoreTreasureTile(
                  product: samples[i],
                  controller: controller,
                  onTap: () => showProductPreview(context, controller, samples[i]),
                )),
              ],
            ],
          );
        }),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => showRewards(context, controller),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: r48StoreTile,
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
                  style: const TextStyle(color: R35ReferenceColors.cyan, fontSize: 12, height: 1.25, fontWeight: FontWeight.w700)),
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
            color: r48StoreTile,
            border: Border.all(color: R35ReferenceColors.cyan.withValues(alpha: .76)),
          ),
          child: Column(children: <Widget>[
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: R35ReferenceColors.gold,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: R35ReferenceColors.gold.withValues(alpha: .31), blurRadius: 12),
                ],
              ),
              child: Center(child: Text(product.icon, maxLines: 1,
                style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  product.name(controller.localeCode),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: R35ReferenceColors.gold,
                borderRadius: BorderRadius.circular(9)),
              child: Text('🪙 ${formatNumber(price)}', maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: R35ReferenceColors.navy,
                  fontSize: 11.5, fontWeight: FontWeight.w900)),
            ),
          ]),
        ),
      ),
    );
  }
}


/// R43: navigable native Flutter tiles for the user-approved reference gallery.
/// This is not a flattened image: every tile routes to the existing live feature.
/// No mock balances, fictitious prizes or dummy bot opponents are introduced.
class R43ReferenceQuickDestinations extends StatelessWidget {
  const R43ReferenceQuickDestinations({
    super.key, required this.controller, required this.onTab,
  });
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final items = <R43ReferenceDestination>[
      R43ReferenceDestination(
        icon: Icons.emoji_events_rounded,
        title: ar ? 'البطولات' : 'Tournaments',
        detail: ar ? 'يومية وأسبوعية وكبرى' : 'Daily, weekly and grand',
        tone: const Color(0xFFFFCD46),
        onTap: () => Navigator.push<void>(context,
          MaterialPageRoute<void>(builder: (_) => R12CompetitiveArenaPage(controller: controller))),
      ),
      R43ReferenceDestination(
        icon: Icons.shield_rounded,
        title: ar ? 'الأندية' : 'Clubs',
        detail: ar ? 'المنافسات والمجموعات' : 'Clubs and communities',
        tone: const Color(0xFF6AFFC2),
        onTap: () => Navigator.push<void>(context,
          MaterialPageRoute<void>(builder: (_) => ClubsPage(controller: controller))),
      ),
      R43ReferenceDestination(
        icon: Icons.account_circle_rounded,
        title: ar ? 'تخصيص الملف' : 'Personalize',
        detail: ar ? 'الصورة والإطار والغلاف' : 'Avatar, frame and cover',
        tone: const Color(0xFF91E9FF),
        onTap: () => showAvatarPicker(context, controller),
      ),
      R43ReferenceDestination(
        icon: Icons.emoji_emotions_rounded,
        title: ar ? 'ردود الفعل' : 'Reactions',
        detail: ar ? 'إيموجي وباقات مميزة' : 'Emojis and collections',
        tone: const Color(0xFFFFDC88),
        onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(
          builder: (_) => R43ReferenceCatalogPage(controller: controller, category: 'emoji'))),
      ),
      R43ReferenceDestination(
        icon: Icons.smart_toy_rounded,
        title: ar ? 'الروبوتات' : 'Practice bots',
        detail: ar ? 'تدرّب داخل الألعاب' : 'Train in supported games',
        tone: const Color(0xFFCDB8FF),
        onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(
          builder: (_) => R43BotRosterPage(controller: controller, onTab: onTab))),
      ),
      R43ReferenceDestination(
        icon: Icons.style_rounded,
        title: ar ? 'خلفيات الورق' : 'Card backs',
        detail: ar ? 'ألوان وتصميمات فاخرة' : 'Premium card collections',
        tone: const Color(0xFFFFAB8E),
        onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(
          builder: (_) => R43ReferenceCatalogPage(controller: controller, category: 'cards'))),
      ),
      R43ReferenceDestination(
        icon: Icons.bolt_rounded,
        title: ar ? 'المعززات' : 'Boosters',
        detail: ar ? 'المميزات المتاحة' : 'Available special features',
        tone: const Color(0xFF96F5AB),
        onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(
          builder: (_) => R43ReferenceCatalogPage(controller: controller, category: 'boost'))),
      ),
      R43ReferenceDestination(
        icon: Icons.storefront_rounded,
        title: ar ? 'المتجر' : 'Store',
        detail: ar ? 'العروض والصناديق' : 'Offers and prize boxes',
        tone: const Color(0xFFFFE382),
        onTap: () => onTab(0),
      ),
      R43ReferenceDestination(
        icon: Icons.info_outline_rounded,
        title: ar ? 'معلومات عامة' : 'About Warqnaa',
        detail: ar ? 'التطبيق والألعاب والخدمات' : 'Apps, games and services',
        tone: const Color(0xFFA3E9FF),
        onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(
          builder: (_) => R43GeneralInformationPage(controller: controller))),
      ),
    ];
    return R35ReferencePanel(
      key: const ValueKey('r43-reference-navigation'),
      title: ar ? 'اكتشف عالم ورقنا' : 'Discover the Warqnaa world',
      icon: Icons.auto_awesome_rounded,
      child: LayoutBuilder(
        builder: (context, bounds) {
          final columns = bounds.maxWidth >= 1150
              ? 4
              : bounds.maxWidth >= 600
                  ? 4
                  : 2;
          return GridView.builder(
            key: const ValueKey('r43-reference-destinations-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              childAspectRatio: bounds.maxWidth < 380 ? 1.14 : 1.47,
            ),
            itemBuilder: (context, index) => R43DestinationTile(
              destination: items[index],
            ),
          );
        },
      ),
    );
  }
}

class R43ReferenceDestination {
  const R43ReferenceDestination({
    required this.icon,
    required this.title,
    required this.detail,
    required this.tone,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String detail;
  final Color tone;
  final VoidCallback onTap;
}

class R43DestinationTile extends StatelessWidget {
  const R43DestinationTile({super.key, required this.destination});
  final R43ReferenceDestination destination;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: destination.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: destination.onTap,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: destination.tone.withValues(alpha: .85), width: 1.3),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF119DEB),Color(0xFF086BC0),Color(0xFF063A7D)],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(color: R35ReferenceColors.navy.withValues(alpha: .27),
                  blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(destination.icon, size: 30, color: destination.tone),
                  const SizedBox(height: 5),
                  Text(
                    destination.title,
                    textAlign: TextAlign.center,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900,
                      fontSize: 13.5, color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    destination.detail,
                    textAlign: TextAlign.center,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5,
                      color: R35ReferenceColors.cyan, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// Reference-screen category browser. Renders actual inventory from the same
/// store model and invokes its existing preview/checkout flow; no invented
/// offers or prices are displayed. Works in both portrait and landscape.
class R43ReferenceCatalogPage extends StatelessWidget {
  const R43ReferenceCatalogPage({
    super.key,
    required this.controller,
    required this.category,
  }) : assert(category == 'cards' || category == 'boost' || category == 'emoji');

  final AppController controller;
  final String category;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final title = switch (category) {
      'cards' => ar ? 'خلفيات أوراق اللعب' : 'Card-back collection',
      'boost' => ar ? 'المعززات والمميزات' : 'Boosters and benefits',
      _ => ar ? 'الإيموجي وردود الفعل' : 'Emojis and reactions',
    };
    final description = ar
        ? 'الأسعار والمقتنيات من المتجر الحقيقي، وتظهر لك التفاصيل قبل تأكيد الشراء.'
        : 'Real store prices and items. Review each item before confirming a purchase.';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            tooltip: ar ? 'المحفظة' : 'Wallet',
            onPressed: () => showWallet(context, controller),
            icon: const Icon(Icons.account_balance_wallet_rounded),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final items = controller.storeProductsR36.where((product) =>
            product.category == category &&
            controller.isStoreProductVisible(product) &&
            !product.id.startsWith('table_reference_')
          ).toList(growable: false);
          return LayoutBuilder(
            builder: (context, bounds) {
              final columns = bounds.maxWidth >= 1080
                  ? 5
                  : bounds.maxWidth >= 740
                      ? 4
                      : bounds.maxWidth >= 370
                          ? 3
                          : 2;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: R35ReferencePanel(
                          title: title,
                          icon: category == 'cards'
                              ? Icons.style_rounded
                              : category == 'boost'
                                  ? Icons.bolt_rounded
                                  : Icons.emoji_emotions_rounded,
                          actionLabel: ar ? 'المتجر الكامل' : 'Full store',
                          onAction: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(
                              builder: (_) => StorePage(controller: controller),
                            )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(description,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w700,
                                )),
                              const SizedBox(height: 6),
                              Text(
                                ar ? 'العناصر المتاحة: ${items.length}' : 'Available items: ${items.length}',
                                style: const TextStyle(
                                  color: R35ReferenceColors.paleGold,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: items.isEmpty
                            ? Center(child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  ar
                                      ? 'لا تتوفر مقتنيات في هذا القسم حاليًا. يمكنك العودة للمتجر للاطلاع على الأقسام الأخرى.'
                                      : 'No items are currently available in this category. Browse the full store for more.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ))
                            : GridView.builder(
                                key: const ValueKey('r43-live-catalog-grid'),
                                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                                itemCount: items.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisExtent: 185,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemBuilder: (context, index) => R35StoreTreasureTile(
                                  key: ValueKey('r43-product-${items[index].id}'),
                                  product: items[index],
                                  controller: controller,
                                  onTap: () => showProductPreview(context, controller, items[index]),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


/// Information screen is a native, readable widget, not the small screenshot
/// itself. The wording describes available project modules, not guaranteed
/// publication in an external app store.
class R43GeneralInformationPage extends StatelessWidget {
  const R43GeneralInformationPage({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final features = <(IconData, String, String)>[
      (
        Icons.devices_rounded,
        ar ? 'متعددة المنصات' : 'Multi-platform',
        ar ? 'واجهات للويب والهاتف مع مشاريع بناء Android وiOS.'
           : 'Web and mobile interfaces with Android and iOS build projects.',
      ),
      (
        Icons.style_rounded,
        ar ? 'ألعاب ورق عربية' : 'Arabic card games',
        ar ? 'مكتبة ألعاب وصالات وغرف ومباريات.'
           : 'Card-game library, lobbies, rooms and matches.',
      ),
      (
        Icons.people_alt_rounded,
        ar ? 'المجتمع والأندية' : 'Community and clubs',
        ar ? 'ملفات شخصية وأصدقاء وأندية ودعوات.'
           : 'Profiles, friends, clubs and invitations.',
      ),
      (
        Icons.emoji_events_rounded,
        ar ? 'البطولات والمنافسات' : 'Tournaments',
        ar ? 'المشاركة وفق شروط كل بطولة ومواعيدها وجوائزها الفعلية.'
           : 'Participation follows each event’s actual terms, dates and prizes.',
      ),
      (
        Icons.storefront_rounded,
        ar ? 'المتجر والمكافآت' : 'Store and rewards',
        ar ? 'مقتنيات افتراضية، ومكافآت وصناديق بحسب المتاح.'
           : 'Digital collectibles, rewards and prize boxes where available.',
      ),
      (
        Icons.palette_rounded,
        ar ? 'التخصيص' : 'Customization',
        ar ? 'طاولات وخلفيات أوراق وإطارات وألوان.'
           : 'Tables, card backs, profile frames and colors.',
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'معلومات عامة' : 'About Warqnaa')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            key: const ValueKey('r43-general-information-list'),
            padding: const EdgeInsets.all(14),
            children: <Widget>[
              R35ReferencePanel(
                title: ar ? 'ورقنا — ألعاب الورق العربية' : 'Warqnaa — Arabic card games',
                icon: Icons.info_outline_rounded,
                child: Text(
                  ar ? 'منصة اجتماعية للألعاب والتواصل والمنافسة على الهاتف والويب. توفر الميزات والمكافآت يعتمد على حالة الخادم والإصدار.'
                     : 'A social card-game platform for play, connection and competition on web and mobile. Availability depends on the server and release.',
                  style: const TextStyle(
                    fontSize: 14, height: 1.55,
                    color: Colors.white, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: R35FeatureLine(
                  icon: feature.$1,
                  title: feature.$2,
                  detail: feature.$3,
                ),
              )),
              const SizedBox(height: 8),
              R35GoldAction(
                label: ar ? 'تصفح المتجر' : 'Browse store',
                icon: Icons.storefront_rounded,
                onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(
                  builder: (_) => StorePage(controller: controller),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Reuses the verified bot identities already shipped with the Flutter app.
/// Avatar cards are illustrative; joining a real practice match remains
/// governed by the engine and room capabilities in the existing Games tab.
class R43BotRosterPage extends StatelessWidget {
  const R43BotRosterPage({
    super.key,
    required this.controller,
    required this.onTab,
  });
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'شخصيات الروبوتات الذكية' : 'Computer-player roster')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            key: const ValueKey('r43-bot-roster-screen'),
            padding: const EdgeInsets.all(12),
            children: <Widget>[
              R35ReferencePanel(
                title: ar ? 'شخصيات الروبوتات' : 'Bot personalities',
                icon: Icons.smart_toy_rounded,
                child: Text(
                  ar ? 'شاهد الشخصيات ومستوياتها. اختر لعبة متوافقة لبدء التدريب من صالة الألعاب.'
                     : 'Browse personalities and their levels. Choose a compatible game to begin practice from the game hall.',
                  style: const TextStyle(
                    color: Colors.white, height: 1.45, fontSize: 13, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              BotRosterShowcase(locale: controller.localeCode),
              const SizedBox(height: 16),
              R35GoldAction(
                label: ar ? 'اختر لعبة للتدريب' : 'Choose a game to practice',
                icon: Icons.sports_esports_rounded,
                onTap: () {
                  Navigator.pop(context);
                  onTab(1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
