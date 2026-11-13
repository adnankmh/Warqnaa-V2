# R238 — Accessible bilingual pack inventory in Warqnaa Blue

Issue: #204. Baseline main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.

## Existing implementation
`PackInventoryStripV176` already showed up to four server/local reward records with active/expired status, color-coded borders and a store inventory action. It hard-coded Arabic labels and used a single-row heading that could crowd narrow portrait screens.

## Scope
- Localize heading, help, inventory action, reward labels and display-only status to Arabic RTL / English LTR.
- Stack heading and action at narrow widths, preserving the horizontal reward strip and original theme-derived blue palette.
- Provide a single screen-reader label per reward, combining name and status without duplicated icon/text announcements.
- Preserve reward ownership, expiry checks, server ledger, purchase actions and all existing keys/colors.

## Verification
- `flutter test test/r238_pack_inventory_accessibility_test.dart`
- `flutter test test/r130_pack_inventory_theme_test.dart`
- Matrix: 320/390 portrait, RTL/LTR, light/dark blue themes; checks semantics, text, navigation callback, theme colors and overflow.
- Five GitHub gates (Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime, Production Release) must succeed on the same PR HEAD before merge.
- No screenshots or visual approval claimed until captured and reviewed. No third-party assets used.
