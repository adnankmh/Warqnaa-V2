# R84 — shared partnership meld surfaces

R84 presents Hand partnership and Banakil melds in one visible surface per
team. Each surface names both partners and retains a distinct owner section for
every original meld, so the UI no longer implies that partners have unrelated
table areas.

This is a presentation change only. The original owner identifiers and card
groups remain intact, and Laravel continues to authorize every layoff. Existing
engine tests still require same-team ownership and reject attempts to add cards
to an opposing team's meld. Stock, discard, buried-fire selection, scoring,
dealing, networking and economy behavior are unchanged.

Flutter coverage renders both shared team surfaces in Arabic and English with
royal-crimson and emerald-light themes at 390×844. R7 captures the four frames
for manual RTL/LTR, contrast, card legibility and pile-position review. The web
room uses the same team grouping while preserving `data-owner` on each nested
owner section.
