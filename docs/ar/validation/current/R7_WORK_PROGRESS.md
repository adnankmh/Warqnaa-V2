# R7 work checkpoint

- Baseline: R6.5 merged to main as `82bd3ba18b673fa48f51266833c49fa5cf8755ae`; baseline CI and Android build passed.
- Current branch: `codex/r7-release-verification`.
- Scope: runtime journeys, authoritative Flutter identity, captured responsive UI review, private room bootstrap data, reproducible source/installer package.
- Initial implementation is awaiting CI execution; do not describe it as validated until the workflows pass.
- Continue from the current branch, inspect uncommitted work and the latest Actions, fix actual failures, and preserve successful work. Do not repeat older patches.
- Private account credentials, raw API responses, local databases and server logs must not become artifacts or tracked source. Runtime accounts are synthetic and temporary.
- The scheduled continuation must avoid overlapping active work and must not purchase credits or paid services.
- After R7 gates pass, review the captured UI images and source package, record evidence, and hand off the validated commit. Production hosting, real-device verification and store signing require the relevant environment/credentials; do not invent access or claim they are done.

## 2026-09-21 continuation

- Inspected clean local worktree, remote branches and draft PR #2 at `519cc00`; no conflicting local work found.
- That commit passed Web, Android, Windows installer and Production Release Gate. Backend run `35530905472` failed only the new bootstrap privacy fixture (duplicate seeded `games.key`); 144 existing tests passed.
- Runtime run `35530905452` reached Flutter after HTTP checks, then exposed optional notification initialization escaping into login and an asset listener returning a Future from setState.
- Fixes reuse the seeded game, contain optional notification initialization failure, and make the asset state callback synchronous. Added focused Flutter regression tests.
- These fixes still require CI execution. Do not mark R7 complete or merge before all gates and artifact review pass. Local PHP and Flutter executables are unavailable; runtime verification is performed by existing CI, without buying tools or deploying production.
