# R214 — reversible meld selection feedback (Issue #204)

## Existing baseline
R36MeldWorkspace already selects cards by **hand index**, supports reversible
visual sorting, colors each saved group and returns original card identities
for engine validation. R44 keeps public melds in their authoritative owner/team
areas. This change does not replace those systems.

## UI-only increment
The existing meld dialog now shows a live, localized selection count and the
reason a group is or is not ready to save (minimum 3 cards, maximum 13, maximum
8 groups). A **Clear selection / مسح التحديد** button clears only unsaved
selection, never saved groups. The status uses the active theme's on-surface
color and a screen-reader live region. Wrapping controls remain usable in
narrow portrait viewports without horizontal overflow.

## Regression tests
`flutter_app/test/r214_meld_selection_feedback_test.dart` exercises Arabic
RTL and English LTR, blue-seeded light/dark schemes, and 320/390px portrait
widths. It verifies selected counts, disabled/enabled actions, clear without
saved-group loss, two distinct theme-colored groups, and exact submitted card
identities.

## Safety
No new gameplay action, engine rule, card mutation, network call, economy,
permissions, or hidden-card projection. The existing engine validates the
submitted groups. Merge only after Backend CI, Flutter Web, Android APK/AAB,
R7 Visual Runtime and Production Release pass on the same HEAD.
