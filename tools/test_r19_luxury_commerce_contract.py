from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = (ROOT / 'flutter_app/lib/r10_1_release.dart').read_text(encoding='utf-8')
PROFILE = (ROOT / 'flutter_app/lib/v304_vertical_legend.dart').read_text(encoding='utf-8')
WORLD = (ROOT / 'flutter_app/lib/r6_1_world_class.dart').read_text(encoding='utf-8')
PREFLIGHT = (ROOT / 'tools/validate_release.py').read_text(encoding='utf-8')
WIDGET_TEST = ROOT / 'flutter_app/test/r19_profile_pasha_test.dart'
RUNTIME_REVIEW = (ROOT / 'flutter_app/test/r7_runtime_review_test.dart').read_text(encoding='utf-8')

checks = {
    'R19 release anchor': "warqnaaR19LuxuryCommerce = '1.9.1+710-luxury-commerce'" in SRC,
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
    'R19 profile widget regression exists': WIDGET_TEST.is_file(),
    'active Pasha profile is captured in runtime review': all(x in RUNTIME_REVIEW for x in [
        "controller.selectedPashaStyle = 'blue'",
        "controller.selectedProfileColorB304 = 'r19_profile_sapphire_pasha_30d'",
        "('local-profile', R61ProfilePage(controller: controller))",
    ]),
    'R19 contract is part of release preflight': 'test_r19_luxury_commerce_contract.py' in PREFLIGHT,
}

failed = [name for name, ok in checks.items() if not ok]
for name, ok in checks.items():
    print(f"[{'PASS' if ok else 'FAIL'}] {name}")
if failed:
    raise SystemExit('R19 LUXURY COMMERCE CONTRACT FAILED: ' + ', '.join(failed))
print('R19 LUXURY COMMERCE CONTRACT: PASS')
