# R212 — discoverable stack pickup in portrait (Issue #204)

## Baseline and scope
- Based on `main` `0b026e3045450bf1d2f07d35dc689de0e9dfb6e6` (R211).
- Existing R40DiscardStackPicker already selects a buried public discard and
  requests precisely that card and the newer cards above it.
- Existing R44RummyTableOverlay already renders the two central piles, and
  delegates draw operations to supplied server-gated callbacks.
- This increment **does not reimplement** either mechanism or alter game rules.

## Implementation
- The existing stack-selection action is no longer an icon-only affordance.
  A visible `اختر / Pick` label, themed surface and border identify the
  action while retaining its localized explanatory tooltip.
- All colors come from the active gameplay theme adapter. The control keeps
  its stable `r44-stack-pick` key and only renders when the authorized
  `onDrawStack` callback is present.
- Width stays within the 204px compact center-pile row, including RTL.

## Regression coverage
`flutter_app/test/r212_stack_pick_discoverability_test.dart` checks
Arabic RTL and English LTR, blue-seeded light and dark palettes, 204px
and 390px portrait table widths, label readability, action invocation,
stable central piles, and absence of the control without a callback.

## Safety boundary
No changes to engines, deck/discard indexing, hidden cards, ownership,
economy, multiplayer, authentication, or room permissions.

## Release gate
Do not merge until Backend CI, Flutter Web, Android APK/AAB, R7 Visual
Runtime and Production Release all pass on the same exact PR head,
with a conflict-free merge check. Runtime screenshots must be reviewed.
