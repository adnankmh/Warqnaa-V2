# R66 — Preserve random competitive dealing at engine initialization

## Defect

R65 selects among several whole-deck candidates for **friendly/casual** games to keep all seats playable. Ranked matchmaking and tournament brackets called `initialState()` without any ranked/tournament/deal context, and only stamped `ranked=true` or `competitive=true` onto room state *after dealing*. The global engine therefore could apply the casual candidate-selection policy before receiving the official match classification.

## Correction

- `GlobalCardEngineRules::initialState()` now forwards a constrained set of dealing options (`dealPolicy`, `ranked`, `competitive`, `match_mode`) to the engine *before* it allocates any cards.
- The official Ranked and Tournament room creators both explicitly pass `dealPolicy=random` and their correct competition markers into the initial state call, before adding public room metadata.
- Casual games retain their symmetrical strong/varied candidate selection. Ranked and official tournament deals use the original unconditioned shuffle, without special cards for any account or bot.
- No changes to 12-game catalogue, scoring, bot decisions, official room pricing, wallet, XP Boosters, backend ownership or visibility.

## Evidence

`R66RankedDealBoundaryTest.php` checks 11 globally routed card variants: stable seed-matched physical hands/deck for explicit random, ranked and tournament; no competitive `dealQuality`; preserved casual policy. It also verifies the two actual official match-creation call sites pass the policy before dealing.

All 5 exact-head CI gates and visual review remain prerequisites to merge. GitHub Pages does not host the multiplayer Laravel API.
