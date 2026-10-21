# R65 — Stronger, varied and symmetric casual deals across card engines

**User intent:** stronger, useful and varied starting hands for everyone across game types, without favoring a named account, the administrator, one team, bots or paying members. Winning and game outcomes are never guaranteed.

## Implemented policy

- Existing Tarneeb-family balanced playable hands are preserved for ordinary casual rooms.
- Trix, Trix Complex, Baloot and the shared Saudi Hand, partnership Hand and Banakil engine now apply a **bounded (default 12)** candidate search in casual mode. Each candidate is a **whole shuffled deck**; no cards are inserted, removed or granted to a special seat.
- Every player's score uses the same formula: mixed rank/suit and useful high-card/long-suit opportunities in trick games; potential adjacent same-suit runs, sets and legal wilds in rummy. The weakest seat is improved first and score spread breaks ties.
- Chosen decks retain seeded replay for existing integrity tools, physical card multiplicity, Banakil's one extra starting card, discard position and real turn rules.
- **Ranked, tournament, league, cup and explicit random-deal rooms remain ordinary shuffled deals**. No candidate conditioning or extra advantage is used there.
- The policy is not a guarantee of an ace or a win. Trix trick-avoidance contracts have different definitions of a good hand, so this is a balanced-playability heuristic, not a promise of rank strength in every contract. Games such as Basra and skill/board modes keep their own official rules.

## Regression

`backend-laravel/tests/Unit/R65SymmetricDealVarietyTest.php` verifies six representative engines, physical-card conservation including duplicate-deck jokers, eight seed replays, diverse seat assignments, and untouched random/ranked/tournament paths.

No changes to rewards, wallet, premiums, Pasha, product IDs, results, game scoring or user entitlements. **All five exact-head release checks must pass before merge.** Public multiplayer requires real Laravel hosting; GitHub Pages is a client only.
