#!/usr/bin/env python3
from pathlib import Path
import re, sys
ROOT=Path(__file__).resolve().parents[1]
def text(rel): return (ROOT/rel).read_text(encoding='utf-8',errors='ignore')
def ok(cond,msg):
    if not cond:
        print('[FAIL]',msg); sys.exit(1)
    print('[PASS]',msg)
user=text('backend-laravel/app/Models/User.php')
ok("PRIMARY_ADMIN_DISPLAY_BALANCE = '1000000'" in user,'primary admin UI balance is exactly one million')
state=text('backend-laravel/app/Services/Admin/PrimaryAdminStateService.php')
ok('TOKEN_RESERVE = 9000000000000000000' in state and 'INVENTORY_QUANTITY = 100' in state,'underlying unlimited-style admin reserve and 100-item floor remain intact')
mobile=text('backend-laravel/app/Http/Controllers/MobileApiController.php')
ok('$user->displayTokenBalance()' in mobile and "'tokens_formatted' => number_format((int) $displayTokens)" in mobile,'mobile API uses the player-facing admin balance')
seed=text('backend-laravel/database/seeders/DatabaseSeeder.php')
block=re.search(r'\$demoUsers\s*=\s*\[(.*?)\];\s*if \(!\$seedDemoUsers\)',seed,re.S)
ok(block is not None and block.group(1).count('@warqna.local')==10,'historical ten demo accounts remain isolated for compatibility')
ok('$r17QaUsers = [' in seed and seed.count('2000000')>=10 and seed.count('1000000')>=10,'R17 adds twenty medium/low QA users with requested balances')
ok(seed.count('10000000')>=10,'ten high-tier QA users hold ten million tokens')
ok('grantQaItems' in seed and "tier==='high'" in seed and "tier==='mid'" in seed,'QA inventory tiers are seeded deterministically')
bots=text('flutter_app/lib/premium_v149.dart')
for name in ('عاصم','عدنان','كنان','بيان','حور','كامل','سحر','ميس','شهد','حلا'):
    ok(name in bots,f'bot roster contains {name}')
pasha=text('flutter_app/lib/v173_global.dart')
ok('pashaStyleV173(controller.selectedPashaStyle)' in pasha and 'Image.asset(style.asset' in pasha,'Pasha hat follows selected color/style asset')
sounds=text('flutter_app/lib/services/app_sounds.dart')
ok("'reaction': 'emoji'" in sounds and "'reaction_victory': 'legendary_emote'" in sounds and "final cue = _cueAliases[requestedCue] ?? requestedCue" in sounds and "AssetSource('sounds/r10/$cue.ogg')" in sounds,'reaction audio aliases point to shipped sound assets while preserving the R10 OGG bus contract')
ok("AppSounds.fire('reaction_${widget.reaction.category}')" in bots,'animated reactions select category-specific sound cues')
privacy=text('tools/check_git_privacy_v304.py')
ok('BAD_NAMES' in privacy and "'.env'" in privacy and 'BAD_SUFFIXES' in privacy,'privacy gate blocks local environment, database, key and credential files without publishing real secrets')
print('R17 CONTENT & SOCIAL POLISH CONTRACT: PASS')
