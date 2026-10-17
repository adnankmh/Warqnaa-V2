# R41 — readable Backgammon and Jackaroo boards

Base: merged R40 main `ffc21f20fb702d9aa071b83334632fb3368b9e8d`. Older PR7 remains untouched.

This increment removes the remaining 7–9px labels from the live Backgammon and Jackaroo boards. Backgammon point numbers and checker counts now use an 11px floor with stronger contrast. Jackaroo player labels and piece positions use the same floor, a wider bounded name column, localized Home text, and safe single-line overflow.

The visual labels now expose semantic descriptions for point numbers, checker counts, pieces at home, pieces on the track, and pieces that reached safety. Arabic and English are both covered. No move rules, dice/card outcomes, turn authority, scoring, dealing, rewards, inventory, or economy behavior changed.

Verification includes a Flutter source contract, four narrow-phone widget renders (Arabic/English × Backgammon/Jackaroo), and a Laravel-side cross-client contract. All five exact-head workflows and visual artifacts must pass before merge.

GitHub Pages remains a static/offline Flutter demonstration. Public Laravel hosting/API configuration, production store signing/payment credentials, and physical-device validation remain external deployment inputs.
