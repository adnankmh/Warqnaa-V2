# R69 — gameplay theme propagation

The application-level theme already reached navigation, dialogs, buttons and
the store, but the Hand/Banakil play surfaces still painted several fixed
sky/gold colors. Selecting a purchased theme therefore left the most visible
rummy controls unchanged.

R69 introduces a visual-only palette adapter sourced from the active Material
`ColorScheme` and applies it to:

- the two central stock/discard piles and multi-discard action;
- public owner/team meld panels without changing their stable team distinction;
- reversible Hand/Banakil meld selection and colored draft groups;
- the public discard-stack picker selection border.

No engine payload, card index, ownership rule, draw callback, economy value or
server action is changed. The existing rule remains intact: selecting an older
Banakil discard requests that card and every newer public discard above it.

Regression coverage renders Arabic RTL and English LTR with a dark premium
theme and a light premium theme. It asserts that pile, owner and selected-card
surfaces receive the active theme accent/surface while the central-pile and
meld-workspace controls remain present. Full Flutter, Web, Android, backend,
visual-runtime and production gates are still required on one exact PR head.
