# R102 — Bilingual economy seasons and offers

R102 completes the Arabic and English presentation contract for the Laravel economy hub.

## Scope

- Localizes the page title, economy summary, store action, current-season dates and empty state, active-offer section, rare-collectible section, rarity labels, featured items, and preview actions.
- Selects localized season, offer, collectible, and item names with a safe fallback to the other supported locale and then the stable server key.
- Adds direction and accessibility refinements while preserving the existing responsive economy surfaces.

## Preserved contracts

- Active season, offer, collectible, and item queries are unchanged.
- Featured categories remain `table`, `card_back`, `effect`, `xp_booster`, and `emoji_pack`, with the same latest-first 16-item limit.
- Season reward payloads, offer discounts, rarity keys, claimed/supply counts, item keys, categories, and prices are unchanged.
- Store routing and the existing `previewStoreItem` interaction remain unchanged.
- No wallet mutation, reward quantity, price, currency, permission, game engine, multiplayer behavior, credential, or secret is changed.

## Verification

`R102BilingualEconomySurfaceTest` guards the bilingual presentation together with the stable economy and catalogue contracts.
