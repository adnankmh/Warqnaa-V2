# R110 — Bilingual professional game library

## Scope

The Laravel professional game library now follows the active Arabic or English locale, applies RTL/LTR direction, and translates the page title, family and game names, navigation, metadata, difficulty labels, and protection guidance.

English presentation labels were added beside the existing Arabic matrix labels. The page still renders the same family membership and supported-game entries.

## Contracts preserved

- Family keys and their game-key lists are unchanged.
- All 20 matrix entries retain their player counts, engine identifiers, and difficulty identifiers.
- Room links still use each original game key through `rooms.index`.
- The all-games link still uses the existing `games` route.
- The controller still reads `warqna_games_matrix` and passes it directly to the view.
- The global layout remains responsible for the active site theme, so every theme continues to apply to this page.
- Engines, legal actions, dealing, scoring, persistence, economy, permissions, multiplayer authority, and R36/R40/R44 Hand/Banakil behavior are untouched.

## Verification

`R110BilingualGameLibraryTest` protects both language surfaces, RTL/LTR direction, routes, iteration over the existing matrix, representative engine/player/difficulty tuples, matrix size, and inherited theme hooks.
