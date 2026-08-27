#!/usr/bin/env python3
"""B302 final regression gate for Flutter analyzer blockers and Hand gold deadlocks."""
from __future__ import annotations
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(rel:str)->str:
    p=ROOT/rel
    if not p.is_file(): raise SystemExit('[FAIL] missing '+rel)
    return p.read_text(encoding='utf-8')
def check(v:bool,label:str)->None:
    if not v: raise SystemExit('[FAIL] '+label)
    print('[PASS] '+label)
meta=json.loads(read('RELEASE_VERSION.json'))
check(int(meta.get('build',0)) >= 302,'current release preserves V302 or newer')
check('version:' in read('flutter_app/pubspec.yaml'),'Flutter package version remains declared after V302')
main=read('flutter_app/lib/main.dart')
check("import 'package:flutter/cupertino.dart';" in main,'Cupertino transition library imported')
check("part 'r14_1_legendary.dart';" in main,'R14.1 stale-file compatibility part is wired')
tomb=read('flutter_app/lib/r14_1_legendary.dart')
check(tomb.startswith("part of 'main.dart';") and 'compatibility tombstone' in tomb.lower(),'R14.1 stale analyzer file is neutralized')
r101=read('flutter_app/lib/r10_1_release.dart')
check("CupertinoPageTransitionsBuilder()" in r101,'Cupertino page transition remains configured')
check("priceLabel:'US\\$0.99'" in r101 and "priceLabel:'US$0.99'" not in r101,'Dart dollar interpolation bug is fixed')
r11=read('flutter_app/lib/r11_social_world.dart')
check("selected!['icon']" not in r11 and "selected![ar ? 'ar' : 'en']" not in r11,'unnecessary selected non-null assertions removed')
core=read('backend-laravel/app/Services/GameEngine/GlobalEngines/GlobalCardEngineCore.php')
for needle,label in [
    ('selectDisjointMeldGroups','disjoint meld-group validator exists'),
    ('Taking the discard is only legal','discard draw deadlock guard exists'),
    ("$openingRequired = $this->hasRummyOpened",'opening threshold is state-aware'),
]: check(needle in core,label)
gold=read('backend-laravel/tools/test-v250-r13-engine-gold.php')
check('WARQNA_GOLD_ENGINE_FILTER' in gold,'focused deterministic Engine Gold diagnostics supported')
for wf in ['backend-ci.yml','production-release-check.yml','flutter-android.yml','flutter-ios.yml','flutter-web-pages.yml','global-release.yml']:
    check('test_v302_flutter_hand_final_contract.py' in read('.github/workflows/'+wf),f'V302 gate wired into {wf}')
print('V302 FLUTTER + HAND FINAL STABILITY CONTRACT: PASS')
