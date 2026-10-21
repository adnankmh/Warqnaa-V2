# XP Booster naming — «معزز النقاط» / “XP Boosters”

The Flutter store, rewards and toast, admin studio, Laravel web store and backend catalogue all use the approved Arabic name «معزز النقاط». Individual items retain colors (for example «معزز النقاط الذهبي ×5»). English category remains exactly “XP Boosters”; individual English product names remain unchanged.

Internal keys `boost` and `xp_booster`, the seven SKUs, prices, inventory, timers, expiry, XP multipliers and role permissions remain unchanged. The backend's existing catalog sync updates the built-in Arabic titles in existing catalogue rows; admin-authored overrides remain custom intentionally.

An existing R44 ownership test expected the second rather than the first stock card. The corrected assertion reflects `array_shift` while retaining all cross-team layoff and card conservation checks.

Regression: `flutter_app/test/r64_booster_names_test.dart` and `backend-laravel/tests/Unit/R64BoosterLocalizationTest.php`, plus R44. All five exact-head GitHub Actions gates must pass prior to merge.
