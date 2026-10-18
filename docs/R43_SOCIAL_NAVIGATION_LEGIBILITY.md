# R43 — readable social navigation

Base: merged R42 main `a56f684f5773eed786717c27dc9e8139f3b94751`. PR #7 remains untouched.

This focused increment raises the seven remaining labels below 11px in the live R6.1 top bar, five-tab bottom navigation, social strip, social hub and player-progress header. Secondary copy also moves from `white60` to `white70` where needed for stronger contrast.

Real navigation is preserved: profile, friends, notifications, Social World, Clubs and the five top-level destinations retain their existing callbacks. No game rules, server authority, rewards, purchases, wallet, inventory, admin privileges or economy behavior changed.

Verification includes Flutter source and 320px Arabic/English widget interaction tests, a Laravel route/type-floor contract, and R7 screenshots for the social hub and navigation shell.

GitHub Pages remains a static/offline Flutter demonstration. Public Laravel hosting and `WARQNA_API_URL`, production store signing/payment credentials, and physical-device validation remain external inputs.
