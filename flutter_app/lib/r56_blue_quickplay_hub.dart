part of 'main.dart';

/// Original Warqnaa blue quick-play hub. All actions reuse existing navigation.
class WarqnaaBlueQuickPlayHub extends StatelessWidget {
  const WarqnaaBlueQuickPlayHub({super.key, required this.controller, required this.onTab});
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = Colors.white;
    return Semantics(
      container: true,
      label: ar ? 'بوابة اللعب السريع' : 'Quick play hub',
      child: Container(
        key: const ValueKey('warqnaa-blue-quickplay-hub'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF041B42), Color(0xFF074A9A), Color(0xFF0B3573)]
                : const [Color(0xFF0659BA), Color(0xFF087ED2), Color(0xFF064589)],
          ),
          border: Border.all(color: const Color(0x8C8CEAFF), width: 1.3),
          boxShadow: const [BoxShadow(color: Color(0x33001A50), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const Icon(Icons.style_rounded, color: Color(0xFFFFD46C), size: 30),
              const SizedBox(width: 9),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ar ? 'عالم ورقنا الأزرق' : 'Warqnaa Blue World',
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                Text(ar ? 'اختَر وجهتك وابدأ من مكان واحد' : 'Your games and destinations in one place',
                    style: const TextStyle(color: Color(0xFFCBF2FF), fontSize: 12, fontWeight: FontWeight.w600)),
              ])),
            ]),
            const SizedBox(height: 12),
            Container(
              key: const ValueKey('warqnaa-blue-table-preview'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF032B61),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF77CFFF), width: 1),
              ),
              child: Row(children: [
                const _WarqnaaBlueSuit(symbol: '♠', color: Color(0xFFFFFFFF)),
                const _WarqnaaBlueSuit(symbol: '♥', color: Color(0xFFFF8C98)),
                const _WarqnaaBlueSuit(symbol: '♣', color: Color(0xFFFFFFFF)),
                const _WarqnaaBlueSuit(symbol: '♦', color: Color(0xFFFF8C98)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  ar ? 'طاولتك بانتظارك' : 'Your table awaits',
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  style: const TextStyle(color: Color(0xFFE6F8FF), fontSize: 12, fontWeight: FontWeight.w800),
                )),
              ]),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, bounds) {
              final compact = bounds.maxWidth < 350;
              final width = compact ? (bounds.maxWidth - 9) / 2 : (bounds.maxWidth - 18) / 3;
              final destinations = <_WarqnaaBlueDestination>[
                _WarqnaaBlueDestination(Icons.sports_esports_rounded, ar ? 'الألعاب' : 'Games',
                    ar ? 'ابدأ اللعب' : 'Start playing', () => onTab(1)),
                _WarqnaaBlueDestination(Icons.meeting_room_rounded, ar ? 'الغرف' : 'Rooms',
                    ar ? 'العب مع الأصدقاء' : 'Play with friends', () => onTab(1)),
                _WarqnaaBlueDestination(Icons.emoji_events_rounded, ar ? 'التحديات' : 'Challenges',
                    ar ? 'استكشف المنافسات' : 'Explore competitions', () => onTab(2)),
                _WarqnaaBlueDestination(Icons.storefront_rounded, ar ? 'المتجر' : 'Store',
                    ar ? 'المقتنيات' : 'Collectibles', () => onTab(0)),
                _WarqnaaBlueDestination(Icons.groups_rounded, ar ? 'الأندية' : 'Clubs',
                    ar ? 'مجتمع اللاعبين' : 'Player community',
                    () => Navigator.push(context, MaterialPageRoute<void>(
                      builder: (_) => ClubsPage(controller: controller)))),
                _WarqnaaBlueDestination(Icons.account_circle_rounded, ar ? 'ملفي' : 'Profile',
                    ar ? 'تخصيص الحساب' : 'Customize account', () => showProfile(context, controller)),
              ];
              return Wrap(spacing: 9, runSpacing: 9, children: destinations.map((destination) {
                return SizedBox(width: width, child: Material(
                  color: const Color(0xD107396F),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: destination.onTap,
                    child: Semantics(
                      button: true,
                      label: '${destination.title}. ${destination.subtitle}',
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 104),
                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(destination.icon, size: 29, color: const Color(0xFFFFD46C)),
                            const SizedBox(height: 5),
                            Text(destination.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center, style: TextStyle(color: foreground, fontWeight: FontWeight.w800, fontSize: 13)),
                            Text(destination.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFCCECFF), fontSize: 10)),
                          ])),
                      ),
                    ),
                  ),
                ));
              }).toList());
            }),
          ]),
        ),
      ),
    );
  }
}

class _WarqnaaBlueDestination {
  const _WarqnaaBlueDestination(this.icon, this.title, this.subtitle, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _WarqnaaBlueSuit extends StatelessWidget {
  const _WarqnaaBlueSuit({required this.symbol, required this.color});
  final String symbol;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 5),
      child: ExcludeSemantics(
        child: Container(
          width: 30,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF125BA0),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: const Color(0xFF91DFFF)),
          ),
          child: Text(symbol, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}
