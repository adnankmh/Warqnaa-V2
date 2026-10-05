# R24 — Production Observability & Operational Readiness

R24 builds cumulatively on the merged R23 baseline and focuses on production-grade observability without weakening gameplay, economy, security, privacy, or the 12-game surface.

## Objectives

- Correlate server-authoritative gameplay/economy operations with stable request/match/room identifiers.
- Define structured, privacy-safe operational events for matchmaking, heartbeat, reconnect, WebRTC voice signalling, store verification, anti-cheat and economy audit paths.
- Keep secrets, credentials, raw authorization tokens and unnecessary personal data out of logs and diagnostics.
- Establish actionable health/readiness signals and failure classifications suitable for production operations.
- Preserve `primary_admin` authority on the server; telemetry must never grant or infer privileges.
- Preserve Arabic RTL and English LTR clients and responsive phone/tablet/desktop behavior.
- Preserve all R20–R23 contracts and release gates.

## Merge boundary

R24 remains draft until its dedicated executable contract and workflow are green on the exact final HEAD together with Backend/Security, Production Release, Flutter Web/Chrome, Android/emulator and Runtime/Visual gates. Known security, privacy, economy, gameplay, accessibility or visual regressions block merge.
