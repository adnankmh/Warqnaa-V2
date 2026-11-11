# R235 — Accessible original-blue challenge progress

## Baseline / feature parity
The existing `ChallengeCenterV175` already renders server/local challenge data, progress, cadence, and claim/activation buttons. This change does **not** introduce rewards, alter challenge data, or replicate the reference game's artwork. It improves a real challenge progress row that previously used a generic progress indicator and an unannounced numeric fraction.

## UI-only implementation
- `flutter_app/lib/v175_release.dart`: existing challenge card progress row now uses `R235ChallengeProgress`, a read-only widget with a localized Arabic/English screen-reader label, percentage value, a visible LTR `current / target` fraction in both languages, and the original Warqnaa azure/sky progress colors for light/dark themes.
- Clamp the visual fraction to [0, 1] and handle missing/invalid target safely; retain actual nonnegative displayed progress. No server mutation.
- `flutter_app/test/r235_challenge_progress_blue_test.dart`: 11 cases: source integration, 8 combinations of Arabic RTL / English LTR × 320 / 390 portrait × light / dark blue, 844×390 RTL landscape, and malformed progress safety.

## Safety and ownership
No modifications to gameplay engines, authoritative multiplayer state, networking, entitlements, store ledger, rewards, permissions, or existing callbacks. No third-party graphics, branding, video frames, or proprietary assets.

## Verification
Base main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.
Branch: `automation/r235-challenge-progress-portrait-blue-20261111-1327`.
Do not merge before **all five** workflows pass on one final HEAD: Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime, Production Release; confirm mergeability and visual acceptance. Capture screenshots only if actually produced by CI/runtime; none are claimed here.
