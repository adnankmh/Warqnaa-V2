# R225 — Portrait live-room cards with bilingual screen-reader summaries

## Baseline and scope
- GitHub Issue #204 reference-video feature parity; original Warqnaa UI only.
- Based on main `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9` after checking the open PR heads and all five CI gates.
- The existing R64 room browser already fetches public rooms and delegates joining to `openGameRoom`; do not alter server admission, room privacy or network calls.
- Existing R149 room-browser empty/error state and R70 blue command bar tests remain unchanged.

## Implemented
- Room cards show a two-line, ellipsized room name and one-line LTR numeric/code metadata, preserving correct reading order in RTL Arabic.
- A single localized accessibility summary announces name, occupancy, turn duration, public code and whether voice is enabled. The native Join button remains a distinct action.
- Voice/card avatar uses the active theme's blue primary and primary-container tokens rather than a fixed gold accent.
- The existing private `_R64RoomCard` contract is preserved for legacy source validation; a public `R64RoomCard` subclass makes the same card testable without a network-backed AppController. The browser's join callback is unchanged.

## Files
- `flutter_app/lib/r6_4_world_championship.dart` — presentation only.
- `flutter_app/test/r225_live_room_card_accessibility_test.dart` — 8 RTL/LTR × 320/390 portrait × blue light/dark widget scenarios, plus empty-name fallback.
- `docs/R225_LIVE_ROOM_CARD_ACCESSIBILITY.md` — this audit.

## Validation and constraints
- Widget tests cover spoken metadata, LTR code, overflow-safe text, active blue palette and Join callback.
- No game engine, wallet, ledger, backend, socket, permissions, private room visibility, or protected third-party artwork modified.
- Five CI workflows must succeed on the identical PR HEAD before merge. Manual visual review remains a separate requirement; no screenshot is claimed here.
