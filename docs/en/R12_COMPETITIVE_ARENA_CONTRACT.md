# Warqnaa R12 Competitive Arena Contract

Release: **0.7.0+240**, additive over **R11 Build 230**.

R12 preserves every R8–R11 contract. Ranked and tournament rooms are created through the registered server game engine, contain no bots, and never accept a client-authoritative winner. Match results are resolved from the persisted room state and applied once under row locks to both overall and per-game ratings. Immutable rating-event uniqueness prevents duplicate MMR.

Matchmaking enforces one active queue, legal seat counts, two-sided expanding rating windows, delayed cross-region matching, block boundaries, active-room exclusion, and head-of-line-safe candidate selection. An abandoning player's seat remains human-owned and reconnectable instead of being replaced by a bot. Placements, per-season soft resets, abandon penalties, tiers, streaks, country/club/game leaderboards, and periodic standing snapshots are server-owned. Season activation is serialized under a stable lock.

Season finalization creates one atomic reward claim per placement-qualified user and tier. A claimed reward cannot be credited twice. Multi-round brackets are deterministically seeded with exact capacities for supported 2/3/4/6-seat engines, become immutable after rooms are issued, and advance only after verified matches complete. Draws create server-owned tiebreak rooms; voided matches are replaced with audited history. Early rounds cannot release prize escrow. The locked settlement transaction revalidates the exact final room, champion identities, registrations, and readiness before a single payout.

High-severity anti-cheat events hold MMR, advancement, and rewards for administrative review. Competitive settings, season actions, integrity decisions, rating adjustments, and bracket creation require the explicit `competitive` permission and are written to the audit log. Manual rating adjustments create synthetic immutable match and rating events rather than silently editing a number.

The web and Flutter Admin control planes cover season creation/lifecycle, MMR settlement, integrity review, championship creation, and bracket recovery. Production must run Laravel Scheduler every minute. `warqna:competitive-tick --dry-run` reports pending work without changing data; the mutating tick isolates per-stage/per-match errors, continues recoverable work, and returns a failing status for monitoring when any error occurred.
