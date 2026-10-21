# R60 — Saudi Hand low-ace opening authority

Base: merged R59 main `2ac56c094eebd5a7c0d93b1b2fad8439315ada1d`. Legacy draft PR #7 remains untouched.

## Rule correction

- Values the ace as one point when it is used low in an `A-2-3` Saudi Hand run.
- Preserves the ace's eleven-point value in high runs such as `Q-K-A` and in remaining-hand penalties.
- Resolves joker gaps against both legal ace variants and chooses the highest legal interpretation when an unordered meld is ambiguous.
- Prevents an inflated low-ace value from authorizing a sub-51 fire pickup or opening.
- Preserves valid 51-point multi-group openings, physical-card counts and the mandatory fire-card lock.

## Regression

`backend-laravel/tests/Unit/R60SaudiHandLowAceTest.php` covers individual and partnership Saudi Hand. It verifies exact natural/joker values, rejects an inflated 46-point fire path, accepts a real 51-point opening and conserves every physical card.

GitHub Pages remains a static client. Public multiplayer still requires a deployed Laravel API, `WARQNA_API_URL`, production signing and provider configuration.
