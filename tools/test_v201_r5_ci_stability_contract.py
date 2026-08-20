#!/usr/bin/env python3
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]

def text(rel):
    return (ROOT/rel).read_text(encoding='utf-8', errors='ignore')

def ok(cond,msg):
    if not cond:
        print('[FAIL]',msg); raise SystemExit(1)
    print('[PASS]',msg)

meta=json.loads(text('RELEASE_VERSION.json'))
ok(int(meta.get('build',0)) >= 201, 'release remains at build 201 or newer')
for port in (8007,8008,8009,8010):
    current=ROOT/f'scripts/windows/current/START_WARQNA_V201_PORT_{port}.bat'
    legacy=ROOT/f'scripts/windows/current/START_WARQNA_V200_PORT_{port}.bat'
    ok(current.is_file(), f'current V201 Windows launcher {port}')
    ok(legacy.is_file() and f'START_WARQNA_V201_PORT_{port}.bat' in legacy.read_text(encoding='utf-8',errors='ignore'), f'legacy V200 launcher {port} delegates to V201')

v142=text('backend-laravel/tests/Feature/V142MobileRealEnginesSocialEconomyTest.php')
ok("9000000000000000000" in v142, 'V142 admin reserve expectation matches current safe reserve')
v161=text('backend-laravel/tests/Feature/V161VoiceSocialProgressionTest.php')
ok("assertSame(20, $first['xp'])" in v161 and "assertSame(20, (int)$user->profile()->firstOrFail()->xp)" in v161, 'V161 XP contract matches V201 progression')
view=text('backend-laravel/config/view.php')
ok("storage_path('framework/views')" in view, 'Laravel compiled view path is explicit')
testcase=text('backend-laravel/tests/TestCase.php')
ok('storage/framework/views' in testcase and 'setUpBeforeClass' in testcase, 'Laravel tests create cache directories before boot')
ci=text('.github/workflows/backend-ci.yml')
ok('mkdir -p storage/framework/views storage/framework/cache/data storage/framework/sessions bootstrap/cache' in ci, 'Backend CI prepares writable cache directories')

v200=text('tools/test_v200_full_fusion_contract.py')
ok('current.is_file() or legacy.is_file()' in v200, 'historical V200 contract accepts current-version launcher')
print('V201 R5 CI STABILITY CONTRACT: PASS')
