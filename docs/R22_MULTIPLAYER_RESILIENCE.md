# R22 — Multiplayer Resilience / Rooms / Reconnect

R22 starts from merged and exact-head-verified R21 `main` (`121514e6e8a62368f27147ff61ac33eabdef66d5`) and remains cumulative.

## Mission

Harden the existing multiplayer experience without weakening the validated 12-game engines, economy, store, clubs, tournaments, social surfaces, or primary-admin role authority.

## Release scope

1. Rooms and party lifecycle: create/join/leave/readiness/host transition where supported, with authoritative membership and no client-trusted privilege mutation.
2. Matchmaking and heartbeat: explicit liveness, bounded retry/backoff, stale-session cleanup, and observable state transitions.
3. Reconnect: resume the authoritative match/session after transient network loss without duplicating moves, rewards, purchases, tournament registration, or wallet mutations.
4. Spectator integrity: read-only spectator state; spectators cannot submit gameplay/economy mutations or leak hidden hand/private state.
5. WebRTC voice resilience: signaling/session recovery, permission-safe UI, mute/deafen state, and no credentials or private signaling secrets in Git.
6. Arabic RTL / English LTR responsive polish across phone, short landscape, tablet and desktop.
7. Accessibility and reduced-motion remain first-class.

## Authority invariants

- Gameplay, scoring, wallet/economy and entitlement verification remain server-authoritative where server authority exists today.
- Reconnect tokens/session identifiers must not become authorization substitutes.
- A retried request must not duplicate a gameplay mutation, reward, purchase, wallet debit/credit, club/tournament mutation, or store entitlement.
- `primary_admin` authority remains role based; no username/email based privilege path.
- Existing privacy/no-secrets gates remain mandatory.

## Exact-head merge rule

R22 may merge only after its dedicated contract/workflow and the complete production matrix pass against the same final PR head: Backend/Security, Production Release Gate, Flutter Web/Chrome, Android/emulator, Runtime/Visual, plus the R22 focused gate. Known reconnect, room, spectator, RTL, accessibility, economy, or authority regressions block merge.
