# R215 — Public discard top-card screen-reader context

Issue: #204 (Warqnaa Blue original functional UX).

## Baseline
Based on main `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9` after R213.
The unrelated R214 draft PR #207 modifies `r36_meld_workspace.dart`; this
change modifies only the R44 public table widget, a new test and this document.
The R44 table already centers stock and discard and renders only public melds.

## Increment
The public discard pile's accessible label now includes its count and the
**top visible card**, formatted through the existing `cardLabel` function.
The stock pile continues to announce only its **count**, never a deck card.
Empty discards announce only the zero count. Arabic RTL and English LTR labels
are supported. No new action or gameplay rule is introduced.

## Tests
`flutter_app/test/r215_discard_public_semantics_test.dart` covers:
- Arabic RTL and English LTR;
- Warqnaa-blue seeded light and dark schemes;
- compact 204px table and 390px portrait table inside a 390×844 phone;
- exact public discard top card, empty discard and hidden deck exclusion;
- preserved stock/discard callbacks and themed pile border.

## Safety and merge gate
No engine, draw authorization, private hand, opponent ownership, economy,
multiplayer, or backend changes. The feature uses real Flutter semantics, not
screenshots. Keep the PR draft until Backend CI, Flutter Web, Android APK/AAB,
R7 Visual Runtime and Production Release all pass on **the same HEAD**, with
mergeability checked against the latest main. No force-push.
