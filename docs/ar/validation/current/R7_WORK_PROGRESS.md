# R7 work checkpoint

- Baseline: R6.5 merged to main as `82bd3ba18b673fa48f51266833c49fa5cf8755ae`; baseline CI and Android build passed.
- Current branch: `codex/r7-release-verification`.
- Scope: runtime journeys, authoritative Flutter identity, captured responsive UI review, private room bootstrap data, reproducible source/installer package.
- Initial implementation is awaiting CI execution; do not describe it as validated until the workflows pass.
- Continue from the current branch, inspect uncommitted work and the latest Actions, fix actual failures, and preserve successful work. Do not repeat older patches.
- Private account credentials, raw API responses, local databases and server logs must not become artifacts or tracked source. Runtime accounts are synthetic and temporary.
- The scheduled continuation must avoid overlapping active work and must not purchase credits or paid services.
- After R7 gates pass, review the captured UI images and source package, record evidence, and hand off the validated commit. Production hosting, real-device verification and store signing require the relevant environment/credentials; do not invent access or claim they are done.
