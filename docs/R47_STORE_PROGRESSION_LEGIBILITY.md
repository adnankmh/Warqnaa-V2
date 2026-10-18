# R47 Store progression legibility

R47 is a focused readability increment for the live progression panel at the
top of the Flutter store.

## Changes

- Extracts the production `R47StoreProgressPanel` so the real store widget can
  be exercised directly in widget and visual tests.
- Raises the next-level caption to 11.5px and the live multiplier explanation
  to 11px with stronger contrast and line height.
- Raises round, tournament and club metric labels from 8px to 11px, allowing
  two centered lines at narrow phone widths.
- Keeps XP, level, points, Pasha and active-booster multiplier calculations
  sourced from the existing `AppController`; no economy value changes.

## Verification

- Arabic RTL and English LTR widget tests render the panel at 320x640 and
  verify the live multiplier and typography floors.
- A Laravel source contract locks the controller-backed values and prevents
  the former 8px metric labels from returning.
- Isolated R7 review captures both phone-width locales for manual inspection.

GitHub Pages remains a static Flutter Web demonstration. A public Laravel
multiplayer deployment still requires `WARQNA_API_URL`; production signing,
payment credentials and physical-device validation remain external inputs.
