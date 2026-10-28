# R108 — Bilingual tournament replay

## Scope

The tournament replay viewer now presents Arabic and English copy from the active Laravel locale and applies the matching RTL or LTR direction. The localized surface includes the page title, replay description, navigation, playback controls, status, action-log heading, and empty state.

## Contracts preserved

- The replay continues to consume the existing `$frames` and `$finalHands` datasets.
- `TOURNAMENT_REPLAY_FRAMES`, `TOURNAMENT_FINAL_HANDS`, and `TOURNAMENT_REPLAY_TITLE` remain the JavaScript bridge.
- The existing canvas, video element, playback functions, tournament route, and optional room route are unchanged.
- Final hands remain available only when the authoritative room state is `finished`.
- No tournament bracket, reward, entry fee, economy, engine, dealing, permission, or multiplayer behavior changed.

## Verification

`R108BilingualTournamentReplayTest` protects the bilingual labels, RTL/LTR selector, replay bridge, playback hooks, navigation routes, and finished-state final-hand boundary.
