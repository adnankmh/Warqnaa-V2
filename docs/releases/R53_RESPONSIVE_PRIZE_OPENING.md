# R53 — responsive, registered prize-box opening

Base main: `78d95fc5895d733d412b9ace1cfee19a524f7a25` (R52).
All five main workflows, including post-merge Pages deployment, were successful
at the initial refresh. Only preserved draft PR #7 was open.

## Problem and correction

The old fullscreen scene placed 390px sprite layers at unrelated fixed offsets
inside a viewport-scaled container. Its front panel moved downward while the
reward description was independently anchored to the screen bottom. At common
phone sizes this produced a detached second chest face behind the prize text.

All 24 original PNG sprites remain byte-for-byte unchanged. They share a
720x540 registration canvas. The new stage uses the same fitted rectangle for
body, front panel and lid; the lid rotates around the original 235/540-height
seam. The duplicate front panel fades in place instead of moving into the footer.
The reward rises within a clipped stage. A separate blue/gold summary panel owns
the label and controls, without overlapping the artwork. Portrait layouts stack
the regions, while wide landscape layouts place them side by side. Oversized
text scrolls within the bounded summary without clipping the Continue control.

The five-second animation remains. Skip animation finishes presentation only;
Continue dismisses the existing dialog. The existing caller still settles the
reward once before showing it. Reduced-motion preferences reveal it immediately.
No draw weights, SKU, wallet, XP, permission, server or game rule code changes.

## Executable verification

- Flutter: all six chest designs × AR/EN × five viewport sizes, checking closed
  sprite registration, mid-animation/final region separation, reward-art bounds,
  label identity and dismissal. Additional 1.6x text and reduced-motion cases use
  320x568 and 844x390. Actual PrizeBoxesPage journeys verify skipping/continuing
  never re-settles an already-opened box.
- R7: executes the new suite and captures the actual opening/reward states,
  including short phones, portrait, tablet, desktop, AR/EN and enlarged text.
- Laravel: a real authenticated prize-box endpoint ignores forged animation
  reward metadata and rejects repeat opens without changing the settled reward,
  wallet, profile, inventory or tickets.
- Existing source contracts preserve all sprite files, asset budgets, reward
  routes and economy tests. The old fixed-rotation text check is replaced by
  checks for the production registered stage and R7 executable suite.

Framework/visual certification requires all five workflows on the exact final
PR head and manual inspection of the resulting screenshots. Local Python/Node
contracts alone are not a release gate. Pages remains static Flutter Web;
production Laravel hosting/API configuration and production signing remain
separate requirements. No paid service, new binary art or secret is used.
