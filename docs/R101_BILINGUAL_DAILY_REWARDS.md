# R101 — Bilingual daily rewards

R101 completes the Arabic and English presentation contract for daily reward claims and history on the Laravel rewards page.

## Scope

- Localizes the daily reward title, explanation, claimed state, claim action, history heading, streak label, reward-value accessibility label, and empty state.
- Localizes both redirect and JSON success messages returned by `RewardController::claim`.
- Adds page-title and decorative-icon accessibility refinements while preserving the existing responsive reward surfaces.

## Preserved contracts

- Lucky-wheel segments, spin sources, cooldowns, token cost, and five-spin limit are unchanged.
- Prize-box ownership checks, open state, and reward payloads are unchanged.
- Daily streak calculation, `rewardForStreak`, idempotent `firstOrCreate`, `wasRecentlyCreated` guard, and wallet token increment remain server-authoritative.
- The JSON response retains `ok`, `message`, and `claim`; only the message language follows the active locale.
- No reward quantities, economy values, routes, permissions, game engines, multiplayer behavior, credentials, or secrets are changed.

## Verification

`R101BilingualDailyRewardsTest` guards the bilingual copy together with the wheel, box, streak, idempotency, wallet, and response-shape contracts.
