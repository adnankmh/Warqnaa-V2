# R222 — responsive, localized social composer (Issue #204)

## Existing behavior
R11 social composer already sends the selected `type` and `audience` to the existing server API. Both controls were displayed side by side at every width and their labels/options were English-only, including when the user selected Arabic.

## Focused change
- Stack the post-type and audience selectors when the dialog offers less than 440 logical pixels, retaining a two-column layout on wider surfaces.
- Localize visible option labels and field labels in Arabic RTL and English LTR.
- Preserve the **exact** API identifiers (`status`, `looking_for_game`, `achievement`, `public`, `friends`, `followers`, `private`) and default audience `friends`; no permission, privacy enforcement or server changes.
- Use the active Warqnaa-blue theme's primary color for dropdown affordances; no competitor artwork or copy.

## Regression coverage
`flutter_app/test/r222_social_composer_responsive_test.dart` exercises eight portrait configurations (Arabic/English × light/dark × 320/390), actual audience selection and preserved API value, active blue theme, text direction, field stacking, and no overflow; a ninth test checks the wide two-column layout.

## Merge safety
Independent of the active PRs #7 and #207–#214. This is a UI-only change in `flutter_app/lib/r11_social_world.dart`, one test and this document. Keep the PR as a draft until Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime and Production Release all pass on the **same final HEAD**, with a clean mergeability check. Flutter SDK was unavailable locally, so CI is authoritative.
