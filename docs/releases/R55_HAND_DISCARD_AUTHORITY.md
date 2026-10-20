# R55 — Authoritative Hand discard pickup

The global Hand executor previously checked phase and pile presence but did not
call the legal-opening predicate used by availableActions and the offline UI.
A directly submitted draw_discard could therefore bypass the advertised rule,
move an unusable discard into the hand, and leave must_meld blocking completion.

The executor now checks the same predicate before popping a card or recording
an event. Saudi Hand and Partnership Hand retain their opening threshold and
team-opening behavior. Banakil retains single and multi-card fire pickup without
Hand's opening requirement. No scoring, shuffle, permissions, wallet, deal,
UI, or asset changes are included.

R55HandDiscardAuthorityTest covers direct rejected requests, below-threshold and
unrelated melds, stock fallback, legal multi-group openings, already-opened
low-value melds, and unchanged Banakil pickup; card multisets are compared.

Implementation is via the existing GitHub connector because the local execution
environment is unavailable. Tests must be executed by CI, not claimed locally.
All five mandatory workflows on one exact head and fresh manual screenshot
review remain required before any merge. Production API, WARQNA_API_URL and
production signing remain external; Pages is a static frontend. PR #7 untouched.
