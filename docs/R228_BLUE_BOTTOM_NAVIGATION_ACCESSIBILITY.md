# R228 — Accessible original blue bottom navigation

Issue: #204. Baseline main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.

## Existing behavior
The production `B307BottomNavigation` already exposes five real navigation
destinations (Store, Games, Home, Social, Events) with RTL/LTR localized labels,
working `onSelected` callbacks, and the original blue/cyan selected gradient.
Its InkWell + icon/text subtree did not explicitly announce button and selected
state as one destination to assistive technology.

## Small isolated change
- Add one explicit localized button semantics node per destination, including
  its selected state and accessible activation action.
- Exclude redundant decorative icon/text semantics and the duplicate InkWell
  semantic tap action, while preserving pointer and keyboard interaction.
- Keep five tab indices, callbacks, compact portrait layout, minimum hit target,
  blue gradients, theme behavior, network and permission boundaries unchanged.
- No third-party artwork, interface tracing, or proprietary code.

## Regression
`flutter_app/test/r228_blue_bottom_navigation_accessibility_test.dart`:
eight Arabic RTL / English LTR × blue light/dark × 320/390 portrait cases,
plus Arabic short landscape. Assert localized labels, single explicit action,
selected state, 48px+ target, direction, blue/gold original palette,
working tap callback and absence of layout errors.

## Gate
Run Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime and Production
Release on one identical final HEAD. Leave PR draft and unmerged until all
five succeed, conflict check remains clean and visual review is completed.
No local Flutter SDK or manually verified screenshots are claimed.
