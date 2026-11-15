# R237 — original-blue Tarneeb bid accessibility (Issue #204)

Base: `main@1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`. New branch: `automation/r237-tarneeb-bid-blue-a11y-20261111-1526-1ff82f8`.

## Existing implementation
`TarneebBidButtonV170` already renders interactive Tarneeb bid controls. R137 checks existing theme adaptation and click callbacks. The selected bid previously blended blue with a hard-coded brown and did not expose an explicit selected/disabled state for assistive technology.

## Isolated change
- Only the presentation widget in `flutter_app/lib/v170_global.dart`: selected gradient now uses the active Warqnaa blue theme, mirrors directionally in RTL/LTR, and retains R137 keys, callbacks, theme-dependent text and borders.
- Localized bid semantics expose selected and enabled states, an actionable onTap, and a single screen-reader label without duplicated decorative children.
- 48px minimum target, single-line ellipsis on narrow portrait phones. No engine, economy, network, ledger, or permission changes.
- `flutter_app/test/r237_tarneeb_bid_accessibility_test.dart`: 8 RTL/LTR × light/dark × 320/390 portrait widget cases plus landscape disabled and narrow long-text cases. Semantics handles are explicitly disposed.
- R137 legacy test remains unchanged.

## Verification required
Run all five CI gates on one final HEAD: Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime, Production Release. Confirm mergeability and visual acceptance before any merge. R7 workflow artifacts are not a claim of feature-specific screenshots. No protected third-party assets, layout tracing, or borrowed copy.

## CI regression correction
First candidate `74eb1d4ccc266f36a5c29f471597fed3fe94008c`: the 10 new R237 widget cases passed, but full Web/Android suites failed: R37 source contract expects the exact 11px subtitle token `fontSize:11`, and stretching a Column in a horizontally unbounded bid row caused infinite-width layout exceptions across older gameplay tests. Follow-up retains the 11px floor and centers (rather than stretches) children to support both constrained portrait and unconstrained game rows. All five CI gates must be revalidated on the new HEAD.
