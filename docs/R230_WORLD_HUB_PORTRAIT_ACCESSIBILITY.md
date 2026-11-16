# R230 — Accessible portrait World Hub actions

## Existing behavior and scope
The existing `V300WorldHubPage` already provides Quick Match, Party, Spectate and Reconnect with their original callbacks and server authority. The four `_V300HubCard` tiles used a fixed two-column `0.95` aspect ratio on narrow portrait phones, a three-line visual subtitle, and lacked a single explicit accessible action label. No gameplay, room permission, matchmaking, account, network or economy logic is changed.

## Implementation
- `flutter_app/lib/v300_world_experience.dart`: use the public `R230WorldHubActionCard` for the four existing actions; keep callbacks unchanged.
- On portrait hub widths below 350 logical pixels, use a taller `0.82` tile ratio; keep the existing `0.95` portrait and `1.25` wide layouts otherwise.
- Apply the active Warqnaa-blue `ColorScheme.primary` gradient and outline, with readable compact two-line title/subtitle. Expose the complete localized title and subtitle as one accessible button label. Disabled Reconnect announces `enabled: false` and has no accessibility tap action.
- `flutter_app/test/r230_world_hub_card_accessibility_test.dart`: eight portrait widget cases for Arabic RTL / English LTR, 320 / 390 widths and light / dark blue schemes, plus disabled action semantics and landscape smoke test (10 total).

## Safety and verification
The source is an original blue UI enhancement; no reference-game art, sound, layout or code was copied. No changes to authoritative game engines, multiplayer, private hands, ledgers, or permissions.

This is a draft change based on main `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`. CI and review must verify Backend CI, Flutter Web, Android APK/AAB, R7 Visual Runtime and Production Release on one identical final HEAD. Do not merge until all five succeed, the PR is conflict-free and visual review is complete. Screenshots are not claimed without a real runtime capture.
