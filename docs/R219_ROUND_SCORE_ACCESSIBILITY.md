# R219 — Accessible previous-round score changes

Issue: #204 — original Warqnaa Blue gameplay quality; no third-party artwork.

## Existing implementation
`R52RoundScoreCard` already displayed the previous round's authoritative
`round_results.last.delta`, player names, signed numbers and the active
`R69PlaySurfaceColors` blue theme. It did not provide spoken sign descriptions
for screen readers. This work does **not** change score calculations.

## Change
- Keep the exact visible `+30`, `-15`, and `0` labels.
- Supply a localized `Text.semanticsLabel` that explicitly announces
  **plus**, **minus**, or **no change**. Avoid calling a positive score a win:
  Hand and other games have different scoring conventions.
- Preserve nonnumeric server-provided labels as-is.
- No edits to engines, networking, permissions, economy or game state.

## Test matrix
`flutter_app/test/r219_round_score_accessibility_test.dart` covers:
- Arabic RTL / English LTR.
- Warqnaa-blue seeded light and dark themes.
- 320×844 and 390×844 portrait widths.
- Signed positive, negative and zero values, visible labels, semantic labels,
  unchanged theme surface/border and no layout exceptions.
- Pure helper cases, including nonnumeric fallback.

## Merge policy
Isolated branch based on `main` at
`1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.
Keep PR draft until Backend CI, Flutter Web, Android APK/AAB,
R7 Visual Runtime and Production Release all succeed on the same HEAD
and GitHub reports a clean merge against a fresh main.
