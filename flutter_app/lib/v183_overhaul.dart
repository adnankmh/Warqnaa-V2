part of 'main.dart';

/// V183: responsive desktop shell, adaptive previews and data-driven store rules.
const String warqnaaV183Release = '0.3.2+183';

bool isDesktopWebV183(double width) => kIsWeb && width >= 1024;
bool isWideDesktopV183(double width) => kIsWeb && width >= 1440;

String _multiplierLabelV183(double? multiplier) {
  if (multiplier == null || multiplier <= 1) return '';
  final rounded = multiplier == multiplier.roundToDouble()
      ? multiplier.toStringAsFixed(0)
      : multiplier.toStringAsFixed(1);
  return '×$rounded';
}

int raisedStorePriceV183(StoreProduct product) {
  if (product.price <= 0) return product.price;
  if (product.category == 'pasha') return product.price;
  // R9.1 luxury economy: tables are intentionally the most premium class,
  // card backs sit below them, and the rest of the cosmetics are raised while
  // Pasha remains unchanged; ticket artwork/value stays fixed while its purchase price receives only a small economy uplift.
  final multiplier = switch (product.category) {
    'tables' => 5.25,
    'cards' => 3.50,
    'emoji' => 3.25,
    'themes' => 3.00,
    'effects' => 3.50,
    'covers' => 3.10,
    'badges' => 3.00,
    'names' => 2.85,
    'chat_colors' => 2.85,
    'boost' => 2.25,
    'competition_ticket' => 1.10,
    _ => 3.00,
  };
  final raw = (product.price * multiplier).round();
  // Luxury-store rounding avoids random-looking prices.
  if (raw < 1000) return ((raw + 49) ~/ 50) * 50;
  if (raw < 10000) return ((raw + 249) ~/ 250) * 250;
  return ((raw + 499) ~/ 500) * 500;
}

int boosterValidityDaysV183(String id) => switch (id) {
  'booster_yellow_v183' => 7,
  'booster_green_v183' => 8,
  'booster_red_v183' => 9,
  'booster_blue_v183' => 10,
  'booster_black_v183' => 11,
  'booster_silver_v183' => 12,
  'booster_gold_v183' => 14,
  _ => 10,
};

String boosterColorNameV183(StoreProduct product, String lang) {
  final color = product.id.replaceAll('booster_', '').replaceAll('_v183', '');
  const ar = <String, String>{
    'yellow': 'الأصفر', 'green': 'الأخضر', 'red': 'الأحمر', 'blue': 'الأزرق',
    'black': 'الأسود', 'silver': 'الفضي', 'gold': 'الذهبي',
  };
  const en = <String, String>{
    'yellow': 'Yellow', 'green': 'Green', 'red': 'Red', 'blue': 'Blue',
    'black': 'Black', 'silver': 'Silver', 'gold': 'Gold',
  };
  return lang == 'ar' ? (ar[color] ?? color) : (en[color] ?? color);
}

class DesktopShellNavigationV183 extends StatelessWidget {
  final AppController controller;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const DesktopShellNavigationV183({
    super.key,
    required this.controller,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = <(IconData, String)>[
      (Icons.redeem_rounded, L.t(controller.localeCode, 'store')),
      (Icons.style_rounded, L.t(controller.localeCode, 'games')),
      (Icons.home_rounded, L.t(controller.localeCode, 'home')),
      (Icons.shield_rounded, L.t(controller.localeCode, 'clubs')),
      (Icons.public_rounded, L.t(controller.localeCode, 'social_world')),
    ];
    return Container(
      width: 224,
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: .96),
        border: BorderDirectional(end: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .25))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Image.asset('assets/images/brand/warqna_logo.png', width: 46, height: 46, fit: BoxFit.contain),
            const SizedBox(width: 9),
            const Expanded(child: Text('Warqnaa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 20),
          for (var i = 0; i < destinations.length; i++) ...[
            _DesktopDestinationV183(
              icon: destinations[i].$1,
              label: destinations[i].$2,
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
            const SizedBox(height: 7),
          ],
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .24)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(controller.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('LV.${controller.level}  •  🪙 ${formatNumber(controller.coins)}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DesktopDestinationV183 extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DesktopDestinationV183({required this.icon, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: .15) : Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(children: [
          Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w900 : FontWeight.w700))),
        ]),
      ),
    ),
  );
}

class AdaptiveTablePreviewV183 extends StatelessWidget {
  final AppController controller;
  final StoreProduct product;
  final bool compact;
  final bool gameplay;
  const AdaptiveTablePreviewV183({super.key, required this.controller, required this.product, this.compact = false, this.gameplay = false});

  @override
  Widget build(BuildContext context) => R9DirectionalTablePreview(controller: controller, product: product, compact: compact);
}

class CompetitionTicketPreviewV183 extends StatelessWidget {
  final String denomination;
  final bool compact;
  const CompetitionTicketPreviewV183({super.key, required this.denomination, this.compact = false});

  @override
  Widget build(BuildContext context) {
    // R9.1: the denomination is part of the ticket artwork itself. Never paint a
    // second number over the image; that was the source of duplicated ticket values.
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Padding(
        padding: EdgeInsets.all(compact ? 2 : 4),
        child: Image.asset(ticketAssetV02(denomination), fit: BoxFit.contain, filterQuality: FilterQuality.high),
      ),
    );
  }
}

class BoosterPreviewV183 extends StatefulWidget {
  final StoreProduct product;
  final bool compact;
  const BoosterPreviewV183({super.key, required this.product, this.compact = false});

  @override
  State<BoosterPreviewV183> createState() => _BoosterPreviewV210State();
}

class _BoosterPreviewV210State extends State<BoosterPreviewV183> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  late final Animation<double> _turn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat(reverse: true);
    _pulse = Tween<double>(begin: .975, end: 1.025).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
    _turn = Tween<double>(begin: -.018, end: .018).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c1 = widget.product.previewColor1 ?? const Color(0xfff59e0b);
    final c2 = widget.product.previewColor2 ?? const Color(0xff451a03);
    final multiplier = _multiplierLabelV183(widget.product.multiplier);
    final size = widget.compact ? 138.0 : 260.0;
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.rotate(
          angle: _turn.value,
          child: Transform.scale(scale: _pulse.value, child: child),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(alignment: Alignment.center, children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [c1.withValues(alpha: .28), c1.withValues(alpha: .08), Colors.transparent]),
                ),
              ),
            ),
            SizedBox(
              width: size * .78,
              height: size * .82,
              child: ClipPath(
                clipper: _BoosterShieldClipperV210(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, Color.lerp(c1, c2, .44)!, c2]),
                    boxShadow: [BoxShadow(color: c1.withValues(alpha: .42), blurRadius: widget.compact ? 14 : 28, spreadRadius: 1)],
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    Positioned.fill(child: CustomPaint(painter: _BoosterCircuitPainterV210(color: Colors.white.withValues(alpha: .18)))),
                    Container(
                      width: size * .43,
                      height: size * .43,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x52020a12),
                        border: Border.all(color: Colors.white.withValues(alpha: .56), width: widget.compact ? 1.4 : 2.2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .32), blurRadius: 18)],
                      ),
                      child: Icon(Icons.rocket_launch_rounded, size: size * .23, color: Colors.white),
                    ),
                    Positioned(
                      top: size * .13,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.bolt_rounded, size: size * .09, color: Colors.white),
                        Text('XP BOOST', style: TextStyle(fontSize: widget.compact ? 8 : 12, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: widget.compact ? 6 : 12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: widget.compact ? 12 : 18, vertical: widget.compact ? 6 : 9),
                decoration: BoxDecoration(
                  color: const Color(0xee061019),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: c1.withValues(alpha: .82), width: 1.5),
                  boxShadow: [BoxShadow(color: c1.withValues(alpha: .28), blurRadius: 14)],
                ),
                child: Text('×$multiplier XP', style: TextStyle(fontSize: widget.compact ? 14 : 21, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BoosterShieldClipperV210 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * .5, 0)
      ..lineTo(w * .92, h * .17)
      ..lineTo(w * .84, h * .72)
      ..quadraticBezierTo(w * .5, h, w * .5, h)
      ..quadraticBezierTo(w * .5, h, w * .16, h * .72)
      ..lineTo(w * .08, h * .17)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BoosterCircuitPainterV210 extends CustomPainter {
  final Color color;
  const _BoosterCircuitPainterV210({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke;
    for (var i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(Offset(size.width * .08, y), Offset(size.width * .28, y), paint);
      canvas.drawCircle(Offset(size.width * .31, y), 2.2, paint);
      canvas.drawLine(Offset(size.width * .72, y), Offset(size.width * .92, y), paint);
      canvas.drawCircle(Offset(size.width * .69, y), 2.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoosterCircuitPainterV210 oldDelegate) => oldDelegate.color != color;
}

class DesignerQuickControlsV183 extends StatelessWidget {
  final AppController controller;
  const DesignerQuickControlsV183({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => PremiumPanel(
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('مركز التعديل المباشر V183', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 5),
        Text('تعديل الأسعار، الإتاحة، النصوص، الألوان، المدة، المعاينات، المسرعات، الإيموت والأصوات مع حفظ محلي ومزامنة الخادم.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10, height: 1.5)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.tonalIcon(
            onPressed: controller.isPrimaryAdmin ? () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Scaffold(appBar: AppBar(title: const Text('استديو المتجر الشامل')), body: SafeArea(child: AdminStoreStudioV151(controller: controller))))) : null,
            icon: const Icon(Icons.storefront_rounded),
            label: const Text('استديو كل عناصر المتجر'),
          ),
          for (final item in const <(String, String, IconData)>[
            ('مسرعات النقاط', 'xp_booster', Icons.rocket_launch_rounded),
            ('الإيموت والحزم', 'emoji_pack', Icons.emoji_emotions_rounded),
            ('الأصوات والمؤثرات', 'audio', Icons.graphic_eq_rounded),
            ('المعاينات والأحجام', 'preview_layout', Icons.aspect_ratio_rounded),
            ('قواعد ومحركات الألعاب', 'game_rules', Icons.rule_rounded),
          ])
            OutlinedButton.icon(
              onPressed: controller.isPrimaryAdmin ? () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DesignerEntityManagerV173(controller: controller, initialEntityType: item.$2, title: item.$1))) : null,
              icon: Icon(item.$3),
              label: Text(item.$1),
            ),
        ]),
      ]),
    ),
  );
}

class HomeDashboardV183 extends StatelessWidget {
  final AppController controller;
  final ValueChanged<int> onTab;
  const HomeDashboardV183({super.key, required this.controller, required this.onTab});

  Widget _games(BuildContext context, double width) {
    final lang = controller.localeCode;
    final selectedGames = controller.homeGames;
    final columns = width >= 1180 ? 4 : width >= 760 ? 3 : 2;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionTitle(
        title: L.t(lang, 'homeGames'),
        action: L.t(lang, 'customize'),
        onTap: () => showHomeGamesSelector(context, controller),
      ),
      const SizedBox(height: 10),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: math.min(columns, selectedGames.length).clamp(1, 4).toInt(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: width >= 900 ? 1.34 : .92,
        ),
        itemCount: selectedGames.length,
        itemBuilder: (_, i) => GameCard(
          game: selectedGames[i],
          lang: lang,
          onTap: () => showGameLobby(context, controller, selectedGames[i]),
        ),
      ),
    ]);
  }

  Widget _playActions(BuildContext context) {
    final lang = controller.localeCode;
    return Row(children: [
      Expanded(child: PremiumActionButton(
        icon: Icons.handshake,
        title: L.t(lang, 'friendly'),
        color: Theme.of(context).colorScheme.secondary,
        onPressed: () => showGameLobby(context, controller, gamesCatalog[1]),
      )),
      const SizedBox(width: 12),
      Expanded(child: PremiumActionButton(
        icon: Icons.emoji_events,
        title: L.t(lang, 'competitions'),
        color: const Color(0xffa06f1d),
        onPressed: () => showCompetitions(context, controller),
      )),
    ]);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final desktop = isDesktopWebV183(constraints.maxWidth);
    if (!desktop) {
      return ListView(
        padding: const EdgeInsets.all(13),
        children: [
          ResponsiveAccountStatsV170(controller: controller),
          const SizedBox(height: 13),
          HeroBanner(lang: controller.localeCode, onJoin: () => showCompetitions(context, controller)),
          const SizedBox(height: 13),
          LuckyWheelHomeCardV182(controller: controller),
          const SizedBox(height: 13),
          PrizeBoxesHomeCardV02(controller: controller, onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PrizeBoxesPageV02(controller: controller)))),
          const SizedBox(height: 13),
          GiftRoad(controller: controller),
          const SizedBox(height: 16),
          _games(context, constraints.maxWidth),
          const SizedBox(height: 13),
          _playActions(context),
          const SizedBox(height: 13),
          HomeQuickActionsV170(controller: controller, onTab: onTab),
        ],
      );
    }

    final sideWidth = constraints.maxWidth >= 1450 ? 430.0 : 370.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ResponsiveAccountStatsV170(controller: controller),
            const SizedBox(height: 16),
            HeroBanner(lang: controller.localeCode, onJoin: () => showCompetitions(context, controller)),
            const SizedBox(height: 18),
            _games(context, constraints.maxWidth - sideWidth - 34),
            const SizedBox(height: 16),
            _playActions(context),
          ]),
        ),
        const SizedBox(width: 18),
        SizedBox(
          width: sideWidth,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            LuckyWheelHomeCardV182(controller: controller),
            const SizedBox(height: 14),
            PrizeBoxesHomeCardV02(controller: controller, onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PrizeBoxesPageV02(controller: controller)))),
            const SizedBox(height: 14),
            GiftRoad(controller: controller),
            const SizedBox(height: 14),
            HomeQuickActionsV170(controller: controller, onTab: onTab),
          ]),
        ),
      ]),
    );
  });
}
