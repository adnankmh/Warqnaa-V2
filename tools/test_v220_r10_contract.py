#!/usr/bin/env python3
from __future__ import annotations
import hashlib, json, re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def fail(msg): print('[FAIL] '+msg); raise SystemExit(1)
def ok(cond,msg):
    if not cond: fail(msg)
    print('[PASS] '+msg)
def text(rel):
    p=ROOT/rel; ok(p.is_file(),f'{rel} exists'); return p.read_text(encoding='utf-8')

def declared_flutter_asset_bytes()->int:
    pub=text('flutter_app/pubspec.yaml')
    assets=[]; active=False
    for line in pub.splitlines():
        if line.strip()=='assets:': active=True; continue
        if active:
            if line.startswith('    - '): assets.append(line.split('- ',1)[1].strip())
            elif line and not line.startswith('    ') and not line.lstrip().startswith('#'): break
    total=0
    for rel in assets:
        p=ROOT/'flutter_app'/rel
        if p.is_file(): total+=p.stat().st_size
        elif p.is_dir(): total+=sum(x.stat().st_size for x in p.rglob('*') if x.is_file())
        else: fail(f'declared Flutter asset missing: {rel}')
    return total

def main():
    meta=json.loads(text('RELEASE_VERSION.json'))
    ok(int(meta.get('build',0))>=220,'current release preserves R10 build 220 or newer')
    pub=text('flutter_app/pubspec.yaml')
    ok('assets/optimized/r10/' in pub and 'assets/sounds/r10/' in pub,'Flutter ships R10 WebP/OGG derivative bundle')
    ok('assets/images/tables/' not in pub and 'assets/images/v02/prize_boxes/' not in pub and 'assets/images/v02/tickets/' not in pub,'heavy historical image directories are not packaged in Flutter')
    bundled=declared_flutter_asset_bytes()
    ok(bundled < 15*1024*1024,f'R10 declared Flutter visual/audio assets stay below 15 MiB ({bundled/1024/1024:.2f} MiB)')
    ok((ROOT/'flutter_app/assets/images/tables/reference/table_reference_01.png').is_file(),'historical source artwork is preserved outside the release bundle')
    ogg=list((ROOT/'flutter_app/assets/sounds/r10').glob('*.ogg'))
    ok(len(ogg)>=50,'R10 compressed OGG sound set is present')
    sound=text('flutter_app/lib/services/app_sounds.dart')
    ok("AssetSource('sounds/r10/$cue.ogg')" in sound and '.wav' not in re.search(r'AssetSource\([^\n]+',sound).group(0),'sound bus uses R10 OGG cues')

    manifest=json.loads(text('assets/manifest/r10_asset_manifest.json'))
    entries=manifest.get('entries',[])
    ok(manifest.get('build')==220 and len(entries)>=200,'R10 central asset manifest is versioned and comprehensive')
    ok(sum(1 for e in entries if e.get('delivery')=='ondemand')>=100,'R10 manifest classifies 100+ on-demand assets')
    for e in entries[:25]:
        p=ROOT/'flutter_app'/e['local_asset']
        ok(p.is_file(),f"manifest local asset exists: {e['local_asset']}")
        digest=hashlib.sha256(p.read_bytes()).hexdigest()
        ok(digest==e.get('sha256'),f"manifest SHA-256 matches: {e['id']}")

    service=text('flutter_app/lib/services/r10_asset_delivery.dart')
    for needle in ['class R10AssetDelivery','sha256.convert(bytes)','setDataSaver','thumbnailUrl','_memoryBudget','R10AssetImage']:
        ok(needle in service,f'Flutter asset delivery contains {needle}')
    main_dart=text('flutter_app/lib/main.dart')
    ok('R10AssetDelivery.instance.restore()' in main_dart and 'R10AssetDelivery.instance.refresh(api, bootstrap: data)' in main_dart,'Flutter restores and refreshes R10 manifest without blocking core gameplay')
    ok('توفير البيانات' in main_dart and 'R10 Asset Delivery' in main_dart,'Data Saver and asset status are exposed in settings')

    backend=text('backend-laravel/app/Services/WarqnaPro/AssetDeliveryService.php')
    for needle in ['cdn_enabled','manifest_url','thumbnail_url','Cache-Control']:
        if needle=='Cache-Control':
            ok(needle in text('backend-laravel/app/Http/Controllers/MobileAssetController.php'),'asset manifest has cache-control response')
        else: ok(needle in backend,f'Laravel asset service contains {needle}')
    routes=text('backend-laravel/routes/api.php')
    ok("Route::get('/assets/manifest'" in routes,'public mobile asset-manifest endpoint exists')
    api=text('backend-laravel/app/Http/Controllers/MobileApiController.php')
    ok("'asset_delivery' => $assetDelivery->summary()" in api and "'locale' => 'nullable|in:ar,en" in api,'bootstrap exposes R10 delivery and preserves ar/en in the profile locale validator')

    web_public=ROOT/'backend-laravel/public'
    web_bytes=sum(p.stat().st_size for p in web_public.rglob('*') if p.is_file())
    ok(web_bytes < 12*1024*1024,f'Laravel public runtime stays below 12 MiB ({web_bytes/1024/1024:.2f} MiB)')
    ok(not (web_public/'assets/store/tables/v173').exists() and not (web_public/'assets/store/pasha/v173').exists(),'superseded heavy V173 web originals are removed from public runtime')
    catalog_text=text('backend-laravel/resources/data/v173_store_catalog.json')
    catalog_data=json.loads(catalog_text)
    image_values=[str(item.get('image','')) for item in catalog_data if isinstance(item,dict)]
    ok(image_values and all('/assets/r10/store/' in value and value.endswith('.webp') for value in image_values if value),'web store catalog image URLs use R10 WebP paths')
    ht=text('backend-laravel/public/.htaccess')
    ok('BROTLI_COMPRESS' in ht and 'DEFLATE' in ht and 'immutable' in ht,'Apache compression and immutable asset caching hints exist')

    stage=text('tools/r10_stage_cdn.py')
    ok('copy_verified' in stage and 'warqnaa/r10/manifest.json' in stage and 'R10_CDN_DEPLOY_INFO.json' in stage,'R10 deterministic CDN staging tool exists')
    cdn_doc=text('docs/ar/deployment/R10_CDN_SETUP_AR.md')
    ok('WARQNA_ASSET_MODE=hybrid' in cdn_doc and 'max-age=31536000' in cdn_doc,'R10 CDN deployment guide documents hybrid fallback and immutable caching')
    readme=text('README.md')
    ok(('0.5.0+220' in readme or '0.5.1+221' in readme) and '12.7 MiB' in readme,'root README preserves R10 compact asset-delivery documentation')

    for port in (8007,8008,8009,8010):
        ok((ROOT/f'scripts/windows/current/START_WARQNA_R10_PORT_{port}.bat').is_file(),f'R10 launcher alias {port} exists')
    for wf in ['backend-ci.yml','production-release-check.yml','flutter-android.yml','flutter-ios.yml','flutter-web-pages.yml']:
        ok('test_v220_r10_contract.py' in text('.github/workflows/'+wf),f'R10 contract wired into {wf}')
    print('V220 R10 ASSET DELIVERY & SIZE REVOLUTION CONTRACT: PASS')
if __name__=='__main__': main()
