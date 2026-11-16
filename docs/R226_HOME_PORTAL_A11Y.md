# R226 — Blue home portals: accessibility and responsive touch targets

## Scope
- Issue #204 original functional parity; no third-party visual assets.
- Baseline main `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`; open PRs #7, #207–#218 inspected.
- Existing `_R8Portal` is a local navigation action; this change does not touch route callbacks, game rules, networking, wallets or permission checks.

## Changes
- Give the existing home portal one localized screen-reader button label and accessible activation action; hide its decorative icon from duplicate spoken output.
- Use the active theme's surface container for light/dark backgrounds; use the active blue primary token on the Rooms portal.
- Keep 76 px minimum height, two-line ellipsis and existing navigation callback.
- Add a public `R8HomePortal` subclass solely for isolated widget testing, retaining the private `_R8Portal` contract.

## Verification
- `flutter_app/test/r226_home_portal_accessibility_test.dart`: eight portrait RTL/LTR × 320/390 × blue light/dark combinations, plus landscape.
- Checks semantic label/action, tap callback, theme palette, direction, 76 px touch target, two-line truncation, and absence of widget exceptions.
- No screenshot or local Flutter test execution claimed. Five remote gates must pass on identical HEAD; do not merge without conflict and visual review.
- Existing PR #218 has Web and Android failures due to 8 leaked SemanticsHandle test cases; this PR does not modify that worker's files.
