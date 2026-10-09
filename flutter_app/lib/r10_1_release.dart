part of 'main.dart';

const String warqnaaR101Release = '0.5.1+221';
const String warqnaaR19LuxuryCommerce = '1.9.5+714-game-art-stage';

/// R10.1 keeps unfinished server-dependent titles out of the customer lobby.
List<GameInfo> get customerGamesR101 => gamesCatalog.where((game) => !game.serverOnly && !b304BannedCustomerGames.contains(game.id)).toList(growable: false);

class R101ThemeSpec {
  const R101ThemeSpec({required this.code, required this.accent, required this.accent2, required this.background, required this.surface, required this.light});
  final String code;
  final Color accent;
  final Color accent2;
  final Color background;
  final Color surface;
  final bool light;
}

const Map<String, R101ThemeSpec> r101Themes = <String, R101ThemeSpec>{
  'dark': R101ThemeSpec(code:'dark',accent:Color(0xffd8ad3f),accent2:Color(0xff35794b),background:Color(0xff111111),surface:Color(0xff1d1d1d),light:false),
  'light': R101ThemeSpec(code:'light',accent:Color(0xff8b5e34),accent2:Color(0xff0f766e),background:Color(0xfff3eee5),surface:Color(0xfffffbf4),light:true),
  'green': R101ThemeSpec(code:'green',accent:Color(0xff34d399),accent2:Color(0xffd4af37),background:Color(0xff03261c),surface:Color(0xff084936),light:false),
  'gold': R101ThemeSpec(code:'gold',accent:Color(0xfff5c75b),accent2:Color(0xffc08457),background:Color(0xff211709),surface:Color(0xff3a2a12),light:false),
  'purple': R101ThemeSpec(code:'purple',accent:Color(0xffc4a7ff),accent2:Color(0xffff7ab8),background:Color(0xff160f2b),surface:Color(0xff2b2050),light:false),
  'classic': R101ThemeSpec(code:'classic',accent:Color(0xfff3d27a),accent2:Color(0xffb24a4a),background:Color(0xff10221b),surface:Color(0xff19382b),light:false),
  'ocean': R101ThemeSpec(code:'ocean',accent:Color(0xff38bdf8),accent2:Color(0xff22d3ee),background:Color(0xff041b2d),surface:Color(0xff0b2d45),light:false),
  'sky': R101ThemeSpec(code:'sky',accent:Color(0xff0284c7),accent2:Color(0xff0ea5e9),background:Color(0xffe0f2fe),surface:Color(0xfff0f9ff),light:true),
  'forest': R101ThemeSpec(code:'forest',accent:Color(0xff84cc16),accent2:Color(0xff22c55e),background:Color(0xff102a16),surface:Color(0xff183c20),light:false),
  'desert': R101ThemeSpec(code:'desert',accent:Color(0xffd97706),accent2:Color(0xfff59e0b),background:Color(0xff2b1b0f),surface:Color(0xff4a2f18),light:false),
  'rose': R101ThemeSpec(code:'rose',accent:Color(0xfffb7185),accent2:Color(0xfff472b6),background:Color(0xff2c0b17),surface:Color(0xff4c1024),light:false),
  'graphite': R101ThemeSpec(code:'graphite',accent:Color(0xff94a3b8),accent2:Color(0xff64748b),background:Color(0xff0f172a),surface:Color(0xff1e293b),light:false),
  'royal_blue': R101ThemeSpec(code:'royal_blue',accent:Color(0xff60a5fa),accent2:Color(0xff818cf8),background:Color(0xff0a1740),surface:Color(0xff13275a),light:false),
  'emerald_light': R101ThemeSpec(code:'emerald_light',accent:Color(0xff047857),accent2:Color(0xff0d9488),background:Color(0xffecfdf5),surface:Color(0xfff0fdfa),light:true),
  'sunset': R101ThemeSpec(code:'sunset',accent:Color(0xffff8a4c),accent2:Color(0xfff43f5e),background:Color(0xff2a0d14),surface:Color(0xff4b1720),light:false),
  // R19 premium visual collection. These are original Warqnaa palettes and
  // remain purely cosmetic; they never alter gameplay or economy rules.
  'midnight_cyan': R101ThemeSpec(code:'midnight_cyan',accent:Color(0xff25e4df),accent2:Color(0xff2c9cff),background:Color(0xff050d18),surface:Color(0xff0b1e31),light:false),
  'obsidian_gold': R101ThemeSpec(code:'obsidian_gold',accent:Color(0xffffcb62),accent2:Color(0xffd68a28),background:Color(0xff0b0a0c),surface:Color(0xff211b17),light:false),
  'royal_crimson': R101ThemeSpec(code:'royal_crimson',accent:Color(0xffffc857),accent2:Color(0xfff03e68),background:Color(0xff17070e),surface:Color(0xff35101d),light:false),
  'sapphire_pasha': R101ThemeSpec(code:'sapphire_pasha',accent:Color(0xff73c8ff),accent2:Color(0xff8c74ff),background:Color(0xff071129),surface:Color(0xff102a52),light:false),
  'aurora_luxe': R101ThemeSpec(code:'aurora_luxe',accent:Color(0xff63f2d1),accent2:Color(0xffc18cff),background:Color(0xff09151b),surface:Color(0xff17313a),light:false),
};

/// R34: foreground is selected by actual WCAG contrast, not theme labels.
/// Sky-blue buttons receive a deep navy ink; dark cosmetic accents use white.
Color r101ReadableInk(Color background) {
  const navy = Color(0xFF061827);
  final luminosity = background.computeLuminance();
  final darkContrast = (luminosity + .05) / (navy.computeLuminance() + .05);
  final lightContrast = 1.05 / (luminosity + .05);
  // A few medium-blue accents leave both navy and white below WCAG AA.
  // Pure black is the guaranteed accessible fallback for those midtones.
  final blackContrast = (luminosity + .05) / .05;
  if (darkContrast >= 4.5 && darkContrast >= lightContrast) return navy;
  return blackContrast >= lightContrast ? Colors.black : Colors.white;
}

ThemeData r101Theme(String code, String fallbackAccentHex, {String? fontFamily, String localeCode = 'en'}) {
  final fallbackAccent = colorFromHex(fallbackAccentHex);
  final spec = r101Themes[code] ?? R101ThemeSpec(
    code: code,
    accent: fallbackAccent,
    accent2: fallbackAccent,
    background: const Color(0xff07111d),
    surface: const Color(0xff111e2e),
    light: false,
  );
  // R33: cosmetic themes may change accents, but the shared luxury world stays sky-blue.
  // Keep the legacy theme specifications intact for user settings and compatibility.
  final worldBackground = spec.light ? const Color(0xffe0f2fe) : R9Design.skyCanvas;
  final worldSurface = spec.light ? const Color(0xfff0f9ff) : R9Design.skyPanel;
  // Bright sky actions read crisply in Arabic and English, unlike white on cyan.
  final blueAction = spec.code == 'sky' || spec.code == 'ocean' || spec.code == 'royal_blue';
  final actionFill = blueAction ? R9Design.sky : spec.accent;
  final actionInk = r101ReadableInk(actionFill);
  final surfaceInk = r101ReadableInk(worldSurface);
  final base = R9Design.theme(light: spec.light, accent: spec.accent, fontFamily: fontFamily, arabic: localeCode == 'ar');
  final scheme = base.colorScheme.copyWith(
    primary: spec.accent,
    secondary: spec.accent2,
    surface: worldSurface,
    onSurface: surfaceInk,
    onPrimary: actionInk,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: worldBackground,
    canvasColor: worldBackground,
    cardTheme: base.cardTheme.copyWith(color: worldSurface.withValues(alpha: spec.light ? .94 : .88)),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: Color.lerp(worldSurface, worldBackground, .22),
      indicatorColor: actionFill.withValues(alpha: .38),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: states.contains(WidgetState.selected) ? surfaceInk : surfaceInk.withValues(alpha: .72))),
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: states.contains(WidgetState.selected) ? FontWeight.w900 : FontWeight.w700, color: surfaceInk)),
    ),
    appBarTheme: base.appBarTheme.copyWith(foregroundColor: scheme.onSurface),
    dialogTheme: base.dialogTheme.copyWith(backgroundColor: Color.lerp(worldSurface, worldBackground, .08)),
    bottomSheetTheme: base.bottomSheetTheme.copyWith(
      backgroundColor: Color.lerp(worldSurface, worldBackground, .08),
      modalBackgroundColor: Color.lerp(worldSurface, worldBackground, .08),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Color.lerp(worldSurface, worldBackground, spec.light ? .08 : .20),
      labelStyle: TextStyle(fontFamily: fontFamily, color: scheme.onSurface.withValues(alpha: .72), fontWeight: FontWeight.w700),
      prefixIconColor: spec.accent,
      suffixIconColor: scheme.onSurface.withValues(alpha: .66),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: actionFill,
      foregroundColor: actionInk,
      textStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w900, letterSpacing: localeCode == 'ar' ? 0 : .15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      minimumSize: const Size(44, 46),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: scheme.onSurface,
      side: BorderSide(color: r101ReadableInk(worldSurface).withValues(alpha: .48)),
      textStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      minimumSize: const Size(44, 46),
    )),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
      foregroundColor: surfaceInk,
      textStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    )),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: worldSurface,
      selectedColor: spec.accent.withValues(alpha: .22),
      side: BorderSide(color: spec.accent.withValues(alpha: .22)),
      labelStyle: TextStyle(fontFamily: fontFamily, color: scheme.onSurface, fontWeight: FontWeight.w800),
    ),
    listTileTheme: base.listTileTheme.copyWith(
      textColor: scheme.onSurface,
      iconColor: spec.accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      backgroundColor: Color.lerp(worldSurface, worldBackground, .18),
      contentTextStyle: TextStyle(fontFamily: fontFamily, color: scheme.onSurface, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerColor: spec.accent.withValues(alpha: .16),
    pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      TargetPlatform.linux: ZoomPageTransitionsBuilder(),
    }),
  );
}

String r101GameArtAsset(String gameId) => 'assets/optimized/r101/games/$gameId.webp';

class R101CommercialOffer {
  const R101CommercialOffer({required this.key, required this.titleAr, required this.titleEn, required this.subtitleAr, required this.subtitleEn, required this.badge, required this.priceLabel, required this.icon, required this.cadence});
  final String key;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final String badge;
  final String priceLabel;
  final String icon;
  final String cadence;
}

const List<R101CommercialOffer> r101CommercialOffers = <R101CommercialOffer>[
  R101CommercialOffer(key:'daily',titleAr:'عرض اليوم',titleEn:'Daily Drop',subtitleAr:'توكنز + مسرّع قصير + فرصة صندوق',subtitleEn:'Tokens + short booster + box chance',badge:'24H',priceLabel:'US\$0.99',icon:'☀️',cadence:'daily'),
  R101CommercialOffer(key:'weekly',titleAr:'حزمة الأسبوع',titleEn:'Weekly Bundle',subtitleAr:'توكنز أكثر + طاولة مؤقتة + إيموت متحرك',subtitleEn:'More tokens + temporary table + animated emote',badge:'7D',priceLabel:'US\$3.99',icon:'✨',cadence:'weekly'),
  R101CommercialOffer(key:'monthly',titleAr:'حزمة النخبة',titleEn:'Monthly Elite',subtitleAr:'مقتنيات موسمية + تذاكر + مسرّعات',subtitleEn:'Seasonal cosmetics + tickets + boosters',badge:'30D',priceLabel:'US\$9.99',icon:'💎',cadence:'monthly'),
  R101CommercialOffer(key:'annual',titleAr:'عام ورقنا',titleEn:'Warqnaa Year',subtitleAr:'هوية سنوية حصرية ومكافآت شهرية بدون أفضلية لعب',subtitleEn:'Annual identity and monthly rewards with no gameplay advantage',badge:'365D',priceLabel:'US\$39.99',icon:'👑',cadence:'annual'),
];

Color r19OfferAccent(String cadence) => switch (cadence) {
  'daily' => const Color(0xff25e4df),
  'weekly' => const Color(0xff8f7cff),
  'monthly' => const Color(0xffffbd4d),
  'annual' => const Color(0xffff6a8a),
  _ => const Color(0xff25e4df),
};

/// R19 identity header shared by the full profile surface.
///
/// The purchased profile gradient remains the backdrop while the active
/// Pasha style supplies only the identity accent. This keeps both cosmetic
/// selections visible without changing membership, gameplay, or economy.
class R19PashaProfileHero extends StatelessWidget {
  const R19PashaProfileHero({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final pashaActive = controller.vipDays > 0;
    final pashaStyle = controller.activePashaStyleV173;
    final pashaAccent = colorFromHex(pashaStyle.primaryHex);
    final profileProduct = storeProductById(controller.selectedProfileColorB304);
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      label: 'r19-pasha-profile-hero',
      container: true,
      child: ProfileCover(
        coverId: controller.selectedCover,
        height: 258,
        colors: b304ProfileGradient(controller),
        animated: !reduceMotion,
        child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          final avatarSize = compact ? 92.0 : 112.0;
          return Stack(children: <Widget>[
            PositionedDirectional(
              top: 14,
              start: 14,
              child: _R19IdentityPill(
                key: const Key('r19-pasha-membership'),
                icon: pashaActive ? Icons.workspace_premium_rounded : Icons.workspace_premium_outlined,
                label: pashaActive
                    ? (ar ? 'باشا • ${controller.vipDays} يوم' : 'Pasha • ${controller.vipDays} days')
                    : (ar ? 'الباشا غير فعّال' : 'Pasha inactive'),
                accent: pashaActive ? pashaAccent : Colors.white70,
              ),
            ),
            PositionedDirectional(
              top: 14,
              end: 14,
              child: _R19IdentityPill(
                key: const Key('r19-pasha-style'),
                icon: Icons.palette_outlined,
                label: ar ? pashaStyle.nameAr : pashaStyle.nameEn,
                accent: pashaAccent,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(compact ? 14 : 18, 70, compact ? 14 : 18, 17),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                    InkWell(
                      onTap: () => showAvatarPicker(context, controller),
                      borderRadius: BorderRadius.circular(80),
                      child: AccountAvatar(controller: controller, size: avatarSize),
                    ),
                    SizedBox(width: compact ? 11 : 15),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Flexible(
                              child: Text(
                                controller.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: compact ? 21 : 26,
                                  fontWeight: FontWeight.w900,
                                  color: pashaActive ? pashaAccent : colorFromHex(controller.selectedNameColor),
                                  shadows: <Shadow>[Shadow(color: pashaAccent.withValues(alpha: .46), blurRadius: 12)],
                                ),
                              ),
                            ),
                            if (controller.isAdmin)
                              const Padding(
                                padding: EdgeInsetsDirectional.only(start: 6),
                                child: Icon(Icons.verified_rounded, color: Color(0xffffcf58), size: 20),
                              ),
                          ]),
                          const SizedBox(height: 3),
                          Text(
                            '@${controller.username} • ${controller.countryFlag} ${controller.countryName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(spacing: 7, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
                            _R19IdentityPill(
                              key: const Key('r19-server-state'),
                              icon: controller.serverConnected && controller.isAuthenticated
                                  ? Icons.cloud_done_outlined
                                  : Icons.cloud_off_outlined,
                              label: controller.serverConnected && controller.isAuthenticated
                                  ? (ar ? 'متصل بالخادم' : 'Server connected')
                                  : (ar ? 'غير متصل بالخادم' : 'Server offline'),
                              accent: controller.serverConnected && controller.isAuthenticated
                                  ? const Color(0xff62d68a)
                                  : const Color(0xffffba6d),
                              compact: true,
                            ),
                            _R19IdentityPill(
                              key: const Key('r19-profile-gradient'),
                              icon: Icons.gradient_rounded,
                              label: profileProduct?.name(controller.localeCode) ?? (ar ? 'هوية ورقنا' : 'Warqnaa identity'),
                              accent: b304ProfileGradient(controller).last,
                              compact: true,
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ]);
        }),
      ),
    );
  }
}

class _R19IdentityPill extends StatelessWidget {
  const _R19IdentityPill({super.key, required this.icon, required this.label, required this.accent, this.compact = false});
  final IconData icon;
  final String label;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(maxWidth: compact ? 210 : 170),
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 5 : 7),
        decoration: BoxDecoration(
          color: const Color(0xff07111d).withValues(alpha: .82),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: accent.withValues(alpha: .55)),
          boxShadow: <BoxShadow>[BoxShadow(color: accent.withValues(alpha: .16), blurRadius: 12)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(icon, size: compact ? 13 : 15, color: accent),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: compact ? 9 : 10, fontWeight: FontWeight.w900),
            ),
          ),
        ]),
      );
}

/// Premium presentation for the existing XP booster contract.
///
/// This surface deliberately reads the controller's already established
/// multiplier and expiry only. It does not activate a booster, award XP, alter
/// a hand, or decide a match result; those responsibilities remain in the
/// existing economy/progression paths.
class R19BoosterStatus extends StatelessWidget {
  const R19BoosterStatus({super.key, required this.controller, required this.onBrowse});

  final AppController controller;
  final VoidCallback onBrowse;

  String _remaining(bool ar) {
    final expiry = controller.boosterExpiresAtV173;
    if (expiry == null) return ar ? 'غير فعّال' : 'Inactive';
    final duration = expiry.difference(DateTime.now());
    if (duration <= Duration.zero) return ar ? 'منتهي' : 'Expired';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return ar ? '$hours س $minutes د متبقية' : '${hours}h ${minutes}m left';
    return ar ? '$minutes د متبقية' : '${minutes}m left';
  }

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final active = controller.activeXpMultiplier > 1 &&
        controller.boosterExpiresAtV173 != null &&
        controller.boosterExpiresAtV173!.isAfter(DateTime.now());
    final accent = active ? const Color(0xff55f4ca) : const Color(0xffffc85a);
    final multiplier = active
        ? _multiplierLabelV183(math.max(1.0, controller.activeXpMultiplier)).replaceFirst('×', '')
        : '1';

    return Semantics(
      label: 'r19-premium-booster-status',
      container: true,
      child: Container(
        key: const Key('r19-premium-booster-status'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[Color(0xff071724), Color(0xff102b3b), Color(0xff20162d)],
          ),
          border: Border.all(color: accent.withValues(alpha: .34)),
          boxShadow: <BoxShadow>[BoxShadow(color: accent.withValues(alpha: .11), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final visual = _R19BoosterOrb(active: active, accent: accent, multiplier: multiplier, compact: compact);
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(
                  child: Text(
                    ar ? 'مسرّعات التقدّم' : 'Progress boosters',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                _R19StorePill(
                  icon: active ? Icons.bolt_rounded : Icons.bolt_outlined,
                  text: active ? (ar ? 'فعّال الآن' : 'Active now') : (ar ? 'جاهز للاختيار' : 'Ready to browse'),
                  color: accent,
                ),
              ]),
              const SizedBox(height: 5),
              Text(
                active
                    ? (ar ? 'مضاعف XP ×$multiplier • ${_remaining(true)}' : '×$multiplier XP • ${_remaining(false)}')
                    : (ar ? 'لا يوجد مسرّع فعّال الآن' : 'No booster is active right now'),
                style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 9),
              Text(
                ar
                    ? 'يعزّز تقدّم XP المؤهّل فقط. لا يغيّر أوراقك أو ترتيب الأدوار أو نقاط الجولة أو نتيجة المباراة.'
                    : 'Boosts eligible XP progression only. It never changes your cards, turn order, round score, or match result.',
                style: TextStyle(fontSize: 10.5, height: 1.5, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .72)),
              ),
              const SizedBox(height: 11),
              Wrap(spacing: 7, runSpacing: 7, children: <Widget>[
                _R19BoosterBoundary(icon: Icons.auto_graph_rounded, label: ar ? 'تقدّم XP فقط' : 'XP progression only'),
                _R19BoosterBoundary(icon: Icons.timer_outlined, label: ar ? 'تفعيل مؤقت واضح' : 'Clear timed activation'),
                _R19BoosterBoundary(icon: Icons.gpp_good_outlined, label: ar ? 'لا أفضلية داخل اللعب' : 'No in-match advantage'),
              ]),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('r19-browse-boosters'),
                onPressed: onBrowse,
                icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                label: Text(ar ? 'استعراض المسرّعات' : 'Browse boosters'),
              ),
            ],
          );
          if (compact) {
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              Align(alignment: Alignment.center, child: visual),
              const SizedBox(height: 10),
              details,
            ]);
          }
          return Row(children: <Widget>[
            visual,
            const SizedBox(width: 18),
            Expanded(child: details),
          ]);
        }),
      ),
    );
  }
}

class _R19BoosterOrb extends StatelessWidget {
  const _R19BoosterOrb({required this.active, required this.accent, required this.multiplier, required this.compact});
  final bool active;
  final Color accent;
  final String multiplier;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 104.0 : 126.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: <Color>[accent.withValues(alpha: .31), const Color(0xff091521), const Color(0xff050b12)]),
        border: Border.all(color: accent.withValues(alpha: .55), width: 1.5),
        boxShadow: <BoxShadow>[BoxShadow(color: accent.withValues(alpha: .20), blurRadius: 25)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Icon(active ? Icons.rocket_launch_rounded : Icons.rocket_launch_outlined, color: accent, size: compact ? 30 : 38),
        const SizedBox(height: 5),
        Text('×$multiplier', style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
        Text('XP', style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ]),
    );
  }
}

class _R19BoosterBoundary extends StatelessWidget {
  const _R19BoosterBoundary({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 210),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .055),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.white.withValues(alpha: .11)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(icon, size: 13, color: const Color(0xff73ddff)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white70),
            ),
          ),
        ]),
      );
}

class R101CommerceShowcase extends StatelessWidget {
  const R101CommerceShowcase({super.key, required this.controller});
  final AppController controller;

  void _openCheckout(BuildContext context) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => B307CashShopPage(controller: controller)));
  }

  void _openBoosters(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final boosters = products.where((product) => product.category == 'boost' && controller.isStoreProductVisible(product)).toList(growable: false);
    showPremiumSheet(
      context,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Text(ar ? 'مسرّعات XP' : 'XP boosters', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(
          ar
              ? 'اختر مسرّع التقدّم المناسب. التفعيل مؤقت ولا يغيّر أي قرار أو نتيجة داخل المباراة.'
              : 'Choose a progression booster. Activation is temporary and never changes an in-match decision or result.',
          style: const TextStyle(color: Colors.white60, fontSize: 10.5, height: 1.5),
        ),
        const SizedBox(height: 12),
        for (final product in boosters)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PremiumPanel(
              child: ListTile(
                onTap: () => showProductPreview(context, controller, product),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: <Color>[controller.color1For(product), controller.color2For(product)]),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 23),
                ),
                title: Text(controller.nameFor(product), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(
                  ar
                      ? '24 ساعة بعد التفعيل • مخزون ${boosterValidityDaysV183(product.id)} أيام'
                      : '24h after activation • ${boosterValidityDaysV183(product.id)}-day inventory',
                  style: const TextStyle(fontSize: 9.5, color: Colors.white60),
                ),
                trailing: Text('×${_multiplierLabelV183(product.multiplier).replaceFirst('×', '')}', style: TextStyle(color: controller.color1For(product), fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final scheme = Theme.of(context).colorScheme;
    final verifiedLabel = controller.serverConnected
        ? (ar ? 'التحقق الخادمي متصل' : 'Server verification online')
        : (ar ? 'الشراء يتطلب اتصال الخادم' : 'Checkout requires server connection');
    return R9Section(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[Color(0xff071b2c), Color(0xff0d2a3c), Color(0xff24142d)],
            ),
            border: Border.all(color: const Color(0xff25e4df).withValues(alpha: .24)),
            boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x3500d8d0), blurRadius: 28, offset: Offset(0, 12))],
          ),
          child: Row(children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                gradient: const LinearGradient(colors: <Color>[Color(0xff25e4df), Color(0xff2c9cff)]),
                boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x5525e4df), blurRadius: 20)],
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Color(0xff04131e), size: 29),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ar ? 'متجر ورقنا المميز' : 'Warqnaa Luxury Store', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                ar ? 'عروض حقيقية، مقتنيات، مسرّعات وهوية بصرية — مع تحقق خادمي قبل منح أي رصيد.' : 'Real offers, collectibles, boosters and visual identity — server verified before currency is granted.',
                style: TextStyle(fontSize: 10, height: 1.45, color: scheme.onSurface.withValues(alpha: .70)),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                _R19StorePill(icon: Icons.verified_user_outlined, text: verifiedLabel, color: controller.serverConnected ? const Color(0xff5df0a4) : const Color(0xffffc85a)),
                _R19StorePill(icon: Icons.lock_outline_rounded, text: ar ? 'إيصال موثّق' : 'Receipt verified', color: const Color(0xff25e4df)),
                _R19StorePill(icon: Icons.credit_card_off_outlined, text: ar ? 'لا نخزن بيانات البطاقة' : 'No raw card storage', color: const Color(0xff9c87ff)),
              ]),
            ])),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => _openCheckout(context),
              icon: const Icon(Icons.shopping_bag_rounded, size: 18),
              label: Text(ar ? 'العروض' : 'Offers'),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xffffc657), foregroundColor: const Color(0xff201300)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: r101CommercialOffers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final offer = r101CommercialOffers[index];
              final accent = r19OfferAccent(offer.cadence);
              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _openCheckout(context),
                child: Container(
                  width: 244,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[accent.withValues(alpha: .24), const Color(0xff101d2a), scheme.surface, accent.withValues(alpha: .08)],
                    ),
                    border: Border.all(color: accent.withValues(alpha: .38)),
                    boxShadow: <BoxShadow>[BoxShadow(color: accent.withValues(alpha: .10), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .13), border: Border.all(color: accent.withValues(alpha: .32))), child: Text(offer.icon, style: const TextStyle(fontSize: 24))),
                      const Spacer(),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: accent.withValues(alpha: .15), border: Border.all(color: accent.withValues(alpha: .28))), child: Text(offer.badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: accent))),
                    ]),
                    const SizedBox(height: 9),
                    Text(ar ? offer.titleAr : offer.titleEn, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(ar ? offer.subtitleAr : offer.subtitleEn, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5, height: 1.35, color: scheme.onSurface.withValues(alpha: .68))),
                    const Spacer(),
                    Row(children: [
                      Text(offer.priceLabel, style: TextStyle(fontWeight: FontWeight.w900, color: accent, fontSize: 13)),
                      const Spacer(),
                      Icon(Icons.arrow_forward_rounded, size: 17, color: accent),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        R20StoreCollections(controller: controller),
        const SizedBox(height: 12),
        R19BoosterStatus(controller: controller, onBrowse: () => _openBoosters(context)),
        const SizedBox(height: 9),
        Text(
          ar ? 'الدفع الحقيقي لا يمنح التوكنز من نجاح العميل وحده؛ الاعتماد النهائي يتم بعد تحقق الخادم من الإيصال.' : 'Real-money purchases remain server receipt-verified. Client success alone never grants tokens.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9, color: scheme.onSurface.withValues(alpha: .50), fontWeight: FontWeight.w700),
        ),
      ]),
    );
  }
}

/// Browse the existing catalog without mutating inventory or currency.
class R20StoreCollections extends StatelessWidget {
  const R20StoreCollections({super.key, required this.controller});
  final AppController controller;

  List<StoreProduct> items(String category) => products.where((p) =>
      p.category == category && controller.isStoreProductVisible(p) &&
      (p.collection != 'daily_pack_v176' || controller.isOwnedActiveV176(p.id))).toList(growable: false);

  void browse(BuildContext context, String category, String title) {
    final ar = controller.localeCode == 'ar';
    final catalog = items(category);
    showPremiumSheet(context, child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(ar ? 'اختر عنصرًا للمعاينة. الشراء أو التفعيل يتم بعد التأكيد.' : 'Choose an item to preview. Purchase or activation requires confirmation.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        if (catalog.isEmpty) Text(ar ? 'لا توجد عناصر متاحة حاليًا.' : 'No items are available right now.'),
        for (final product in catalog) ListTile(
          key: ValueKey('r20-collection-item-${product.id}'),
          leading: Icon(controller.isOwnedActiveV176(product.id) ? Icons.inventory_2_outlined : Icons.auto_awesome_outlined),
          title: Text(controller.nameFor(product), maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(controller.isOwnedActiveV176(product.id) ? (ar ? 'مملوك • معاينة وتفعيل' : 'Owned • preview and activate') : (ar ? 'معاينة قبل الشراء' : 'Preview before purchase')),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => showProductPreview(context, controller, product),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final groups = <(String, String, IconData)>[
      ('pasha', ar ? 'الباشا' : 'Pasha', Icons.diamond_rounded),
      ('themes', ar ? 'الثيمات' : 'Themes', Icons.palette_outlined),
      ('cards', ar ? 'ظهر الورق' : 'Card backs', Icons.style_outlined),
      ('profile_colors', ar ? 'هوية الملف' : 'Profile identity', Icons.gradient_rounded),
      ('emoji', ar ? 'التفاعلات' : 'Reactions', Icons.emoji_emotions_outlined),
      ('covers', ar ? 'الأغلفة' : 'Covers', Icons.wallpaper_outlined),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(ar ? 'مجموعاتك المميزة' : 'Explore your collections', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
      LayoutBuilder(builder: (context, box) {
        final columns = box.maxWidth >= 1000 ? 6 : box.maxWidth >= 600 ? 3 : 2;
        final width = (box.maxWidth - (columns - 1) * 8) / columns;
        return Wrap(spacing: 8, runSpacing: 8, children: [for (final group in groups)
          SizedBox(width: width, child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              key: ValueKey('r20-collection-${group.$1}'),
              borderRadius: BorderRadius.circular(18),
              onTap: () => browse(context, group.$1, group.$2),
              child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(group.$3, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(group.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(ar ? '${items(group.$1).length} عنصر • ${items(group.$1).where((p) => controller.isOwnedActiveV176(p.id)).length} مملوك' : '${items(group.$1).length} items • ${items(group.$1).where((p) => controller.isOwnedActiveV176(p.id)).length} owned', style: Theme.of(context).textTheme.bodySmall),
              ])),
            ),
          )),
        ]);
      }),
    ]);
  }
}

class _R19StorePill extends StatelessWidget {
  const _R19StorePill({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: .22)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ]),
      );
}
