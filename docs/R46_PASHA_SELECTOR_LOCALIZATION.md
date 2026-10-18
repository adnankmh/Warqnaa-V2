# R46 Pasha selector localization

R46 closes a remaining bilingual and catalogue-consistency gap in the Pasha
fez selector while preserving entitlement and administrator rules.

## Changes

- Localizes the selector title, explanatory copy, color names, state labels,
  and selection confirmation for Arabic RTL and English LTR.
- Replaces the hard-coded 6,500 token label with the effective live catalogue
  price from `AppController.priceFor`.
- Raises the color label and state/price typography to readable 13px and 12px
  sizes with stronger contrast and single-line overflow protection.
- Extracts `PashaStyleSelectorV173` as a testable production widget without
  changing the existing sheet entry point.
- Keeps activation restricted to owned styles or server-authorized
  administrators; ordinary unowned selections still open the real product
  preview and checkout path.

## Verification

- Flutter widget coverage exercises Arabic and English at 320x640, a live
  price override, localized color labels, and the 12px price/status floor.
- Laravel source-contract coverage locks the bilingual labels, live-price
  path, legibility floor, and ownership/administrator gate.
- The isolated runtime review captures the real selector in both locales at
  phone width for visual inspection.

GitHub Pages remains a static Flutter Web demonstration. A public Laravel
multiplayer deployment still requires a configured `WARQNA_API_URL`; store
signing and payment credentials are not included in this change.
