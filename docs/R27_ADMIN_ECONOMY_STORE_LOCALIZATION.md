# R27 — Admin / Economy / Store / Content / Localization Closure

R27 starts from the exact merged R26 `main` and is the final closure pass for privileged administration, economy/store integrity, content/localization, accessibility, performance, and originality/licensing before release-candidate QA.

## Invariants

- `primary_admin` remains the only primary administrator authority. Client UI must never mint or escalate server roles.
- The agreed visible primary-admin balance is `99,999,999,999,999,999` and its reserve is non-depleting; ordinary player balances remain ledger-backed and depleting.
- Inventory and ticket entitlements are server authoritative and idempotent. No client-side grant path is permitted.
- Store fulfillment requires server-side receipt/provider verification. Refunds, webhook replay/idempotency, provider failure, duplicate delivery, and pending/failed states must be safe.
- Production provider readiness must be explicit. Missing real credentials remain an external release blocker and must never be replaced by embedded secrets or fake production claims.
- Arabic and English surfaces must remain complete: Arabic RTL and English LTR, including admin, store, inventory, tickets, errors, empty states, accessibility labels, and transactional status.
- Accessibility and performance checks cover compact phone widths, short landscape, tablet and desktop. Reduced-motion and semantics remain supported.
- Assets/content must be original, properly licensed, or attributable under their license. Jawaker is quality inspiration only; no proprietary assets/layouts are copied.

## Cumulative safety

R27 must preserve all verified R20–R26 behavior: premium/store customization, clubs/tournaments/social, multiplayer resilience, anti-cheat/economy ledger, observability/health/readiness, release resilience, the 12-game matrix, rooms/party/matchmaking/heartbeat/reconnect/spectator, WebRTC voice, privacy and no-secrets guarantees.

## Merge gate

R27 stays draft until its dedicated executable contract/workflow and focused implementation tests are green on the exact final PR head together with the complete Backend, Production Release, Flutter Web/Chrome, Android/emulator, Runtime/Visual, and cumulative R20–R27 matrix. No known regression or blocking review may remain.
