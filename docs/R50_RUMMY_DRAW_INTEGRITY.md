# R50 — Hand/Banakil draw integrity

Base: merged R49 main `9286984daea4287c35d7716afa1aa84a0fafa15a`. PR #7 remains untouched.

## Server-authoritative fixes

- **No phantom stock draw.** Hand and Banakil now reject `draw_deck` if the stock is empty and the public discard pile has just its face-up top card. That visible card cannot simultaneously become a stock card. Action hints use exactly the same condition as server validation.
- **Real stock recycling.** When the stock is empty and two or more discards are available, the engine retains the visible top in the fire, securely reshuffles the buried discards, and draws one card from the recycled stock.
- **Strict Banakil stack counts.** Multi-draw accepts an integer (or a canonical positive decimal integer string from an API form) within the public pile size. Booleans, fractional numbers, arrays and strings like `2extra` no longer get silently truncated to a valid count.
- No changes to dealing odds, score rules, deck identities, private hands, server authority, wallets, payments, admin privileges or the other ten games.

## Regression

`backend-laravel/tests/Unit/R50RummyDrawIntegrityTest.php` tests both engines against a one-card fire pile and a recyclable fire pile, covers legal/illegal Banakil stack counts and tests no mutations after rejected actions. The existing Backend CI runs all PHPUnit tests, PHP lint and security checks. R7 runtime, Production Release, Flutter Web and Android build checks are mandatory on the **same PR HEAD** before review and merge. Do not confuse GitHub Pages with deployed multiplayer Laravel hosting.
