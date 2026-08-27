#!/usr/bin/env python3
from pathlib import Path
import json,re,sys
ROOT=Path(__file__).resolve().parents[1]
def read(rel): return (ROOT/rel).read_text(encoding='utf-8')
def ok(cond,msg):
    if not cond:
        print('[FAIL]',msg); raise SystemExit(1)
    print('[PASS]',msg)
meta=json.loads(read('RELEASE_VERSION.json'))
build=int(meta.get('build',0))
ok(build >= 209,'R9 foundation is preserved at build 209 or newer')
main=read('flutter_app/lib/main.dart')
ok("Locale('ar')" in main and "Locale('en')" in main,'Flutter preserves the R9 Arabic/English locale baseline; newer releases may add locales')
r101 = read('flutter_app/lib/r10_1_release.dart') if (ROOT/'flutter_app/lib/r10_1_release.dart').is_file() else ''
uses_r9_direct = "R9Design.theme" in main
uses_r101_wrapper = build >= 221 and 'theme: r101Theme(' in main and 'R9Design.theme' in r101
successor_home = main + (read('flutter_app/lib/v300_world_experience.dart') if (ROOT/'flutter_app/lib/v300_world_experience.dart').is_file() else '')
ok((uses_r9_direct or uses_r101_wrapper) and "R9HomeDashboard" in successor_home,'Flutter preserves R9 design system foundation and lobby through the current home wrapper')
ok('final palette = AppPalette.fromCode(controller.themeCode);' not in main,'R9 app shell has no stale unused palette local')
ok("part 'r9_release.dart';" in main,'R9 Flutter release module is wired')
r9=read('flutter_app/lib/r9_release.dart')
ok('final accent = Theme.of(context).colorScheme.primary;' not in r9 or 'accent.withValues' in r9,'R9 lobby has no stale unused accent local')
legacy_table_preview = 'aspectRatio: portrait ? 10 / 16 : 16 / 9' in r9 and 'BoxFit.cover' in r9
r101_table_preview = build >= 221 and 'aspectRatio: portrait ? 10 / 16 : 16 / 9' in r9 and 'FractionallySizedBox' in r9 and 'BoxFit.contain' in r9
ok(legacy_table_preview or r101_table_preview,'R9 directional table preview foundation is preserved (R10.1 may use proportional artwork inlay)')
ok(('Live lobby • R9' in r9 and 'العب الآن' in r9) or ('premiumHeroTitle' in r9 and 'worldStatus' in r9),'R9 home lobby foundation or successor premium hero exists')
layout=read('backend-laravel/resources/views/layouts/app.blade.php')
ok('r9-design-system.css' in layout and 'warqna-r9' in layout,'Laravel loads R9 design system')
ok('data-lang-pick="ar"' in layout and 'data-lang-pick="en"' in layout,'Laravel language picker preserves the R9 Arabic/English baseline')
langs=read('backend-laravel/config/warqna_languages.php')
ok("'ar'" in langs and "'en'" in langs,'Laravel language config preserves the R9 Arabic/English baseline')
store=read('backend-laravel/app/Services/WarqnaPro/StoreCatalogService.php')
ok('normalizeBilingualNames' in store and 'deactivateExactDuplicates' in store,'store normalizes bilingual names and deactivates exact duplicates')
mobile=read('backend-laravel/app/Http/Controllers/MobileApiController.php')
ok("'languages' => [" in mobile and all(f"'{code}'" in mobile for code in ('ar','en')),'mobile bootstrap preserves the R9 ar/en locale baseline')
liveops=read('backend-laravel/app/Services/WarqnaPro/LiveOpsService.php')
ok('rewarded_enabled' in liveops and "'daily'" in liveops and "'weekly'" in liveops and "'monthly'" in liveops and "'annual'" in liveops,'R9 live-ops foundation includes ads and offer cadences')
bots=read('flutter_app/lib/premium_v149.dart')
ok("Text('BOT'" in bots,'bot identity is explicit in the avatar UI')
asset=ROOT/'docs/ar/reports/current/R9_ASSET_AUDIT.json'
ok(asset.is_file(),'R9 asset audit report exists')
audit=json.loads(asset.read_text(encoding='utf-8'))
ok(audit.get('potential_duplicate_savings_bytes',0)>0,'R9 asset audit quantifies duplicate savings')
# Verify the exact safe duplicates targeted by the R9 migration are gone.
# Do not hard-code an absolute total asset-size ceiling: upgraded projects may
# legitimately contain additional purchased/preview assets from later patches.
r9_dedupe_targets = [
    'flutter_app/assets/images/games/backgammon.png',
    'flutter_app/assets/images/games/game_library_reference.png',
    'flutter_app/assets/images/games/pinochle.png',
    'flutter_app/assets/images/games/solitaire_multiplayer.png',
    'flutter_app/assets/images/games/tarneeb_41.png',
    'flutter_app/assets/images/games/tarneeb_61.png',
    'flutter_app/assets/images/v02/rewards/ticket_200.png',
]
remaining=[rel for rel in r9_dedupe_targets if (ROOT/rel).exists()]
ok(not remaining,'R9 safe duplicate assets are removed')
size=sum(p.stat().st_size for p in (ROOT/'flutter_app/assets').rglob('*') if p.is_file())
print(f'[INFO] Flutter runtime assets: {size/1024/1024:.2f} MB (informational; no brittle absolute-size gate)')
for port in (8007,8008,8009,8010):
    ok((ROOT/f'scripts/windows/current/START_WARQNA_R9_PORT_{port}.bat').is_file(),f'R9 launcher {port}')
ok((ROOT/'scripts/windows/current/CHECK_R9_WINDOWS.bat').is_file(),'R9 full check launcher exists')
for wf in ['backend-ci.yml','production-release-check.yml','flutter-android.yml','flutter-ios.yml','flutter-web-pages.yml']:
    ok('test_v209_r9_contract.py' in read('.github/workflows/'+wf),f'R9 contract wired into {wf}')
print('V209 R9 VISUAL REVOLUTION CONTRACT: PASS')
