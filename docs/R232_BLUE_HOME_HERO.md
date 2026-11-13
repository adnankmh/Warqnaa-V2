# R232 — Directional original-blue home hero

## Baseline and isolation
- Base main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.
- Issue: #204, functional reference only. No reference artwork, text, or UI geometry was copied.
- Existing: `R9HomeDashboard._hero` already had a dark green-tinted static gradient, a responsive layout, and a connection status badge with English-only text. Shared `R9Design.sky` already provides the original Warqnaa blue.
- Scope: `flutter_app/lib/r9_release.dart` and a new isolated widget test. No changes to gameplay, multiplayer authority, hidden information, store/ledger, or permissions.

## Change
- Use `R232BlueHomeHeroSurface` in the existing dashboard hero, with original blue-toned light/dark gradients and `AlignmentDirectional` lighting so RTL and LTR mirror correctly.
- Preserve the dashboard's existing 270/320px minimum heights, 20/30px padding, 32px radius, and its contents/actions.
- Localize the connection indicator to Arabic or English via `r232HomeConnectionLabel`, without changing connection semantics or API calls.
- Keep the original Warqnaa blue border; do not import third-party assets.

## Verification
- Nine Flutter widget tests in `flutter_app/test/r232_blue_home_hero_test.dart`: Arabic RTL and English LTR, sky light and ocean dark, 320/390px portrait (8), plus 844px landscape (1).
- Checks directional gradient, blue-channel dominance, border token, localized connected/disconnected text, width/min-height, and no Flutter exceptions.
- CI gates required on one identical final HEAD: Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime, Production Release.
- Screenshots: use the R7 visual runtime artifact when available. No screenshots are claimed as locally captured in this connector-only execution.
- Merge: blocked until all five checks pass on the same HEAD, PR is conflict-free, and visual review is accepted.
