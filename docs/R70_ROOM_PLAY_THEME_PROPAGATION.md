# R70 — room and play-center theme propagation

R69 connected the selected cosmetic theme to Hand/Banakil table surfaces. The
next audit found that the world play command panel and the game-lobby action
tiles still painted a fixed sky-blue gradient, so switching themes changed the
surrounding application but not the controls used to enter a room.

R70 derives those panel gradients, outlines, icons and readable text colors
from the active Material `ColorScheme` through the existing R69 visual adapter.
Friendly and competitive action accents, plus online/offline status colors,
remain distinct semantic signals. No callback, route, room option, network
request, engine state, entitlement or economy value changes.

Widget coverage renders Arabic RTL and English LTR at phone size using both a
dark premium palette and a light premium palette. It verifies the exact active
accent on the play-center and room-tool outlines, preserves the compact lobby
grid, and rejects runtime layout exceptions. The five exact-head release gates
remain mandatory before merge.
