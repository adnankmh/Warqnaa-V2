# R21 — Clubs and tournaments

Based cumulatively on verified R20 merge `1e5315fe8d663b22c53a82291a38588dc7a4c6c1`. Shared track: PR #14, `codex/r21-clubs-tournaments`.

## Delivered behavior
- Responsive original green/gold club and championship cards, localized Arabic RTL / English LTR, server counts, league, capacity, prize pool, entry fee, local start date, and membership/registration state.
- Search club names/leagues and tournament names/games; filter clubs accepting members, global/club/country cups, open registration, and own entries.
- Club requests persist after refresh and remain private to their applicant; pending and full clubs cannot receive another join from the UI. Existing membership, moderation, announcements, events and leave paths remain available.
- Offline/failed refresh is explicitly read-only; it cannot enable founding, joining, Ranked search, tournament registration or season reward claims.
- Tournament details must refresh successfully before live registration. Confirm entry fees and automatic eligible-ticket preference; withdrawals disclose existing no-refund and bracket-lock rules.
- Capture accepted entry fee and compare it with the locked server price before any ticket or wallet debit. Stale consent returns HTTP 409 and requires review. Older clients retain their existing endpoint contract.
- Guard repeated registration and reward actions, refresh authoritative wallet/session after successful operations, and retain server-controlled brackets, scope/rating restrictions, payouts and primary-admin revenue.

## Verification
R21 widget coverage includes both locales and phone/landscape/desktop discovery, pending/full states, search and own-entry filters, failed-detail gating, confirmation, repeated-tap protection and offline action gating. Laravel regressions verify private pending requests, moderation restoration, stale zero/under/over-price consent, ticket/wallet non-consumption and valid ticket registration.

The isolated HTTP suite creates synthetic club and global/club/country cups, checks two-account privacy, approval, fee rejection, registration, withdrawal and restored entries. Review screenshots use these server responses. Existing all-12-game, bilingual, four-size runtime coverage remains intact.

Merge requires seven workflows on the exact PR head: R21 community, R20 premium retention, production/engine contracts, Laravel/security/Docker, Flutter Web, runtime/visual review, and Android APK/AAB/emulator. All checkout steps select `${{ github.event.pull_request.head.sha || github.sha }}`.

## External release prerequisites
Store signing, production payment credentials and production service configuration remain deployment prerequisites governed by the existing release preflight. Development and isolated QA do not depend on live purchases or copied assets.
