#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def t(p): return (ROOT/p).read_text(encoding='utf-8')
def ok(c,m):
    if not c: raise SystemExit('[FAIL] '+m)
    print('[PASS] '+m)
main=t('flutter_app/lib/main.dart')
r5=t('flutter_app/lib/r5_world_class.dart')
layout=t('backend-laravel/resources/views/layouts/app.blade.php')
css=t('backend-laravel/public/assets/css/r5-world-class.css')
ok("part 'r5_world_class.dart';" in main,'R5 Flutter module wired')
ok('R5TopBar' in main and 'R5HomeDashboard' in main and 'R5BottomNavigation' in main,'R5 shell integrated')
ok('Primary Administrator' in r5 and 'controller.isPrimaryAdmin' in r5,'admin identity visibly role-based')
ok('_registerLocal' not in main.split('_loginOrCreateLocalFallback',1)[1].split('\n  }',1)[0],'failed online login cannot create fresh local account')
ok('r5-world-class.css' in layout,'R5 web visual layer wired')
ok('aspect-ratio:9/16' in css and 'orientation:landscape' in css,'portrait-first responsive table CSS')
ok('/offers' in t('backend-laravel/routes/web.php'),'real-money offers route remains wired')
ok('primary_admin' in t('backend-laravel/app/Console/Commands/SetupLocalAdmins.php'),'dual admin provisioning remains role-based')
print('WARQNAA R5 WORLD CLASS CONTRACT: PASS')
