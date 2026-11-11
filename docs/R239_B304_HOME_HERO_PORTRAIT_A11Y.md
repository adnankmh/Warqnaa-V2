# R239 — Warqnaa Blue B304 home hero, portrait accessibility

Issue: #204. Baseline `main@1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.

## Existing behavior
`B304HomeDashboard` already showed a themed hero, original game catalog, and a working notifications callback. Its logo, long title, description and unlabeled notification icon shared a single horizontal row, which left very little reading space on narrow portrait devices.

## Isolated change
- Extract a testable `B304HomeHero` from the existing header, retaining the exact original copy and `showNotifications` callback.
- On narrow available widths (<340 logical pixels), stack the copy beneath the logo/action row; wider layouts retain the horizontal arrangement.
- Give the notifications control Arabic/English tooltips and screen-reader labels, and color it with the active theme's primary/on-primary containers (Warqnaa blue light/dark).
- No copied Jawaker UI/assets/code. No changes to games, matchmaking, server-authoritative rules, balances, rewards, purchases, permissions, or network calls.

## Regression coverage
`flutter_app/test/r239_b304_home_hero_accessibility_test.dart` runs 8 combinations: 320/390 portrait × Arabic RTL/English LTR × blue light/dark. It checks locale direction, notification accessibility, theme colors, no overflow/Flutter exception, and exactly one callback per tap. SemanticsHandle is disposed before each test ends.

## Verification and merge gate
CI must pass Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime and Production Release **on the same commit SHA**. Verify no PR file overlap or merge conflicts. Keep draft pending all five and visual acceptance. Screenshots: pending R7 runtime artifacts, not fabricated.
