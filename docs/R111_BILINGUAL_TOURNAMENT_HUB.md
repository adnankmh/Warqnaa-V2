# R111 — Bilingual tournament hub

## Scope

The Laravel tournament hub now follows the active Arabic or English locale and applies RTL/LTR direction to tournament discovery, creation, registration, stage guidance, prize summaries, recordings, and empty states.

The live tournament-size and prize estimate panel also renders localized labels while retaining the original arithmetic.

## Contracts preserved

- The tournament list still uses creator, game, entry, profile, bracket, prize-distribution, and leaderboard data supplied by `TournamentController`.
- Active tournament games remain limited to `GameCatalog::customerKeys()`.
- Form field names, validation limits, routes, CSRF protection, Pasha/admin authorization, seat rules, and launch permissions are unchanged.
- Creation fee remains 1,000 tokens.
- Expected prize remains base prize plus 90% of collected entry fees.
- Partnership estimates remain 55% first, 30% second, and 10% semi-final allocation.
- Prize escrow, entry debits, admin revenue, database transactions, row locking, replay events, and final-hand privacy remain server-authoritative.
- Final hands remain available only when the room state is `finished`.
- The global layout remains responsible for the selected site theme.
- Game engines, legal actions, dealing, scoring, R36/R40/R44 Hand and Banakil behavior, and historical PR #7 are untouched.

## Verification

`R111BilingualTournamentHubTest` protects bilingual labels, RTL/LTR direction, form and route contracts, organizer permissions, prize arithmetic, catalog filtering, economy transaction markers, replay privacy, and inherited theme hooks.
