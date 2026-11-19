# R278 — Bot avatar accessibility regression

Issue: #204

Scope: one new Flutter widget regression file; no gameplay, networking, economy, permissions, original-blue artwork or production UI modifications.

## Checks

- 8 portrait configurations: Arabic RTL / English LTR × blue-seeded light/dark × 320/390 logical pixels, 844-pixel height.
- Screen-reader avatar identity is localized and names the selected original bot profile.
- Directionality is inherited correctly and the widget renders without exceptions.
- Additional case verifies explicit Arabic locale takes precedence over an English ambient locale.

## Run

`cd flutter_app && flutter test test/r278_bot_avatar_semantics_test.dart`

## Acceptance

Draft until Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime and Production Release succeed on one final HEAD, clean mergeability is reconfirmed, and actual portrait evidence is visually reviewed. This test-only increment does not certify production readiness by itself.
