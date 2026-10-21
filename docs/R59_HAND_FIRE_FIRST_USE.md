# R59 — Hand fire card must be used first

Base: merged R58 main `076a2190067dd0f229bbc3483a05418f935d1c6c`. Legacy draft PR #7 remains untouched.

## Gameplay and authority fix

- Advertises only meld actions that consume the exact fire card while the pickup lock is active.
- Rejects unrelated single and multi-group melds before any cards or events mutate.
- Blocks layoff and joker replacement until the picked fire card has entered a new legal meld.
- Prevents a player or bot from consuming the supporting cards first and deadlocking the turn.
- Preserves compatibility for in-flight pre-R58 turn metadata and leaves Banakil fire draws unchanged.

## Regression

`backend-laravel/tests/Unit/R59HandFireFirstUseTest.php` covers Saudi Hand and partnership Hand. It verifies action filtering, direct-request rejection for meld/layoff/joker replacement, immutable rejected state, successful required-card consumption and physical-card conservation.

All five GitHub workflows must pass on one exact PR head before review or merge. GitHub Pages remains a static client; public multiplayer still requires a deployed Laravel API, `WARQNA_API_URL`, production signing and provider configuration.
