# R25 — Resilience & Release Hardening

R25 starts from the exact R24 merge on `main` and is cumulative. It must preserve the 12-game product, server-authoritative gameplay and economy, `primary_admin` authority, rooms/party/matchmaking/heartbeat/reconnect, WebRTC voice, anti-cheat, verified store flows, privacy/no-secrets, Arabic RTL and English LTR, and every R20–R24 release contract.

## Focus

- Exercise failure and recovery paths for matchmaking, heartbeat/reconnect, realtime/WebRTC, store verification and economy boundaries.
- Keep retries deterministic and idempotent; bound timeouts/backoff and prevent duplicate authoritative mutations.
- Strengthen production health/readiness diagnostics while keeping credentials, tokens, secrets and unnecessary PII out of telemetry.
- Add focused backend/runtime regressions and a dedicated executable R25 contract plus GitHub Actions gate.
- Require the complete exact-head release matrix before R25 can become merge-ready.

## Merge boundary

R25 remains draft until its dedicated gate and all cumulative backend, production-release, Flutter web/Chrome, Android/emulator and runtime/visual checks are green on the exact final head, with no known regression or blocking review. No force-push or history rewrite is permitted.
