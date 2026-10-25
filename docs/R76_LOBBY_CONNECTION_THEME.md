# R76 — lobby connection theme propagation

R76 removes the remaining fixed sky/gold styling from the game-lobby identity
art border and connection-status strip. Both now derive their surfaces, borders,
readable text and offline accent from the selected cosmetic theme. The connected
state keeps a green semantic signal blended slightly toward the active accent.

Room availability, local/server mode selection, navigation callbacks, player
identity, game engines, networking, permissions and economy are unchanged.

Arabic RTL and English LTR widget coverage exercises dark crimson and light
emerald themes at 390×844. R7 captures all four lobby states for manual review.
