# R19 Release Checklist

Before merge to `main`:

## Validated checkpoint — `1a133afc82a0bb74e96d298983d7f44e1a9510ab`

- [x] R19 focused commerce contract passes.
- [x] Backend CI / security foundation passes.
- [x] Production Release Gate / privacy checks pass.
- [x] Flutter analyze and widget/engine tests pass (207 passed; live-only cases covered by the runtime workflow).
- [x] Chrome responsive checks and Flutter Web release build pass (18 passed).
- [x] Android APK/AAB build and API 35 emulator install/launch/first-frame checks pass.
- [x] Runtime workflow passes on the validated checkpoint.
- [x] Typography selection is wired into the live theme with Arabic/English regression coverage.

## Final R19 visual gate — required before merge

- [ ] Replace the decorative profile-counter text glyphs (`🏅`, `🪙`, `👑`) in `ResponsiveAccountStatsV170` with stable Material `IconData`/`Icon` rendering. Keep real content emoji (avatars, gifts, reactions) unchanged.
- [ ] Complete the remaining pattern / gradient polish without changing gameplay, wallet authority, entitlements, or multiplayer lifecycle.
- [ ] Re-run Arabic and English runtime captures after the visual fix and verify there are no missing glyph boxes, overflow, clipping, or RTL/LTR inversion.
- [ ] Re-run the complete five-gate CI matrix on the exact final PR head.
- [ ] Confirm no blocking PR review remains.
- [ ] Confirm the exact PR head being merged is the same head that passed the final matrix.

Do not mark R19 merge-ready from an older green checkpoint after a new visual commit. Every code change after the checkpoint requires a fresh exact-head matrix.
