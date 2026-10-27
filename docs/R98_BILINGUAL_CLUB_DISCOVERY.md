# R98 — bilingual club discovery

Date: 27 October 2026.

## Scope

The Laravel club discovery page now follows the active Arabic or English locale across its browser title, hero, capacity levels, club creation guidance, owner and creation metadata, league labels, presence, point and treasury summaries, membership state and actions.

The club name field, CSRF protection, routes, membership requests, Pasha token price, balances, permissions and stored club data remain unchanged.

## Verification

`R98BilingualClubDiscoveryTest` guards both language variants and the stable club creation, navigation and membership contracts. The stage remains a draft until all five required GitHub Actions gates pass on one head and representative Arabic/English club screenshots are reviewed.
