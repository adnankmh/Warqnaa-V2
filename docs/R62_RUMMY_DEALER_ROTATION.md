# R62 authoritative Hand and Banakil dealer rotation

R62 fixes round ownership in the shared rummy engine:

- the seat immediately after the dealer receives the extra card;
- that same seat owns the first discard and is published as the current turn;
- the dealer and starter advance together on every later round;
- the initial default remains compatible: the final seat deals and seat zero
  starts;
- the Laravel adapter accepts a server-supplied `dealer_index` and projects the
  resulting starter as the public turn;
- Hand uses 14+15 cards and Banakil uses 18+19 without changing either deck or
  scoring contract.

Regression coverage pins non-default dealers, rejects a forged discard by the
wrong seat, verifies card counts, rotates two consecutive rounds, preserves
scores, and checks the Laravel adapter's public turn projection.
