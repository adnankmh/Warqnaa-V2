# R112 — Authoritative theme preferences

## Purpose

R112 closes two theme-consistency gaps without changing gameplay, economy, permissions, or networking:

1. A stale browser `localStorage.siteTheme` value could replace the authenticated profile theme after the server rendered the page.
2. A local value could visually bypass an administrator-enforced global theme.
3. Theme swatches on the settings page previewed a theme but did not reliably persist it or report a failed save.

## Runtime contract

- The server-rendered body now exposes whether the theme is locked and whether the server is authoritative.
- Authenticated sessions trust the server/profile theme on page load and synchronize local storage to it.
- Administrator-enforced themes reject client-side theme changes.
- Guest sessions retain the existing local preference behavior when no global lock is active.
- Settings swatches and the select control use the existing authenticated `preferences.quick` endpoint.
- The selected swatch exposes `aria-pressed`, and saving, success, lock, and rollback states are announced through an `aria-live` status.
- A failed request restores the previously active theme instead of silently leaving an unsaved preview.

## Stable boundaries

R112 does not modify:

- Hand, Banakel, discard-stack, meld, dealing, bot, or scoring engines.
- Tournament, store, wallet, rewards, inventory, or token arithmetic.
- Authentication, authorization, admin permissions, realtime room state, or multiplayer authority.
- The six existing theme identifiers and the server-side validation whitelist.
- Flutter gameplay screens or their portrait/landscape contracts.

## Verification

`R112AuthoritativeThemePreferenceTest` protects:

- server/profile authority over stale browser state;
- the global admin theme lock;
- immediate persistence through the existing preference route;
- bilingual status and lock messages;
- accessible selection state;
- failure rollback;
- the existing theme whitelist.
