# R213 — explicit discard pickup origin (Issue #204)

## Existing baseline
R40DiscardStackPicker already enforces the selection of a public discard and
all newer cards above it, with an engine-validated count. R212 made its entry
control visible in the blue portrait table. Neither mechanism is replaced.

## UI-only increment
The picker now announces the **first card to be taken**, alongside the current
count, before the existing preview. The message updates when the player taps
another public discard or changes the count. It uses the active Material theme's
readable on-surface ink and an accessible live region. Arabic RTL and English
LTR are both supported.

## Regression coverage
`flutter_app/test/r213_discard_pickup_origin_test.dart` checks 320px and
390px portrait widths, both locales and blue-seeded light/dark themes. It
verifies the origin changes from the second-newest card to the third-newest,
that the confirmation returns the existing count, and no widget exceptions.

## Safety and release
No changes to server calls, hidden cards, discard ordering, gameplay engines,
ownership, economy or multiplayer. Keep the PR draft until Backend CI, Flutter
Web, Android APK/AAB, R7 Visual Runtime and Production Release pass on one
identical HEAD and mergeability is clean.
