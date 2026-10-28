# R105 — Bilingual recovery email

R105 completes the Arabic/English account-recovery journey after R103 and R104.

## Delivered

- Localized password-reset email subject, greeting, guidance, action, and safety note.
- Localized email-verification email subject, greeting, guidance, action, and expiry note.
- Localized the shared verification/legal page metadata and return action.
- Added behavior tests that build both notification messages in Arabic and English and verify that their signed/reset URLs remain unchanged.

## Preserved security and delivery boundaries

- Notification transport remains Laravel mail.
- Reset and verification URLs are passed through unchanged.
- The 60-minute signed verification lifetime, signature check, email-hash check, password broker, hashing, token revocation, and anti-enumeration response remain in the R104 controller without modification.
- The shared legal page continues to render only controller-provided trusted content.
- Routes, permissions, economy values, gameplay engines, multiplayer contracts, and historical PR #7 are unchanged.

## Release gates

R105 remains a draft until Backend CI, R7 isolated runtime and visual review, Production Release Gate, Flutter Web, and Android APK/AAB all pass on one exact head.
