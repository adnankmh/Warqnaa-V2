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
    return Container(
      constraints: BoxConstraints(minHeight: wide ? 280 : 230),
      padding: EdgeInsets.all(wide ? 30 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(R9Design.rHero),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF13263B), Color(0xFF0B1727), Color(0xFF08111E)],
        ),
        border: Border.all(color: R9Design.gold.withValues(alpha: .18)),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 34, offset: Offset(0, 18))],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -24,
            bottom: -36,
            child: Text('♠♥♦♣', style: TextStyle(fontSize: wide ? 132 : 92, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: .035))),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: R9Design.gold.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: R9Design.gold.withValues(alpha: .18)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4ADE80))),
                      const SizedBox(width: 7),
                      Text(_ar ? 'اللوبي مباشر • R9' : 'Live lobby • R9', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFF0D486))),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _ar ? 'اللعب يبدأ من هنا.' : 'Your table starts here.',
                    style: TextStyle(fontSize: wide ? 42 : 31, height: 1.04, fontWeight: FontWeight.w900, letterSpacing: -.8),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _ar
                        ? 'ادخل مباراة بسرعة، تابع أصدقاءك، أو ابدأ منافسة بدون ازدحام بصري أو خطوات زائدة.'
                        : 'Jump into a match, follow friends, or enter a competition without visual clutter or extra steps.',
                    style: TextStyle(fontSize: wide ? 15 : 13, height: 1.55, color: Colors.white.withValues(alpha: .68)),
                  ),
                  const SizedBox(height: 19),
                  Wrap(spacing: 9, runSpacing: 9, children: [
                    FilledButton.icon(
                      onPressed: () => showGameLobby(context, controller, controller.homeGames.first),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(_ar ? 'العب الآن' : 'Play now'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showCompetitions(context, controller),
                      icon: const Icon(Icons.emoji_events_outlined),
                      label: Text(_ar ? 'المنافسات' : 'Competitions'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
