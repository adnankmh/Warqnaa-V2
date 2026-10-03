from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = (ROOT / 'flutter_app/lib/r10_1_release.dart').read_text(encoding='utf-8')
PROFILE = (ROOT / 'flutter_app/lib/v304_vertical_legend.dart').read_text(encoding='utf-8')
WORLD = (ROOT / 'flutter_app/lib/r6_1_world_class.dart').read_text(encoding='utf-8')
AVATAR = (ROOT / 'flutter_app/lib/v170_global.dart').read_text(encoding='utf-8')
MAIN = (ROOT / 'flutter_app/lib/main.dart').read_text(encoding='utf-8')
PREFLIGHT = (ROOT / 'tools/validate_release.py').read_text(encoding='utf-8')
PROFILE_WIDGET_TEST = ROOT / 'flutter_app/test/r19_profile_pasha_test.dart'
BOOSTER_WIDGET_TEST = ROOT / 'flutter_app/test/r19_booster_status_test.dart'
REACTION_WIDGET_TEST = ROOT / 'flutter_app/test/r19_reaction_stage_test.dart'
AVATAR_WIDGET_TEST = ROOT / 'flutter_app/test/r19_avatar_bot_stage_test.dart'
GAME_ART_WIDGET_TEST = ROOT / 'flutter_app/test/r19_game_art_stage_test.dart'
RUNTIME_REVIEW = (ROOT / 'flutter_app/test/r7_runtime_review_test.dart').read_text(encoding='utf-8')
REACTIONS = (ROOT / 'flutter_app/lib/premium_v149.dart').read_text(encoding='utf-8')
SOUNDS = (ROOT / 'flutter_app/lib/services/app_sounds.dart').read_text(encoding='utf-8')
SMALL_TABLE = (ROOT / 'flutter_app/lib/v021_patch.dart').read_text(encoding='utf-8')

checks = {
    'R19 release anchor': "warqnaaR19LuxuryCommerce = '1.9.5+714-game-art-stage'" in SRC,
    'premium visual themes': all(x in SRC for x in ["'midnight_cyan'", "'obsidian_gold'", "'royal_crimson'", "'sapphire_pasha'", "'aurora_luxe'"]),
    'legacy themes retained': all(x in SRC for x in ["'dark'", "'light'", "'green'", "'gold'", "'purple'", "'ocean'"]),
    'luxury store hero': 'Warqnaa Luxury Store' in SRC and 'متجر ورقنا المميز' in SRC,
    'real checkout route': 'B307CashShopPage(controller: controller)' in SRC,
    'offer cards are interactive': 'onTap: () => _openCheckout(context)' in SRC,
    'server verification state shown': 'Server verification online' in SRC and 'Checkout requires server connection' in SRC,
    'receipt verification preserved': 'Real-money purchases remain server receipt-verified.' in SRC,
    'client success cannot grant tokens': 'Client success alone never grants tokens.' in SRC,
    'raw card data warning retained': 'No raw card storage' in SRC,
    'offer cadence palette': all(x in SRC for x in ["'daily' =>", "'weekly' =>", "'monthly' =>", "'annual' =>"]),
    'luxury profile collection': all(x in PROFILE for x in [
        'r19_profile_midnight_cyan_30d',
        'r19_profile_obsidian_gold_30d',
        'r19_profile_royal_crimson_30d',
        'r19_profile_sapphire_pasha_30d',
        'r19_profile_aurora_luxe_30d',
        'r19_profile_emerald_crown_30d',
    ]),
    'profile colours remain real store products': PROFILE.count("category:'profile_colors'") >= 12,
    'profile gradient remains selected-product driven': 'storeProductById(controller.selectedProfileColorB304)' in PROFILE,
    'luxury profile products expire safely': PROFILE.count("collection:'r19_luxury_profile'") == 6 and PROFILE.count('durationDays:30') >= 12,
    'responsive Pasha profile hero': all(x in SRC for x in [
        'class R19PashaProfileHero',
        "constraints.maxWidth < 420",
        "MediaQuery.maybeOf(context)?.disableAnimations",
        "controller.activePashaStyleV173",
        "b304ProfileGradient(controller)",
    ]),
    'real profile uses R19 identity hero': 'R19PashaProfileHero(controller: controller)' in WORLD,
    'Pasha avatar uses the selected style once': (
        'final String? pashaAsset;' in AVATAR
        and "pashaAsset ?? 'assets/images/pasha.png'" in AVATAR
        and 'pashaAsset: controller.activePashaStyleV173.asset' in MAIN
        and 'PashaHatV173(controller: controller, width: compact' not in SRC
    ),
    'R19 profile widget regression exists': PROFILE_WIDGET_TEST.is_file(),
    'premium booster status is integrated into real store': all(x in SRC + MAIN for x in [
        'class R19BoosterStatus',
        'R19BoosterStatus(controller: controller',
        "product.category == 'boost'",
        'showProductPreview(context, controller, product)',
        'controller.activeXpMultiplier',
        'controller.boosterExpiresAtV173',
    ]),
    'booster copy forbids in-match advantage': all(x in SRC for x in [
        'XP progression only',
        'No in-match advantage',
        'turn order, round score, or match result',
        'لا أفضلية داخل اللعب',
    ]),
    'R19 booster widget regression exists': BOOSTER_WIDGET_TEST.is_file() and all(x in BOOSTER_WIDGET_TEST.read_text(encoding='utf-8') for x in [
        "const Size(320, 640)",
        "const Size(844, 390)",
        "for (final locale in <String>['ar', 'en'])",
        "Key('r19-browse-boosters')",
    ]),
    'R19 reaction stage is localized, audible and reduced-motion safe': all(x in REACTIONS for x in [
        "String get soundCue => switch (category)",
        "rtl ? 'تفاعلات ورقنا' : 'Warqnaa reactions'",
        "reduceMotion ? 1050 : 1700",
        "if (soundEnabled && widget.reaction.animated) AppSounds.fire(widget.reaction.soundCue)",
        "liveRegion: true",
    ]),
    'reaction audio stays on the shipped fail-safe sound bus': all(x in SOUNDS for x in [
        "'reaction_friendly': 'emoji'",
        "'reaction_power': 'card_combo'",
        "'reaction_victory': 'legendary_emote'",
        "cue.startsWith('reaction_')",
        "await Future<void>.delayed(const Duration(milliseconds: 70))",
        "AssetSource('sounds/r10/$cue.ogg')",
    ]),
    'R19 reaction regression covers RTL, LTR, phone and landscape': REACTION_WIDGET_TEST.is_file() and all(x in REACTION_WIDGET_TEST.read_text(encoding='utf-8') for x in [
        "for (final locale in <String>['ar', 'en'])",
        "const Size(320, 640)",
        "const Size(844, 390)",
        "reduceMotion: true",
    ]),
    'R19 bot identities keep original localized presentation': all(x in REACTIONS for x in [
        'class BotIdentityShowcase',
        'class BotRosterShowcase',
        "language == 'ar' ? 'آلي' : 'BOT'",
        'Original Arabic identity',
        'Gameplay decisions come from the authoritative engine, not this presentation layer.',
    ]),
    'public bot profile keeps its painted identity': all(x in AVATAR for x in [
        'candidate.seed == -visible.id',
        'BotIdentityShowcase(profile: botProfile, locale: controller.localeCode)',
        "ar ? 'المباريات' : 'Games'",
        'Token balance is private and never appears on a public profile.',
    ]),
    'small-table bot badges are localized': all(x in SMALL_TABLE for x in [
        "locale == 'ar' ? 'ذكاء خبير' : 'MASTER AI'",
        "locale == 'ar' ? 'ذكاء احترافي' : 'PRO AI'",
    ]),
    'R19 bot regression covers RTL, LTR, phone, landscape and web': AVATAR_WIDGET_TEST.is_file() and all(x in AVATAR_WIDGET_TEST.read_text(encoding='utf-8') for x in [
        "for (final locale in <String>['ar', 'en'])",
        'const Size(320, 640)',
        'const Size(844, 390)',
        'const Size(1280, 800)',
        'find.byType(Bot3DAvatar)',
    ]),
    'R19 original table and card art is generated in app': all(x in MAIN for x in [
        'class WarqnaaTableSurface',
        'class _WarqnaaTablePatternPainter',
        "ValueKey('r19-warqnaa-table-surface')",
        'class _WarqnaaCardFacePainter',
        'class _WarqnaaCardBackPainter',
        "ValueKey('r19-card-face-$label')",
        "oldDelegate.color != color",
    ]),
    'R19 game-art regression covers RTL, LTR, portrait and landscape': GAME_ART_WIDGET_TEST.is_file() and all(x in GAME_ART_WIDGET_TEST.read_text(encoding='utf-8') for x in [
        "for (final locale in <String>['ar', 'en'])",
        'const Size(320, 640)',
        'const Size(844, 390)',
        "PlayingCard(label: 'A♠'",
        "PlayingCard(label: 'Q♥'",
        "PlayingCard(label: '10♦'",
        "ValueKey('r19-warqnaa-table-surface')",
        "ValueKey('r19-warqnaa-card-back')",
    ]),
    'active Pasha profile is captured in runtime review': all(x in RUNTIME_REVIEW for x in [
        "controller.selectedPashaStyle = 'blue'",
        "controller.selectedProfileColorB304 = 'r19_profile_sapphire_pasha_30d'",
        "('local-profile', R61ProfilePage(controller: controller))",
        "'local-booster',",
        'controller.activeXpMultiplier = 2.5',
        "('local-reaction', R19ReactionReview(locale: locale))",
        "('local-bots', R19BotReview(locale: locale))",
    ]),
    'R19 contract is part of release preflight': 'test_r19_luxury_commerce_contract.py' in PREFLIGHT,
}

failed = [name for name, ok in checks.items() if not ok]
for name, ok in checks.items():
    print(f"[{'PASS' if ok else 'FAIL'}] {name}")
if failed:
    raise SystemExit('R19 LUXURY COMMERCE CONTRACT FAILED: ' + ', '.join(failed))
print('R19 LUXURY COMMERCE CONTRACT: PASS')
