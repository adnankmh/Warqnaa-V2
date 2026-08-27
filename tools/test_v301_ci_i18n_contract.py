#!/usr/bin/env python3
"""Warqnaa V1.1.1+301 CI + six-language stability contract.

This gate prevents historical release contracts from pinning obsolete product limits.
R9/R10/R10.1 remain regression baselines, while the current product consistently
supports Arabic, English, German, Turkish, French and Spanish end-to-end.
"""
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCALES = ('ar','en','de','tr','fr','es')

def read(rel: str) -> str:
    p = ROOT / rel
    if not p.is_file():
        raise SystemExit('[FAIL] missing '+rel)
    return p.read_text(encoding='utf-8')

def check(value: bool, label: str) -> None:
    if not value:
        raise SystemExit('[FAIL] '+label)
    print('[PASS] '+label)

meta=json.loads(read('RELEASE_VERSION.json'))
check(int(meta.get('build',0)) >= 301,'current release preserves V301 or newer')
check('version:' in read('flutter_app/pubspec.yaml'),'Flutter package version remains declared')

main=read('flutter_app/lib/main.dart')
for code in LOCALES:
    check(f"Locale('{code}')" in main, f'Flutter locale {code} remains wired')
check("api.updateProfile({'locale': localeCode})" in main,'Flutter locale changes synchronize to the server')

langs=read('backend-laravel/config/warqna_languages.php')
layout=read('backend-laravel/resources/views/layouts/app.blade.php')
mobile=read('backend-laravel/app/Http/Controllers/MobileApiController.php')
page=read('backend-laravel/app/Http/Controllers/PageController.php')
admin=read('backend-laravel/app/Http/Controllers/AdminController.php')
for code in LOCALES:
    check(f"'{code}'" in langs, f'Laravel language config includes {code}')
    check(f'data-lang-pick="{code}"' in layout, f'Web language picker includes {code}')
check("'languages' => ['ar', 'en', 'de', 'tr', 'fr', 'es']" in mobile,'mobile bootstrap exposes exactly the six product locales')
check("'locale' => 'nullable|in:ar,en,de,tr,fr,es'" in mobile,'mobile profile validator accepts six locales')
check("$profile->locale = $data['locale'];" in mobile,'mobile profile locale is persisted')
check("'lang'=>'nullable|string|in:ar,en,de,tr,fr,es'" in page,'web quick preference accepts six locales')
check("'default_locale'=>'nullable|in:ar,en,de,tr,fr,es'" in admin,'admin default locale accepts six locales')

profile=read('backend-laravel/app/Models/Profile.php')
user=read('backend-laravel/app/Models/User.php')
check("'country_name','locale','name_color'" in profile,'Profile model allows locale persistence')
check("'locale'=>$p?->locale ?? 'ar'" in user,'public/self profile payload exposes persisted locale')
check((ROOT/'backend-laravel/database/migrations/2026_08_27_000301_ci_i18n_stability.php').is_file(),'profile locale upgrade migration exists')

catalog=read('backend-laravel/app/Services/Games/GameCatalog.php')
translations=catalog[catalog.index('public static function translations'):]
for code in LOCALES:
    check(f"'{code}'=>" in translations, f'game-rule response contains {code}')

r9=read('tools/test_v209_r9_contract.py')
check("Locale('de')\" not in main" not in r9 and "data-lang-pick=\"de\"' not in layout" not in r9,'R9 regression contract no longer bans successor locales')

for wf in ['backend-ci.yml','production-release-check.yml','flutter-android.yml','flutter-ios.yml','flutter-web-pages.yml','global-release.yml']:
    body=read('.github/workflows/'+wf)
    check('test_v301_ci_i18n_contract.py' in body, f'V301 gate wired into {wf}')

check('run: python3 ../tools/test_v263_r14_3_contract.py\n      - name: Verify V300' in read('.github/workflows/backend-ci.yml'),'backend CI V300 command is a separate YAML step')
check('- run: python3 tools/test_v263_r14_3_contract.py\n      - run: python3 tools/test_v300_world_experience_contract.py' in read('.github/workflows/global-release.yml'),'global release V300 command is a separate YAML step')

print('V301 CI + SIX-LANGUAGE STABILITY CONTRACT: PASS')
