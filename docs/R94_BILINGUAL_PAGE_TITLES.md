# R94 — bilingual page-specific titles

Date: 27 October 2026.

## Scope

Page-specific browser titles now follow the active Arabic or English locale on:

- the public home page;
- offers and checkout;
- Social World;
- live spectator stands;
- privacy-safe match replays;
- the competitive arena.

This closes overrides that bypassed the locale-aware global title introduced in R93. Page content, routes, spectator privacy, replay digests, commerce, economy, permissions and gameplay are unchanged.

## Verification

`R94BilingualPageTitlesTest` guards the Arabic and English title variants for every updated page. The stage stays unmerged until all five required GitHub Actions gates pass on one head and the latest main/head SHAs are rechecked.
