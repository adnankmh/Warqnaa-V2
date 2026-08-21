#!/usr/bin/env python3
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[1]
def fail(msg): print('[FAIL] '+msg); raise SystemExit(1)
def ok(cond,msg):
    if not cond: fail(msg)
    print('[PASS] '+msg)
def txt(rel):
    p=ROOT/rel
    ok(p.is_file(), f'{rel} exists')
    return p.read_text(encoding='utf-8')
def has(rel,*needles):
    t=txt(rel)
    for n in needles: ok(n in t, f'{rel}: {n}')
    return t

def main():
    meta=json.loads((ROOT/'RELEASE_VERSION.json').read_text(encoding='utf-8'))
    ok(int(meta.get('build',0))>=210,'R9.1 feature foundation is preserved at build 210 or newer')
    xp=has('backend-laravel/config/warqna_xp_levels.php','80 => 4000000','89 => 7428796','90 => 9000000','95 => 15000000','98 => 19000000','99 => 20000000')
    dart=has('flutter_app/lib/v175_release.dart','80: 4000000','90: 9000000','95: 15000000','98: 19000000','99: 20000000')
    store=has('backend-laravel/app/Services/WarqnaPro/StoreCatalogService.php','grantPrimaryAdminAllCollectibles','grantPrimaryAdminItem',"'table'=>5.25","'card_back'=>3.50","'xp_booster'=>2.25", "if($category==='pasha') return $price;")
    seed=has('backend-laravel/database/seeders/DatabaseSeeder.php',"'level'=>99,'xp'=>193947651",'// R9.1: exactly 10 curated non-admin demo users')
    ok(seed.count("@warqna.local")>=10,'10 demo user accounts are seeded')
    admin=has('backend-laravel/app/Http/Controllers/AdminController.php','deleteStoreItem','purgeStoreItem','grantPrimaryAdminItem')
    routes=has('backend-laravel/routes/web.php',"admin.store.update","admin.store.delete","admin.store.purge")
    booster=has('flutter_app/lib/v183_overhaul.dart','class _BoosterPreviewV210State','_BoosterShieldClipperV210','_BoosterCircuitPainterV210','WARQNAA BOOST')
    rooms=has('backend-laravel/app/Http/Controllers/RoomController.php','manual_exit_counts',">= 5",'game_started')
    mobile=has('backend-laravel/app/Http/Controllers/MobileGameController.php','manual_exit_counts',">= 5")
    tarneeb=has('backend-laravel/app/Services/GameEngine/TarneebRules.php','last_played_by_player','seat_tricks','last_round_score_delta')
    ui=has('flutter_app/lib/main.dart','last_played_by_player','seat_tricks','last_round_score_delta')
    web=has('backend-laravel/resources/views/room/show.blade.php','lastPlayedByPlayer','seatTricks','lastRoundScoreDelta')
    road=has('backend-laravel/app/Services/WarqnaPro/ChallengeRoadService.php','10,12,15','ATTEMPTS = 5','challenge_road_match','min(1000')
    wheel=has('backend-laravel/app/Services/WarqnaPro/LuckyWheelService.php','store_item_key')
    tickets=has('flutter_app/lib/v183_overhaul.dart','Never paint a\n    // second number over the image')
    print('V210 R9.1 GAMEPLAY POLISH CONTRACT: PASS')
if __name__=='__main__': main()
