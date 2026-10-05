# R26 — Game Matrix / 12 Games Final QA

R26 is the final focused gameplay-quality stage after the merged R25 baseline. It must preserve every stable capability from R20–R25 while proving the complete game matrix on the exact candidate head.

## Required game matrix

1. Tarneeb
2. Tarneeb 400
3. Syrian Tarneeb
4. Trix
5. Trix Complex
6. Trix Partnership
7. Hand
8. Partnership Hand
9. Saudi Hand
10. Banakil
11. Baloot
12. Basra

## Acceptance surface

For every applicable game/variant, QA must cover rule initialization, legal actions, illegal-action guards, bidding/pass flows, scoring, round/match completion, restart/rematch, and deterministic state restoration. Local/bot/server paths must not silently diverge on shared rules.

Networked play must retain server-authoritative mutations and exercise heartbeat/reconnect during active gameplay without granting client authority over scores, balances, inventory, or match outcomes.

UI verification must include Arabic RTL and English LTR plus narrow 320px, short-landscape, normal phone/tablet and desktop layouts. Card/table presentation must remain readable, tappable and free of clipping/overflow.

## Cumulative invariants

R26 must not regress the 12-game catalogue, store/customization, clubs/tournaments/social, rooms/party/matchmaking/spectator, heartbeat/reconnect, WebRTC voice, anti-cheat, ledger/economy controls, observability/readiness, resilience policies, privacy/no-secrets, or primary_admin authority established by earlier releases.

## Merge policy

R26 stays draft until its dedicated executable contract and visible GitHub Actions workflow exist and the complete release matrix is green on the exact final head. Any known gameplay, visual, authority, reconnect, localization, or accessibility regression blocks merge.
