#!/usr/bin/env python3
from pathlib import Path
root=Path(__file__).resolve().parents[1]
def text(rel): return (root/rel).read_text(encoding='utf-8')
assert "9000000000000000000" in text('backend-laravel/tests/Feature/V142MobileRealEnginesSocialEconomyTest.php')
v161=text('backend-laravel/tests/Feature/V161VoiceSocialProgressionTest.php')
assert "$this->assertSame(20, $first['xp']);" in v161
assert "storage_path('framework/views')" in text('backend-laravel/config/view.php')
assert "setUpBeforeClass" in text('backend-laravel/tests/TestCase.php') and "framework/views" in text('backend-laravel/tests/TestCase.php')
ci=text('.github/workflows/backend-ci.yml')
assert 'mkdir -p storage/framework/views' in ci
store=text('backend-laravel/app/Services/WarqnaPro/StoreCatalogService.php')
for needle in ['v201R4Items','emoji_r4_legend_beasts','table_r4_phoenix','card_r4_nebula','name_r4_aurora','cover_r4_nebula','theme_r4_aurora']:
    assert needle in store, needle
assert "foreach(['fr','tr','de','es'] as $locale)" in store
view=text('backend-laravel/resources/views/store/index.blade.php')
assert "'profile_cover'=>'أغلفة البروفايل'" in view
assert "'competition_ticket'=>'تذاكر المنافسات'" in view
flutter=text('flutter_app/lib/main.dart')
assert 'buildV201R4StoreProducts' in flutter and 'r4_emoji_beasts' in flutter and 'r4_theme_aurora' in flutter
assert store.count("['emoji_r4_") >= 10
assert flutter.count("id:'r4_emoji_") >= 10
for needle in ['r4_table_celestial','r4_card_palestine','r4_name_diamond','r4_chat_violet','r4_badge_crown','r4_cover_palace','r4_frame_dragon']:
    assert needle in flutter, needle
policy=text('tools/validate_release.py')
assert 'LEGACY_UPGRADE_ROOT_ARTIFACTS' in policy
print('[PASS] V201 R4 CI cache, historical contracts, legendary store, translations and patch-root compatibility')
