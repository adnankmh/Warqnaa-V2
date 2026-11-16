# R217 — Theme-aware Backgammon board (Issue #204)

## Existing baseline
R41BackgammonBoard already renders all 24 points in a constrained portrait-friendly layout and provides point/count semantics with 11px text. R41JackarooBoard is unchanged. Existing R41 tests are retained.

## Focused change
- Replace fixed brown point fills and dark number ink with the active Material ColorScheme's alternating primary/secondary containers and corresponding on-container ink. Default Warqnaa blue remains the palette seed, while user-selected light/dark themes propagate correctly.
- Use the same readable on-container ink for checker symbols and counts, and give the existing checker-owner glyph a localized screen-reader label (player, bot, or generic).
- Add stable point keys for focused regression checks; do not change point ordering, checker counts, ownership, rules, turn state, network, or economy.

## Regression
Eight widget cases: Arabic RTL and English LTR × blue-seeded light and dark × 320px and 390px portrait. Assert palette fills and foreground ink, owner semantics, direction and no layout exception. Keep existing R41 11px accessibility test.

## Release gate
Draft until Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime and Production Release all succeed on one exact HEAD and mergeability is clean. No third-party assets or reference-video imagery are used.
