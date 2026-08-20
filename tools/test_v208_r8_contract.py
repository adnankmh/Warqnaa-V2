#!/usr/bin/env python3
from pathlib import Path
import json,sys
ROOT=Path(__file__).resolve().parents[1]
def ok(cond,msg):
    if not cond:
        print('[FAIL]',msg); raise SystemExit(1)
    print('[PASS]',msg)
def read(rel): return (ROOT/rel).read_text(encoding='utf-8')
meta=json.loads(read('RELEASE_VERSION.json'))
ok(meta.get('full')=='0.4.8+208' and meta.get('build')==208,'R8 release metadata is 0.4.8+208')

tarneeb=read('backend-laravel/app/Services/GameEngine/TarneebStandalone/TarneebEngine.php')
ok("$delta[$bidTeam] = $bidAmount === 13 ? 26 : 16;" in tarneeb and "$delta[$bidTeam] = $bidTricks;" in tarneeb,'Tarneeb successful-contract and sweep scoring hardened')
ok("$delta[$bidTeam] = $bidAmount === 13 ? -16 : -$bidAmount;" in tarneeb,'Tarneeb failed 13 contract scoring hardened')
ok("'singleRound' => false" in tarneeb and "!empty($state['rules']['singleRound'])" in tarneeb,'Tarneeb server supports one-round match mode')

core=read('backend-laravel/app/Services/GameEngine/GlobalEngines/GlobalCardEngineCore.php')
for needle,msg in [
    ('rummyTurnMeta','Hand/Banakil turn metadata'),
    ("'must_meld'=>empty($state['config']['banakilScoring'])",'Hand fire-pile draw requires meld'),
    ('handCardPoints','Hand residual score values'),
    ('isFullHandFinish','full Hand finish scoring'),
    ('replaceWild','Joker replacement/recovery'),
    ('scoreBanakilRound','Banakil dedicated round scoring'),
]: ok(needle in core,msg)

wrapper=read('backend-laravel/app/Services/GameEngine/GlobalCardEngineRules.php')
ok('$this->engine->applyAction($g,$playerId,$a);' in wrapper,'global engine validation uses authoritative dry-run')
ok("$cfgPlayers===2 && $target===222) $target=150;" in wrapper,'Banakil duel target 150 supported')

flutter=read('flutter_app/lib/main.dart')
ok('MediaQuery.orientationOf(context) == Orientation.landscape' in flutter,'Flutter room responds to real device orientation')
ok('_chooseMeldMany' in flutter and '_chooseLayoff' in flutter and '_chooseWildReplacement' in flutter,'Flutter exposes advanced Hand/Banakil actions')
ok('مباراة من جولة واحدة فقط' in flutter and 'singleRound: singleRound' in flutter,'Flutter room creation exposes one-round mode')
ok('_lastCardLabel' in flutter and flutter.count('_tableStatusStrip(') >= 2,'Tarneeb UI renders bid/trump/last-card status strip')

blade=read('backend-laravel/resources/views/room/show.blade.php')
ok('responsive-table' in blade,'Laravel game room uses responsive directional table')
ok('square-table' not in blade,'primary Laravel room no longer uses square table class')
ok('نمط المباراة' in blade and 'آخر حركة' in blade,'Laravel game room exposes match mode and current activity')

mobile=read('backend-laravel/app/Http/Controllers/MobileGameController.php')
ok('advanceRoundWithoutPause' in mobile,'mobile server sessions auto-advance rounds without waiting')
ok("'single_round' => 'nullable|boolean'" in mobile,'mobile API validates one-round mode')

for port in (8007,8008,8009,8010):
    ok((ROOT/f'scripts/windows/current/START_WARQNA_R8_PORT_{port}.bat').is_file(),f'R8 Windows launcher {port}')
ok((ROOT/'scripts/windows/current/CHECK_R8_WINDOWS.bat').is_file(),'R8 one-click Windows check exists')
ok((ROOT/'backend-laravel/tools/test-v208-r8-rules.php').is_file(),'R8 deep rule audit exists')
ok((ROOT/'backend-laravel/tools/test-v208-r8-playthrough-stress.php').is_file(),'R8 playthrough stress exists')

for workflow in [
    '.github/workflows/backend-ci.yml','.github/workflows/production-release-check.yml',
    '.github/workflows/flutter-android.yml','.github/workflows/flutter-ios.yml','.github/workflows/flutter-web-pages.yml']:
    content=read(workflow)
    ok('test_v208_r8_contract.py' in content,f'R8 static contract wired into {Path(workflow).name}')

print('V208 R8 ENGINE INTEGRITY CONTRACT: PASS')
