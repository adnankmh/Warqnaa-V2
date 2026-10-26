# R82 — themed bilingual profile dialogs

R82 completes the active-theme and Arabic/English treatment for three profile
dialogs: avatar preview, country selection and account cancellation. Their
surfaces and borders now derive from the selected theme, while the destructive
account action remains semantically red.

Country rows use compact ISO-code badges instead of platform-dependent flag
glyphs, and a chosen profile-name colour falls back to the theme foreground
only when its contrast against the dialog surface is below WCAG AA.

The existing avatar edit callback, country search and selection, 30-day account
recovery policy, password confirmation and cancellation API call are unchanged.
No game engine, networking authority, permission or economy behavior is altered.

Flutter coverage renders the three dialogs in Arabic and English with dark
royal-crimson and light emerald themes at 390×844. R7 captures all twelve frames
for manual RTL/LTR, contrast, typography and overflow review.
