# R97 — bilingual competitive controls

Date: 27 October 2026.

## Scope

The competitive arena now presents its trust strip, ranked matchmaking state, region choices, tournament scope and format, ladder abbreviations, division and season reward labels, reward tiers and claim action in the active Arabic or English locale. The public hero no longer exposes an internal build marker.

Submitted values such as `levant`, `mena`, `gcc`, `global`, queue states, game keys and preferred seat counts remain unchanged. Matchmaking, MMR calculations, tournament records, reward authorization, routes, economy and gameplay are unchanged.

## Verification

`R97BilingualCompetitiveControlsTest` guards both language variants, stable submitted values and removal of the internal marker. The stage remains a draft until all five required GitHub Actions gates pass on one head and representative Arabic/English competitive screenshots are reviewed.
