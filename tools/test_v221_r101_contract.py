#!/usr/bin/env python3
from __future__ import annotations
import json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def fail(msg): print('[FAIL] '+msg); raise SystemExit(1)
def ok(cond,msg):
    if not cond: fail(msg)
    print('[PASS] '+msg)
def text(rel):
    p=ROOT/rel; ok(p.is_file(),f'{rel} exists'); return p.read_text(encoding='utf-8')

def main():
    meta=json.loads(text('RELEASE_VERSION.json'))
    ok(meta.get('full')=='0.5.1+221' and int(meta.get('build',0))==221,'R10.1 release metadata is 0.5.1+221')
    pub=text('flutter_app/pubspec.yaml')
    ok('version: 0.5.1+221' in pub and 'assets/optimized/r101/' in pub,'Flutter packages R10.1 build and original game-cover bundle')
    main=text('flutter_app/lib/main.dart')
    r101=text('flutter_app/lib/r10_1_release.dart')
    ok("part 'r10_1_release.dart';" in main and 'r101Theme(controller.themeCode' in main,'R10.1 release module and full theme are wired')
    ok('customerGamesR101' in main and 'gamesCatalog.where((game) => !game.serverOnly)' in r101,'server-only games are hidden from customer Flutter catalogs')
    game_catalog=text('backend-laravel/app/Services/Games/GameCatalog.php')
    game_controller=text('backend-laravel/app/Http/Controllers/GameController.php')
    mobile_game=text('backend-laravel/app/Http/Controllers/MobileGameController.php')
    mobile_api=text('backend-laravel/app/Http/Controllers/MobileApiController.php')
    tournaments=text('backend-laravel/app/Http/Controllers/TournamentController.php')
    ok('customerKeys' in game_catalog and 'isCustomerVisible' in game_catalog,'Laravel has a canonical customer-visible game allowlist')
    ok("whereIn('key', GameCatalog::customerKeys())" in game_controller and 'if($isNew) $game->active=true' in game_controller,'web hides server-only games and preserves GUI admin deactivation')
    ok('only(GameCatalog::customerKeys())' in mobile_game and 'GameCatalog::isCustomerVisible($gameKey)' in mobile_game,'mobile room/rules catalog hides server-only games')
    ok("whereIn('key', GameCatalog::customerKeys())" in mobile_api and "whereIn('key', GameCatalog::customerKeys())" in tournaments,'bootstrap and tournament pickers hide server-only games')
    ok(len(list((ROOT/'flutter_app/assets/optimized/r101/games').glob('*.webp')))>=18,'18 modern Flutter game covers exist')
    ok(len(list((ROOT/'backend-laravel/public/assets/r101/games').glob('*.webp')))>=18,'18 modern web game covers exist')
    ok("String r101GameArtAsset(String gameId) => 'assets/optimized/r101/games/$gameId.webp';" in r101,'all Flutter game cards use per-game R10.1 artwork mapping')

    r9=text('flutter_app/lib/r9_release.dart')
    ok('FractionallySizedBox' in r9 and 'BoxFit.contain' in r9 and "portrait ? .70 : .62" in r9,'table preview uses proportional portrait/landscape artwork inlay')
    ok('has-table-art' in text('backend-laravel/resources/views/room/show.blade.php') and '--r101-table-art' in text('backend-laravel/resources/views/room/show.blade.php'),'web room table uses proportional artwork variable instead of cover stretch')
    css=text('backend-laravel/public/assets/css/r10-1-experience.css')
    ok('.game-table.has-table-art::after' in css and 'background-size:contain' in css and 'aspect-ratio:10/16' in css and 'aspect-ratio:16/9' in css,'R10.1 CSS enforces phone portrait and desktop/landscape table geometry')

    for code in ['dark','light','green','gold','purple','classic']:
        ok(f"'{code}': R101ThemeSpec" in r101,f'Flutter full theme {code} exists')
        ok(f'.theme-{code}' in css,f'Web full theme {code} exists')
    ok('inputDecorationTheme:' in r101 and 'filledButtonTheme:' in r101 and 'outlinedButtonTheme:' in r101 and 'chipTheme:' in r101,'theme recolors controls, buttons, inputs and chips')

    settings=text('backend-laravel/resources/views/pages/settings.blade.php')
    ok('r101AvatarPreview' in settings and 'URL.createObjectURL(file)' in settings and 'r101-avatar-stage' in settings,'web avatar has circular live preview before save')
    crop=text('flutter_app/lib/premium_v149.dart')
    ok('borderRadius: BorderRadius.circular(viewport / 2)' in crop and "'Use photo'" in crop,'Flutter avatar crop uses circular bilingual preview')
    ok("'lang'=>'nullable|string|in:ar,en'" in text('backend-laravel/app/Http/Controllers/PageController.php'),'web quick locale is Arabic/English only')
    catalog=text('backend-laravel/app/Services/Games/GameCatalog.php')
    translations=catalog[catalog.index('public static function translations'):]
    ok("'ar'=>self::rules($key)" in translations and "'en'=>$en" in translations and "'tr'=>" not in translations and "'fr'=>" not in translations,'current game-rule translations are Arabic/English only')

    commerce_cfg=text('backend-laravel/config/warqna_commerce.php')
    ok("'sandbox' => env('WARQNAA_COMMERCE_SANDBOX', false)" in commerce_cfg,'commerce sandbox is opt-in and defaults off')
    ok("'during_match' => false" in commerce_cfg and "'offer_cadences' => ['daily','weekly','monthly','annual']" in commerce_cfg,'ads never run during matches and all offer cadences exist')
    verifier=text('backend-laravel/app/Services/Commerce/ReceiptVerificationService.php')
    ok('provider_verifier_not_configured' in verifier and "str_starts_with($receiptToken,'sandbox:')" in verifier,'real-money rewards require server receipt verification')
    mobile=text('backend-laravel/app/Http/Controllers/MobileCommerceController.php')
    ok("'credited_tokens'=>$receipt->status==='verified'" in mobile and 'real_money_token_purchase' in mobile,'tokens are credited only after verified receipt')
    routes=text('backend-laravel/routes/api.php')
    ok("/commerce/catalog" in routes and "/commerce/verify-receipt" in routes,'mobile commerce catalog and verification APIs exist')
    api=text('flutter_app/lib/services/api_client.dart')
    ok('commerceCatalogR101' in api and 'verifyCommerceReceiptR101' in api and "defaultValue: '0.5.1'" in api and 'defaultValue: 221' in api,'Flutter API client is ready for server commerce verification')

    ads=text('flutter_app/lib/services/interstitial_ads_mobile.dart')
    ok('_lastShown' in ads and 'now.difference(_lastShown!).inMinutes < minMinutes' in ads,'interstitial ads enforce spacing')
    rewards=text('flutter_app/lib/v182_rewards.dart')
    ok('InterstitialAds.showIfEligible(minMinutes: 12)' in rewards,'interstitial can appear only after explicit game exit')
    ok(rewards.count("'key':")>=12 and 'الدولاب يحتوي 12 جائزة' in rewards,'Flutter wheel exposes 12 varied rewards')
    backend_wheel=text('backend-laravel/app/Services/WarqnaPro/LuckyWheelService.php')
    ok(backend_wheel.count("['key'=>")==12 and "'tokens_900'" in backend_wheel and "'ticket_1000'" in backend_wheel,'server wheel mirrors 12 authorized rewards')

    admin=text('backend-laravel/resources/views/admin/index.blade.php')
    ok('data-admin-tab="commerce"' in admin and 'id="admin-commerce"' in admin and 'Rewarded Ads' in admin and 'Interstitial' in admin,'admin command center exposes commerce and ads GUI')
    web_routes=text('backend-laravel/routes/web.php')
    ok('admin.commerce.settings' in web_routes and 'admin.commerce.offer.save' in web_routes and 'admin.commerce.offer.delete' in web_routes,'admin commerce GUI routes are wired')
    store=text('backend-laravel/resources/views/store/index.blade.php')
    ok('r101-web-commerce' in store and 'Receipt verified' in store,'web store mirrors R10.1 commerce experience')
    layout=text('backend-laravel/resources/views/layouts/app.blade.php')
    ok('r10-1-experience.css' in layout and 'data-theme-pick="classic"' in layout,'web loads R10.1 visual system and six-theme picker')

    for wf in ['backend-ci.yml','production-release-check.yml','flutter-android.yml','flutter-ios.yml','flutter-web-pages.yml']:
        ok('test_v221_r101_contract.py' in text('.github/workflows/'+wf),f'R10.1 contract wired into {wf}')
    print('V221 R10.1 COMMERCE & VISUAL EXPERIENCE CONTRACT: PASS')

if __name__=='__main__': main()
