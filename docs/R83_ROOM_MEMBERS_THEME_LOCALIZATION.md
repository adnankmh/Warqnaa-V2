# R83 — themed bilingual room-member moderation

R83 makes the room-member manager and remove-player confirmation inherit the
selected cosmetic theme and follow the active Arabic or English direction.
Stable Material icons and ISO country-code badges replace platform-dependent
emoji in this moderation surface.

The room owner still sees the remove control only when the server advertises
`allow_owner_kick`; the current player and computer players cannot be removed.
Profile opening, user identifiers and the existing server-authoritative kick
request are unchanged. No game engine, networking authority, permission or
economy behavior is altered.

Flutter coverage renders the manager and confirmation dialog in Arabic and
English with dark royal-crimson and light emerald themes at 390×844. R7 captures
all eight frames for manual RTL/LTR, contrast, typography and overflow review.
