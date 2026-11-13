# R240 — Discover the full original Warqnaa bot roster

## Existing implementation and issue

`BotRosterShowcase` in `flutter_app/lib/premium_v149.dart` already renders original Arabic/English bot identities in a blue-themed responsive grid, but its `itemCount` was capped at two rows (`columns * 2`). On a portrait phone, only four of the fourteen existing bot profiles were discoverable; the rest were silently omitted from this showcase.

## Focused change

- Preserve the initial two-row preview and its responsive 2/4/6-column layout.
- Add a localized **Show all players (N)** / **عرض جميع اللاعبين (N)** control when more profiles exist, and a reversible **Show fewer** / **عرض أقل** action.
- Keep the control in Warqnaa's original cyan-on-dark / deep-blue-on-light palette, with a minimum 48×48 touch target and normal button semantics.
- Keep existing bot identities, avatar artwork, levels, difficulty and play decisions unchanged.
- No engine, authoritative game state, networking, economy, purchase or permissions code changed.

## Verification

`flutter_app/test/r240_bot_roster_discovery_test.dart` adds 9 widget scenarios: RTL Arabic / LTR English × 320/390 portrait × light/dark blue theme, including expanding and collapsing the complete six-profile test roster, stable direction, original blue panel, button contrast, and the no-extra-items case. Existing `r19_avatar_bot_stage_test.dart` remains valid because the default preview is still four cards on narrow phones.

CI requirements before merge: Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime and Production Release must all pass on one identical HEAD; confirm conflict-free mergeability and conduct a human visual review. Screenshots were not captured locally in this change. No copyrighted Jawaker assets, layouts, code or audio are used.
