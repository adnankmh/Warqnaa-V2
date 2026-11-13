# R236 — active-game room identity in original Warqnaa Blue

Issue: #204. Base main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.

## Existing behavior
`ActiveGameBanner` already resumes an active game, opens a confirmation before leaving, and delegates actual exit to `exitActiveGameV182`. Room codes were previously concatenated into a single bidi text run; the backdrop mixed green with the current theme.

## Narrow change
- Add a read-only `ActiveGameRoomLabelR236` for the current game and optional room code.
- Keep the room code in its own LTR directionality and localized accessibility label in Arabic/English; truncate long text rather than overflow a 320px portrait screen.
- Use active theme blue primary/primary-container for the directional banner gradient and code badge in light/dark themes.
- No changes to navigation callbacks, game engines, room membership, server APIs, economy, hidden information or permissions.

## Validation
`flutter test test/r236_active_game_room_identity_test.dart` — ten widget cases: 2 locales × 2 brightness modes × 2 portrait widths, plus empty and long code cases. All required CI workflows must complete on the same PR HEAD. This document does not claim a screenshot or a passing run before GitHub Actions verifies it.

## Files
- `flutter_app/lib/v166_polish.dart`
- `flutter_app/test/r236_active_game_room_identity_test.dart`
- `docs/R236_ACTIVE_GAME_ROOM_IDENTITY.md`
