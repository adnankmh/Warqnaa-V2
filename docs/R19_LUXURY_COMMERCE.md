# R19 Luxury Commerce

R19 continues directly from the fully validated R18 visual baseline.

The reaction-stage increment upgrades the existing in-table reaction system
without changing gameplay or economy authority. A single category-specific
sound cue now accompanies each animated reaction while static reactions keep
their subtle tap (removing the previous overlapping double feedback). The floating stage includes its localized reaction name and
screen-reader live-region semantics, and reduced-motion users receive a
fade-only presentation. The dock reports whether sound is enabled and adapts
its grid across phone, landscape and desktop widths. All cues remain local,
fail-safe OGG assets on the existing sound bus.

## Increment 1 — Storefront and themes
- Adds five original Warqnaa premium themes: Midnight Cyan, Obsidian Gold, Royal Crimson, Sapphire Pasha and Aurora Luxe.
- Reworks the real `R101CommerceShowcase` used by `StorePage` into a navy/glass luxury storefront surface.
- Daily, weekly, monthly and annual offer cards are interactive and route to the existing `B307CashShopPage` checkout flow.
- Shows online/offline server-verification readiness, receipt-verification status and the no-raw-card-storage guarantee.
- Preserves the existing rule that client-side payment success alone never grants tokens.
- Keeps all legacy themes available and does not change game engines, wallet authority or multiplayer lifecycle.

## Design rule
Warqnaa remains original. External card-game products are feature/quality benchmarks only; no third-party assets, branding or proprietary layouts are copied.

## Validation
`tools/test_r19_luxury_commerce_contract.py` protects the R19 store/theme hooks. Full Backend, Release Gate, Flutter/Web/Chrome, Android/emulator and runtime visual-review workflows remain authoritative before merge.
