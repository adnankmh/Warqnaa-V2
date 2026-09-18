#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def need(rel,*tokens):
    p=ROOT/rel
    if not p.is_file(): raise SystemExit(f'[FAIL] missing {rel}')
    t=p.read_text(encoding='utf-8')
    for token in tokens:
        if token not in t: raise SystemExit(f'[FAIL] {rel}: missing {token}')
    print(f'[PASS] {rel}')
    return t

main=need('flutter_app/lib/main.dart',"part 'b307_visual_revolution.dart';",'B307TopBar(controller: controller)','B307BottomNavigation(','B307HomeDashboard(controller: controller','B307RealMoneyStoreBanner(controller: widget.controller)')
need('flutter_app/lib/b307_visual_revolution.dart','class B307TopBar','class B307HomeDashboard','class B307CashShopPage','class B307BottomNavigation')
need('backend-laravel/public/assets/css/b307-cardroom-ui.css','aspect-ratio:0.72','@media (orientation:landscape)','b307-shop')
need('backend-laravel/resources/views/store/offers.blade.php','b307-offer-grid','إتمام الشراء','مزود الدفع')
need('backend-laravel/routes/web.php',"Route::get('/offers',[StoreController::class,'offers'])->name('store.offers')")
need('backend-laravel/app/Http/Controllers/StoreController.php','public function offers(CommerceCatalogService $commerce)')
# Critical auth regression: online failure must never manufacture a new local account.
needle="return 'تعذر الاتصال بالخادم. لم يتم إنشاء حساب محلي جديد. تأكد من عنوان API أو استخدم وضع Offline فقط لحساب محفوظ مسبقًا.';"
if needle not in main: raise SystemExit('[FAIL] online login still allows unsafe local-account manufacture')
print('[PASS] server-login fallback no longer creates empty local accounts')
need('flutter_app/lib/main.dart','DeviceOrientation.portraitUp','DeviceOrientation.landscapeLeft','DeviceOrientation.landscapeRight')
print('B307 VISUAL + RUNTIME CONTRACT: PASS')
