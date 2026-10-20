# R52 playability and rewards

This change continues main `37c1edc74e32e212dcf7bcc2f97713759a4c85d8` in PR #45. The older draft PR #7 is preserved. The approved R48 purple, ocean and eagle artwork and catalogue identities remain in place.

## Implemented paths

- Local Hand now runs five scored rounds when single-round mode is off. Banakil keeps half-point precision and team scoring to the configured 150/222 target. The starter rotates; completed matches wait for an explicit exit or replay.
- Local wild-assisted meld suggestions, opening values, fire-pile obligations, physical-card counts and Joker recovery use deterministic rule helpers. Recovering the Joker in a rank set containing two natural cards requires both missing suits. A Banakil two cannot be recovered as a Joker.
- Laravel applies the same Joker recovery restriction and preserves the full-hand bonus through the final discard.
- A single card identity parser handles local, server and displayed suit forms. Hands overlap within the available width. Previous-round deltas remain visible across fast round transitions.
- Home routes to the actual wheel and chest pages. The wheel has 12 segments and eight reward types, with the same segment ordering online and offline. A temporary table prize uses a separate reward SKU so it cannot change the original paid SKU's price.
- Six complete original chest sprite sets are restored to the bundle. The 24 PNG files add 6.92 MiB. Separate checks retain the previous legacy/R48 budgets and cap restored chest art at 8 MiB and the complete asset bundle at 25 MiB.
- Authenticated Laravel reward forms use the existing wheel/chest services, CSRF, rate limits, ownership checks and single-open protections.
- Club owners can assign deputy, membership-manager, event-organizer and ordinary-member presets from Flutter. Delegates cannot assign roles, alter the owner or obtain global admin privileges. Role changes are logged.
- AdMob rewards have issued, account-bound sessions and a signed Google SSV callback. The callback verifies original query bytes using Google's EC public keys, checks ad unit, user and time, locks account/session rows, enforces eight rewards per day and credits a fixed 50 tokens/15 XP once. Client-supplied reward amounts are ignored. Unverified legacy claims remain disabled.
- The default UI scale is 1.12; game labels use 16-point text with two lines. Desktop tables are bounded to approximately two thirds of the viewport. Paired landscape card-back art is rotated into portrait while approved portrait sources retain their orientation. Catalogue surfaces use native clipping rather than an opaque rectangular background; the three approved alpha artworks keep their own contour.
- The five parent workflows remain. Backend and Production now cancel obsolete runs for the same ref, matching the existing Android/Web/runtime behavior.

## Test accounts

Run `php artisan warqna:playtest-accounts` on a local/testing/staging Laravel instance. It creates `QAPlayer01` through `QAPlayer10`, each with a unique random password and 10,000 test tokens, without admin permissions. Credentials are written exclusively to `storage/app/private/playtest/accounts.json` with mode 0600. Re-running does not overwrite existing users or credentials. The command refuses production. No credentials are embedded in the app or published as CI artifacts.

## AdMob deployment configuration

After deploying Laravel over HTTPS and configuring the AdMob SSV callback to `/api/mobile/v1/ads/admob/ssv`, set `WARQNAA_ADMOB_SSV_ENABLED=true` and `WARQNAA_ADMOB_REWARDED_UNITS` to the allowed numeric ad-unit identifiers sent in Google's callbacks. The mobile production build must use the corresponding real rewarded ad-unit ID. Google test ad IDs remain appropriate for the test APK. A real provider callback has not been claimed to work on GitHub Pages.

The existing official purchase receipt-verification boundary remains server-controlled. Payment console products, verification credentials, production signing and an actual Laravel deployment must be configured before claiming paid purchases or live ad revenue are enabled. GitHub Pages hosts the static Flutter client only.

## Verification requirements

R52 adds pure rules tests, a complete five-round local Hand playthrough, server-side Joker/full-hand regression tests, wheel reward-SKU isolation tests, authenticated web reward tests, private account provisioning tests, scoped club-role tests and generated-key ECDSA tamper/replay/cap tests. Runtime UI tests open the actual wheel and chest routes, open a chest using its real sprites, exit a completed Hand route and render catalogue table galleries. All existing suites and the five final-head gates must pass before merge; screenshots require manual inspection.

## Rule references

- https://blog.jawaker.com/hand-rules/
- https://blog.jawaker.com/banakil-rules/ (the Arabic full-hand distinction is 51 after opposition has opened, 102 otherwise)
- https://blog.jawaker.com/tarneeb-rules/
- https://blog.jawaker.com/competitions-rules/
- https://developers.google.com/admob/flutter/ssv

These references guide rules and feature behavior. They do not establish pixel-for-pixel equivalence, full production readiness, or permission to copy another app's branding/assets.

## Follow-up validation — 20 October 2026

Backend on `be1fed45` reported 275 passing tests and one failing SSV cap
assertion. Eight verified rewards give 400 ad tokens/120 XP; crossing 80 XP
also gives the existing 230-token level-two bonus. The corrected test checks
the ad ledger separately and retries all eight signed callbacks after the cap,
including the level-up callback, to prove no duplicated tokens or XP.

Manual review of the R7 screenshots found wheel sectors hardcoded to Arabic
and using an unthemed canvas font. The painter now receives the active locale
and theme font, with 12px labels, and repaints when either changes. Route tests
check all 12 localized labels and font propagation. The same visual review found
dark replay text on a dark result panel; replay now has white text, a cyan outline
and a 48px touch target, with callback/style tests in both languages.

These are targeted corrections, not blanket approval of every screen. All five
gates and final-head screenshots still need verification before merge.
