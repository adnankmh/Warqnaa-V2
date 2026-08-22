# R13 Engine Gold Contract — Build 250

R13 is a cumulative certification layer on top of R12. It preserves every R8–R12 feature and covers all 20 customer-registered engines.

## Profiles

| Profile | Matches per engine | Transition bound | Purpose |
|---|---:|---:|---|
| Smoke | 25 | 160 | Local and pull-request feedback |
| Release Gold | 2,000 | 320 | Production release gate |
| Scheduled Gold | 5,000 | 400 | Extended weekly certification |

Each bounded match must remain server-authoritative, JSON-serializable and deadlock-free. Advertised actions must validate and produce a state transition. Active turns must belong to registered players; hands may not contain null or empty entries; supplied seeds are retained by seeded engines for replay.

The global bot policy is deterministic and chooses exclusively from advertised legal actions. It uses hand strength, suit strength, meld size and phase-aware priorities. Chess certification never uses resignation or a draw offer as an artificial completion shortcut.

GitHub Actions retains a machine-readable per-engine report for release and scheduled certification. The complete R8–R13 regression chain remains mandatory.
