from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = (ROOT / 'flutter_app/lib/r10_1_release.dart').read_text(encoding='utf-8')

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
}

failed = [name for name, ok in checks.items() if not ok]
for name, ok in checks.items():
    print(f"[{'PASS' if ok else 'FAIL'}] {name}")
if failed:
    raise SystemExit('R19 LUXURY COMMERCE CONTRACT FAILED: ' + ', '.join(failed))
print('R19 LUXURY COMMERCE CONTRACT: PASS')
