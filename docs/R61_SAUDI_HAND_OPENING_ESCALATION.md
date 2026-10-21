# R61 Saudi Hand opening escalation

R61 closes an authoritative rules gap between the two Hand modes:

- `saudi_hand` starts at 51. After a player opens, every player who has not yet
  opened must beat that opening total by one point. A 62-point opening therefore
  changes the shared unopened-player target to 63.
- `hand` remains the regular fixed-51 variant.
- Players who already opened are not asked to satisfy the raised target again.
- The server owns and publishes `individualOpeningThreshold`; clients cannot
  submit or override it.
- Older in-flight states that do not contain the new field safely fall back to
  the configured opening value.

The distinction follows Jawaker's published rules for
[Saudi Hand](https://blog.jawaker.com/en/hand-saudi-rules-en/) and
[regular Hand](https://blog.jawaker.com/en/hand-rules-en/).

Regression coverage exercises a real 62-point opening, rejects another player's
62-point forged opening, accepts a legal 63, checks the next target is 64, keeps
regular Hand fixed at 51, and verifies legacy-state compatibility.

## Reproducible production image

The production image installs `phpredis` 6.3.0 with the PHP Foundation's PIE
1.5.0 image instead of resolving the floating `redis` release through PECL.
This removes the build's dependency on the currently incomplete PECL REST
metadata while keeping the same extension version and verifying that PHP loads
it before the build layer succeeds.
