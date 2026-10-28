# R107 — Bilingual engine audit console

R107 completes Arabic/English presentation for the administrative Engine Audit v124 console.

## Delivered

- Localized the audit description, engine counters, and unavailable-state fallback.
- Added RTL/LTR direction at the audit page boundary.
- Added a contract test covering both locales and every engine-evidence field rendered by the page.

## Preserved audit and gameplay boundaries

- The controller-provided \`$score\` and \`$rows\` datasets are unchanged.
- Deep-engine and safe-fallback counts are read from the same keys.
- Game name, key, family, engine, phase, turn, readiness, and error evidence are rendered unchanged.
- The \`ok\` / \`bad\` classification is unchanged.
- No gameplay engine, card dealing, rules, economy, permission, multiplayer, or historical PR #7 code is modified.

## Release gates

R107 remains a draft until Backend CI, R7 isolated runtime and visual review, Production Release Gate, Flutter Web, and Android APK/AAB all pass on one exact head.
