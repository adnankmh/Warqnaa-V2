# R64 partnership joker/full-Hand boundary

## Problem

Partnership opening permission is shared. A player who had not personally
melded could therefore replace a joker in the partner's table meld, recover the
joker, then empty the remaining hand into a new meld. The old turn metadata did
not record the replacement, so the finish incorrectly received the full-Hand
`-60` score.

## Resolution

- Every new rummy turn records `replaced_wild=false`.
- A successful authoritative joker replacement changes it to `true`.
- Full-Hand detection now rejects turns that used either a layoff or a joker
  replacement while preserving the R63 personal-meld/team-opening distinction.
- Older in-flight states remain compatible because a missing marker is treated
  as no replacement until the server accepts one.

The regression exercises the public action boundary: a player replaces the
partner's joker, uses the recovered joker in a legal run, empties the hand, and
receives the normal `-30` finish rather than the full-Hand bonus.
