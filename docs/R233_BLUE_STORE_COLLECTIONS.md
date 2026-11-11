# R233 — Accessible blue store collections in portrait (Issue #204)

## Existing implementation
`R20StoreCollections` already browses the authorized `products` catalog and uses `controller.isStoreProductVisible` and `isOwnedActiveV176` to filter inventory. Its preview flow delegates to `showProductPreview` and does not grant coins or entitlements.

Before this change, the grid always used two columns below 600px, including narrow 320px phones. Some icon/border accents followed arbitrary theme primary colors, and the outer screen-reader label had no direct semantic tap action.

## Change
- A **single full-width collection card below 360 logical pixels**; two columns at 360–599px; existing 3/6 columns retained for larger layouts.
- Preserve the original dark-blue store panel, with Warqnaa azure/sky borders, icons and header for consistent light/dark presentation.
- Expose a localized collection summary and a direct accessibility tap action; exclude duplicate child semantics while keeping the existing InkWell and product-preview behavior.
- Keep natural RTL/LTR order, including the directional arrow, without copying any third-party layout, assets, logos or text.

## Files
- `flutter_app/lib/r10_1_release.dart`
- `flutter_app/test/r233_store_collections_portrait_blue_test.dart` — 9 widget cases: Arabic/English × sky light/ocean dark × portrait 320/390, plus 844×390 landscape.
- `docs/R233_BLUE_STORE_COLLECTIONS.md`

## Invariants and verification
No modifications to gameplay rules, server authority, networking, wallet/ledger, prices, purchase settlement, inventory, permissions or hidden information. The existing `r20_store_collections_test.dart` remains an important regression test for catalog browsing without purchases.

CI must complete all five gates (Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime, Production Release) **on one final HEAD**. Draft only; no merge until clean and visual review. No third-party imagery or source copied.
