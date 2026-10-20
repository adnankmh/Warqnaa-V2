# R52 — 20 October 2026 playability and rewards requirements

Base: main 37c1edc74e32e212dcf7bcc2f97713759a4c85d8; all five base workflows passed. Preserve draft PR #7. This is the single active release branch; use guarded fast-forward writes.

## Requested work (pending until executable evidence)
- [ ] Hand/Banakil online/offline rule parity: opening, discard obligation, multiple fire cards, wild replacement, scoring, five Hand rounds and Banakil targets, stronger legal bots.
- [ ] Tarneeb 7–13/pass/bidder/trump clarity; responsive overlapping hand; next trick without a blocking delay.
- [ ] End-of-match result/celebration, per-round score delta, explicit exit to lobby and reliable next-round flow.
- [ ] Restore actual wheel and boxes through reachable Home/store routes; eight or more distinct reward types, opening animation and exactly-once server grants.
- [ ] Improve competitions/groups/community and readable chat/friends routes; preserve authoritative rewards and membership/actor authorization.
- [ ] Larger default readable fonts/game hall; portrait phone and bounded desktop table geometry; upright card backs and table-surface masking.
- [ ] Review official store purchase and rewarded-ad integration; client callbacks never mint online currency without server validation.
- [ ] Provision ten test accounts without embedding passwords in source/APK or public artifacts; separate local/staging from production.
- [ ] Reduce duplicate workflow runs while preserving the five required exact-head gates and APK security checks.
- [ ] Exact-head backend/Web/Android/runtime/release gates + actual image review, guarded merge and main Web publication.

## Primary rule sources
- https://blog.jawaker.com/hand-rules/ (Hand: 14+15, 51 opening, discard-draw meld obligation, five rounds, low score wins)
- https://blog.jawaker.com/banakil-rules/ (Arabic clarification: wild restrictions, 51/102 full-hand ordering; takes precedence over the conflicting English summary)
- https://blog.jawaker.com/tarneeb-rules/
- https://blog.jawaker.com/competitions-rules/

The user supplied the original blue/cyan/gold screen board again. Approved artwork and existing functionality remain the visual foundation; no third-party assets or code are copied.

Public Laravel hosting, production payment/provider credentials, ad identifiers/SSV setup and store signing are external deployment inputs. GitHub Pages hosts only the Flutter web client. Do not describe integrations as live before those inputs and verification exist.
