# R63 partnership full-Hand scoring

R63 separates team opening permission from a player's personal meld history.

- A Hand Partnership player may use the team's shared opening state after their
  partner has opened.
- If that player has never personally melded and empties the whole hand through
  new melds in one turn without a layoff, the team receives the full-Hand `-60`
  result.
- A player who had personally melded in an earlier turn still receives the
  normal `-30` finish.
- Legacy in-flight states without the new personal-history marker keep the old
  conservative scoring fallback.

The change does not alter opening thresholds, card validation, partnership
permissions, turn ownership, or Saudi Hand/Banakil scoring.
