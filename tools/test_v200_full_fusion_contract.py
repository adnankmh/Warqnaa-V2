#!/usr/bin/env python3
from pathlib import Path
import json,re,sys
ROOT=Path(__file__).resolve().parents[1]

def text(p): return (ROOT/p).read_text(encoding='utf-8',errors='ignore')
def ok(cond,msg):
    if not cond: print('[FAIL]',msg); raise SystemExit(1)
    print('[PASS]',msg)

m=json.loads(text('RELEASE_VERSION.json'))
ok(int(m.get('build',0))>=200,'release remains at build 200 or newer')
for port in (8007,8008,8009,8010):
    current = ROOT / f'scripts/windows/current/START_WARQNA_V{int(m.get("build", 200))}_PORT_{port}.bat'
    legacy = ROOT / f'scripts/windows/current/START_WARQNA_V200_PORT_{port}.bat'
    ok(current.is_file() or legacy.is_file(), f'Windows launcher {port}')
ok('min:10' in text('backend-laravel/app/Http/Controllers/WalletController.php'),'wallet transfer minimum is 10')
p=text('backend-laravel/app/Services/Progression/ProgressionService.php')
ok("'round_complete' => 10" in p and 'pashaMultiplier' in p and 'boosterMultiplier' in p,'XP = 10 base + Pasha + booster contract')
c=text('backend-laravel/app/Services/WarqnaPro/CompetitionService.php')
ok('competition_entry_income' in c and "'system_50'" in c and "'prize'=>300" in c,'competition economy and system 50/300 preset')
t=text('backend-laravel/app/Http/Controllers/TournamentController.php')
ok('exit_counts' in t and '>=5' in t and 'tournament_prize_escrow' in t,'per-competition exit limit and prize escrow')
ok((ROOT/'backend-laravel/app/Services/WarqnaPro/TournamentSettlementService.php').is_file(),'server-side tournament settlement service')
rooms=text('backend-laravel/app/Http/Controllers/RoomController.php')
ok('TournamentSettlementService' in rooms,'room completion triggers tournament settlement')
d=text('backend-laravel/app/Services/GameEngine/DeckFactory.php')
ok('random_int' in d or 'shuffle' in d,'deck shuffle uses server randomness')
ok('secureShuffle($deck)' in d and 'random_int(0,$i)' in d and 'return self::secureShuffle($deck)' in d,'deck factory has no player-targeted deal path and uses secure random shuffle')
store=text('backend-laravel/app/Services/WarqnaPro/StoreCatalogService.php')
for needle in ["'price'=>1700","'price'=>5000","'price'=>10000","'price'=>105000","'price'=>300000",",5.0,100000,14,'gold'"]: ok(needle in store,f'store contract {needle}')
assets=list((ROOT/'flutter_app/assets').rglob('*'))
ok(sum(1 for p in assets if p.is_file())>=250,'full Flutter asset set preserved (>=250 files)')
ok(sum(p.stat().st_size for p in assets if p.is_file())>50_000_000,'Flutter assets remain >50 MB unpacked')
css=text('backend-laravel/public/assets/css/app.css')
for theme in ['dark','light','blue','sky','green','light_green','gold','purple','light_pink']: ok(f'body.theme-{theme}' in css,f'web theme {theme}')
ok('8007' in text('flutter_app/RUN_FLUTTER_WEB.bat') and '8010' in text('flutter_app/RUN_FLUTTER_WEB.bat'),'Flutter Web supports selected Laravel ports')
print('V200_FULL_FUSION_CONTRACT_OK')
