part of 'main.dart';

/// B307 visual system: an original Warqnaa premium card-room experience
/// inspired by the polish of modern MENA social card-game products without
/// copying third-party branding, assets, or proprietary layouts.
const String warqnaaB307VisualRelease = '1.4.0+308-sky-luxe';

/// Bright sky-blue visual foundation requested for the R27 luxury pass.
///
/// The palette deliberately keeps the main product surfaces clearly blue and
/// luminous instead of near-black. Gold is reserved for premium emphasis and
/// conversion CTAs so hierarchy stays readable in Arabic RTL and English LTR.
abstract final class B307SkyLuxury {
  static const Color sky = Color(0xff24c8ff);
  static const Color cyan = Color(0xff22d3ee);
  static const Color azure = Color(0xff0b8cff);
  static const Color royal = Color(0xff075fbd);
  static const Color deep = Color(0xff064777);
  static const Color navy = Color(0xff052f54);
  static const Color surface = Color(0xff07598f);
  static const Color surfaceRaised = Color(0xff0a6eb0);
  static const Color gold = Color(0xffffc84a);
  static const Color goldSoft = Color(0xffffdf7d);
  static const Color emerald = Color(0xff2dd4a8);
  static const Color text = Color(0xfff8fcff);
  static const Color textMuted = Color(0xffc9eaff);

  static const LinearGradient shellGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xff0b8cff), Color(0xff075fbd), Color(0xff064777)],
  );

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xff0a6eb0), Color(0xff07598f), Color(0xff064777)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xff11a8f5), Color(0xff0878cf), Color(0xff07528e)],
  );

  static BoxBorder border({double alpha = .28}) => Border.all(color: sky.withValues(alpha: alpha));

  static List<BoxShadow> get glow => <BoxShadow>[
        BoxShadow(color: sky.withValues(alpha: .17), blurRadius: 22, spreadRadius: 1, offset: const Offset(0, 7)),
        const BoxShadow(color: Color(0x33001933), blurRadius: 18, offset: Offset(0, 9)),
      ];
}

class B307TopBar extends StatelessWidget {
  const B307TopBar({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 390;
      final avatarSize = compact ? 36.0 : 42.0;
      return Container(
        margin: const EdgeInsets.fromLTRB(8, 6, 8, 4),
        padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: 7),
        decoration: BoxDecoration(
          gradient: B307SkyLuxury.shellGradient,
          borderRadius: BorderRadius.circular(17),
          border: B307SkyLuxury.border(alpha: .40),
          boxShadow: B307SkyLuxury.glow,
        ),
        child: Row(children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, controller),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: <Color>[B307SkyLuxury.sky, B307SkyLuxury.gold]),
                border: Border.all(color: B307SkyLuxury.goldSoft, width: 2),
                boxShadow: <BoxShadow>[BoxShadow(color: B307SkyLuxury.sky.withValues(alpha: .34), blurRadius: 12)],
              ),
              child: Center(child: Text(controller.avatarEmoji, style: TextStyle(fontSize: compact ? 19 : 22))),
            ),
          ),
          SizedBox(width: compact ? 6 : 9),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text(controller.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: B307SkyLuxury.text, fontWeight: FontWeight.w900, fontSize: compact ? 11.5 : 13)),
              const SizedBox(height: 2),
              Row(children: <Widget>[
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: controller.serverConnected ? B307SkyLuxury.emerald : B307SkyLuxury.gold)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    controller.serverConnected ? (ar ? 'متصل' : 'Online') : (ar ? 'وضع محلي' : 'Local mode'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: B307SkyLuxury.textMuted, fontWeight: FontWeight.w700),
                  ),
                ),
              ]),
            ]),
          ),
          if (!compact) ...<Widget>[
            B307TopCounter(icon: Icons.workspace_premium_rounded, value: '${controller.vipDays}', accent: B307SkyLuxury.gold),
            const SizedBox(width: 5),
          ],
          B307TopCounter(icon: Icons.monetization_on_rounded, value: formatNumber(controller.coins), accent: B307SkyLuxury.goldSoft),
          SizedBox(width: compact ? 2 : 4),
          if (!compact)
            IconButton(
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tooltip: ar ? 'الأصدقاء' : 'Friends',
              onPressed: () => showFriends(context, controller),
              icon: const Icon(Icons.people_alt_outlined, size: 21, color: B307SkyLuxury.text),
            ),
          IconButton(
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            tooltip: ar ? 'الإشعارات' : 'Notifications',
            onPressed: () => showNotifications(context, controller),
            icon: const Icon(Icons.notifications_none_rounded, size: 21, color: B307SkyLuxury.text),
          ),
        ]),
      );
    });
  }
}

class B307TopCounter extends StatelessWidget {
  const B307TopCounter({super.key, required this.icon, required this.value, required this.accent});
  final IconData icon;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 58),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: <Color>[Color(0xff0b70b3), Color(0xff07558d)]),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: B307SkyLuxury.sky.withValues(alpha: .34)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 4),
          Flexible(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 9, fontWeight: FontWeight.w900))),
        ]),
      );
}

class B307BottomNavigation extends StatelessWidget {
  const B307BottomNavigation({super.key, required this.controller, required this.selectedIndex, required this.onSelected});
  final AppController controller;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final icons = <IconData>[
      Icons.storefront_outlined,
      Icons.style_outlined,
      Icons.home_rounded,
      Icons.groups_2_outlined,
      Icons.emoji_events_outlined,
    ];
    final labels = <String>[
      ar ? 'المتجر' : 'Store',
      ar ? 'الألعاب' : 'Games',
      ar ? 'الرئيسية' : 'Home',
      ar ? 'الأصدقاء' : 'Social',
      ar ? 'البطولات' : 'Events',
    ];
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 7),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          gradient: B307SkyLuxury.shellGradient,
          borderRadius: BorderRadius.circular(18),
          border: B307SkyLuxury.border(alpha: .38),
          boxShadow: B307SkyLuxury.glow,
        ),
        child: Row(
          children: List<Widget>.generate(icons.length, (i) {
            final selected = i == selectedIndex;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: selected
                        ? const LinearGradient(colors: <Color>[Color(0xff23c7ff), Color(0xff0b8cff)])
                        : null,
                    color: selected ? null : Colors.transparent,
                    border: selected ? Border.all(color: B307SkyLuxury.goldSoft.withValues(alpha: .72)) : null,
                    boxShadow: selected ? <BoxShadow>[BoxShadow(color: B307SkyLuxury.sky.withValues(alpha: .28), blurRadius: 12)] : null,
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Icon(icons[i], size: 21, color: selected ? Colors.white : B307SkyLuxury.textMuted),
                    const SizedBox(height: 2),
                    Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8.5, fontWeight: selected ? FontWeight.w900 : FontWeight.w700, color: selected ? Colors.white : B307SkyLuxury.textMuted)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class B307DesktopNavigation extends StatelessWidget {
  const B307DesktopNavigation({
    super.key,
    required this.controller,
    required this.selectedIndex,
    required this.onSelected,
  });

  final AppController controller;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final destinations = <({IconData icon, String ar, String en})>[
      (icon: Icons.storefront_outlined, ar: 'المتجر', en: 'Store'),
      (icon: Icons.style_outlined, ar: 'الألعاب', en: 'Games'),
      (icon: Icons.home_rounded, ar: 'الرئيسية', en: 'Home'),
      (icon: Icons.groups_2_outlined, ar: 'المجتمع', en: 'Social'),
      (icon: Icons.emoji_events_outlined, ar: 'البطولات', en: 'Events'),
    ];

    return SafeArea(
      right: false,
      child: Container(
        key: const Key('r28-sky-desktop-navigation'),
        width: 220,
        margin: const EdgeInsets.fromLTRB(10, 10, 6, 10),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          gradient: B307SkyLuxury.shellGradient,
          borderRadius: BorderRadius.circular(24),
          border: B307SkyLuxury.border(alpha: .42),
          boxShadow: B307SkyLuxury.glow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xff18b9ff), Color(0xff0b79d0)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: B307SkyLuxury.sky.withValues(alpha: .48)),
            ),
            child: Row(children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: <Color>[B307SkyLuxury.sky, B307SkyLuxury.gold]),
                  border: Border.all(color: B307SkyLuxury.goldSoft, width: 2),
                ),
                alignment: Alignment.center,
                child: const Text('W', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  const Text('WARQNAA', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: B307SkyLuxury.text, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: .9)),
                  Text(ar ? 'مجتمع ألعاب الورق' : 'Social card games', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.textMuted, fontSize: 9.5, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < destinations.length; i++) ...<Widget>[
            _B307DesktopDestination(
              icon: destinations[i].icon,
              label: ar ? destinations[i].ar : destinations[i].en,
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
            if (i != destinations.length - 1) const SizedBox(height: 7),
          ],
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: B307SkyLuxury.sky.withValues(alpha: .26)),
            ),
            child: Row(children: <Widget>[
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: B307SkyLuxury.navy.withValues(alpha: .52),
                  border: Border.all(color: B307SkyLuxury.gold.withValues(alpha: .65)),
                ),
                child: Text(controller.avatarEmoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text(controller.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 11.5, fontWeight: FontWeight.w900)),
                  Text(ar ? 'المستوى ${controller.level}' : 'Level ${controller.level}', style: const TextStyle(color: B307SkyLuxury.textMuted, fontSize: 9, fontWeight: FontWeight.w700)),
                ]),
              ),
              IconButton(
                tooltip: ar ? 'الإعدادات' : 'Settings',
                visualDensity: VisualDensity.compact,
                onPressed: () => showSettings(context, controller),
                icon: const Icon(Icons.settings_outlined, size: 19, color: B307SkyLuxury.goldSoft),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _B307DesktopDestination extends StatelessWidget {
  const _B307DesktopDestination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(colors: <Color>[Color(0xff22c8ff), Color(0xff0b85e0)])
                  : null,
              color: selected ? null : Colors.white.withValues(alpha: .055),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? B307SkyLuxury.sky.withValues(alpha: .65)
                    : B307SkyLuxury.sky.withValues(alpha: .16),
              ),
              boxShadow: selected
                  ? <BoxShadow>[BoxShadow(color: B307SkyLuxury.cyan.withValues(alpha: .22), blurRadius: 14)]
                  : const <BoxShadow>[],
            ),
            child: Row(children: <Widget>[
              Icon(icon, color: selected ? Colors.white : B307SkyLuxury.textMuted, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : B307SkyLuxury.textMuted,
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                  ),
                ),
              ),
              if (selected) const Icon(Icons.chevron_right_rounded, size: 18, color: B307SkyLuxury.goldSoft),
            ]),
          ),
        ),
      );
}

class B307HomeDashboard extends StatelessWidget {
  const B307HomeDashboard({super.key, required this.controller, required this.onTab});
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final games = customerGamesR101;
    final featured = games.take(6).toList(growable: false);
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 16),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: B307SkyLuxury.heroGradient,
            border: Border.all(color: B307SkyLuxury.goldSoft.withValues(alpha: .46)),
            boxShadow: B307SkyLuxury.glow,
          ),
          child: Row(children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: <Color>[Color(0x66ffffff), Color(0x1600e5ff)]),
                border: Border.all(color: B307SkyLuxury.goldSoft.withValues(alpha: .42)),
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 40, color: B307SkyLuxury.goldSoft),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(ar ? 'بطولات ورقنا الكبرى' : 'Warqnaa Grand Tournaments', style: const TextStyle(color: B307SkyLuxury.text, fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 4),
              Text(ar ? 'نافس كل يوم، اجمع الجوائز، وارتقِ من واجهة زرقاء فاخرة وسريعة.' : 'Compete daily, collect rewards and progress from a bright premium blue hub.', style: const TextStyle(fontSize: 10, height: 1.45, color: B307SkyLuxury.textMuted)),
              const SizedBox(height: 9),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: B307SkyLuxury.gold, foregroundColor: B307SkyLuxury.navy),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => R12CompetitiveArenaPage(controller: controller))),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(ar ? 'شارك الآن' : 'Join now'),
              ),
            ])),
          ]),
        ),
        const SizedBox(height: 9),
        Row(children: <Widget>[
          Expanded(child: B307StatCard(icon: Icons.shield_outlined, label: ar ? 'المستوى' : 'Level', value: '${controller.level}')),
          const SizedBox(width: 7),
          Expanded(child: B307StatCard(icon: Icons.workspace_premium_outlined, label: ar ? 'باشا' : 'Pasha', value: '${controller.vipDays}')),
          const SizedBox(width: 7),
          Expanded(child: B307StatCard(icon: Icons.military_tech_outlined, label: ar ? 'الفوز' : 'Wins', value: '${controller.wins}')),
        ]),
        const SizedBox(height: 10),
        B307SectionHeader(
          title: ar ? 'ألعابك' : 'Your games',
          action: ar ? 'عرض الكل' : 'View all',
          onTap: () => onTab(1),
        ),
        const SizedBox(height: 7),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: featured.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: .78),
          itemBuilder: (context, index) {
            final game = featured[index];
            return InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => showGameLobby(context, controller, game),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: B307SkyLuxury.panelGradient,
                  borderRadius: BorderRadius.circular(15),
                  border: B307SkyLuxury.border(alpha: .34),
                  boxShadow: <BoxShadow>[BoxShadow(color: B307SkyLuxury.sky.withValues(alpha: .10), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: Image.asset(
                      r101GameArtAsset(game.id),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => Center(child: Text(game.icon, style: const TextStyle(fontSize: 30))),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(L.t(controller.localeCode, game.id), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 10, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: <Color>[B307SkyLuxury.emerald, Color(0xff15a981)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(ar ? 'العب' : 'Play', style: const TextStyle(color: Color(0xff062f36), fontSize: 8.5, fontWeight: FontWeight.w900)),
                  ),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        B307SectionHeader(title: ar ? 'الخدمات السريعة' : 'Quick actions'),
        const SizedBox(height: 7),
        Wrap(spacing: 7, runSpacing: 7, children: <Widget>[
          B307QuickAction(icon: Icons.storefront_outlined, label: ar ? 'المتجر' : 'Store', onTap: () => onTab(0)),
          B307QuickAction(icon: Icons.credit_card_rounded, label: ar ? 'العروض النقدية' : 'Cash offers', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => B307CashShopPage(controller: controller)))),
          B307QuickAction(icon: Icons.people_alt_outlined, label: ar ? 'الأصدقاء' : 'Friends', onTap: () => showFriends(context, controller)),
          B307QuickAction(icon: Icons.account_balance_wallet_outlined, label: ar ? 'المحفظة' : 'Wallet', onTap: () => showWallet(context, controller)),
          if (controller.isLocalAdmin)
            B307QuickAction(
              key: const ValueKey('r9-open-studio'),
              icon: Icons.design_services_rounded,
              label: ar ? 'استوديو Adnan' : 'Adnan studio',
              onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R9LocalStudio(controller: controller))),
            ),
        ]),
      ],
    );
  }
}

class B307StatCard extends StatelessWidget {
  const B307StatCard({super.key, required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        decoration: BoxDecoration(
          gradient: B307SkyLuxury.panelGradient,
          borderRadius: BorderRadius.circular(14),
          border: B307SkyLuxury.border(alpha: .31),
        ),
        child: Column(children: <Widget>[
          const SizedBox(height: 1),
          Icon(icon, size: 18, color: B307SkyLuxury.gold),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: B307SkyLuxury.text, fontWeight: FontWeight.w900, fontSize: 13)),
          Text(label, style: const TextStyle(fontSize: 8.5, color: B307SkyLuxury.textMuted, fontWeight: FontWeight.w700)),
        ]),
      );
}

class B307SectionHeader extends StatelessWidget {
  const B307SectionHeader({super.key, required this.title, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
        Container(width: 4, height: 20, decoration: BoxDecoration(color: B307SkyLuxury.sky, borderRadius: BorderRadius.circular(99))),
        const SizedBox(width: 7),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!, style: const TextStyle(fontSize: 9, color: B307SkyLuxury.sky))),
      ]);
}

class B307QuickAction extends StatelessWidget {
  const B307QuickAction({super.key, required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 112,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              gradient: B307SkyLuxury.panelGradient,
              borderRadius: BorderRadius.circular(13),
              border: B307SkyLuxury.border(alpha: .31),
            ),
            child: Column(children: <Widget>[
              Icon(icon, size: 20, color: B307SkyLuxury.goldSoft),
              const SizedBox(height: 5),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 9, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      );
}

class B307RealMoneyStoreBanner extends StatelessWidget {
  const B307RealMoneyStoreBanner({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => B307CashShopPage(controller: controller))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: <Color>[Color(0xff0b8cff), Color(0xff075fbd), Color(0xff805b12)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: B307SkyLuxury.goldSoft.withValues(alpha: .46)),
          boxShadow: B307SkyLuxury.glow,
        ),
        child: Row(children: <Widget>[
          const Icon(Icons.shopping_bag_rounded, color: B307SkyLuxury.goldSoft, size: 34),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(ar ? 'متجر العروض المميزة' : 'Premium offers', style: const TextStyle(color: B307SkyLuxury.text, fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 3),
            Text(ar ? 'حزم وتوكنز وعروض موسمية مع شراء موثّق وآمن عبر مزود الدفع.' : 'Bundles, tokens and seasonal offers with verified provider checkout.', style: const TextStyle(fontSize: 9.5, color: B307SkyLuxury.textMuted)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: B307SkyLuxury.text),
        ]),
      ),
    );
  }
}

class B307CashShopPage extends StatefulWidget {
  const B307CashShopPage({super.key, required this.controller});
  final AppController controller;
  @override
  State<B307CashShopPage> createState() => _B307CashShopPageState();
}

class _B307CashShopPageState extends State<B307CashShopPage> {
  late Future<Map<String, dynamic>> future;
  String category = 'all';
  @override
  void initState() {
    super.initState();
    future = widget.controller.api.commerceCatalogR101();
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.controller.localeCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'العروض والشراء' : 'Offers & checkout')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final commerce = snapshot.data?['commerce'];
          final catalog = commerce is Map ? Map<String, dynamic>.from(commerce) : <String, dynamic>{};
          final packagesRaw = catalog['packages'];
          final packages = packagesRaw is List ? packagesRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : <Map<String, dynamic>>[];
          return ListView(padding: const EdgeInsets.all(12), children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: B307SkyLuxury.heroGradient,
                border: Border.all(color: B307SkyLuxury.goldSoft.withValues(alpha: .42)),
                boxShadow: B307SkyLuxury.glow,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(ar ? 'عروض ورقنا الخاصة' : 'Warqnaa special offers', style: const TextStyle(color: B307SkyLuxury.text, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(ar ? 'اختَر الحزمة المناسبة. الدفع النهائي يتم عبر مزود دفع موثوق، ولا يخزن ورقنا بيانات بطاقتك.' : 'Choose a package. Final payment is handled by a trusted provider; Warqnaa does not store raw card details.', style: const TextStyle(fontSize: 10, height: 1.5, color: B307SkyLuxury.textMuted)),
              ]),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 39, child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
              for (final entry in <Map<String, String>>[
                <String, String>{'key':'all', 'label': ar ? 'الكل' : 'All'},
                <String, String>{'key':'featured', 'label': ar ? 'مميزة' : 'Featured'},
                <String, String>{'key':'weekly', 'label': ar ? 'الأسبوع' : 'Weekly'},
                <String, String>{'key':'tokens', 'label': ar ? 'توكنز' : 'Tokens'},
              ])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: ChoiceChip(
                    label: Text(entry['label']!),
                    selected: category == entry['key'],
                    onSelected: (_) => setState(() => category = entry['key']!),
                  ),
                ),
            ])),
            const SizedBox(height: 10),
            if (snapshot.hasError || packages.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: B307SkyLuxury.panelGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: B307SkyLuxury.border(alpha: .30),
                ),
                child: Text(ar ? 'تعذر تحميل العروض من الخادم. تأكد من اتصال التطبيق بعنوان API الصحيح.' : 'Could not load offers. Check the app API/server connection.', textAlign: TextAlign.center),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: packages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .78),
                itemBuilder: (context, i) => B307CashOfferCard(controller: widget.controller, data: packages[i]),
              ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('${widget.controller.api.webBaseUrl}/offers');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.open_in_browser_rounded),
              label: Text(ar ? 'فتح متجر الويب' : 'Open web store'),
            ),
          ]);
        },
      ),
    );
  }
}

class B307CashOfferCard extends StatelessWidget {
  const B307CashOfferCard({super.key, required this.controller, required this.data});
  final AppController controller;
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final tokens = int.tryParse(data['tokens']?.toString() ?? '') ?? 0;
    final minor = int.tryParse(data['price_minor']?.toString() ?? '') ?? 0;
    final price = (minor / 100).toStringAsFixed(2);
    final badge = data['badge']?.toString() ?? '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: B307SkyLuxury.panelGradient,
        borderRadius: BorderRadius.circular(15),
        border: B307SkyLuxury.border(alpha: .34),
        boxShadow: <BoxShadow>[BoxShadow(color: B307SkyLuxury.sky.withValues(alpha: .10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: <Widget>[
        Align(alignment: AlignmentDirectional.topEnd, child: badge.isEmpty ? const SizedBox(height: 22) : Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: B307SkyLuxury.gold, borderRadius: BorderRadius.circular(99)), child: Text(badge, style: const TextStyle(color: B307SkyLuxury.navy, fontSize: 8, fontWeight: FontWeight.w900)))),
        const Spacer(),
        Text(data['icon']?.toString() ?? '🪙', style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 7),
        Text('${formatNumber(BigInt.from(tokens))} ${ar ? 'توكنز' : 'tokens'}', textAlign: TextAlign.center, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 13, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text('${data['currency'] ?? 'USD'} $price', style: const TextStyle(color: B307SkyLuxury.goldSoft, fontWeight: FontWeight.w900)),
        const Spacer(),
        SizedBox(width: double.infinity, child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: B307SkyLuxury.gold, foregroundColor: B307SkyLuxury.navy),
          onPressed: () async {
            final uri = Uri.parse('${controller.api.webBaseUrl}/offers?package=${Uri.encodeQueryComponent(data['key']?.toString() ?? '')}');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          child: Text(ar ? 'شراء' : 'Buy'),
        )),
      ]),
    );
  }
}
