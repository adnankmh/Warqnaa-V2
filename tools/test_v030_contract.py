#!/usr/bin/env python3
"""Historical V0.3 feature contract; compatible with later Warqnaa releases."""
from __future__ import annotations
import json, re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]

def fail(message: str) -> None:
    print('[FAIL] '+message)
    raise SystemExit(1)

def req(rel: str, *needles: str) -> str:
    p=ROOT/rel
    if not p.is_file(): fail('Missing '+rel)
    text=p.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text: fail(f'Missing {needle!r} in {rel}')
    return text

def main() -> None:
    meta=json.loads((ROOT/'RELEASE_VERSION.json').read_text(encoding='utf-8'))
    version=str(meta.get('version','')).strip()
    build=meta.get('build')
    full=str(meta.get('full','')).strip()
    if not version or not isinstance(build,int) or build < 184:
        fail('V0.3 compatibility contract requires release build 184 or later')
    if full != f'{version}+{build}':
        fail('Release metadata full/version/build fields are inconsistent')
    req('flutter_app/pubspec.yaml',f'version: {full}')

    premium=req('flutter_app/lib/premium_v151.dart','const List<(String, String, Color)> v151ThemeOptions')
    theme_block=premium[premium.index('const List<(String, String, Color)> v151ThemeOptions'):premium.index('const List<String> v151AccentColors')]
    theme_count=len(re.findall(r"^\s*\('[^']+',\s*'[^']+',\s*Color\(",theme_block,re.M))
    if int(build) >= 209:
        # R9 established six required production themes. Successor releases may
        # add more themes, but they must never remove the R9 compatibility set.
        required_r9={'dark','light','green','gold','purple','classic'}
        found_r9=set(re.findall(r"^\s*\('([^']+)',",theme_block,re.M))
        if not required_r9.issubset(found_r9):
            fail(f'R9 compatibility themes are missing; found {sorted(found_r9)}')
        if int(build) < 300 and theme_count != 6:
            fail(f'R9-era releases require exactly six curated themes, found {theme_count}')
        if int(build) >= 300 and theme_count < 13:
            fail(f'WORLD EXPERIENCE successors require at least 13 themes, found {theme_count}')
    elif theme_count != 9:
        fail('Historical pre-R9 releases require exactly nine built-in themes')

    main=req('flutter_app/lib/main.dart',
        "final List<String> homeGameIds = <String>['tarneeb', 'hand', 'trix'];",
        'Future<String?> updateHomeGames',
        'if (raw.toSet().length > 4)',
        'showHomeGamesSelector',
        'coins -= BigInt.from(price);',
        'lastStoreError = e.message;',
        'if (amount < 10)',
        'final fee = (amount * .10).ceil();',
        'challengeRoadTotal = const <int>{10, 12, 15}.contains(totalStages)',
        'challengeRoadAttempts = 5',
        "bool get isPrimaryAdmin => isAdmin && username.trim().toLowerCase() == 'adnan';",
        'Web/GitHub Pages preview: keep the temporary rewarded-ad feature testable',
        '_grantLocalLevelReward',
    )
    create_room=main[main.index('void showCreateRoom'):main.index('class OpenRoomsSheet') if 'class OpenRoomsSheet' in main else len(main)]
    if "DropdownMenuItem(value: 'friends'" in create_room: fail('Friends-only option remains in create-room UI')

    pasha=req('flutter_app/lib/v173_global.dart',"(key == 'black' ? 'red' : key)")
    if "PashaStyleV173('black'" in pasha: fail('Black Pasha style remains active')

    rooms=req('backend-laravel/app/Http/Controllers/MobileGameController.php',
        "->where('visibility', 'public')",
        'Keep every public active room discoverable',
        "'avatars' =>",
    )
    if "where('connected', true)" in rooms[rooms.index('public function rooms'):rooms.index('public function join')]:
        fail('Open-room discovery still requires an open/connected game screen')

    req('backend-laravel/app/Http/Controllers/MobileAdminController.php',
        'guardPrimaryDesigner',
        "strtolower((string) $request->user()?->username) === 'adnan'",
    )
    req('backend-laravel/app/Http/Controllers/ClubController.php','ClubActivityLog','manage_club','updateSettings')
    req('backend-laravel/database/migrations/2026_07_14_000300_create_club_activity_logs.php',"Schema::create('club_activity_logs'")
    req('backend-laravel/app/Services/Leveling/XpService.php','level_rewards','pasha_days','ticket_200','prize_box')

    banakil=req('backend-laravel/app/Services/GameEngine/GlobalEngines/BanakilEngine.php',
        "'cardsEach' => 18",
        "'starterExtraCard' => true",
        "'starterMustDiscard' => true",
        "'opening' => 0",
        "'partnership' => true",
    )
    core=req('backend-laravel/app/Services/GameEngine/GlobalEngines/GlobalCardEngineCore.php',
        'removeOneCard',
        'recycleDiscard',
        'protected function layoff',
        "unset($view['deck'], $view['seed']);",
        "'dealCommitment'=>$dealCommitment",
    )
    req('backend-laravel/app/Http/Controllers/RoomController.php',"$copy['_global_engine']","$copy['plain_room_password']")

    seeder=req('backend-laravel/database/seeders/DatabaseSeeder.php',"['Kareem'",'نخبة ورقنا','manage_club')
    demo_block=seeder[seeder.index('$demoUsers = ['):seeder.index('];', seeder.index('$demoUsers = ['))+2]
    legacy_demo_names={'Kareem','Rami','Lina','Samar','Layla','Jameel','Nour','Omar','Sara','Basel','Hala','Yazan'}
    r91_demo_names={'Kareem','Rami','Lina','Samar','Layla','Jameel','Nour','Omar','Sara','Basel'}
    expected_demo_names=r91_demo_names if build>=210 else legacy_demo_names
    found_demo_names=set(re.findall(r"^\s*\['([^']+)'", demo_block, re.M))
    if found_demo_names!=expected_demo_names:
        fail(f'Expected {len(expected_demo_names)} non-admin server demo users, found {sorted(found_demo_names)}')
    if build>=210:
        req('docs/R9_1_DEMO_ACCOUNTS_AR_EN.md','Kareem123','Basel12345','Level 99','10 demo users')
    else:
        req('docs/DEMO_ACCOUNTS_V0.3_AR.md','Adnan123','Kareem123','Yazan12345')

    req('flutter_app/web/index.html','application/ld+json','VideoGame','og:title','twitter:card')
    req('flutter_app/web/robots.txt','Sitemap:')
    req('flutter_app/web/sitemap.xml','<urlset')
    print('[PASS] Warqnaa V0.3 store, home games, rooms, challenges, clubs, rewards, Banakil, anti-cheat, demo accounts and SEO contract')

if __name__=='__main__': main()
