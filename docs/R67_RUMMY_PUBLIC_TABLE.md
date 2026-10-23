# R67 — public rummy tables and competitive deal boundaries

R66 runtime screenshots exposed a cross-layer UI defect, independent of the game rules:
local sessions emit `melds: List<List<String>>` with parallel `meld_owners` seat indexes and `discard_pile`, while the rummy surface consumed only server owner maps and `discard`. Room player identities use `key`/`user_key`, but the old surface read only `id`/`player_id`. Server discards may be `{card, player}` records rather than strings.

The public surface now accepts these actual emitted formats, resolves owners to room names and stable seat-based teams, shows the correct discard count/top card, and keeps all existing draw callbacks server/action gated. It never reads opponents' hidden hands or mutates the engine state. Rummy rooms render this surface alone instead of placing a flattened legacy table summary underneath it. Trick and board games retain their existing summary. Compact tables use a smaller gap between piles so the multi-discard button retains its full Material touch target without a four-pixel overflow.

Regression coverage checks local and authoritative payloads in Arabic/English at compact/portrait/landscape table bounds, physical separation of meld scroll content and piles, exact top discard, stable partnership ownership, and all three authorized draw callbacks. Real Hand/Banakil sessions play legal automated turns and mount the actual game-room route in six device/locale combinations per game; table card rendering must exist only inside the single rummy surface. The existing runtime job captures these real room renders for pre-merge review.

Release requirement: all five gates on one exact PR head, then actual artifact and render review before merge. PR #7 remains untouched. No production API, signing or provider credentials are invented.

## Standalone Tarneeb competitive boundary

A further review of `GameFactory` found that base Tarneeb/41/61 use `TarneebRules`, independently of the 11 global adapters fixed in R66. Its standalone engine still defaulted to balanced casual dealing. The adapter now selects random dealing before `newGameWithTarget` for ranked, competitive, tournament, league and cup contexts, including callers that explicitly request a casual policy. The chosen policy stays in engine rules for subsequent rounds/redeals. Friendly defaults remain balanced. A deterministic regression covers all three factory aliases, both context spellings, forced policy isolation, full hands and the actual next-round entry point.
