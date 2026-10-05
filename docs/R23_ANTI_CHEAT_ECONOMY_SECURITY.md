# R23 — Anti-Cheat, Economy & Security Hardening

R23 starts from the exact merged R22 `main` baseline and is cumulative. It must preserve all 12 games and the R20/R21/R22 experience, social, multiplayer, reconnect, spectator and voice contracts.

## Authority invariants

- Gameplay outcomes and authoritative mutations remain server-authoritative.
- Wallet balances, purchases, grants, refunds, boosters, rewards and entitlement changes remain server-authoritative and auditable.
- Client-supplied prices, balances, rewards, ownership, role claims, match outcomes or privileged flags are never trusted as authority.
- `primary_admin` authority remains role-based and server-enforced; no password, token, signing key or production secret is committed to Git.
- Store verification and replay/idempotency protections must prevent duplicate economic mutations under retries.

## R23 hardening scope

1. Anti-cheat: validate turn ownership, legal actions, sequencing, replay/idempotency and authoritative match state for every game mutation path.
2. Economy: audit transaction boundaries, immutable/auditable ledger semantics, duplicate-request protection, entitlement verification and negative/overflow edge cases.
3. Security: authorization/role boundaries, rate limits where appropriate, input validation, privacy/no-secret checks and conservative logging.
4. Multiplayer integrity: reconnect, spectator and WebRTC signaling must not grant gameplay/economy authority.
5. Admin: privileged operations must be explicitly authorized, attributable and auditable without embedding credentials.
6. Regression: preserve Arabic RTL and English LTR, Android/Web, accessibility and all 12 games.

## Merge gate

R23 may become merge-ready only when its dedicated contract/workflow and the full production matrix are green on the exact final HEAD, with no known integrity, economy, security or regression blocker. External-only deployment inputs (production signing/payment/2FA credentials or public infrastructure) are documented rather than committed.
