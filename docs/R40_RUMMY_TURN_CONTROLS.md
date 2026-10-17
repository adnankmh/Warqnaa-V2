# R40 — playable rummy turn controls and public fire-pile preview

Base: merged R39 main `973d651331b13ec82c76b16e7fc91a1a808c019e`. Older PR7 is untouched.

The website rummy workspace selected cards for meld drafts but offered no explicit discard action. A player could draw or meld and then be unable to end the turn through that workspace. The new control submits exactly one selected card only when the current server snapshot advertises that discard. Grouped cards cannot be reused, and two identical cards remain separate physical selections.

Legal layoff and joker-replacement options now expose the engine's advertised target, meld and card payloads. Snapshot/turn checks run again at click time; stale controls cannot submit a formerly legal action after a sync. Server-side validation remains authoritative. Rejected or unchanged-hand responses preserve selection and group drafts; a new hand or round resets them. A partial extra selection must be grouped or cleared before a multi-group submission. Both desktop and mobile draw buttons follow the same advertised action availability.

Banakil stack drawing now previews the selected last N cards of the **public** discard pile, with the top discard last. Flutter confirms the chosen count explicitly; preview changes or cancellation do not draw. The Web view also shows real public discard/deck counts. No hidden deck contents, opponent hands, dealing rules, prices, entitlements or rewards are changed.

Verification: shipped JavaScript interaction tests in `tools/test_r36_requested_fixes.cjs` run in the existing Backend gate for Arabic/English and all five rummy identifiers. Four Flutter tests exercise two phone widths, selection, preview ordering, confirm/cancel and render exceptions. The same tests emit actual preview PNGs in the isolated R7 visual run. All five exact-head release gates and manual image review are required before merge.

GitHub Pages is a static/offline Flutter demonstration. Public Laravel hosting/API configuration, production store signing/payment credentials and physical-device validation remain external deployment inputs. No live-account repair or public multiplayer launch is implied.
