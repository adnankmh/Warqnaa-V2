# R229 — Blue game-hall quick actions

- Baseline main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9` (rechecked before branch creation).
- Existing behavior: GamesPage displayed four 58px-wide QuickButton actions in one fixed Row. Arabic/English labels were forced into one line with ellipsis, especially problematic on portrait devices and with larger text.
- Changed: only the GamesPage quick-action panel now uses a responsive two-column portrait / four-column wide Wrap, readable two-line labels, explicit screen-reader button labels and actions, 84px touch surfaces, and original blue light/dark tones. Existing destination callbacks are unchanged.
- No third-party artwork, code, sound, or branded layout copied.
- Scope: `flutter_app/lib/main.dart`, `flutter_app/test/r229_game_hall_quick_links_test.dart`, this document.
- 9 widget cases: RTL/LTR × light/dark × 320/390 portrait; 800px landscape. Assert wrapping, active blue colors, semantics, real tap callback, and no framework exceptions.
- No engine, network, economy, wallet, store, permission, or server changes. CI on final HEAD and visual review are mandatory before merge.
