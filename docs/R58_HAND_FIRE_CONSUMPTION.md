# R58 — authoritative Hand fire-card consumption

Base: merged R57 main `48df393e09796be67c5b9c162da5cf852405bc11`. Legacy draft PR #7 remains untouched.

## Gameplay fix

- Persists the exact top fire card that authorized a Hand discard pickup.
- Keeps the mandatory-meld lock active when the player melds an unrelated group.
- Releases the lock only after a single or multi-group meld consumes that fire card.
- Preserves compatibility for in-flight pre-R58 games whose turn metadata predates the new field.
- Leaves Banakil single and multi-card fire draws unchanged.

## Regression

`backend-laravel/tests/Unit/R58HandFireConsumptionTest.php` covers Saudi Hand and partnership Hand. It proves that an unrelated run cannot authorize discarding the picked fire card, that the intended run releases the lock, and that every physical card remains conserved through the turn.

All five GitHub workflows must pass on one exact PR head before review or merge. GitHub Pages remains a static client; public multiplayer still requires a deployed Laravel API, `WARQNA_API_URL`, production signing and provider configuration.
