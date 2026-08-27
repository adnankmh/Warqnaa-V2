#!/usr/bin/env python3
"""Warqnaa Build 300 WORLD EXPERIENCE additive feature-baseline contract."""
from __future__ import annotations
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def text(rel:str)->str:
    p=ROOT/rel
    if not p.is_file(): raise SystemExit('[FAIL] missing '+rel)
    return p.read_text(encoding='utf-8')
def check(ok:bool,label:str):
    if not ok: raise SystemExit('[FAIL] '+label)
    print('[PASS] '+label)

meta=json.loads(text('RELEASE_VERSION.json'))
check(int(meta.get('build',0))>=300,'release preserves WORLD EXPERIENCE build 300 or newer')
main=text('flutter_app/lib/main.dart'); world=text('flutter_app/lib/v300_world_experience.dart'); themes=text('flutter_app/lib/r10_1_release.dart')
for code in ('ar','en','de','tr','fr','es'): check(f"Locale('{code}')" in main and f"'{code}'" in world, f'locale {code} is wired')
check(themes.count('R101ThemeSpec(code:')>=15,'15+ product themes')
check("lottie: ^3.3.3" in text('flutter_app/pubspec.yaml') and 'assets/lottie/world/' in text('flutter_app/pubspec.yaml'),'Lottie dependency and local animation bundle')
check(world.count("category:'covers'")>=20,'20+ new WORLD profile covers')
check(len(re.findall(r"'[^']+'",world.split('v300EmojiLibrary',1)[1].split('];',1)[0]))>=60,'60+ reaction emoji library')
check("category:'frames'" in world and "case 'frames':" in main,'profile frames are purchasable/activatable')
check('V300WorldHome' in main and 'V300WorldHubPage' in world,'new world lobby/home hub is reachable')
check('V300AdminWorldOpsPanel' in world and "Tab(text:'WORLD OPS')" in main,'admin WORLD OPS panel is reachable')
for rel in (
 'backend-laravel/app/Services/Gameplay/MatchLifecycleService.php',
 'backend-laravel/app/Http/Controllers/MobileLifecycleController.php',
 'backend-laravel/app/Http/Controllers/MobilePartyController.php',
 'backend-laravel/app/Services/Economy/EconomyAuditService.php',
 'backend-laravel/app/Http/Controllers/AdminEconomyAuditController.php',
 'backend-laravel/database/migrations/2026_08_27_000300_world_experience.php'):
    check((ROOT/rel).is_file(), rel+' exists')
routes=text('backend-laravel/routes/api.php')
for route in ('/heartbeat','/reconnect','/parties/mine','/parties/{party}/invite/{user}','/admin/economy-audit'):
    check(route in routes,'route '+route)
check("$allowed = ['ar','en','de','tr','fr','es'];" in text('backend-laravel/app/Providers/AppServiceProvider.php'),'Laravel locale allow-list matches Flutter')
cat=text('backend-laravel/app/Services/Games/GameCatalog.php')
check(all(bad not in re.findall(r"'([a-z0-9_]+)'",cat.split('customerKeys',1)[-1]) for bad in ('domino','jackaroo','chess')),'removed games remain outside customer catalog')
global_wf=text('.github/workflows/global-release.yml')
check('tools/release_metadata.py --github-output' in global_wf and '--build-name=${{ steps.release.outputs.version }}' in global_wf,'global workflow uses dynamic release metadata')
check('actions/upload-pages-artifact@v5' in text('.github/workflows/flutter-web-pages.yml'),'Pages artifact action updated to v5')
print('V300 WORLD EXPERIENCE CONTRACT: PASS')
