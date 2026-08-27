part of 'main.dart';

const String warqnaaR9Release = '0.4.9+209';

class R9HomeDashboard extends StatelessWidget {
  const R9HomeDashboard({super.key, required this.controller, required this.onTab});
  final AppController controller;
  final ValueChanged<int> onTab;

  bool get _ar => controller.localeCode == 'ar';

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1040;
          final content = <Widget>[
            _hero(context, wide),
            const SizedBox(height: R9Design.s16),
            _liveStrip(context),
            const SizedBox(height: R9Design.s24),
            _games(context, constraints.maxWidth),
            const SizedBox(height: R9Design.s24),
            _engagement(context, wide),
            const SizedBox(height: R9Design.s24),
            _quickLinks(context, wide),
            const SizedBox(height: 32),
          ];
          return ListView(
            padding: EdgeInsets.fromLTRB(wide ? 24 : 14, 14, wide ? 24 : 14, 28),
            children: content,
          );
        },
      );

  Widget _hero(BuildContext context, bool wide) {
    final accent = Theme.of(context).colorScheme.primary;
    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: R9Design.gold.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: R9Design.gold.withValues(alpha: .20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF5FF0A4),
                  boxShadow: [BoxShadow(color: Color(0x665FF0A4), blurRadius: 12)],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                L.t(controller.localeCode, 'worldStatus'),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFF0D486), letterSpacing: .8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          L.t(controller.localeCode, 'premiumHeroTitle'),
          style: TextStyle(
            fontSize: wide ? 46 : 32,
            height: 1.02,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 11),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            L.t(controller.localeCode, 'premiumHeroSubtitle'),
            style: TextStyle(fontSize: wide ? 15 : 12.5, height: 1.62, color: Colors.white.withValues(alpha: .68)),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            FilledButton.icon(
              onPressed: () => showGameLobby(context, controller, controller.homeGames.first),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(L.t(controller.localeCode, 'play')),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => V300WorldHubPage(controller: controller))),
              icon: const Icon(Icons.public_rounded),
              label: Text(L.t(controller.localeCode, 'worldHub')),
            ),
            OutlinedButton.icon(
              onPressed: () => showCompetitions(context, controller),
              icon: const Icon(Icons.emoji_events_outlined),
              label: Text(L.t(controller.localeCode, 'enterArena')),
            ),
          ],
        ),
      ],
    );

    return Container(
      constraints: BoxConstraints(minHeight: wide ? 320 : 270),
      padding: EdgeInsets.all(wide ? 30 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2531), Color(0xFF081824), Color(0xFF07120F)],
        ),
        border: Border.all(color: R9Design.gold.withValues(alpha: .16)),
        boxShadow: const [BoxShadow(color: Color(0x4A000000), blurRadius: 42, offset: Offset(0, 20))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -60,
              top: -90,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .08)),
              ),
            ),
            PositionedDirectional(
              start: -80,
              bottom: -120,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(shape: BoxShape.circle, color: R9Design.gold.withValues(alpha: .045)),
              ),
            ),
            PositionedDirectional(
              end: -22,
              bottom: -32,
              child: Text(
                '♠♥♦♣',
                style: TextStyle(fontSize: wide ? 126 : 82, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: .025)),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: copy),
                        const SizedBox(width: 24),
                        _heroStatusCard(),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [copy, const SizedBox(height: 18), _heroStatusCard(compact: true)],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStatusCard({bool compact = false}) {
    final connected = controller.serverConnected;
    return Container(
      width: compact ? double.infinity : 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xA80A1720),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [Color(0x3358C9FF), Color(0x3357E0B4)]),
                ),
                child: const Icon(Icons.hub_rounded, size: 19, color: Color(0xFF70E6BF)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L.t(controller.localeCode, 'liveNetwork'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    Text(
                      connected ? 'ONLINE • API' : 'LOCAL • READY',
                      style: TextStyle(fontSize: 8, color: connected ? const Color(0xFF70E6BF) : Colors.white54, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _heroMetric('LV.${controller.level}', L.t(controller.localeCode, 'level'))),
              const SizedBox(width: 8),
              Expanded(child: _heroMetric('${controller.vipDays}', L.t(controller.localeCode, 'vip'))),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(color: const Color(0x1457E0B4), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF70E6BF)),
                const SizedBox(width: 7),
                Expanded(child: Text(L.t(controller.localeCode, 'serverFair'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroMetric(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .035), borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Colors.white54)),
          ],
        ),
      );

  Widget _liveStrip(BuildContext context) => R9Section(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Wrap(
          spacing: 16,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _metric(Icons.military_tech_rounded, 'LV.${controller.level}', _ar ? 'مستواك' : 'Level'),
            _metric(Icons.monetization_on_outlined, formatNumber(controller.coins), _ar ? 'توكن' : 'Tokens'),
            _metric(Icons.workspace_premium_outlined, '${controller.vipDays}', _ar ? 'أيام باشا' : 'Pasha days'),
            _metric(Icons.local_fire_department_outlined, '${controller.challengeStreakV173}', _ar ? 'سلسلة التحدي' : 'Challenge streak'),
          ],
        ),
      );

  Widget _metric(IconData icon, String value, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: R9Design.gold),
          const SizedBox(width: 7),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54)),
          ]),
        ],
      );

  Widget _games(BuildContext context, double width) {
    final games = controller.homeGames;
    final columns = width >= 1300 ? 4 : width >= 760 ? 3 : 2;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionTitle(title: _ar ? 'ألعابك' : 'Your games', action: _ar ? 'تخصيص' : 'Customize', onTap: () => showHomeGamesSelector(context, controller)),
      const SizedBox(height: 11),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: math.min(columns, games.length).clamp(1, 4).toInt(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: width >= 1000 ? 1.46 : .96,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) => GameCard(
          game: games[index],
          lang: controller.localeCode,
          onTap: () => showGameLobby(context, controller, games[index]),
        ),
      ),
    ]);
  }

  Widget _engagement(BuildContext context, bool wide) {
    final wheel = LuckyWheelHomeCardV182(controller: controller);
    final boxes = PrizeBoxesHomeCardV02(controller: controller, onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PrizeBoxesPageV02(controller: controller))));
    return wide
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: wheel), const SizedBox(width: 12), Expanded(child: boxes)])
        : Column(children: [wheel, const SizedBox(height: 12), boxes]);
  }

  Widget _quickLinks(BuildContext context, bool wide) {
    final items = <({IconData icon, String ar, String en, VoidCallback tap})>[
      (icon: Icons.groups_2_outlined, ar: 'الأندية', en: 'Clubs', tap: () => onTab(3)),
      (icon: Icons.storefront_outlined, ar: 'المتجر', en: 'Store', tap: () => onTab(0)),
      (icon: Icons.public_rounded, ar: 'العالم الاجتماعي', en: 'Social World', tap: () => onTab(4)),
      (icon: Icons.task_alt_rounded, ar: 'المهام', en: 'Missions', tap: () => showRewards(context, controller)),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: wide ? 4 : 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: wide ? 2.2 : 1.55),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: item.tap,
          borderRadius: BorderRadius.circular(R9Design.rMedium),
          child: R9Section(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .11), borderRadius: BorderRadius.circular(13)), child: Icon(item.icon, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(_ar ? item.ar : item.en, style: const TextStyle(fontWeight: FontWeight.w900))),
            ]),
          ),
        );
      },
    );
  }
}

/// R10.1 table preview follows device orientation but keeps artwork as a
/// proportional inlay inside the premium table surface; the artwork never
/// stretches across the whole table or distorts its frame.
class R9DirectionalTablePreview extends StatelessWidget {
  const R9DirectionalTablePreview({super.key, required this.controller, required this.product, this.compact = false});
  final AppController controller;
  final StoreProduct product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final portrait = !kIsWeb && size.height > size.width;
    final c1 = controller.color1For(product);
    final c2 = controller.color2For(product);
    return AspectRatio(
      aspectRatio: portrait ? 10 / 16 : 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 18 : 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.lerp(c1, Colors.black, .35)!, c1, Color.lerp(c2, Colors.black, .48)!]),
            border: Border.all(color: c2.withValues(alpha: .54), width: compact ? 2 : 3),
          ),
          child: Stack(fit: StackFit.expand, children: [
            DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .05), Colors.transparent, Colors.black.withValues(alpha: .18)]))),
            if (product.imageAsset != null)
              Center(
                child: FractionallySizedBox(
                  widthFactor: portrait ? .70 : .62,
                  heightFactor: portrait ? .54 : .68,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(compact ? 12 : 18),
                    child: Opacity(
                      opacity: .72,
                      child: Image.asset(product.imageAsset!, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                    ),
                  ),
                ),
              ),
            if (product.imageAsset == null) Center(child: Text(product.icon, style: TextStyle(fontSize: compact ? 38 : 70))),
          ]),
        ),
      ),
    );
  }
}
