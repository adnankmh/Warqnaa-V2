# R57 — authoritative long Hand meld suggestions

Base: merged R56 main `55ef172a7db705410ae36f6f9bd50031d73171f4`. Legacy draft PR #7 remains untouched.

## Gameplay fix

- Extends server-validated three-card suggestion seeds into legal runs and sets of up to thirteen cards.
- Makes a legal 51+ point opening visible to the action API even when no three-card subset reaches the opening threshold.
- Lets Hand take the top fire card when that exact card completes one long legal opening, matching the direct meld validator fixed in R52.
- Preserves real card multiplicity, the configured joker/two rules, deterministic ordering and a bounded candidate search.

## Regression

`backend-laravel/tests/Unit/R57RummyLongMeldSuggestionTest.php` covers Saudi Hand and partnership Hand with a six-card 9-to-A clubs run worth 60 points. It proves that the ace may be taken from the fire, the full run is advertised as one server action, the mandatory meld lock clears, and every physical card is conserved.

All five GitHub workflows must pass on one exact PR head before review or merge. GitHub Pages remains a static client; public multiplayer still requires a deployed Laravel API, `WARQNA_API_URL`, production signing and provider configuration.
