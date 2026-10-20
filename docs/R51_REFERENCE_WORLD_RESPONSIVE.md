# R51 — Screenshot-guided premium dashboard layout

Base: R50 merged main `01efdfbe16b6453dde3edda635644498447bd41f`. Source art reference: user's approved Warqnaa blue/gold desktop and mobile UI board.

## Implementation (Flutter Android and Web)

- Preserve the championship hero, live game catalogue, tournament routes, clubs, profiles, store and all existing actions.
- Fix the 320–390px portrait squeeze: game cards and tournaments now appear as *stacked full-width* panels below 760px instead of being forced into a narrow desktop 11:7 split.
- Responsive game grid: two genuinely readable columns under 420px; three columns from 420px; four when the stacked panel reaches 610px; on larger viewports keep the classic side-by-side game/tournament layout with three or four columns as appropriate.
- Keep the existing source artwork, sky/cyan/royal-blue/gold identity, visible tournament CTA, accessibility touch targets, RTL Arabic and LTR English. No artificial pricing or reward claims and no modifications to private authoritative game state.
- Stable keys `r51-featured-stacked`, `r51-featured-wide`, and `r51-games-panel` make mobile layout behavior regression-testable.

## Verification

`flutter_app/test/r51_reference_world_responsive_test.dart` covers Arabic and English across 320×640, 390×844, 600×800, 844×390 and 1440×900, with column counts, artwork/hero presence, genuine tab callback and layout-exception checks.

R51 remains draft until all five exact-head CI gates pass, plus image review when available. GitHub Pages remains the static web demonstration; Laravel public multiplayer and commerce require deployed backend configuration.
