# R227 — Stable account identifiers in Arabic/English

Issue: #204. Base main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.

## Existing behavior
`R143AccountSecurityPage` already provides username/email/password updates and
server-authoritative security validation. Its identity inputs previously inherited
RTL text direction from Arabic UI, which can make ASCII usernames and email
addresses awkward to edit. Password visibility buttons had no explicit
localized tooltip.

## Narrow change
- Preserve localized form layout and active blue light/dark themes.
- Force only username/email **value entry** to LTR, with no autocorrection,
  suggestions, or automatic capitalization. Keep email keyboard and autofill.
- Label show/hide actions for current/new passwords in Arabic and English.
- No changes to authentication, password handling, network, ledger, gameplay,
  permissions, or server validation.

## Verification
- `flutter_app/test/r227_account_identity_direction_test.dart`: eight
  portrait combinations (320/390 × ar/en × light/dark) plus Arabic landscape.
- Verify five workflows on the **same final PR HEAD**: Backend CI, Flutter Web,
  Android APK/AAB, R7 Visual Runtime, Production Release.
- Runtime screenshots/artifacts are CI-generated; do not substitute screenshots
  or claim visual verification before that gate succeeds.
- No third-party game assets or proprietary design elements.
