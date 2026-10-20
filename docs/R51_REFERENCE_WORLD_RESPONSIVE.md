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

## Actual Home route correction and visual evidence

The initial draft only tested `R35ReferenceWorldDashboard` in isolation. `B307HomeDashboard` still chose its old three-column game grid below 1024px, making the new phone layout unreachable. The game/tournament panel now lives in `R51FeaturedGamesAndTournaments`, used by both actual Home routes. The compact Home retains its account statistics, local administrator studio and authorization, world shortcuts, store previews, reactions, profile, bot practice and cash/wallet actions. No balance, inventory, pricing, admin privilege or game-rule behavior changes.

The regression suite now mounts `B307HomeDashboard`, checks geometry and readable physical card width, tests Arabic/English at five sizes with 1.0/1.4 text scaling, and opens actual Hand/Banakil friendly settings from the game cards. R7 executes this suite with real decoded artwork and fonts and captures games/tournament sections at all ten locale/size combinations (20 PNGs). Historical source wiring contracts follow the shared renderer and continue rejecting disconnected Home and practice routes. Backend multiplayer production hosting remains separate from static Pages publication.

Visual review also identified low-contrast legacy `Warqnaa world`/`Explore` text over the sky Home backdrop. Home opts into navy section headings and actions; settings/lobby section headers retain their existing theme. Two AR/EN actual-Home tests require at least 4.5:1 text contrast against the sky backdrops (26 cases total).
