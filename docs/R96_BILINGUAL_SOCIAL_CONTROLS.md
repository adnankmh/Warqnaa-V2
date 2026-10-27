# R96 — bilingual Social World controls

Date: 27 October 2026.

## Scope

Social World now presents activity types, audiences, event states, replay metadata, profile levels, gift motion labels, event visibility, composer options and every privacy field/switch in the active Arabic or English locale. Internal release labels are removed from the public hero.

Submitted values such as `looking_for_game`, `public`, `friends`, `private`, `everyone` and `nobody` remain unchanged, preserving controllers, validation, stored preferences and authorization behavior. Routes, records, counters, privacy enforcement, economy, themes and gameplay are unchanged.

## Verification

`R96BilingualSocialControlsTest` guards both language variants and the stable submitted values. The stage remains a draft until all five required GitHub Actions gates pass on one head and representative Arabic/English Social World screenshots are reviewed.
