# R72 — round-score and match-result theme propagation

R72 closes the next gameplay-theme gap after R69–R71. The previous-round score
card and final match result still painted the fixed reference navy/cyan palette
even when a player selected another cosmetic theme.

Both surfaces now obtain background, readable ink, neutral borders and replay
controls from `R69PlaySurfaceColors`. The gold victory outline and trophy remain
semantic win signals. Scores, winner identity, callbacks, replay/exit behavior,
engine state, server authority and economy are unchanged.

Arabic RTL and English LTR widget coverage exercises dark crimson and light
emerald themes at 390×844. R7 captures all four review screens, including score,
victory and non-victory result states.
