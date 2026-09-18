#!/usr/bin/env python3
from pathlib import Path
import json,sys
ROOT=Path(__file__).resolve().parents[1]
def text(rel): return (ROOT/rel).read_text(encoding='utf-8',errors='ignore')
def ok(c,m):
    if not c: print('[FAIL]',m); sys.exit(1)
    print('[PASS]',m)
meta=json.loads(text('RELEASE_VERSION.json'))
ok(int(meta.get('build',0))>=610,'current release preserves the R6.1 curated-table baseline')
main=text('flutter_app/lib/main.dart'); v305=text('flutter_app/lib/v305_single_table.dart'); r61=text('flutter_app/lib/r6_1_world_class.dart')
ok("part 'v305_single_table.dart';" in main,'V305 Flutter module is wired')
ok("v305CustomerTableIds = <String>{v305PremiumTableId}" in v305,'exactly one customer table identity is permitted')
ok(v305.count("category:'tables'")==1 and v305.count("category:'cards'")==1,'exactly one V305 table and one card back product exist')
ok("price:0" in v305 and "Color(0xff073b2b)" in v305 and "Color(0xffb8893e)" in v305,'single table is free dark emerald with wood/gold edge palette')
ok("part 'r6_1_world_class.dart';" in main and 'warqnaaR61MultiTableStore = true' in r61,'R6.1 multi-table successor is wired')
ok("product.id.startsWith('table_v173_')" in r61 and 'buildR61PairedCardBacks' in r61,'Flutter exposes curated V173 tables and paired backs')
ok('isR61SelectableTableId(selectedTable)' in main and 'isR61SelectableCardBackId(selectedCardBack)' in main,'saved selections validate against the R6.1 curated catalog')
store=text('backend-laravel/app/Services/WarqnaPro/StoreCatalogService.php')
ok('syncR61CuratedTablesAndCardBacks' in store and "'key'=>'v305_table_emerald_royal'" in store and "'price'=>0" in store,'Laravel R6.1 catalog keeps the free V305 starter table')
ok('r61PairedCardBacks' in store and "'paired_table'=>$tableKey" in store,'Laravel generates one matching card back per curated table')
ok("where('category','table')->update(['active'=>false" in store and "where('category','card_back')->update(['active'=>false" in store,'Laravel resets legacy table/card visibility before the curated R6.1 upsert')
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

print('R6.1 CURATED TABLE SUCCESSOR CONTRACT: PASS')
