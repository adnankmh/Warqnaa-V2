#!/usr/bin/env python3
"""B303 regression gate for Social World runtime auth, Flutter analyzer fixes, and premium UI."""
from __future__ import annotations
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def read(rel:str)->str:
    p=ROOT/rel
    if not p.is_file(): raise SystemExit('[FAIL] missing '+rel)
    return p.read_text(encoding='utf-8')

def check(value:bool,label:str)->None:
    if not value: raise SystemExit('[FAIL] '+label)
    print('[PASS] '+label)

meta=json.loads(read('RELEASE_VERSION.json'))
build=int(meta.get('build',0))
check(build>=303,'release preserves B303 or a later additive successor')
check(f"version: {meta.get('full')}" in read('flutter_app/pubspec.yaml'),'Flutter package matches current successor metadata')

resolver=read('backend-laravel/app/Support/AuthenticatedActor.php')
check('PersonalAccessToken::findToken($bearer)' in resolver,'API actor resolves directly from bearer token')
check('setUserResolver' in resolver and 'Auth::setUser($actor)' in resolver,'fresh actor replaces stale request and guard state')
clubs=read('backend-laravel/app/Http/Controllers/MobileClubWorldController.php')
check(clubs.count('AuthenticatedActor::resolve($request);') >= 7,'Clubs World endpoints refresh authenticated actor')
admin=read('backend-laravel/app/Http/Controllers/AdminSocialWorldController.php')
check('$actor = AuthenticatedActor::resolve($request);' in admin and "$actor->hasAdminPermission('social_world')" in admin,'Social World admin permission reads fresh database state')

r11=read('flutter_app/lib/r11_social_world.dart')
check("formatFullDate(startsAt) + ' • ' +" not in r11,'R11 string-composition analyzer lint removed')
check('final gift = selected;' in r11 and "giftKey: gift['key'].toString()" in r11,'R11 nullable gift selection is promoted safely')
check('class _R11AdminSocialWorldPanelState' in r11 and 'Widget build(BuildContext buildContext)' in r11,'R11 admin async context no longer shadows State.context')
r12=read('flutter_app/lib/r12_competitive.dart')
check('builder: (sheetContext) => DraggableScrollableSheet' in r12 and 'if (sheetContext.mounted) Navigator.pop(sheetContext);' in r12,'R12 tournament sheet context is lifecycle-safe')
check('class _R12AdminCompetitivePanelState' in r12 and 'Widget build(BuildContext buildContext)' in r12,'R12 admin async context no longer shadows State.context')
v175=read('flutter_app/lib/v175_release.dart')
check('if (!mounted) return;\n      final navigationContext = Navigator.of(context, rootNavigator: true).context;' in v175,'V175 navigation context is acquired only after mounted check')

css=read('backend-laravel/public/assets/css/b303-global-premium.css')
home=read('backend-laravel/resources/views/home.blade.php')
check('.b303-hero' in css and '.b303-game-grid' in css and '.b303-feature-grid' in css,'B303 premium responsive design assets remain preserved')
if build>=304:
    b304css=read('backend-laravel/public/assets/css/b304-vertical-legend.css')
    check('VERTICAL LEGEND • B304' in home and '.b304-grid' in b304css and "$ar?'" in home,'B304 replaces the B303 hero with compact Arabic/English premium home')
    check('B304HomeDashboard' in read('flutter_app/lib/v304_vertical_legend.dart'),'Flutter B304 home successor is present')
else:
    check('WORLD EXPERIENCE • B303' in home and "'de'=>" in home and "'es'=>" in home,'premium web home ships six-language copy')
    r9=read('flutter_app/lib/r9_release.dart')
    check("L.t(controller.localeCode, 'premiumHeroTitle')" in r9 and '_heroStatusCard' in r9,'Flutter home uses premium global hero')
v300=read('flutter_app/lib/v300_world_experience.dart')
for locale in ('ar','en','de','tr','fr','es'):
    check("'premiumHeroTitle'" in v300 and f"'{locale}'" in v300,f'premium translation registry preserves {locale}')

for wf in ['backend-ci.yml','production-release-check.yml','flutter-android.yml','flutter-ios.yml','flutter-web-pages.yml','global-release.yml']:
    check('test_v303_runtime_premium_contract.py' in read('.github/workflows/'+wf),f'V303 gate wired into {wf}')

backend_ci=read('.github/workflows/backend-ci.yml')
global_ci=read('.github/workflows/global-release.yml')
check('php artisan test --filter V303RuntimeStabilityTest' in backend_ci,'focused V303 runtime feature test wired into backend CI')
check('php artisan test --filter V303RuntimeStabilityTest' in global_ci,'focused V303 runtime feature test wired into global release')

print('V303 RUNTIME SOCIAL + FLUTTER + PREMIUM UI CONTRACT: PASS')
