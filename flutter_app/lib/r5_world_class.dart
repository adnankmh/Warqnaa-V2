part of 'main.dart';

const String warqnaaR5Integration = 'R5-world-class-integration';

class R5TopBar extends StatelessWidget {
  const R5TopBar({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        B307TopBar(controller: controller),
        if (controller.isAdmin)
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: controller.isPrimaryAdmin
                  ? const Color(0xff4d3210)
                  : const Color(0xff243444),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: controller.isPrimaryAdmin
                    ? const Color(0xffd8ad3f).withValues(alpha: .45)
                    : Colors.white.withValues(alpha: .09),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  controller.isPrimaryAdmin
                      ? Icons.admin_panel_settings_rounded
                      : Icons.verified_user_outlined,
                  size: 15,
                  color: controller.isPrimaryAdmin
                      ? const Color(0xffffd76a)
                      : Colors.white70,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    controller.isPrimaryAdmin
                        ? (ar ? 'مدير النظام الرئيسي' : 'Primary Administrator')
                        : (ar ? 'إدارة النظام' : 'Administrator'),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  'LV ${controller.level}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xffffd76a),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class R5BottomNavigation extends StatelessWidget {
  const R5BottomNavigation({
    super.key,
    required this.controller,
    required this.selectedIndex,
    required this.onSelected,
  });

  final AppController controller;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => B307BottomNavigation(
        controller: controller,
        selectedIndex: selectedIndex,
        onSelected: onSelected,
      );
}

class R5HomeDashboard extends StatelessWidget {
  const R5HomeDashboard({
    super.key,
    required this.controller,
    required this.onTab,
  });

  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xff121212),
            Color(0xff171512),
            Color(0xff101010),
          ],
        ),
      ),
      child: B307HomeDashboard(controller: controller, onTab: onTab),
    );
  }
}

class R5RuntimeBadge extends StatelessWidget {
  const R5RuntimeBadge({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final healthy = controller.serverConnected && controller.isAuthenticated;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: healthy ? const Color(0xff173823) : const Color(0xff4a2d16),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            healthy ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            size: 14,
            color: healthy ? const Color(0xff62d68a) : const Color(0xffffba6d),
          ),
          const SizedBox(width: 5),
          Text(
            healthy
                ? (ar ? 'متصل بالخادم' : 'Server connected')
                : (ar ? 'غير متصل بالخادم' : 'Server offline'),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
