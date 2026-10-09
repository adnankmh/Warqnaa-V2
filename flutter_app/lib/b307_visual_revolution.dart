part of 'main.dart';

/// B307 visual system: an original Warqnaa premium card-room experience
/// inspired by the polish of modern MENA social card-game products without
/// copying third-party branding, assets, or proprietary layouts.
const String warqnaaB307VisualRelease = '1.5.0+309-premium-world';

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
              child: Center(child: AccountAvatar(controller: controller, size: avatarSize - 6)),
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
                    Icon(icons[i], size: 21, color: selected ? Colors.black : B307SkyLuxury.textMuted),
                    const SizedBox(height: 2),
                    Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8.5, fontWeight: selected ? FontWeight.w900 : FontWeight.w700, color: selected ? Colors.black : B307SkyLuxury.textMuted)),
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
                child: Image.asset('assets/images/brand/warqna_logo.png', fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.style_rounded, color: Colors.white)),
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
          const SizedBox(height: 12),
          // R35 reference sidebar: retain all five tab indices but make the
          // secondary illustrated world destinations scrollable on short PCs.
          Expanded(child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              for (var i = 0; i < destinations.length; i++) ...<Widget>[
                _B307DesktopDestination(
                  icon: destinations[i].icon,
                  label: ar ? destinations[i].ar : destinations[i].en,
                  selected: selectedIndex == i,
                  onTap: () => onSelected(i),
                ),
                const SizedBox(height: 6),
              ],
              const Divider(color: Colors.white24),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 2, 0, 7),
                child: Text(ar ? 'استكشف ورقنا' : 'Explore Warqnaa',
                  style: const TextStyle(color: B307SkyLuxury.goldSoft, fontSize: 10.5, fontWeight: FontWeight.w900))),
              _B307DesktopDestination(
                icon: Icons.leaderboard_rounded,
                label: ar ? 'المتصدرون' : 'Leaderboards',
                selected: false,
                onTap: () => showLeaderboard(context, controller),
              ),
              const SizedBox(height: 6),
              _B307DesktopDestination(
                icon: Icons.shield_rounded,
                label: ar ? 'الأندية' : 'Clubs',
                selected: false,
                onTap: () => Navigator.push(context, MaterialPageRoute<void>(
                  builder: (_) => ClubsPage(controller: controller))),
              ),
              const SizedBox(height: 6),
              _B307DesktopDestination(
                icon: Icons.card_giftcard_rounded,
                label: ar ? 'المكافآت والمهام' : 'Rewards and quests',
                selected: false,
                onTap: () => showRewards(context, controller),
              ),
              const SizedBox(height: 6),
              _B307DesktopDestination(
                icon: Icons.people_alt_rounded,
                label: ar ? 'الأصدقاء' : 'Friends',
                selected: false,
                onTap: () => showFriends(context, controller),
              ),
              const SizedBox(height: 6),
              _B307DesktopDestination(
                icon: Icons.notifications_active_outlined,
                label: ar ? 'الإشعارات' : 'Notifications',
                selected: false,
                onTap: () => showNotifications(context, controller),
              ),
              const SizedBox(height: 6),
              _B307DesktopDestination(
                icon: Icons.face_retouching_natural_rounded,
                label: ar ? 'تخصيص الملف' : 'Profile studio',
                selected: false,
                onTap: () => showProfile(context, controller),
              ),
              const SizedBox(height: 6),
              _B307DesktopDestination(
                icon: Icons.settings_outlined,
                label: ar ? 'الإعدادات' : 'Settings',
                selected: false,
                onTap: () => showSettings(context, controller),
              ),
              const SizedBox(height: 4),
            ]),
          )),
          const SizedBox(height: 8),
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
              Icon(icon, color: selected ? Colors.black : B307SkyLuxury.textMuted, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.black : B307SkyLuxury.textMuted,
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
    // R35 screenshot-guided composition on larger screens; retain the
    // existing compact/mobile dashboard with its full interaction contracts.
    if (MediaQuery.sizeOf(context).width >= 1024) {
      return R35ReferenceWorldDashboard(controller: controller, onTab: onTab);
    }
    final games = customerGamesR101;
    final featured = games.take(6).toList(growable: false);
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 16),
      children: <Widget>[
        R35ChampionBanner(controller: controller),
        const SizedBox(height: 9),
        Row(children: <Widget>[
          Expanded(child: B307StatCard(icon: Icons.shield_outlined, label: ar ? 'المستوى' : 'Level', value: '${controller.level}')),
          const SizedBox(width: 7),
          Expanded(child: B307StatCard(icon: Icons.workspace_premium_outlined, label: ar ? 'باشا' : 'Pasha', value: '${controller.vipDays}')),
          const SizedBox(width: 7),
          Expanded(child: B307StatCard(icon: Icons.military_tech_outlined, label: ar ? 'الفوز' : 'Wins', value: '${controller.wins}')),
        ]),
        if (controller.isLocalAdmin) ...<Widget>[
          const SizedBox(height: 9),
          InkWell(
            key: const ValueKey('r9-open-studio'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R9LocalStudio(controller: controller))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: <Color>[Color(0xff109eea), Color(0xff0874c7)]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: B307SkyLuxury.goldSoft.withValues(alpha: .38)),
                boxShadow: <BoxShadow>[BoxShadow(color: B307SkyLuxury.cyan.withValues(alpha: .14), blurRadius: 12, offset: const Offset(0, 5))],
              ),
              child: Row(children: <Widget>[
                const Icon(Icons.design_services_rounded, color: B307SkyLuxury.goldSoft, size: 22),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Text(ar ? 'استوديو Adnan' : 'Adnan studio', style: const TextStyle(color: B307SkyLuxury.text, fontSize: 11.5, fontWeight: FontWeight.w900)),
                    Text(ar ? 'إدارة وتخصيص محلي سريع لهذا الجهاز' : 'Quick local management and customization for this device', style: const TextStyle(color: B307SkyLuxury.textMuted, fontSize: 8.8, fontWeight: FontWeight.w700)),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, color: B307SkyLuxury.text),
              ]),
            ),
          ),
        ],
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
                    height: 70,
                    width: double.infinity,
                    child: Stack(fit: StackFit.expand, children: <Widget>[
                       Image.asset(r101GameArtAsset(game.id), fit: BoxFit.contain,
                         filterQuality: FilterQuality.high,
                         errorBuilder: (_, __, ___) => R34GameEmblem(gameId: game.id, compact: true)),
                     ]),
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
        const SizedBox(height: 12),
        B307SectionHeader(
          title: ar ? 'عالم ورقنا' : 'Warqnaa world',
          action: ar ? 'استكشف' : 'Explore',
          onTap: () => onTab(3),
        ),
        const SizedBox(height: 7),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 4 : 2;
            return GridView.count(
              key: const ValueKey('r28-sky-world-grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
              childAspectRatio: constraints.maxWidth >= 760 ? 1.42 : 1.18,
              children: <Widget>[
                B307WorldTile(
                  icon: Icons.emoji_events_rounded,
                  title: ar ? 'البطولات' : 'Tournaments',
                  subtitle: ar ? 'يومية وأسبوعية وكبرى' : 'Daily, weekly and grand',
                  accent: B307SkyLuxury.gold,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => R12CompetitiveArenaPage(controller: controller))),
                ),
                B307WorldTile(
                  icon: Icons.shield_rounded,
                  title: ar ? 'الأندية' : 'Clubs',
                  subtitle: ar ? 'فرق، دوريات ومجتمع' : 'Teams, leagues and community',
                  accent: B307SkyLuxury.emerald,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClubsPage(controller: controller))),
                ),
                B307WorldTile(
                  icon: Icons.face_retouching_natural_rounded,
                  title: ar ? 'تخصيص الملف' : 'Profile studio',
                  subtitle: ar ? 'إطار، غلاف، لون وباشا' : 'Frame, cover, color and Pasha',
                  accent: B307SkyLuxury.cyan,
                  onTap: () => showProfile(context, controller),
                ),
                B307WorldTile(
                  icon: Icons.forum_rounded,
                  title: ar ? 'المجتمع' : 'Social',
                  subtitle: ar ? 'أصدقاء، دعوات وتفاعل' : 'Friends, invites and reactions',
                  accent: B307SkyLuxury.sky,
                  onTap: () => onTab(3),
                ),
              ],
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
              icon: Icons.design_services_rounded,
              label: ar ? 'استوديو Adnan' : 'Adnan studio',
              onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R9LocalStudio(controller: controller))),
            ),
        ]),
      ],
    );
  }
}

class B307PageHero extends StatelessWidget {
  const B307PageHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        key: ValueKey<String>('r28-sky-page-${title.hashCode}'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: B307SkyLuxury.heroGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: B307SkyLuxury.sky.withValues(alpha: .38)),
          boxShadow: B307SkyLuxury.glow,
        ),
        child: Row(children: <Widget>[
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: B307SkyLuxury.cyan.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: B307SkyLuxury.cyan.withValues(alpha: .42)),
            ),
            child: Icon(icon, color: B307SkyLuxury.goldSoft, size: 25),
          ),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.textMuted, fontSize: 9.5, height: 1.35, fontWeight: FontWeight.w700)),
          ])),
          if (trailing != null) ...<Widget>[const SizedBox(width: 8), trailing!],
        ]),
      );
}

class B307WorldTile extends StatelessWidget {
  const B307WorldTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: title,
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xff0b78c4), Color(0xff07588f)],
              ),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: accent.withValues(alpha: .52)),
              boxShadow: <BoxShadow>[
                BoxShadow(color: accent.withValues(alpha: .14), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: accent.withValues(alpha: .15),
                    border: Border.all(color: accent.withValues(alpha: .46)),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: B307SkyLuxury.text, fontWeight: FontWeight.w900, fontSize: 11.5),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: B307SkyLuxury.textMuted, fontWeight: FontWeight.w700, fontSize: 8.8, height: 1.25),
                ),
              ],
            ),
          ),
        ),
      );
}

class B307TarneebHud extends StatelessWidget {
  const B307TarneebHud({
    super.key,
    required this.weLabel,
    required this.theyLabel,
    required this.weScore,
    required this.theyScore,
    required this.roundLabel,
    required this.trickScore,
    required this.xpMultiplier,
    required this.connected,
  });

  final String weLabel;
  final String theyLabel;
  final int weScore;
  final int theyScore;
  final String roundLabel;
  final String trickScore;
  final double xpMultiplier;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    Widget score(String label, int value, CrossAxisAlignment alignment) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: B307SkyLuxury.panelGradient,
              borderRadius: BorderRadius.circular(14),
              border: B307SkyLuxury.border(alpha: .34),
            ),
            child: Column(
              crossAxisAlignment: alignment,
              children: <Widget>[
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.textMuted, fontSize: 8.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('$value', style: const TextStyle(color: B307SkyLuxury.text, fontSize: 18, fontWeight: FontWeight.w900, height: 1)),
              ],
            ),
          ),
        );

    return Container(
      key: const ValueKey('r28-sky-tarneeb-hud'),
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 3),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: B307SkyLuxury.shellGradient,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: B307SkyLuxury.sky.withValues(alpha: .44)),
        boxShadow: <BoxShadow>[BoxShadow(color: B307SkyLuxury.sky.withValues(alpha: .12), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Row(children: <Widget>[
        score(weLabel, weScore, CrossAxisAlignment.start),
        const SizedBox(width: 6),
        Flexible(
          flex: 2,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(roundLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.goldSoft, fontSize: 9.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(trickScore, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 11, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 3,
              children: <Widget>[
                _B307HudBadge(
                  icon: connected ? Icons.cloud_done_rounded : Icons.phone_android_rounded,
                  label: connected ? 'LIVE' : 'LOCAL',
                  accent: connected ? B307SkyLuxury.emerald : B307SkyLuxury.cyan,
                ),
                if (xpMultiplier > 1.0)
                  _B307HudBadge(
                    icon: Icons.bolt_rounded,
                    label: 'x${xpMultiplier.toStringAsFixed(xpMultiplier % 1 == 0 ? 0 : 1)} XP',
                    accent: B307SkyLuxury.gold,
                  ),
              ],
            ),
          ]),
        ),
        const SizedBox(width: 6),
        score(theyLabel, theyScore, CrossAxisAlignment.end),
      ]),
    );
  }
}

class _B307HudBadge extends StatelessWidget {
  const _B307HudBadge({required this.icon, required this.label, required this.accent});
  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: accent.withValues(alpha: .48)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(icon, size: 9, color: accent),
          const SizedBox(width: 2),
          Text(label, style: TextStyle(color: accent, fontSize: 7.5, fontWeight: FontWeight.w900)),
        ]),
      );
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
            B307PageHero(
              icon: Icons.local_mall_rounded,
              title: ar ? 'عروض ورقنا الخاصة' : 'Warqnaa special offers',
              subtitle: ar
                  ? 'حزم واضحة وتسعير مباشر وشراء موثّق، مع إبقاء بيانات الدفع لدى مزود الخدمة.'
                  : 'Clear bundles, transparent pricing and verified checkout while payment data stays with the provider.',
              trailing: const Icon(Icons.verified_user_rounded, color: B307SkyLuxury.emerald, size: 25),
            ),
            const SizedBox(height: 8),
            B307CommerceTrustStrip(catalog: catalog, localeCode: widget.controller.localeCode),
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

class B307CommerceTrustStrip extends StatelessWidget {
  const B307CommerceTrustStrip({super.key, required this.catalog, required this.localeCode});
  final Map<String, dynamic> catalog;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final ar = localeCode == 'ar';
    final sandbox = catalog['sandbox'] == true;
    final productionReady = catalog['production_ready'] == true;
    final providersRaw = catalog['providers'];
    final providers = providersRaw is Map ? Map<String, dynamic>.from(providersRaw) : <String, dynamic>{};
    final verifiedProviders = providers.values.where((value) => value is Map && value['verification_ready'] == true).length;
    final statusLabel = productionReady
        ? (ar ? 'الشراء الموثّق جاهز' : 'Verified checkout ready')
        : sandbox
            ? (ar ? 'وضع تجريبي آمن' : 'Safe sandbox mode')
            : (ar ? 'الشراء محمي والتحقق قيد الإعداد' : 'Protected checkout; verification setup pending');
    final detail = ar
        ? '$verifiedProviders مزود/مزودي دفع جاهزين للتحقق • لا يتم تخزين بيانات البطاقة الخام'
        : '$verifiedProviders verified payment provider(s) ready • raw card details are not stored';
    return Semantics(
      label: '$statusLabel. $detail',
      child: Container(
        key: const ValueKey('r29-commerce-trust-strip'),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          gradient: B307SkyLuxury.panelGradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: (productionReady ? B307SkyLuxury.emerald : B307SkyLuxury.cyan).withValues(alpha: .38)),
        ),
        child: Row(children: <Widget>[
          Icon(productionReady ? Icons.verified_rounded : Icons.shield_outlined, color: productionReady ? B307SkyLuxury.emerald : B307SkyLuxury.cyan, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(statusLabel, style: const TextStyle(color: B307SkyLuxury.text, fontSize: 10.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: B307SkyLuxury.textMuted, fontSize: 8.5, height: 1.3, fontWeight: FontWeight.w700)),
          ])),
          if (sandbox) const Padding(padding: EdgeInsetsDirectional.only(start: 6), child: Icon(Icons.science_outlined, color: B307SkyLuxury.goldSoft, size: 18)),
        ]),
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
