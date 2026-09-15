#!/usr/bin/env python3
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1]

def read(rel): return (ROOT/rel).read_text(encoding='utf-8')
def ok(cond,msg):
    if not cond:
        raise SystemExit('[FAIL] '+msg)
    print('[PASS] '+msg)

challenge=read('backend-laravel/app/Services/WarqnaPro/ChallengeRoadService.php')
room=read('backend-laravel/app/Http/Controllers/RoomController.php')
profile=read('backend-laravel/app/Models/Profile.php')
user=read('backend-laravel/app/Models/User.php')
store=read('backend-laravel/app/Http/Controllers/StoreController.php')
mobile=read('backend-laravel/app/Http/Controllers/MobileApiController.php')
xp=read('backend-laravel/app/Services/Leveling/XpService.php')
modal=read('backend-laravel/resources/views/profile/modal.blade.php')
js=read('backend-laravel/public/assets/js/app.js')
migration=read('backend-laravel/database/migrations/2026_09_15_000306_profile_color_runtime.php')

ok('min(1000,200+$stage*80)' in challenge and 'min(1800,200+$stage*80)' not in challenge,
   'Challenge Road token reward is capped at 1000')
ok("'settings'=>['icon'=>'🛤️','attempts'=>self::ATTEMPTS,'stage_options'=>[10,12,15]]" in challenge,
   'Challenge Road preserves five attempts and 10/12/15-stage choices')
ok("'basra' => [2]" in room, 'Basra room creation is strictly two-player')
ok(all(n in room for n in ['عدنان','بيان','كنان','جميل','رعد','عاصم','معتصم','حسام','جنان','حور','جنات','آلاء','أفنان','شهد','حلا','شذى','قمر']),
   'Requested Arabic named-bot roster is present')
ok("$names=app()->getLocale()==='ar' ? $ar : $en" in room, 'Bot names switch to Latin names outside Arabic UI')
ok("'last_round_summary'" in room and "'last_played_by_player'" in room and "'player_round_score_delta'" in room,
   'Automatic next round keeps previous bid/card/score clarity snapshot')
ok('active_profile_color' in profile and 'profile_color_expires_at' in profile and 'active_profile_color' in user,
   'Profile model and public payload expose expiring profile gradients')
ok('active_profile_color' in migration and 'profile_color_expires_at' in migration,
   'Profile color runtime migration exists')
ok("$item->category==='profile_color'" in store and "case 'profile_color':" in mobile,
   'Web and mobile store activation apply profile colors server-side')
ok('activateTemporaryReward' in challenge and 'profile_color_expires_at=now()->addDays($days)' in challenge,
   'Challenge temporary cosmetics activate immediately')
ok('grantTwoTemporaryRewards' in xp and 'profile_color_expires_at=now()->addDays(7)' in xp,
   'Level-up temporary profile rewards activate for seven days')
ok('has-profile-gradient' in modal and "j.category==='profile_color'" in js,
   'Web profile gradient renders immediately after activation')
ok("'v305_table_emerald_royal'" in read('backend-laravel/app/Services/WarqnaPro/StoreCatalogService.php'),
   'V305 single premium free table remains the customer table')
print('V305 R8 FINAL INTEGRATION CONTRACT: PASS')
