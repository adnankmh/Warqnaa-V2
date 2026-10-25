# R71 — shared table-seat theme propagation

R71 closes the next gameplay-theme gap after R69 and R70. The shared
`R8TableSeat` component is used by local and server-backed game tables, but its
player plaques still painted fixed sky-blue surfaces regardless of the selected
cosmetic theme.

The active and waiting-seat gradients, outline, shadow, readable name/detail
ink and progress-track surface now derive from the active Material
`ColorScheme` through `R69PlaySurfaceColors`. The active-turn gold outline and
critical red countdown remain semantic signals. Seat order, team ownership,
timers, callbacks, engine state and server actions are unchanged.

Arabic RTL and English LTR widget coverage exercises dark crimson and light
emerald themes at 390×844. R7 captures all four states for manual visual review
in addition to the five exact-head release gates.
