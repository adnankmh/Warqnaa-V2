# R19 Luxury Commerce

R19 continues directly from the fully validated R18 visual baseline.

The avatar/bot-stage increment turns the existing deterministic bot portraits
into a coherent original Warqnaa identity system. Bot badges, style,
difficulty and public-profile metrics are localized in Arabic and English;
opening a bot profile now preserves its painted portrait instead of replacing
it with a generic emoji. The responsive roster is covered on phone, landscape
and desktop and is included in runtime screenshot review.

This is presentation only. Bot decisions still come from the authoritative
game engine, and the profile surface cannot alter gameplay, match results or
economy state. The preceding reaction stage remains intact: category-specific
audio uses the fail-safe sound bus, floating reactions expose live-region
semantics, and reduced-motion users receive a fade-only presentation.

The game-art increment refines the real local and server-backed table surfaces,
not a disconnected showcase. It replaces the bright central glare and generic
oval lines with a calm reading zone and an original Warqnaa geometric rosette,
adds a generated matching card-back fallback, and gives ace, court and numbered
cards visibly different faces at playable sizes. No third-party art is bundled.

## Increment 1 — Storefront and themes
- Adds five original Warqnaa premium themes: Midnight Cyan, Obsidian Gold, Royal Crimson, Sapphire Pasha and Aurora Luxe.
- Reworks the real `R101CommerceShowcase` used by `StorePage` into a navy/glass luxury storefront surface.
- Daily, weekly, monthly and annual offer cards are interactive and route to the existing `B307CashShopPage` checkout flow.
- Shows online/offline server-verification readiness, receipt-verification status and the no-raw-card-storage guarantee.
- Preserves the existing rule that client-side payment success alone never grants tokens.
- Keeps all legacy themes available and does not change game engines, wallet authority or multiplayer lifecycle.

## Increment 4 — Original bot identities
- Preserves the deterministic Arabic personas and custom-painted portraits already used at game tables.
- Adds localized Arabic/English difficulty, identity and public-profile presentation.
- Reuses the original portrait when a player opens a bot profile rather than substituting a generic robot emoji.
- Localizes compact-table AI badges and adds explicit semantics to bot portraits.
- Adds focused widget regression coverage plus eight runtime review captures across both languages and four viewport classes.
- Keeps all decisions server/game-engine authoritative; these widgets are not a second bot engine.

## Increment 5 — Game art, cards and tables
- Uses one public `WarqnaaTableSurface` for the local Tarneeb board and the authoritative engine table.
- Replaces the harsh centre glow with a quieter felt reading zone, inset border, corner diamonds and an original 16-point Warqnaa rosette.
- Draws ace, court and 2–10 faces in code so ranks remain distinguishable without third-party card assets.
- Adds a matching generated card-back fallback with localized image semantics.
- Covers Arabic RTL and English LTR on phone portrait and landscape, including compact cards.
- Changes presentation only; deal order, legal actions, scoring and wallet authority remain untouched.

## Design rule
Warqnaa remains original. External card-game products are feature/quality benchmarks only; no third-party assets, branding or proprietary layouts are copied.

## Validation
`tools/test_r19_luxury_commerce_contract.py` protects the R19 store/theme hooks. Full Backend, Release Gate, Flutter/Web/Chrome, Android/emulator and runtime visual-review workflows remain authoritative before merge.
