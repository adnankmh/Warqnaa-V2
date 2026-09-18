part of 'main.dart';

/// B307 visual system: an original Warqnaa dark card-room experience inspired
/// by modern MENA social card-game interfaces, without copying third-party
/// branding, assets, or proprietary layouts.
const String warqnaaB307VisualRelease = '1.3.1+307-ui';

class B307TopBar extends StatelessWidget {
  const B307TopBar({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xff171717),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x4d000000), blurRadius: 18, offset: Offset(0, 7))],
      ),
      child: Row(children: <Widget>[
        GestureDetector(
          onTap: () => showProfile(context, controller),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: <Color>[scheme.primary, const Color(0xff8b6914)]),
              border: Border.all(color: const Color(0xffe0b844), width: 2),
            ),
            child: Center(child: Text(controller.avatarEmoji, style: const TextStyle(fontSize: 22))),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(controller.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            const SizedBox(height: 2),
            Row(children: <Widget>[
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: controller.serverConnected ? const Color(0xff39c86b) : const Color(0xfff2a93b))),
              const SizedBox(width: 4),
              Text(
                controller.serverConnected ? (ar ? 'متصل' : 'Online') : (ar ? 'وضع محلي' : 'Local mode'),
                style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: .54), fontWeight: FontWeight.w700),
              ),
            ]),
          ]),
        ),
        B307TopCounter(icon: Icons.workspace_premium_rounded, value: '${controller.vipDays}', accent: const Color(0xffe4b33f)),
        const SizedBox(width: 5),
        B307TopCounter(icon: Icons.monetization_on_rounded, value: formatNumber(controller.coins), accent: const Color(0xffd6a532)),
        const SizedBox(width: 4),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: ar ? 'الأصدقاء' : 'Friends',
          onPressed: () => showFriends(context, controller),
          icon: const Icon(Icons.people_alt_outlined, size: 21),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: ar ? 'الإشعارات' : 'Notifications',
          onPressed: () => showNotifications(context, controller),
          icon: const Icon(Icons.notifications_none_rounded, size: 21),
        ),
      ]),
    );
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
          color: const Color(0xff222222),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: .055)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 4),
          Flexible(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900))),
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
    final items = <(IconData, String)>[
      (Icons.storefront_outlined, ar ? 'المتجر' : 'Store'),
      (Icons.style_outlined, ar ? 'الألعاب' : 'Games'),
      (Icons.home_rounded, ar ? 'الرئيسية' : 'Home'),
      (Icons.groups_2_outlined, ar ? 'الأصدقاء' : 'Social'),
      (Icons.emoji_events_outlined, ar ? 'البطولات' : 'Events'),
    ];
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 7),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xff151515),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withValues(alpha: .07)),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x5a000000), blurRadius: 20, offset: Offset(0, -4))],
        ),
        child: Row(
          children: List<Widget>.generate(items.length, (i) {
            final selected = i == selectedIndex;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: selected ? const Color(0xff2b2b2b) : Colors.transparent,
                    border: selected ? Border.all(color: const Color(0xffd9ad3c).withValues(alpha: .25)) : null,
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Icon(items[i].$1, size: 21, color: selected ? const Color(0xffe2b844) : Colors.white54),
                    const SizedBox(height: 2),
                    Text(items[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8.5, fontWeight: selected ? FontWeight.w900 : FontWeight.w700, color: selected ? Colors.white : Colors.white54)),
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
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: <Color>[Color(0xff7a2949), Color(0xff4f2037), Color(0xff292929)]),
            border: Border.all(color: const Color(0xffe1b444).withValues(alpha: .18)),
          ),
          child: Row(children: <Widget>[
            Container(width: 72, height: 72, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xff111111).withValues(alpha: .32)), child: const Icon(Icons.emoji_events_rounded, size: 38, color: Color(0xffffdb6e))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(ar ? 'تحديات وفعاليات يومية' : 'Daily challenges & events', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 4),
              Text(ar ? 'نافس، اجمع المكافآت، وارتقِ بمستواك من واجهة واحدة.' : 'Compete, collect rewards and progress from one clean hub.', style: const TextStyle(fontSize: 10, height: 1.45, color: Colors.white70)),
              const SizedBox(height: 9),
              FilledButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => R12CompetitiveArenaPage(controller: controller))),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(ar ? 'ابدأ الآن' : 'Play now'),
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
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: .90),
          itemBuilder: (context, index) {
            final game = featured[index];
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => showGameLobby(context, controller, game),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xff202020),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: .06)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text(game.icon, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 6),
                  Text(L.t(controller.localeCode, game.id), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: const Color(0xff2d6d41), borderRadius: BorderRadius.circular(7)), child: Text(ar ? 'العب' : 'Play', style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900))),
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
        decoration: BoxDecoration(color: const Color(0xff1d1d1d), borderRadius: BorderRadius.circular(13), border: Border.all(color: Colors.white.withValues(alpha: .055))),
        child: Column(children: <Widget>[
          Icon(icon, size: 18, color: const Color(0xffdcb13f)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          Text(label, style: const TextStyle(fontSize: 8.5, color: Colors.white54, fontWeight: FontWeight.w700)),
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
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!, style: const TextStyle(fontSize: 9))),
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xff232323), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: .06))),
            child: Column(children: <Widget>[Icon(icon, size: 20, color: const Color(0xffd9ad3c)), const SizedBox(height: 5), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800))]),
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
      borderRadius: BorderRadius.circular(15),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => B307CashShopPage(controller: controller))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: <Color>[Color(0xff5f253c), Color(0xff252525)]),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xffe0b344).withValues(alpha: .17)),
        ),
        child: Row(children: <Widget>[
          const Icon(Icons.shopping_bag_rounded, color: Color(0xffffd967), size: 34),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(ar ? 'متجر العروض بالنقود الحقيقية' : 'Real-money offers', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 3),
            Text(ar ? 'حزم، توكنز، عروض أسبوعية وإتمام شراء آمن عبر مزود الدفع.' : 'Bundles, tokens, weekly offers and secure provider checkout.', style: const TextStyle(fontSize: 9.5, color: Colors.white60)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Colors.white54),
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
                borderRadius: BorderRadius.circular(17),
                gradient: const LinearGradient(colors: <Color>[Color(0xff742943), Color(0xff3a2730), Color(0xff222222)]),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(ar ? 'عروض Warqnaa المميزة' : 'Warqnaa featured offers', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(ar ? 'اختَر الحزمة المناسبة. الدفع النهائي يتم عبر مزود دفع موثوق، ولا يخزن Warqnaa بيانات بطاقتك.' : 'Choose a package. Final payment is handled by a trusted provider; Warqnaa does not store raw card details.', style: const TextStyle(fontSize: 10, height: 1.5, color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 39, child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
              for (final entry in <(String, String)>[
                ('all', ar ? 'الكل' : 'All'),
                ('featured', ar ? 'مميزة' : 'Featured'),
                ('weekly', ar ? 'الأسبوع' : 'Weekly'),
                ('tokens', ar ? 'توكنز' : 'Tokens'),
              ])
                Padding(padding: const EdgeInsetsDirectional.only(end: 6), child: ChoiceChip(label: Text(entry.$2), selected: category == entry.$1, onSelected: (_) => setState(() => category = entry.$1))),
            ])),
            const SizedBox(height: 10),
            if (snapshot.hasError || packages.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xff1f1f1f), borderRadius: BorderRadius.circular(14)),
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
      decoration: BoxDecoration(color: const Color(0xff202020), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .065))),
      child: Column(children: <Widget>[
        Align(alignment: AlignmentDirectional.topEnd, child: badge.isEmpty ? const SizedBox(height: 22) : Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: const Color(0xff6f2a43), borderRadius: BorderRadius.circular(99)), child: Text(badge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900)))),
        const Spacer(),
        Text(data['icon']?.toString() ?? '🪙', style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 7),
        Text('${formatNumber(BigInt.from(tokens))} ${ar ? 'توكنز' : 'tokens'}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text('${data['currency'] ?? 'USD'} $price', style: const TextStyle(color: Color(0xffffd35a), fontWeight: FontWeight.w900)),
        const Spacer(),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () async {
          final uri = Uri.parse('${controller.api.webBaseUrl}/offers?package=${Uri.encodeQueryComponent(data['key']?.toString() ?? '')}');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }, child: Text(ar ? 'شراء' : 'Buy'))),
      ]),
    );
  }
}
