# R103 — Bilingual authentication entry

R103 completes the Arabic and English presentation contract for the Laravel sign-in and registration entry points.

## Scope

- Localizes page titles, headings, field labels, placeholders, guidance, actions, and account-creation navigation.
- Localizes the explicit rate-limit, suspended-account, and invalid-credentials responses.
- Adds semantic labels, stable autocomplete hints, direction handling, and restoration of submitted non-secret identifiers after validation.
- Localizes country display while retaining the country flag, stable ISO code, previous selection, and Palestine as the default.

## Preserved security and account contracts

- Login continues to accept either username or email with the same password validation and five-attempt limiter.
- Successful login still clears the limiter, enforces the primary-admin state, reactivates eligible cancelled accounts, updates `last_seen_at`, regenerates the session, and redirects to games.
- Registration validation, unique username/email rules, confirmed eight-character password minimum, and forbidden country code remain unchanged.
- New profiles still pass through `safe_country_code`, and new wallets still receive exactly 50 tokens.
- CSRF protection, field names, authentication behavior, permissions, economy values, gameplay, and multiplayer contracts are unchanged.

## Verification

`R103BilingualAuthenticationTest` guards the bilingual copy together with the authentication, registration, rate-limit, country, session, and starter-wallet contracts.
