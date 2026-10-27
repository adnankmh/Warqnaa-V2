# R99 — bilingual club detail and management

Date: 27 October 2026.

## Scope

The Laravel club detail page now follows the active Arabic or English locale across identity settings, league and treasury summaries, presence and member roles, moderation permissions, join requests, announcements, tournament setup, activity history and membership actions.

Accessibility labels were added to management and tournament inputs without changing their submitted names or values.

## Preserved contracts

Club routes, CSRF protection, role and permission keys, visibility values, membership decisions, tournament stages and seats, entry fees, prize pools and server-side authorization remain unchanged. R40 discard selection, R36 meld workspaces and R44 Banakil ownership behavior are outside this presentation-only stage.

## Verification

`R99BilingualClubDetailTest` guards both language variants and the stable authority, membership, announcement and tournament contracts. This stage remains a draft until all five required GitHub Actions gates pass on one head and representative Arabic/English club surfaces are visually reviewed.
