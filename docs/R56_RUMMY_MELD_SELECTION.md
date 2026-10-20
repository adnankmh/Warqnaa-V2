# R56 — Hand/Banakil meld selection authority

Base: merged R55 main `772aa1c1ad25b67c5b8a1da64a7f696e2c2f22a9`. Legacy draft PR #7 remains untouched.

## Server-authoritative fix

- Replaces greedy first-fit selection of suggested rummy groups with a bounded exhaustive search over the server's twelve highest-valued candidates.
- Prevents a high-value set that overlaps two legal runs from hiding a valid multi-group opening.
- Keeps the discard card requirement, opening threshold, physical-card multiplicity and the existing eight-group action limit authoritative on the server.
- Prefers the legal combination that lays down the most cards, then the highest total value, with deterministic ordering.

## Regression

`backend-laravel/tests/Unit/R56RummyMeldSelectionTest.php` constructs the previously rejected 62-point opening in both Saudi Hand and partnership Hand: an ace set sorts ahead of two queen-king-ace runs and overlaps them. The test proves that the fire draw is advertised and accepted, the exact two-run action is generated, the mandatory meld lock clears, and every physical card is conserved.

All five GitHub workflows must pass on one exact PR head before review or merge. GitHub Pages remains a static client; public multiplayer still requires a deployed Laravel API, `WARQNA_API_URL`, production signing and provider configuration.
