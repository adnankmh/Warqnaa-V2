#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]

def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8', errors='ignore')

def ok(condition, message):
    if not condition:
        print('[FAIL]', message)
        raise SystemExit(1)
    print('[PASS]', message)

meta = json.loads(read('RELEASE_VERSION.json'))
ok(meta['build'] >= 610, 'R6.1 baseline is preserved by the current release')

main = read('flutter_app/lib/main.dart')
r61 = read('flutter_app/lib/r6_1_world_class.dart')
for symbol in ['R61TopBar', 'R61BottomNavigation', 'R61DesktopNavigation', 'R61HomeDashboard', 'R61SocialHubPage', 'R61ProfilePage']:
    ok(f'class {symbol}' in r61, f'{symbol} is implemented')
ok("part 'r6_1_world_class.dart';" in main, 'R6.1 Flutter module is wired')
ok('buildR61PairedCardBacks' in r61 and "collection: 'r61_paired_cardbacks'" in r61, 'Flutter creates paired table card backs')
ok('isR61SelectableTableId(selectedTable)' in main and 'isR61SelectableCardBackId(selectedCardBack)' in main, 'persisted cosmetics are validated safely')

catalog = json.loads(read('backend-laravel/resources/data/v173_store_catalog.json'))
tables = [item for item in catalog if item.get('category') == 'table']
ok(len(tables) == 50, 'curated V173 catalog contains exactly 50 image-backed tables')
ok(all(item.get('payload', {}).get('image') and item.get('payload', {}).get('asset') for item in tables), 'all curated tables include web and app assets')

store = read('backend-laravel/app/Services/WarqnaPro/StoreCatalogService.php')
ok('syncR61CuratedTablesAndCardBacks' in store and 'r61PairedCardBacks' in store, 'Laravel curated catalog sync is installed')
ok("'paired_table'=>$tableKey" in store and "'collection'=>'r61_paired_cardbacks'" in store, 'server card backs retain their table relationship')

layout = read('backend-laravel/resources/views/layouts/app.blade.php')
css = read('backend-laravel/public/assets/css/r6-1-world-class.css')
ok('WARQNAA_R61' in layout and 'r6-1-world-class.css' in layout and 'warqna-r61' in layout, 'web runtime exposes the R6.1 layer')
ok('prefers-reduced-motion' in css and ':focus-visible' in css and '.friends-dashboard' in css, 'web design includes responsive and accessibility states')

admin = read('backend-laravel/app/Console/Commands/SetupAdnanPrimaryAdmin.php')
ok('WARQNAA_ADNAN_ADMIN_PASSWORD' in admin and 'WARQNAA_ADNAN_ADMIN_EMAIL' in admin, 'administrator provisioning is environment-driven')
ok("'password'=>'" not in admin and 'Hash::make(' not in admin, 'administrator password value is absent from the dedicated setup command')

print('R6.1 WORLD CLASS CONTRACT: PASS')
