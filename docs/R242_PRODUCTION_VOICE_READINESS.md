# R242 — Production voice readiness localization and safe unknown state

Issue: #204. Base main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.

## Existing behavior
The Production Center already reads the server's `config.voice` map and displays a voice status row. The row rendered raw English labels and Dart boolean values even under Arabic RTL. An absent configuration had a hard-coded English fallback.

## Change
- Keep the existing server API and its `voice.enabled` and `voice.turn_required` fields unchanged.
- Render bilingual, screen-reader-readable voice readiness for Arabic RTL and English LTR.
- Distinguish true, false and unknown/missing data: an absent response never asserts that voice or TURN is disabled.
- Use the active Warqnaa blue-derived Material color scheme, and allow multiline text in narrow portrait layouts.
- Do not change the network, audio transport, permissions, matchmaking, game engines or virtual currency.

## Coverage
`flutter_app/test/r242_production_voice_readiness_test.dart` includes:
- 8 widget combinations: Arabic/English × light/dark blue theme × 320/390 portrait.
- In each combination, unknown and server-reported readiness, direction, semantics, color tokens and layout exceptions.
- Additional pure-function cases for missing, null, malformed and explicit false/true values.

## Verification
The five GitHub CI gates must complete successfully on the **same final PR HEAD**: Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime, and Production Release. The PR remains a draft until all pass, mergeability is conflict-free, and visual review is accepted. No copyrighted reference visuals or assets are included.
