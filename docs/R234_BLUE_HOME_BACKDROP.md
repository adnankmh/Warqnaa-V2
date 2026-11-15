# R234 — Directional original-blue home canvas (Issue #204)

## Existing implementation
`R5HomeDashboard` delegates to the live `B307HomeDashboard`, but wrapped it in a fixed, nearly black/brown vertical gradient (`#121212`, `#171512`, `#101010`). This ignored the active Warqnaa light/dark palette and had no RTL/LTR directional response. The B307 dashboard, navigation callbacks and all underlying game/business logic already existed and remain unchanged.

## Small isolated change
- Replace only the legacy background wrapper with `R234BlueHomeBackdrop`, a decorative, theme-aware `DecoratedBox`.
- Blend existing **Warqnaa** azure/sky tokens (`R9Design.azure` and `R9Design.sky`) over `colorScheme.surface` for both light and dark themes. This preserves contrast and the existing original blue design, without copying any reference game's assets or composition.
- Use `AlignmentDirectional.topStart` to `bottomEnd` so the background lighting mirrors naturally between Arabic RTL and English LTR.
- Preserve the exact `B307HomeDashboard(controller: controller, onTab: onTab)` child and all interactions.

## Files and tests
- `flutter_app/lib/r5_world_class.dart`
- `flutter_app/test/r234_blue_home_backdrop_test.dart`
- `docs/R234_BLUE_HOME_BACKDROP.md`

10 tests: one integration source contract, eight widget scenarios (Arabic/English × light/dark × portrait 320/390 logical pixels), and an 844×390 landscape widget case. They check directional gradient resolution, exact Warqnaa blue color blending, child preservation, viewport sizing and Flutter exceptions.

## Safety and verification
No changes to gameplay engines, matchmaking, network authority, permissions, user state, economy, prices, purchases, ledger, inventory or hidden information. No third-party art, audio, interface tracing or logos used.

Draft PR only. Verify Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime and Production Release on one identical HEAD; inspect failures and do not merge until all five pass, the PR is conflict-free, and visual acceptance is complete. No visual screenshots are claimed in this change.
