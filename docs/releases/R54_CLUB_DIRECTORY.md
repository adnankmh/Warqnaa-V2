# R54 — Blue/gold clubs and explicit join states

## Actual route, not a disconnected mockup

`ClubsPage` still opens `R11ClubsWorldPage`, which retrieves the existing
authenticated `clubsWorldR11` API. The real route now uses a sky backdrop,
navy/gold header, readable search/count controls and blue/gold club cards in
place of the legacy green directory. Names use 20px type, metadata 14px and
actions 16px with at least 48px targets. Cards wrap to one/two/three columns
without fixed heights; long names and 1.6× text do not squeeze actions into a
fixed thumbnail. Existing details, announcements, join moderation and R52
delegated permissions remain in their original authenticated route.

This advances the established sky/cyan/gold direction; it is not a claim of
pixel-perfect equivalence to the user's full composite reference. No new image
assets, copied branding, offers, fake clubs or invented prizes are introduced.

## State and authority

- Differentiate public joining, approval-required requests, pending requests,
  full capacity, current membership, private and unverified/unavailable data.
- Unknown visibility, invalid IDs/capacity and negative membership counts fail
  closed in discovery. The server remains the final membership authority.
- Disable joining while a request is in flight. Show a localized sending state.
- Disable cached detail opening and joins while refreshing or after a failed
  verification; a successful refresh restores the authenticated actions.
- Retain search, availability filter, pull-to-refresh, creation cost/Pasha gate,
  one-club rule, role delegation, and server-owned wallet/membership records.
- Offline view never fabricates a directory or enables founding/joining.

## Evidence required before merge

`flutter_app/test/r54_clubs_reference_test.dart` exercises the actual ClubsPage
in Arabic/English at 320×568, 390×844, 600×800, 844×390 and 1440×900 with 1.0/1.6×
text; card geometry, contrast, real search/filter, pending joins/details,
double-tap locking, failed-refresh recovery, offline behavior and fail-closed
unknown states. R7 runs this suite with decoded fonts and screenshot capture.
The existing Chrome workflow also executes six actual-route club journeys
through `r65_responsive_test.dart`, sharing the same synthetic API fixtures.

`R54ClubDiscoveryAuthorityTest` exercises the actual Laravel API: hidden private
clubs, locked capacity, approval-required requests, no duplicate membership,
one-club rule, no client-chosen role/permissions and unchanged wallet.

All five required workflows must pass on one exact head, followed by manual
screenshot review. Main Pages deployment is separate from PR Web build; Pages
is static only. A real production Laravel API, `WARQNA_API_URL` and production
signing remain external requirements, not facts inferred from CI success.
