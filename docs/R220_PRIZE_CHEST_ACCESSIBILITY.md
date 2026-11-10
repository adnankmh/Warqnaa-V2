# R220 — Accessible reward chest stage (Warqnaa Blue)

Issue: #204. Source: original Warqnaa prize-opening scene, not reference-app assets.

## Change
- Add a concise, localized non-live status to the **decorative** chest animation: opening/open.
- Exclude decorative sprites and sparkles from the stage's semantics tree.
- Preserve the separate reward-description live region so screen readers do not announce the reward twice.
- Keep the current blue theme, layout, image assets, skip/continue callbacks and already-settled reward flow unchanged.

## Regression coverage
`flutter test test/r220_prize_chest_semantics_test.dart` exercises eight portrait combinations:
Arabic RTL and English LTR, 320px and 390px widths, blue light and dark.
Each verifies both animation states, accessible status, non-live stage, non-overlapping controls,
blue-accent summary border and the existing Continue callback.

## Verification / release boundary
PR must remain a draft until all five required CI gates pass on the **same head SHA**:
Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime and Production Release.
No reward/economy, server, multiplayer or permission changes.
