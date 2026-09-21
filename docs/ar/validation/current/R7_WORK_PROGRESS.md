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
- Follow-up `fc5ce0e`: Web and Windows passed; runtime verified the primary administrator identity and rendered all 30 screens. It then caught a late competitive-page request after disposal. Guarded each asynchronous load boundary and polling startup; added three delayed-response disposal regressions. Runtime and remaining gates must pass on the follow-up commit before sign-off.
- Follow-up `307721a`: isolated HTTP/Flutter runtime and source packaging steps passed. Visual inspection of the earlier 30-image artifact found test-only missing icon/default fonts and incomplete image decoding. The review harness now loads the SDK Material icon font and text aliases, waits for visible assets, and removes the debug banner. This improves evidence fidelity; it does not certify physical devices or real payments.
- Follow-up `f6e217c`: runtime, Web, Windows and release gates passed. Flutter analyzer clean, 37 VM tests passed (three live-only tests skipped in that separate suite), 12 Chrome checks passed; live runtime runs those three tests separately. Artifact SHA-256 verified for review and full-source ZIPs. Explicit button styles still retained test typography, so the next review-harness patch sets their font explicitly and loads the runner's emoji font when available.
- Follow-up `07b2cc1`: runtime and rendered button/emoji evidence passed. Backend finally reached the new visibility assertions and exposed a cached bearer actor between sequential requests. Bootstrap now uses the existing AuthenticatedActor resolver (as party/game endpoints do); the regression verifies actor identity and returns to the outsider after owner/member views to detect private-room leakage in either direction. Await all six gates on this fix.
