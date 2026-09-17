#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def text(rel):
    p=ROOT/rel
    assert p.is_file(), f"missing {rel}"
    return p.read_text(encoding='utf-8')

def need(rel,*needles):
    s=text(rel)
    for n in needles:
        assert n in s, f"missing {n!r} in {rel}"

need('backend-laravel/app/Services/Admin/PrimaryAdminStateService.php','LEVEL = 99','PASHA_DAYS = 36500','TOKEN_RESERVE = 9000000000000000000','GEMS = 100000000')
need('backend-laravel/app/Console/Commands/SetupLocalAdmins.php','DUAL_PRIMARY_ADMIN_SETUP_OK',"'admin_role'=>'primary_admin'",'999999')
need('backend-laravel/app/Http/Controllers/AuthController.php','PrimaryAdminStateService::class')
need('backend-laravel/app/Http/Controllers/MobileApiController.php','PrimaryAdminStateService::class')
need('backend-laravel/app/Models/User.php','$effectiveLevel','$effectivePashaDays')
need('flutter_app/lib/main.dart',"if (isPrimaryAdmin)","BigInt.parse('9000000000000000000')",'vipDays = math.max(vipDays, 36500)','Warqnaa Command Center')
need('backend-laravel/public/assets/css/b306-app-parity.css','.b306-admin-identity','.admin-tabs.jumbo-tabs','body.warqna-b304 .topbar')
need('backend-laravel/resources/views/layouts/app.blade.php','b306-app-parity.css')
need('backend-laravel/resources/views/admin/index.blade.php','b306-admin-identity','adminEffectiveLevel','adminEffectivePasha')
print('[PASS] B305 R10 dual primary-admin state + unified web/app admin UI contract')
