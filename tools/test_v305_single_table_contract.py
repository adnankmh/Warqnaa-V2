#!/usr/bin/env python3
from pathlib import Path
import json,sys
ROOT=Path(__file__).resolve().parents[1]
def text(rel): return (ROOT/rel).read_text(encoding='utf-8',errors='ignore')
def ok(c,m):
    if not c: print('[FAIL]',m); sys.exit(1)
    print('[PASS]',m)
meta=json.loads(text('RELEASE_VERSION.json'))
ok(meta.get('full')=='1.3.1+305','release is 1.3.1+305')
main=text('flutter_app/lib/main.dart'); v305=text('flutter_app/lib/v305_single_table.dart')
ok("part 'v305_single_table.dart';" in main,'V305 Flutter module is wired')
ok("v305CustomerTableIds = <String>{v305PremiumTableId}" in v305,'exactly one customer table identity is permitted')
ok(v305.count("category:'tables'")==1 and v305.count("category:'cards'")==1,'exactly one V305 table and one card back product exist')
ok("price:0" in v305 and "Color(0xff073b2b)" in v305 and "Color(0xffb8893e)" in v305,'single table is free dark emerald with wood/gold edge palette')
ok("if (product.category == 'tables') return v305CustomerTableIds.contains(product.id);" in main,'Flutter hides every legacy table')
ok("if (product.category == 'cards') return product.id == v305CardBackId;" in main,'Flutter hides every legacy card back')
ok("selectedTable = v305PremiumTableId" in main and "selectedCardBack = v305CardBackId" in main,'legacy selections normalize to V305 defaults')
store=text('backend-laravel/app/Services/WarqnaPro/StoreCatalogService.php')
ok('syncV305SingleTable' in store and "'key'=>'v305_table_emerald_royal'" in store and "'price'=>0" in store,'Laravel V305 final store sync is authoritative')
ok("where('category','table')->update(['active'=>false" in store and "where('category','card_back')->update(['active'=>false" in store,'Laravel deactivates every legacy table/card back before V305 upsert')
challenge=text('backend-laravel/app/Services/WarqnaPro/ChallengeRoadService.php')
ok('b304_table_phoenix' not in challenge and 'b304_table_aurora' not in challenge,'challenge road cannot reactivate removed tables')
xp=text('backend-laravel/app/Services/Leveling/XpService.php')
ok('b304_table_aurora' not in xp and 'b304_table_emerald' not in xp,'level-up rewards cannot reactivate removed tables')
reward_services = {
    'lucky wheel': text('backend-laravel/app/Services/WarqnaPro/LuckyWheelService.php'),
    'prize boxes': text('backend-laravel/app/Services/WarqnaPro/PrizeBoxService.php'),
    'daily packs': text('backend-laravel/app/Services/WarqnaPro/DailyPackService.php'),
}
for label, source in reward_services.items():
    ok("'type'=>'table'" not in source and 'table_v173_royal_01' not in source and 'table_v173_showcase_01' not in source, f'{label} cannot award removed legacy tables')

print('V305 SINGLE TABLE CONTRACT: PASS')
