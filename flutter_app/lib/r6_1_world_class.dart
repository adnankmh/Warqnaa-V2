part of 'main.dart';

/// R6.1 is the additive Home + Profile + Social + Navigation release.
/// It intentionally keeps the V305 official starter set while opening the
/// curated V173 image collection and a paired card back for every table.
const String warqnaaR61Release = '1.4.0+610-home-profile-social-navigation';
const bool warqnaaR61MultiTableStore = true;

bool isR61CuratedTable(StoreProduct product) =>
    product.category == 'tables' &&
    (product.id == v305PremiumTableId ||
        (product.id.startsWith('table_v173_') &&
            product.imageAsset?.isNotEmpty == true));

bool isR61CuratedCardBack(StoreProduct product) =>
    product.category == 'cards' &&
    (product.id == v305CardBackId ||
        product.id.startsWith('r61_cardback_table_v173_') ||
        product.collection == 'v021_table_cardbacks');

bool isR61SelectableTableId(String id) => products.any(
      (product) => product.id == id && isR61CuratedTable(product),
    );

bool isR61SelectableCardBackId(String id) => products.any(
      (product) => product.id == id && isR61CuratedCardBack(product),
    );

List<StoreProduct> buildR61PairedCardBacks(
  Iterable<StoreProduct> tableProducts,
) =>
    tableProducts
        .where(isR61CuratedTable)
        .where((table) => table.id != v305PremiumTableId)
        .map(
          (table) => StoreProduct(
            id: 'r61_cardback_${table.id}',
            category: 'cards',
            icon: '🂠',
            nameAr: 'ظهر ${table.nameAr.replaceFirst('طاولة ', '')}',
            nameEn: '${table.nameEn.replaceFirst(' Table', '')} Card Back',
            descriptionAr:
                'ظهر ورق مطابق بصريًا للطاولة، قابل للشراء والتفعيل من المقتنيات.',
            descriptionEn:
                'A matching table-inspired card back, ready to buy and activate from inventory.',
            price: (table.price * .65).round().clamp(6000, 90000).toInt(),
            previewColor1: table.previewColor1,
            previewColor2: table.previewColor2,
            imageAsset: table.imageAsset,
            collection: 'r61_paired_cardbacks',
          ),
        )
        .toList(growable: false);

void openR61Inventory(BuildContext context, AppController controller) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(
            controller.localeCode == 'ar' ? 'المتجر والمقتنيات' : 'Store & inventory',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: StorePage(controller: controller),
      ),
    ),
  );
}

class R61TopBar extends StatelessWidget {
  const R61TopBar({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xff18231e), Color(0xff171717)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffd8ad3f).withValues(alpha: .18)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 9)),
        ],
      ),
      child: Row(children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(60),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => R61ProfilePage(controller: controller),
            ),
          ),
          child: AccountAvatar(controller: controller, size: 46),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(children: <Widget>[
                Flexible(
                  child: Text(
                    controller.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
                if (controller.isAdmin) ...<Widget>[
                  const SizedBox(width: 5),
                  const Icon(Icons.verified_rounded, color: Color(0xffffcf58), size: 16),
                ],
              ]),
              const SizedBox(height: 3),
              Row(children: <Widget>[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.serverConnected
                        ? const Color(0xff55e68a)
                        : const Color(0xffffb85c),
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    controller.serverConnected
                        ? (ar ? 'متصل وآمن' : 'Online & secure')
                        : (ar ? 'الوضع المحلي' : 'Local mode'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w800),
                  ),
                ),
              ]),
            ],
          ),
        ),
        _R61HeaderCounter(icon: Icons.monetization_on_rounded, value: formatNumber(controller.coins)),
        const SizedBox(width: 6),
        Badge(
          isLabelVisible: controller.incomingRequests.isNotEmpty,
          label: Text('${controller.incomingRequests.length}'),
          child: IconButton(
            tooltip: ar ? 'المجتمع' : 'Social',
            visualDensity: VisualDensity.compact,
            onPressed: () => showFriends(context, controller),
            icon: const Icon(Icons.forum_outlined),
          ),
        ),
        Badge(
          isLabelVisible: controller.notices.isNotEmpty,
          label: Text('${controller.notices.length}'),
          child: IconButton(
            tooltip: ar ? 'الإشعارات' : 'Notifications',
            visualDensity: VisualDensity.compact,
            onPressed: () => showNotifications(context, controller),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ),
      ]),
    );
  }
}

class _R61HeaderCounter extends StatelessWidget {
  const _R61HeaderCounter({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 70),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(icon, size: 15, color: const Color(0xffffcf58)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
            ),
          ),
        ]),
      );
}

class R61BottomNavigation extends StatelessWidget {
  const R61BottomNavigation({
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
    final items = <(IconData, IconData, String)>[
      (Icons.storefront_outlined, Icons.storefront_rounded, ar ? 'المتجر' : 'Store'),
      (Icons.style_outlined, Icons.style_rounded, ar ? 'الألعاب' : 'Games'),
      (Icons.home_outlined, Icons.home_rounded, ar ? 'الرئيسية' : 'Home'),
      (Icons.groups_outlined, Icons.groups_rounded, ar ? 'المجتمع' : 'Social'),
      (Icons.emoji_events_outlined, Icons.emoji_events_rounded, ar ? 'المنافسات' : 'Events'),
    ];
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xff161916),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x69000000), blurRadius: 24, offset: Offset(0, -4)),
          ],
        ),
        child: Row(
          children: List<Widget>.generate(items.length, (index) {
            final selected = index == selectedIndex;
            final icon = Icon(selected ? items[index].$2 : items[index].$1, size: 22);
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: selected
                        ? const LinearGradient(colors: <Color>[Color(0xff39563f), Color(0xff2a302b)])
                        : null,
                    border: selected
                        ? Border.all(color: const Color(0xffd8ad3f).withValues(alpha: .27))
                        : null,
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    index == 3
                        ? Badge(
                            isLabelVisible: controller.incomingRequests.isNotEmpty,
                            label: Text('${controller.incomingRequests.length}'),
                            child: icon,
                          )
                        : icon,
                    const SizedBox(height: 3),
                    Text(
                      items[index].$3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                        color: selected ? const Color(0xffffd66b) : Colors.white60,
                      ),
                    ),
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

class R61DesktopNavigation extends StatelessWidget {
  const R61DesktopNavigation({
    super.key,
    required this.controller,
    required this.selectedIndex,
    required this.onSelected,
  });
  final AppController controller;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xff17221c), Color(0xff101210)],
          ),
        ),
        child: DesktopShellNavigationV183(
          controller: controller,
          selectedIndex: selectedIndex,
          onSelected: onSelected,
        ),
      );
}

class R61HomeDashboard extends StatelessWidget {
  const R61HomeDashboard({
    super.key,
    required this.controller,
    required this.onTab,
  });
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final games = controller.homeGameIds
        .map((id) => gamesCatalog.where((game) => game.id == id).firstOrNull)
        .whereType<GameInfo>()
        .toList(growable: false);
    final featured = games.isEmpty ? customerGamesR101.take(6).toList() : games;
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1180 ? 4 : constraints.maxWidth >= 720 ? 3 : 2;
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xff111713), Color(0xff101010)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
          children: <Widget>[
            _R61Hero(controller: controller, onPlay: () => onTab(1)),
            const SizedBox(height: 12),
            Row(children: <Widget>[
              Expanded(child: _R61Metric(icon: Icons.military_tech_rounded, label: ar ? 'المستوى' : 'Level', value: '${controller.level}')),
              const SizedBox(width: 8),
              Expanded(child: _R61Metric(icon: Icons.emoji_events_rounded, label: ar ? 'الانتصارات' : 'Wins', value: '${controller.wins}')),
              const SizedBox(width: 8),
              Expanded(child: _R61Metric(icon: Icons.workspace_premium_rounded, label: ar ? 'أيام الباشا' : 'Pasha days', value: '${controller.vipDays}')),
            ]),
            const SizedBox(height: 16),
            B307SectionHeader(
              title: ar ? 'ألعابك المفضلة' : 'Your games',
              action: ar ? 'كل الألعاب' : 'All games',
              onTap: () => onTab(1),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: featured.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: 1.22,
              ),
              itemBuilder: (context, index) {
                final game = featured[index];
                return _R61GameTile(
                  game: game,
                  locale: controller.localeCode,
                  onTap: () => showGameLobby(context, controller, game),
                );
              },
            ),
            const SizedBox(height: 16),
            _R61SocialStrip(controller: controller, onOpen: () => onTab(3)),
            const SizedBox(height: 12),
            Wrap(spacing: 9, runSpacing: 9, children: <Widget>[
              B307QuickAction(icon: Icons.storefront_outlined, label: ar ? 'المتجر' : 'Store', onTap: () => onTab(0)),
              B307QuickAction(icon: Icons.inventory_2_outlined, label: ar ? 'مقتنياتي' : 'Inventory', onTap: () => openR61Inventory(context, controller)),
              B307QuickAction(icon: Icons.account_balance_wallet_outlined, label: ar ? 'المحفظة' : 'Wallet', onTap: () => showWallet(context, controller)),
              B307QuickAction(icon: Icons.person_outline_rounded, label: ar ? 'ملفي' : 'Profile', onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R61ProfilePage(controller: controller)))),
            ]),
          ],
        ),
      );
    });
  }
}

class _R61Hero extends StatelessWidget {
  const _R61Hero({required this.controller, required this.onPlay});
  final AppController controller;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xff1d5136), Color(0xff4b2637), Color(0xff171717)],
        ),
        border: Border.all(color: const Color(0xffffd166).withValues(alpha: .24)),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x55000000), blurRadius: 26, offset: Offset(0, 10))],
      ),
      child: Row(children: <Widget>[
        Container(
          width: 82,
          height: 82,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .22),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Text('🂡', style: TextStyle(fontSize: 48)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(
              ar ? 'مجلسك. لعبتك. مجتمعك.' : 'Your table. Your game. Your community.',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, height: 1.15),
            ),
            const SizedBox(height: 6),
            Text(
              ar
                  ? 'ابدأ مباراة، تابع أصدقاءك، وفعّل طاولتك وظهر ورقك من تجربة واحدة.'
                  : 'Start a match, follow friends, and activate your table and card back in one experience.',
              style: const TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.5),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(ar ? 'العب الآن' : 'Play now'),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _R61Metric extends StatelessWidget {
  const _R61Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xff1b201c),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Column(children: <Widget>[
          Icon(icon, color: const Color(0xffffce61), size: 21),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, color: Colors.white54, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _R61GameTile extends StatelessWidget {
  const _R61GameTile({required this.game, required this.locale, required this.onTap});
  final GameInfo game;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            gradient: LinearGradient(colors: <Color>[game.color.withValues(alpha: .78), const Color(0xff1b1b1b)]),
            border: Border.all(color: Colors.white.withValues(alpha: .08)),
          ),
          child: Row(children: <Widget>[
            Text(game.icon, style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 9),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(L.t(locale, game.id), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              const SizedBox(height: 4),
              Text('${formatNumber(BigInt.from(game.players))} LIVE', style: const TextStyle(fontSize: 8, color: Colors.white60, fontWeight: FontWeight.w800)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white54),
          ]),
        ),
      );
}

class _R61SocialStrip extends StatelessWidget {
  const _R61SocialStrip({required this.controller, required this.onOpen});
  final AppController controller;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final online = controller.friends.where((friend) => friend.online).length;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(21),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xff1d1d1d),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xff55e68a).withValues(alpha: .18)),
        ),
        child: Row(children: <Widget>[
          const Icon(Icons.groups_2_rounded, color: Color(0xff55e68a), size: 32),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(ar ? 'المجتمع الحي' : 'Live community', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            Text(
              ar ? '$online أصدقاء متصلون • ${controller.incomingRequests.length} طلبات جديدة' : '$online friends online • ${controller.incomingRequests.length} new requests',
              style: const TextStyle(color: Colors.white60, fontSize: 9.5),
            ),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Colors.white54),
        ]),
      ),
    );
  }
}

class R61SocialHubPage extends StatelessWidget {
  const R61SocialHubPage({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final online = controller.friends.where((friend) => friend.online).toList(growable: false);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 30),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: <Color>[Color(0xff173c2b), Color(0xff252025)]),
            border: Border.all(color: const Color(0xff55e68a).withValues(alpha: .18)),
          ),
          child: Row(children: <Widget>[
            const Icon(Icons.public_rounded, size: 44, color: Color(0xffffcf65)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(ar ? 'مجتمع ورقنا' : 'Warqnaa Social', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(ar ? 'أصدقاء ورسائل وأندية وعالم حي من مركز واحد.' : 'Friends, messages, clubs and a live world from one hub.', style: const TextStyle(color: Colors.white60, height: 1.45, fontSize: 10)),
            ])),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: <Widget>[
          Expanded(child: _R61SocialPortal(icon: Icons.people_alt_rounded, title: ar ? 'الأصدقاء' : 'Friends', value: '${controller.friends.length}', onTap: () => showFriends(context, controller))),
          const SizedBox(width: 8),
          Expanded(
            child: _R61SocialPortal(
              icon: Icons.public_rounded,
              title: ar ? 'العالم' : 'World',
              value: 'LIVE',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text(ar ? 'العالم الاجتماعي' : 'Social World')),
                    body: R11SocialWorldPage(controller: controller),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _R61SocialPortal(
              icon: Icons.shield_rounded,
              title: ar ? 'الأندية' : 'Clubs',
              value: controller.activeClub == null ? '—' : '1',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text(ar ? 'الأندية' : 'Clubs')),
                    body: R11ClubsWorldPage(controller: controller),
                  ),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        SectionTitle(title: ar ? 'متصلون الآن' : 'Online now', action: ar ? 'إدارة الأصدقاء' : 'Manage', onTap: () => showFriends(context, controller)),
        const SizedBox(height: 8),
        if (online.isEmpty)
          const PremiumPanel(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('لا يوجد أصدقاء متصلون الآن.'))))
        else
          ...online.take(6).map((friend) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PremiumListTile(
                  icon: friend.avatar?.isNotEmpty == true ? friend.avatar! : friend.name.substring(0, 1),
                  title: friend.name,
                  subtitle: '@${friend.username} • ${friend.activity}',
                  action: IconButton(
                    tooltip: ar ? 'رسالة' : 'Message',
                    onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => PrivateChatPage(controller: controller, friend: friend))),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  onTap: () => showPublicPlayerProfileV170(context, controller, friend),
                ),
              )),
      ],
    );
  }
}

class _R61SocialPortal extends StatelessWidget {
  const _R61SocialPortal({required this.icon, required this.title, required this.value, required this.onTap});
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xff1d211e),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.white.withValues(alpha: .06)),
          ),
          child: Column(children: <Widget>[
            Icon(icon, color: const Color(0xffffcf65)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, color: Colors.white60)),
          ]),
        ),
      );
}

class R61ProfilePage extends StatelessWidget {
  const R61ProfilePage({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: Text(ar ? 'الملف الشخصي' : 'Profile', style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: <Widget>[
          IconButton(onPressed: () => showSettings(context, controller), icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 30),
        children: <Widget>[
          ProfileCover(
            coverId: controller.selectedCover,
            height: 245,
            colors: b304ProfileGradient(controller),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                  InkWell(
                    onTap: () => showAvatarPicker(context, controller),
                    borderRadius: BorderRadius.circular(80),
                    child: AccountAvatar(controller: controller, size: 112),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Row(children: <Widget>[
                      Flexible(child: Text(controller.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: colorFromHex(controller.selectedNameColor)))),
                      if (controller.isAdmin) const Padding(padding: EdgeInsetsDirectional.only(start: 6), child: Icon(Icons.verified_rounded, color: Color(0xffffcf58), size: 20)),
                    ]),
                    Text('@${controller.username} • ${controller.countryFlag} ${controller.countryName}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 7),
                    R5RuntimeBadge(controller: controller),
                  ])),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: <Widget>[
            Expanded(child: ProfileMetric(value: '${controller.level}', label: ar ? 'المستوى' : 'Level')),
            const SizedBox(width: 8),
            Expanded(child: ProfileMetric(value: '${controller.winRate.toStringAsFixed(1)}%', label: ar ? 'الفوز' : 'Win rate')),
            const SizedBox(width: 8),
            Expanded(child: ProfileMetric(value: '${controller.gamesPlayed}', label: ar ? 'المباريات' : 'Matches')),
          ]),
          const SizedBox(height: 12),
          PremiumPanel(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Row(children: <Widget>[
                  const Icon(Icons.auto_graph_rounded, color: Color(0xffffcf58)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ar ? 'تقدم اللاعب' : 'Player progress', style: const TextStyle(fontWeight: FontWeight.w900))),
                  Text('${controller.xp}/${controller.xpNext} XP', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                ]),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: controller.levelProgress, minHeight: 9, borderRadius: BorderRadius.circular(20)),
                const SizedBox(height: 11),
                Wrap(spacing: 7, runSpacing: 7, children: <Widget>[
                  Chip(label: Text('🎯 ${controller.roundPoints}')),
                  Chip(label: Text('🏆 ${controller.tournamentPoints}')),
                  Chip(label: Text('🛡️ ${controller.clubPoints}')),
                  Chip(label: Text('👑 ${controller.vipDays}')),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          PremiumPanel(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(ar ? 'التخصيص النشط' : 'Active customization', style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 9),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.table_restaurant_outlined, color: Color(0xffffcf58)),
                  title: Text(storeProductById(controller.selectedTable)?.name(controller.localeCode) ?? 'Warqnaa'),
                  subtitle: Text(ar ? 'الطاولة المفعلة' : 'Active table'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.style_outlined, color: Color(0xff55e68a)),
                  title: Text(storeProductById(controller.selectedCardBack)?.name(controller.localeCode) ?? 'Warqnaa'),
                  subtitle: Text(ar ? 'ظهر الورق المفعّل' : 'Active card back'),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
            FilledButton.tonalIcon(onPressed: () => openR61Inventory(context, controller), icon: const Icon(Icons.inventory_2_outlined), label: Text(ar ? 'المقتنيات' : 'Inventory')),
            FilledButton.tonalIcon(onPressed: () => showWallet(context, controller), icon: const Icon(Icons.account_balance_wallet_outlined), label: Text(ar ? 'المحفظة' : 'Wallet')),
            FilledButton.tonalIcon(onPressed: () => showFriends(context, controller), icon: const Icon(Icons.people_outline), label: Text(ar ? 'الأصدقاء' : 'Friends')),
            FilledButton.tonalIcon(onPressed: () => showProfile(context, controller), icon: const Icon(Icons.edit_outlined), label: Text(ar ? 'تفاصيل وتعديل' : 'Details & edit')),
          ]),
          if (controller.isAdmin) ...<Widget>[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => AdminDashboardPage(controller: controller))),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: Text(ar ? 'فتح لوحة الإدارة' : 'Open administration'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ],
      ),
    );
  }
}
