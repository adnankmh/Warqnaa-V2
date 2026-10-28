# R109 — Bilingual game rules

## Scope

The Laravel game-rules page now follows the active Arabic or English locale, applies RTL/LTR direction, selects the localized game name, and translates navigation, metadata, disclosure controls, and the seven existing rule guides.

The Hand and Banakil guides also expose the already-authoritative interaction boundaries more clearly:

- Banakil may lay off on a partner’s meld, but an opponent may not alter another player’s or team’s meld.
- Selecting a buried discard takes the selected card and every newer card above it, never cards below it.

## Contracts preserved

- The customer-visible catalog remains sourced from `GameCatalog::customerKeys()`.
- Only active catalog games are rendered.
- Game keys, min/max players, partnership flags, room routes, engines, dealing, actions, scores, and persistence are unchanged.
- Existing Arabic guide fields remain intact; English companion fields are presentation data only.
- R40/R36/R44 gameplay and ownership enforcement remain authoritative and were not reimplemented in the view.

## Verification

`R109BilingualGameRulesTest` protects bilingual UI labels, direction, catalog fields, room routing, all existing guide keys, and the Hand/Banakil discard and meld-ownership statements.
