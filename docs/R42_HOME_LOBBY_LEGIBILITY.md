# R42 — readable home lobby

Base: merged R41 main `5cfe45e91e1e737b84c43171a18d2e3468c843ae`. PR #7 remains untouched.

This focused increment raises the remaining 10 labels below 11px on the live R8 home lobby: brand subtitle, safety/event pills, event eyebrow and description, feature rows, quick-play label, portal labels, game-family chip, play prompt, and discovery descriptions.

Navigation remains functional and unchanged: game tiles still open the real game lobby, Rooms still routes to the room browser, With friends still routes to Party, and store/competition destinations keep their existing callbacks. No gameplay, server authority, rewards, purchases, inventory, or economy rules changed.

Verification includes Flutter source and narrow-phone widget contracts, a Laravel cross-client/navigation contract, and Arabic/English R7 runtime frames at 320×640 and 390×844.

GitHub Pages remains a static/offline Flutter demonstration. Public Laravel hosting and `WARQNA_API_URL`, production store signing/payment credentials, and physical-device validation remain external inputs.
