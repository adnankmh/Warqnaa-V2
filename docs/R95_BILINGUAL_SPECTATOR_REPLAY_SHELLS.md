# R95 — bilingual spectator and replay shells

Date: 27 October 2026.

## Scope

The live spectator and privacy-safe replay shells now follow the active Arabic or English locale for visible labels, privacy explanations, navigation, frame and seat labels, empty/default state copy, and replay control accessibility labels.

Dynamic engine action and phase values remain unchanged. Spectator filtering, replay digests, polling cadence, routes, room state, permissions, economy, themes and gameplay are unchanged.

## Verification

`R95BilingualSpectatorReplayShellTest` guards both language variants and the locale-aware client fallbacks. The stage remains a draft until the five required GitHub Actions gates pass on one head and representative Arabic/English screenshots are reviewed.
