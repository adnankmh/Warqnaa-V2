# R20 — Premium Experience / Visual Hardening

R20 starts from the fully merged R19 `main` baseline and is a cumulative release. It must preserve every validated game, store, profile, multiplayer, economy, admin and bilingual behavior while raising the visual and interaction quality to a stronger production standard.

## First blocking increment

The first R20 change is visual hardening carried forward explicitly from R19: replace decorative profile-counter text emoji with stable Material icons, finish profile/home pattern and gradient polish, and verify Arabic/English captures again. Real content emoji such as user avatars, gifts and reactions remain content and are not blanket-replaced.

## Premium design system

- Original Warqnaa identity; external products are quality references only, never copied assets/layouts.
- Deep navy/glass surfaces with controlled gold/cyan accents, restrained glow and readable contrast.
- Consistent premium patterns and gradients across home, store, profile, tables, competitions and social surfaces.
- Responsive behavior from **320px** phones through tablet, landscape and **desktop** web.
- **Arabic RTL** and **English LTR** are first-class layouts, not mirrored afterthoughts.
- Typography, spacing, touch targets, semantic labels, reduced-motion behavior and overflow safety must be testable.

## Product quality boundaries

- All 12 customer games and their validated engines remain intact.
- Gameplay, scoring, wallet and economy remain **server-authoritative** where the server is authoritative today.
- No cosmetic, booster or store presentation may grant gameplay advantage or bypass receipt verification.
- Primary-admin authority remains role based; no username-based authorization.
- No credentials, signing secrets or production payment data are committed.

## R20 planned increments

1. Stable profile metrics + gradient/pattern hardening.
2. Luxury home/navigation hierarchy and responsive density refinement.
3. Store merchandising polish: collections, ownership state, previews, Pasha/boosters/reactions presentation.
4. Table/card visual consistency review across all 12 games.
5. Accessibility and motion polish, including narrow-width and short-landscape review.
6. Exact-head regression matrix: R20 gate + Backend + Release Gate + Flutter Web/Chrome + Android/emulator + Runtime/Visual.

## Merge rule

R20 does not merge while the contract report contains `decorative_profile_glyphs_remaining`, while any required CI gate is red, or while a known responsive/RTL regression is unresolved. After R20 merges, R21 starts only from the latest verified `main`.
