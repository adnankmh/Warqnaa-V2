# R44 — Session continuity legibility

R44 is a focused bilingual presentation and interaction increment for the active-session surfaces.

## Changes

- Raised the active-game subtitle, resume action, connection note, and local-session detail to an 11px minimum.
- Increased low-emphasis connection copy contrast without changing connection behavior.
- Localized the active-game exit tooltip and confirmation dialog in Arabic and English.
- Reused the same localized leave prompt and keep-playing action in the in-room back-navigation guard.
- Preserved the existing resume, room-leave, reconnect, server-authoritative gameplay, and account permission paths.

## Verification

- Flutter source and widget coverage protects the type floor, bilingual 320px layout, resume callback, and localized leave confirmation.
- Laravel contract coverage protects the active-session routing, localization keys, and type floor.
- The isolated runtime review captures Arabic and English 320×640 frames for manual inspection.

## Deployment boundary

GitHub Pages remains a static Flutter demonstration. Public multiplayer still requires a deployed Laravel service and a configured `WARQNA_API_URL`. Store signing, purchase-provider credentials, and physical-device validation remain external release inputs.
