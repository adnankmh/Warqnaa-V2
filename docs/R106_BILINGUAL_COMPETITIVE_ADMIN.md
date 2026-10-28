# R106 — Bilingual competitive administration

R106 completes the Arabic/English presentation layer for the competitive administration console.

## Delivered

- Localized competitive metrics, switches, season lifecycle, championship creation, manual MMR settlement, integrity review, and tournament brackets.
- Added RTL/LTR direction at the competitive console boundary.
- Localized displayed season, scope, format, and tournament status labels without changing their stored values.
- Added a contract test covering both locales and all sensitive field names, action values, and endpoints.

## Preserved competitive and integrity boundaries

- Competitive setting keys and numeric limits are unchanged.
- Season, tournament, scope, and format values are unchanged.
- Manual MMR settlement still creates the same audited records through the same endpoint.
- Integrity actions remain exactly \`approve\` and \`void\`.
- Default audit reasons, CSRF protection, routes, entry fees, prize pools, ratings, rewards, and server authority are unchanged.
- Gameplay engines, card dealing, economy settlement, multiplayer contracts, and historical PR #7 are unchanged.

## Release gates

R106 remains a draft until Backend CI, R7 isolated runtime and visual review, Production Release Gate, Flutter Web, and Android APK/AAB all pass on one exact head.
