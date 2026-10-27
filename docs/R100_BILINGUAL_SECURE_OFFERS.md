# R100 — Bilingual secure offers checkout

R100 completes the Arabic and English presentation contract for the Laravel offers and checkout surface.

## Scope

- Localizes the hero, country and account controls, offer filters, active offers, package actions, checkout summary, and sandbox/provider notices.
- Selects active-offer title and description from the current locale with safe Arabic and English fallbacks.
- Adds localized accessibility labels for the billing-country selector, account field, filter tabs, and decorative icons.
- Keeps the existing responsive shop components and client-side package selection behavior.

## Preserved contracts

- Package keys, categories, token quantities, `price_minor`, currency values, country codes, and filter values are unchanged.
- The existing catalog enablement and sandbox switches remain authoritative.
- No card details are collected by Warqnaa and no production payment capability is claimed. A configured provider or app store and server-side receipt verification are still required before tokens are credited.
- No secrets, credentials, economy values, routes, permissions, or multiplayer behavior are changed.

## Verification

`R100BilingualSecureOffersTest` guards the Arabic and English copy together with the stable commerce and payment-boundary markers.
