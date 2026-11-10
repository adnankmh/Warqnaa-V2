# R216 — Eligible discard picker origins (Issue #204)

## Verified baseline
R40DiscardStackPicker already selects a public discard and every newer
card above it, while the engine validates the pickup. R213 already shows
the selected origin and pickup count. R214 (PR #207) changes a later,
unrelated section of this same source file; R215 (PR #208) changes the
public pile's accessibility label in a different source file.

## Bug and focused fix
The picker previously displayed the newest 18 discards regardless of
`maxCount`. When `maxCount < 18`, tapping an older, ineligible card
silently clamped the selected count to `maxCount`, taking a different
card as the origin than the user tapped. Also, tapping the newest card
silently selected two because stack pickups have a minimum of two cards.
The picker now considers at most `min(18, maxCount)` newest public discards
and offers only origins requiring **two or more** cards. The ordinary
single-card discard draw remains available via the existing pile button.
Every displayed choice therefore matches the exact submitted origin.
This is a presentation-layer eligibility correction; no gameplay rules,
deck secrecy, server authorization, network protocol, economy, or
ownership are changed.

## Regression
`flutter_app/test/r216_discard_picker_eligible_range_test.dart`:
8 widget cases covering Arabic RTL / English LTR, Warqnaa-blue seeded
light / dark themes, and 320 / 390 px portrait viewports. With six
public discards but `maxCount=3`, older cards and the single top card are not selectable through the stack
picker, the two eligible stack origins remain tappable, the origin updates
to the actual selected card, the callback receives exactly three, and no layout
exceptions occur.

## Merge gate
New isolated branch from main SHA
`1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.
Do not merge until Backend CI, Flutter Web, Android APK/AAB,
R7 Visual Runtime and Production Release pass on the same HEAD and
mergeability is rechecked against current main. No force-push.
