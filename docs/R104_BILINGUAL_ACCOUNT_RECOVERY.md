# R104 — Bilingual account recovery

R104 completes the Arabic/English account-recovery entry point that follows the bilingual sign-in and registration work in R103.

## Delivered

- Localized the password-reset page title, guidance, field labels, action, and sign-in return link.
- Added locale-aware `lang`/`dir`, associated labels, status/alert semantics, autocomplete hints, and a compact landscape layout.
- Localized the generic forgot-password response, successful reset response, email-verification responses, signed-link errors, and verification success page.
- Added a regression contract covering the recovery surface and the security-sensitive reset and verification paths.

## Preserved security boundaries

- Forgot-password responses remain account-enumeration resistant.
- Reset validation still requires the email, token, confirmed password, and the existing 8–120 character boundary.
- Passwords are still hashed, remember tokens rotate, existing API tokens are revoked, and the framework `PasswordReset` event is emitted.
- Verification links remain temporary signed URLs with the existing 60-minute lifetime.
- Signature and email-hash checks remain mandatory before verification.
- Routes, throttles, sessions, permissions, economy values, game engines, multiplayer contracts, and PR #7 are unchanged.

## Release gates

R104 remains a draft until Backend CI, R7 isolated runtime and visual review, Production Release Gate, Flutter Web, and Android APK/AAB all pass on one exact head. Representative Arabic and English recovery surfaces must also be reviewed before merge.
