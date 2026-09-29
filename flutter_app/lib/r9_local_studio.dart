part of 'main.dart';

/// A local workspace is deliberately separate from server administration.
class R9SessionBanner extends StatelessWidget {
  const R9SessionBanner({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final localAdmin = controller.isLocalAdmin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xff132c25), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xff385344))),
      child: Row(children: [
        Icon(localAdmin ? Icons.admin_panel_settings_outlined : controller.serverConnected ? Icons.wifi_rounded : Icons.offline_bolt_outlined, color: const Color(0xffefce7b), size: 21),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(localAdmin ? (ar ? 'Adnan • مدير هذا الجهاز' : 'Adnan • device administrator') : controller.serverConnected ? (ar ? 'متصل بالإنترنت' : 'Connected online') : (ar ? 'اللعب دون إنترنت' : 'Offline play'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          Text(localAdmin ? (ar ? 'ألعابك وتصميمك محفوظة هنا' : 'Your games and design are saved here') : controller.serverConnected ? (ar ? 'الغرف والأصدقاء متاحون' : 'Rooms and friends are available') : (ar ? 'تدريب مع الكمبيوتر على هذا الجهاز' : 'Practice with the computer on this device'), style: const TextStyle(fontSize: 10, color: Color(0xffb2c7ba))),
        ])),
        if (localAdmin) TextButton(key: const ValueKey('r9-open-studio'), onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => R9LocalStudio(controller: controller))), child: Text(ar ? 'الإدارة' : 'Studio')),
      ]),
    );
  }
}

class R9GameLibrary extends StatefulWidget {
  const R9GameLibrary({super.key, required this.controller, required this.games, required this.onAllGames});
  final AppController controller;
  final List<GameInfo> games;
  final VoidCallback onAllGames;
  @override
  State<R9GameLibrary> createState() => _R9GameLibraryState();
}

class _R9GameLibraryState extends State<R9GameLibrary> {
  final search = TextEditingController();
  String category = 'all';
  @override
  void dispose() { search.dispose(); super.dispose(); }

  bool matches(GameInfo game) {
    final query = search.text.trim().toLowerCase();
    final text = '${L.t('ar', game.id)} ${L.t('en', game.id)} ${game.id}'.toLowerCase();
    final inCategory = switch (category) {
      'favorites' => widget.controller.homeGameIds.contains(game.id),
      'tarneeb' => game.id.contains('tarneeb'),
      'trix' => game.id.contains('trix'),
      'hand' => game.id.contains('hand') || game.id == 'banakil',
      _ => true,
    };
    return inCategory && (query.isEmpty || text.contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.controller.localeCode == 'ar';
    final visible = widget.games.where(matches).toList();
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 600 ? 3 : 2;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(ar ? 'صالة الألعاب' : 'The game lounge', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
          IconButton(tooltip: ar ? 'تخصيص المفضلة' : 'Edit favorites', onPressed: () => showHomeGamesSelector(context, widget.controller), icon: const Icon(Icons.tune_rounded, size: 20)),
          TextButton(onPressed: widget.onAllGames, child: Text(ar ? 'المزيد' : 'More')),
        ]),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('r9-game-search'), controller: search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: ar ? 'ابحث عن لعبتك…' : 'Find your game…', prefixIcon: const Icon(Icons.search_rounded), isDense: true,
            suffixIcon: search.text.isEmpty ? null : IconButton(tooltip: ar ? 'مسح البحث' : 'Clear search', onPressed: () => setState(search.clear), icon: const Icon(Icons.close_rounded))),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          for (final item in <(String, String)>[('all', ar ? 'الكل' : 'All'), ('favorites', ar ? 'المفضلة' : 'Favorites'), ('tarneeb', ar ? 'طرنيب' : 'Tarneeb'), ('trix', ar ? 'تركس' : 'Trix'), ('hand', ar ? 'هاند وبناكل' : 'Hand & Banakil')])
            Padding(padding: const EdgeInsetsDirectional.only(end: 7), child: ChoiceChip(key: ValueKey('r9-filter-${item.$1}'), label: Text(item.$2), selected: category == item.$1, onSelected: (_) => setState(() => category = item.$1))),
        ])),
        const SizedBox(height: 12),
        if (visible.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Column(children: [
          const Icon(Icons.search_off_rounded, size: 34, color: Colors.white54),
          const SizedBox(height: 8),
          Text(ar ? 'لا توجد لعبة مطابقة' : 'No matching games'),
          TextButton(onPressed: () => setState(() { search.clear(); category = 'all'; }), child: Text(ar ? 'عرض جميع الألعاب' : 'Show all games')),
        ])) else GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: visible.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: constraints.maxWidth < 360 ? 158 : 174),
          itemBuilder: (context, index) => R8GameTile(key: ValueKey('r9-game-${visible[index].id}'), game: visible[index], locale: widget.controller.localeCode, onTap: () => showGameLobby(context, widget.controller, visible[index])),
        ),
      ]);
    });
  }
}

class R9LocalStudio extends StatelessWidget {
  const R9LocalStudio({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (context, _) {
    final ar = controller.localeCode == 'ar';
    if (!controller.isLocalAdmin) return Scaffold(appBar: AppBar(), body: Center(child: Text(ar ? 'افتح إدارة Adnan المحلية أولًا.' : 'Open the local Adnan workspace first.')));
    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'استوديو Adnan' : 'Adnan studio')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Icon(Icons.workspace_premium_rounded, color: Color(0xffefce7b), size: 54),
        const SizedBox(height: 12),
        Text(ar ? 'مساحتك. على ذوقك.' : 'Your space. Your style.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(ar ? 'إدارة محلية تعمل دون إنترنت. تغييراتك تُحفظ على هذا الجهاز؛ إدارة اللاعبين والخادم تحتاج حساب الإدارة المتصل.' : 'Works offline and saves on this device. Player and server administration require your online administrator account.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, height: 1.6)),
        const SizedBox(height: 24),
        ListTile(leading: const Icon(Icons.palette_outlined), title: Text(ar ? 'المظهر والألوان' : 'Appearance & colors'), subtitle: Text(ar ? 'الأزرار، الحواف، الخط ومؤثرات الطاولة' : 'Buttons, corners, text and table effects'), onTap: () => showNoCodeDesignerSheet(context, controller)),
        ListTile(leading: const Icon(Icons.favorite_border_rounded), title: Text(ar ? 'ألعابك المفضلة' : 'Favorite games'), subtitle: Text(ar ? 'اختر الألعاب التي تبدأ بها صالتك' : 'Choose the games at the top of your lounge'), onTap: () => showHomeGamesSelector(context, controller)),
        for (final item in <(String, IconData, String)>[('table', Icons.table_restaurant_rounded, ar ? 'صورة الطاولة' : 'Table image'), ('cards', Icons.style_rounded, ar ? 'ظهر الأوراق' : 'Card back')])
          ListTile(leading: Icon(item.$2), title: Text(item.$3), trailing: const Icon(Icons.add_photo_alternate_outlined), onTap: () async {
            final error = await controller.uploadDesignerImage(item.$1);
            if (context.mounted && error != null) showToast(context, error);
          }),
        if (controller.customTableBackgroundData != null || controller.customCardBackData != null) TextButton.icon(onPressed: () { controller.clearDesignerImage('table'); controller.clearDesignerImage('cards'); }, icon: const Icon(Icons.restore_rounded), label: Text(ar ? 'استعادة صور الطاولة والأوراق' : 'Restore table and card images')),
        SwitchListTile(value: controller.soundEnabled, onChanged: controller.toggleSound, secondary: const Icon(Icons.volume_up_outlined), title: Text(ar ? 'أصوات اللعبة' : 'Game sounds')),
        SwitchListTile(key: const ValueKey('r9-studio-effects'), value: controller.tableAmbientEffects, onChanged: (value) => controller.updateNoCodeDesign(ambientEffects: value), secondary: const Icon(Icons.auto_awesome_outlined), title: Text(ar ? 'مؤثرات الطاولة' : 'Table effects')),
        const SizedBox(height: 20),
        FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.play_arrow_rounded), label: Text(ar ? 'العودة إلى اللعب' : 'Back to play'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48))),
      ]),
    );
  });
}
